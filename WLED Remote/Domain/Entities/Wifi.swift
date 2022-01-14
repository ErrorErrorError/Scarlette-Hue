//
//  Wifi.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/25/21.
//

import Foundation

// MARK: - Wifi
public struct Wifi {
    public let bssid: String?
    public let rssi: Int?
    public let signal: Int?
    public let channel: Int?
}

extension Wifi: Codable, Hashable { }
