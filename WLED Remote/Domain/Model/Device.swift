//
//  Device.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import Foundation

public struct Device {
    public let id: UUID
    public let name: String
    public let ip: String
    public let port: Int
    public var created: Date

    public init(id: UUID, name: String, ip: String, port: Int, created: Date? = nil) {
        self.id = id
        self.name = name
        self.ip = ip
        self.port = port
        self.created = created ?? Date()
    }

    public init(name: String, ip: String, port: Int, created: Date? = nil) {
        self.init(id: UUID(), name: name, ip: ip, port: port, created: created)
    }
}

extension Device: Codable { }

extension Device: Hashable {
    public static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.ip == rhs.ip &&
            lhs.port == rhs.port &&
            lhs.created == rhs.created
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(ip)
        hasher.combine(port)
        hasher.combine(created)
    }
}
