//
//  SegmentSettings.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/13/22.
//

import Foundation

public struct SegmentSettings {
    var start: Int?  // Only changeable in 0.8.4^
    var stop: Int?   // Only changeable in 0.8.4^
    var len: Int?    // Only changeable in 0.8.4^
    var group: UInt8?
    var spacing: UInt8?
    var reverse: Bool?
    var mirror: Bool?

    init(from segment: Segment) {
        start = segment.start
        stop = segment.stop
        len = segment.len
        group = segment.group
        spacing = segment.spacing
        reverse = segment.reverse
        mirror = segment.mirror
    }

    init(start: Int? = nil, stop: Int? = nil, len: Int? = nil, group: UInt8? = nil, spacing: UInt8? = nil, reverse: Bool? = nil, mirror: Bool? = nil) {
        self.start = start
        self.stop = stop
        self.len = len
        self.group = group
        self.spacing = spacing
        self.reverse = reverse
        self.mirror = mirror
    }
}
