//
//  HeartbeatConnection.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/8/22.
//

import Foundation
import RxSwift
import Alamofire
import RxRelay
import RxCocoa

public class HeartbeatConnection {
    public enum ConnectionState: String {
        case connected = "Connected"
        case connecting = "Connecting"
        case reconnecting = "Reconnecting"
        case unreachable = "Unreachable"
        case unknown = "Unknown"
    }

    let ip: String
    let port: Int

    private var host: String {
        return "http://\(ip):\(port)/json/info"
    }

    private var running = false
    private var pinging = false
    private let connectionStateSubject = BehaviorRelay<ConnectionState>(value: .connecting)
    private var urlSessionTask: URLSessionTask?
    private let serialQueue = DispatchQueue(label: "heartbeat-connection", qos: .background)
    private let pingInterval = 5.0
    private let timeoutInterval = 20.0
    private var timeoutTimer: Timer?

    public init(ip: String, port: Int) {
        self.ip = ip
        self.port = port
    }

    public func start() {
        running = true
        connectionStateSubject.accept(.connecting)
        sendPing()
    }

    public func stop() {
        running = false
        timeoutTimer?.invalidate()
        urlSessionTask?.cancel()
        connectionStateSubject.accept(.unknown)
    }

    private func sendPing() {
        let timer = Timer(timeInterval: pingInterval,
                          target: self,
                          selector: #selector(self.timeout),
                          userInfo: nil,
                          repeats: false)

        RunLoop.main.add(timer, forMode: .common)
        timeoutTimer = timer

        pinging = true

        serialQueue.async {
            self.ping()
        }
    }

    private func ping() {
        if let url = URL(string: host) {
            let request = URLRequest(url: url)

            let sessionTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if error != nil {
                    self?.pinging = false
                    self?.connectionStateSubject.accept(.unreachable)
                    return
                }

                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200..<300:
                        self?.timeoutTimer?.invalidate()
                        self?.connectionStateSubject.accept(.connected)
                    default:
                        self?.connectionStateSubject.accept(.unreachable)
                    }
                } else {
                    self?.connectionStateSubject.accept(.unknown)
                }

                self?.pinging = false
                self?.scheduleNextPing()
            }
            sessionTask.resume()

            urlSessionTask = sessionTask
        } else {
            connectionStateSubject.accept(.unknown)
            pinging = false
            scheduleNextPing()
        }
    }

    private func scheduleNextPing() {
        urlSessionTask?.cancel()
        timeoutTimer?.invalidate()

        serialQueue.asyncAfter(deadline: .now() + pingInterval) {
            self.sendPing()
        }
    }

    @objc private func timeout() {
        connectionStateSubject.accept(.unreachable)
        pinging = false
        scheduleNextPing()
    }
}

// RxSwift

extension HeartbeatConnection {
    public var connection: Driver<ConnectionState> {
        return connectionStateSubject.asDriver()
    }
}

extension HeartbeatConnection: Hashable {
    public static func == (lhs: HeartbeatConnection, rhs: HeartbeatConnection) -> Bool {
        lhs.ip == rhs.ip && lhs.port == rhs.port
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ip)
        hasher.combine(port)
    }
}
