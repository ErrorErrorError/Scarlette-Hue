//
//  Device.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import Foundation

public struct Device: Codable {
    public let id: UUID
    public let name: String
    public let ip: String
    public let port: Int
    public var state: State?
//    public var info: Info?

    public init(id: UUID, name: String, ip: String, port: Int, state: State? = nil, info: Info? = nil) {
        self.id = id
        self.name = name
        self.ip = ip
        self.port = port
        self.state = state
//        self.info = info
    }

    public init(name: String, ip: String, port: Int, state: State? = nil, info: Info? = nil) {
        self.init(id: UUID(), name: name, ip: ip, port: port, state: state, info: info)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case ip
        case port
        case state
//        case info
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        ip = try container.decode(String.self, forKey: .ip)
        port = try container.decode(Int.self, forKey: .port)
        state = try? container.decode(State.self, forKey: .state)
//        info = try? container.decode(Info.self, forKey: .info)
    }
}

extension Device: Equatable {
    public static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.ip == rhs.ip &&
            lhs.port == rhs.port && 
            lhs.state == rhs.state
    }
}

extension Device: Hashable {
    
}
