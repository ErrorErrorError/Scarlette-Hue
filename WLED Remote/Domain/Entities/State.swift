//
//  State.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/13/21.
//


import Foundation
import Alamofire
import Then

// MARK: - State
public struct State {
    var on: Bool?
    var bri: UInt8?
    var transition: UInt8?
    var preset: Int?
    var playlist: Int?
    var nightlight: Nightlight?
    var lor: UInt8?   // (available since 0.10.0)
    var mainseg: Int?
    var segments: [Segment] = []
}

extension State {
    var firstSegment: Segment? {
        segments.first(where: { segment in segment.selected == true }) ?? segments.first
    }

    var selectedSegments: [Segment] {
        segments.filter({ $0.selected == true })
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
