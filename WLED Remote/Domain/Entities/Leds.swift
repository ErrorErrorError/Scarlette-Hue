//
//  Leds.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/25/21.
//

import Foundation

// MARK: - Leds
public struct Leds {
    public let count: Int?
    public let rgbw: Bool?
    public let wv: Bool?
    public let pin: [Int]?
    public let pwr: Int?
    public let fps: Int?
    public let maxpwr: Int?
    public let maxseg: Int?
    public let seglock: Bool?
}

extension Leds: Codable, Hashable { }
