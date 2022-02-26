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
    public var id: Int
    public var start: Int?  // Only changeable in 0.8.4^
    public var stop: Int?   // Only changeable in 0.8.4^
    public var len: Int?    // Only changeable in 0.8.4^
    public var group: UInt8?
    public var spacing: UInt8?
    public var on: Bool?
    public var brightness: Int?
    public var colors: [[Int]]?
    public var effect: Int?
    public var speed: Int?
    public var intensity: Int?
    public var palette: Int?
    public var selected: Bool?
    public var reverse: Bool?
    public var mirror: Bool?

    public init(id: Int, start: Int? = nil, stop: Int? = nil, len: Int? = nil, group: UInt8? = nil, spacing: UInt8? = nil, on: Bool? = nil, brightness: Int? = nil, colors: [[Int]]? = nil, effect: Int? = nil, speed: Int? = nil, intensity: Int? = nil, palette: Int? = nil, selected: Bool? = nil, reverse: Bool? = nil, mirror: Bool? = nil) {
        self.id = id
        self.start = start
        self.stop = stop
        self.len = len
        self.group = group
        self.spacing = spacing
        self.on = on
        self.brightness = brightness
        self.colors = colors
        self.effect = effect
        self.speed = speed
        self.intensity = intensity
        self.palette = palette
        self.selected = selected
        self.reverse = reverse
        self.mirror = mirror
    }
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

extension Segment: Copying {
    public var colorsTuple: (first: [Int], second: [Int], third: [Int]) {
        guard let colors = colors, colors.count == 3 else { return (first: [0,0,0], second: [0,0,0], third: [0,0,0]) }
        return (first: colors[0], second: colors[1], third: colors[2])
    }

    // This method copies values without nils

    public mutating func copy(with item: Segment) {
        self.id = item.id
        if let start = item.start { self.start = start }
        if let stop = item.stop { self.stop = stop }
        if let len = item.len { self.len = len }
        if let group = item.group { self.group = group }
        if let spacing = item.spacing { self.spacing = spacing }
        if let on = item.on { self.on = on }
        if let brightness = item.brightness { self.brightness = brightness }
        if let colors = item.colors { self.colors = colors }
        if let effect = item.effect { self.effect = effect }
        if let speed = item.speed { self.speed = speed }
        if let intensity = item.intensity { self.intensity = intensity }
        if let palette = item.palette { self.palette = palette }
        if let selected = item.selected { self.selected = selected }
        if let reverse = item.reverse { self.reverse = reverse }
        if let mirror = item.mirror { self.mirror = mirror }
    }
}

struct SegmentRequest: Codable, Hashable {
    let seg: Segment
}
