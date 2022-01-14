//
//  Device.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import Foundation
import Then

// This is the domain of WLEDDevice core data class

public struct Device {
    public var id = UUID()
    public var name: String
    public let ip: String
    public let port: Int
    public var created: Date?
    
    public init(id: UUID = UUID(),
                name: String,
                ip: String,
                port: Int,
                created: Date? = nil) {
        self.id = id
        self.name = name
        self.ip = ip
        self.port = port
        self.created = created
    }
    
}

extension Device: Codable, Hashable, Then {}
