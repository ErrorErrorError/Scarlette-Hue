//
//  State.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/13/21.
//


import Foundation
import Then

// MARK: - State
public struct State {
    public var on: Bool?
    public var bri: UInt8?
    public var transition: UInt8?
    public var preset: Int?
    public var playlist: Int?
    public var nightlight: Nightlight?
    public var lor: UInt8?   // (available since 0.10.0)
    public var mainseg: Int?
    public var segments: [Segment]?

    public init(on: Bool? = nil, bri: UInt8? = nil, transition: UInt8? = nil, preset: Int? = nil, playlist: Int? = nil, nightlight: Nightlight? = nil, lor: UInt8? = nil, mainseg: Int? = nil, segments: [Segment]? = nil) {
        self.on = on
        self.bri = bri
        self.transition = transition
        self.preset = preset
        self.playlist = playlist
        self.nightlight = nightlight
        self.lor = lor
        self.mainseg = mainseg
        self.segments = segments
    }
}

extension State {
    public var firstSegment: Segment? {
        segments?.first(where: { segment in segment.selected == true }) ?? segments?.first
    }

    public var selectedSegments: [Segment] {
        segments?.filter({ $0.selected == true }) ?? []
    }
}

extension State: Codable {
    enum CodingKeys: String, CodingKey {
        case on = "on"
        case bri = "bri"
        case transition = "transition"
        case preset = "ps"
        case playlist = "pl"
        case nightlight = "nl"
        case lor = "lor"
        case mainseg = "mainseg"
        case segments = "seg"
    }
}

extension State: Hashable, Then {}

extension State: Copying {
    public mutating func copy(with item: State) {
        if let on = item.on { self.on = on }
        if let bri = item.bri { self.bri = bri }
        if let transition = item.transition { self.transition = transition }
        if let preset = item.preset { self.preset = preset }
        if let playlist = item.playlist { self.playlist = playlist }
        if let nightlight = item.nightlight { self.nightlight = nightlight }
        if let lor = item.lor { self.lor = lor }
        if let mainseg = item.mainseg { self.mainseg = mainseg }
        if let segments = item.segments { self.segments = segments }
    }
}
