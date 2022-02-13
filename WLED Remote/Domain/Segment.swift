//
//  Segment.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import Foundation
import Then

// MARK: - Segment
public struct Segment {
    var id: Int
    var start: Int?  // Only changeable in 0.8.4^
    var stop: Int?   // Only changeable in 0.8.4^
    var len: Int?    // Only changeable in 0.8.4^
    var group: UInt8?
    var spacing: UInt8?
    var on: Bool?
    var brightness: Int?
    var colors: [[Int]]?
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

extension Segment: Hashable, Then { }

extension Segment {
    var colorsTuple: (first: [Int], second: [Int], third: [Int]) {
        guard let colors = colors, colors.count == 3 else { return (first: [0,0,0], second: [0,0,0], third: [0,0,0]) }
        return (first: colors[0], second: colors[1], third: colors[2])
    }

    // This method copies values without nils

    mutating func copy(with segment: Segment) {
        self.id = segment.id
        if let start = segment.start { self.start = start }
        if let stop = segment.stop { self.stop = stop }
        if let len = segment.len { self.len = len }
        if let group = segment.group { self.group = group }
        if let spacing = segment.spacing { self.spacing = spacing }
        if let on = segment.on { self.on = on }
        if let brightness = segment.brightness { self.brightness = brightness }
        if let colors = segment.colors { self.colors = colors }
        if let effect = segment.effect { self.effect = effect }
        if let speed = segment.speed { self.speed = speed }
        if let intensity = segment.intensity { self.intensity = intensity }
        if let palette = segment.palette { self.palette = palette }
        if let selected = segment.selected { self.selected = selected }
        if let reverse = segment.reverse { self.reverse = reverse }
        if let mirror = segment.mirror { self.mirror = mirror }
    }
}

struct SegmentRequest: Codable, Hashable {
    let seg: Segment
}
