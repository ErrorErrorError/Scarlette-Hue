//
//  Nightlight.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import Foundation

// MARK: - Nightlight
public struct Nightlight {
    var on: Bool?   // Enabled
    var dur: UInt8?   // Duration
    var fade: Bool? // Fade (Removed in 0.13.0)
    var mode: UInt8?  // Mode (available since 0.10.2)
    var tbri: UInt8?  // Target Brightness
    var rem: Int?   // Remaining
}

extension Nightlight: Codable, Hashable { }
