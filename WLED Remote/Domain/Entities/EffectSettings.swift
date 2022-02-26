//
//  EffectSettings.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/25/22.
//

import WLEDClient

struct EffectSettings {
    var speed: Int?
    var intensity: Int?

    init(from segment: Segment) {
        self.speed = segment.speed
        self.intensity = segment.intensity
    }

    init(speed: Int? = nil, intensity: Int? = nil) {
        self.speed = speed
        self.intensity = intensity
    }
}
