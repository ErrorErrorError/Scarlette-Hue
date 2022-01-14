//
//  Segment.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import Foundation

// MARK: - Segment
public struct Segment {
    var id: Int?        // Not Available in response
    var start: Int?  // Only changeable in 0.8.4^
    var stop: Int?   // Only changeable in 0.8.4^
    var len: Int?    // Only changeable in 0.8.4^
    var group: UInt8?
    var spacing: UInt8?
    var on: Bool?
    var brightness: Int?
    var colors: [[Int]]
    var effect: Int?
    var speed: Int?
    var intensity: Int?
    var palette: Int?
    var selected: Bool?
    var reverse: Bool?
    var mirror: Bool?
}

extension Segment: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case start = "start"
        case stop = "stop"
        case len = "len"
        case group = "grp"
        case spacing = "spc"
        case on = "on"
        case brightness = "bri"
        case colors = "col"
        case effect = "fx"
        case speed = "sx"
        case intensity = "ix"
        case palette = "pal"
        case selected = "sel"
        case reverse = "rev"
        case mirror = "mi"
    }
}

extension Segment: Hashable { }

extension Segment {
    var colorsTuple: (first: [Int], second: [Int], third: [Int]) {
        guard colors.count == 3 else { return (first: [0,0,0], second: [0,0,0], third: [0,0,0]) }
        return (first: colors[0], second: colors[1], third: colors[2])
    }
}
