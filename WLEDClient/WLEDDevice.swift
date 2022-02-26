//
//  WLEDDevice.swift
//  WLEDClient
//
//  Created by Erik Bautista on 2/17/22.
//

import Foundation
import RxSwift

public class WLEDDevice {

    // MARK: - Public Properties

    public var isHeartbeatRunning = false

    // MARK: - Private Properties

    private let host: String

    // MARK: - Heartbeat

    private let pingInterval = 10.0
    private let timeoutInterval = 15.0
    private let pingQueue = DispatchQueue(label: "heartbeat-connection", qos: .default)
    private var timeoutTimer: Timer?
    private var pingSession: URLSession
    private var pingSessionTask: URLSessionTask?
    private var connectionStateSubject = BehaviorSubject<ConnectionState>(value: .unknown)

    // MARK: - Post/Get Requests Store

    private let requestSession: URLSession
    internal let storeCache = BehaviorSubject<Store?>(value: nil)

    public required init(host: String) {
        self.host = host
        self.pingSession = URLSession(configuration: .ephemeral)
        self.requestSession = .init(configuration: .default)
    }
}

// MARK: - Heartbeat connection state

extension WLEDDevice {
    public enum ConnectionState: String {
        case connected = "Connected"
        case connecting = "Connecting"
        case reconnecting = "Reconnecting"
        case unreachable = "Unreachable"
        case unknown = "Unknown"
    }

    public func startHeartbeat() {
        isHeartbeatRunning = true
        timeoutTimer?.invalidate()
        pingSessionTask?.cancel()
        connectionStateSubject.on(.next(.connecting))
        sendPing()
    }

    public func stopHeartbeat() {
        isHeartbeatRunning = false
        timeoutTimer?.invalidate()
        pingSessionTask?.cancel()
        connectionStateSubject.on(.completed)
    }
}

// MARK: - Heartbeat private methods

extension WLEDDevice {
    private func sendPing() {
        let timer = Timer(timeInterval: pingInterval,
                          target: self,
                          selector: #selector(self.timeout),
                          userInfo: nil,
                          repeats: false)

        RunLoop.main.add(timer, forMode: .common)
        timeoutTimer = timer

        pingQueue.async {
            self.ping()
        }
    }

    private func ping() {
        var components = URLComponents()
        components.scheme = "http"
        components.host = host
        components.path = "/json/" + WLEDPath.store.rawValue

        guard let url = components.url else {
            connectionStateSubject.onNext(.unknown)
            storeCache.onNext(nil)
            stopHeartbeat()
            return
        }

        let request = URLRequest(url: url)

        pingSessionTask = pingSession.dataTask(with: request) { [weak self] data, response, error in
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    if let data = data, let value = try? self?.connectionStateSubject.value(), value != .connected {
                        if let item = try? JSONDecoder().decode(Store.self, from: data) {
                            self?.storeCache.onNext(item)
                        }
                    }
                    self?.connectionStateSubject.onNext(.connected)
                default:
                    self?.connectionStateSubject.onNext(.unknown)
                    self?.storeCache.onNext(nil)
                }
            } else {
                self?.connectionStateSubject.onNext(.unreachable)
                self?.storeCache.onNext(nil)
            }
            self?.scheduleNextPing()
        }

        pingSessionTask?.resume()
    }

    @objc private func timeout() {
        if let value = try? connectionStateSubject.value(), value == .connected {
            connectionStateSubject.onNext(.reconnecting)
            storeCache.onNext(nil)
        }
    }

    private func scheduleNextPing() {
        timeoutTimer?.invalidate()

        pingQueue.asyncAfter(deadline: .now() + pingInterval) {
            self.sendPing()
        }
    }
}

// MARK: - Heartbeat Connection Observable

extension WLEDDevice {
    public var heartbeatStateObservable: Observable<ConnectionState> {
        connectionStateSubject.asObservable()
            .distinctUntilChanged()
    }
}

extension WLEDDevice {
    public var storeObservable: Observable<Store?> {
        storeCache.asObservable()
            .distinctUntilChanged()
    }
}

// MARK: - Networking Fetching Data

extension WLEDDevice {
    internal enum WLEDPath: String {
        case state = "state"
        case info = "info"
        case effects = "effects"
        case palettes = "palettes"
        case store = ""
    }

    internal struct DataEndpoint {
        var path: WLEDPath
        var data: Data
    }

    internal enum WLEDConnectionError: Error {
        case failedToPost
        case failedToGet
        case failedToParseData
    }

    internal func post(requestType: WLEDPostRequest) -> Single<Void> {
        var components = URLComponents()
        components.scheme = "http"
        components.host = self.host
        components.path = "/json/" + requestType.path.rawValue

        guard let url = components.url else {
            return Single.error(WLEDConnectionError.failedToGet)
        }

        return Single.create { [unowned self] single in
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = requestType.data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let sessionTask = self.requestSession.dataTask(with: request) { data, response, error in
                if error != nil {
                    single(.failure(WLEDConnectionError.failedToPost))
                } else {
                    single(.success(()))
                }
            }

            sessionTask.resume()

            return Disposables.create {
                sessionTask.cancel()
            }
        }
    }

    internal func get<T: Codable>(requestType: WLEDGetRequest) -> Single<T> {
        var components = URLComponents()
        components.scheme = "http"
        components.host = self.host
        components.path = "/json/" + requestType.path.rawValue

        guard let url = components.url else {
            return Single.error(WLEDConnectionError.failedToGet)
        }

        return Single.create { [unowned self] single in
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let sessionTask = self.requestSession.dataTask(with: request) { data, response, error in
                if error != nil {
                    single(.failure(WLEDConnectionError.failedToGet))
                } else if let data = data {
                    if let item = try? JSONDecoder().decode(T.self, from: data) {
                        single(.success(item))
                    } else {
                        single(.failure(WLEDConnectionError.failedToParseData))
                    }
                } else {
                    single(.failure(WLEDConnectionError.failedToParseData))
                }
            }

            sessionTask.resume()
            return Disposables.create {
                sessionTask.cancel()
            }
        }
    }
}

extension WLEDDevice: Equatable {
    public static func == (lhs: WLEDDevice, rhs: WLEDDevice) -> Bool {
        lhs.host == rhs.host
    }
}
