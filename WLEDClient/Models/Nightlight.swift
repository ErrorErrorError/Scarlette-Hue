//
//  Nightlight.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import Foundation

// MARK: - Nightlight
public struct Nightlight {
    public var on: Bool?   // Enabled
    public var dur: UInt8?   // Duration
    public var fade: Bool? // Fade (Removed in 0.13.0)
    public var mode: UInt8?  // Mode (available since 0.10.2)
    public var tbri: UInt8?  // Target Brightness
    public var rem: Int?   // Remaining

    public init(on: Bool? = nil, dur: UInt8? = nil, fade: Bool? = nil, mode: UInt8? = nil, tbri: UInt8? = nil, rem: Int? = nil) {
        self.on = on
        self.dur = dur
        self.fade = fade
        self.mode = mode
        self.tbri = tbri
        self.rem = rem
    }
}

extension Nightlight: Codable, Hashable { }
