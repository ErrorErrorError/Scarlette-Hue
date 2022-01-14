//
//  HeartbeatObservable.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/8/22.
//

import Foundation
import RxSwift

public class HeartbeatService {
    private var connections: Set<HeartbeatConnection>

    public static var shared = HeartbeatService()

    private init() {
        connections = Set()
    }

    public func getHeartbeat(device: Device) -> HeartbeatConnection {
        let conenction = connections.first { connection in
            connection.ip == device.ip && connection.port == device.port
        }

        if let conenction = conenction {
            return conenction
        } else {
            let connection = createConnection(for: device)
            connections.insert(connection)
            connection.start()
            return connection
        }
    }

    public func removeHeartbeat(device: Device) {
        let connection = connections.first(where: { $0.ip == device.ip && $0.port == device.port })
        if let connection = connection {
            connection.stop()
            connections.remove(connection)
        }
    }

    private func createConnection(for device: Device) -> HeartbeatConnection {
        return HeartbeatConnection(ip: device.ip, port: device.port)
    }
}
