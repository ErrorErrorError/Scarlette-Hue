//
//  HeartbeatObservable.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/8/22.
//

import Foundation
import RxSwift

public class HeartbeatService {
    public static var shared = HeartbeatService()

    private var connections: Set<HeartbeatConnection> = .init()

    private init() {  }

    public func getHeartbeat(for device: Device) -> HeartbeatConnection {
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

    public func sync(with devices: [Device]) {
        let createNewConnections = devices.filter { device in
            connections.first { con in
                con.ip == device.ip && con.port == device.port
            } == nil
        }

        for device in createNewConnections {
            let connection = createConnection(for: device)
            connections.insert(connection)
            connection.start()
        }

        let deleteConnections = connections.filter { con in
            devices.first { device in
                con.ip == device.ip && con.port == device.port
            } == nil
        }

        for connection in deleteConnections {
            connection.stop()
            connections.remove(connection)
        }
    }

    private func createConnection(for device: Device) -> HeartbeatConnection {
        return HeartbeatConnection(ip: device.ip, port: device.port)
    }
}
