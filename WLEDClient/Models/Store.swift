//
//  Store.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/25/21.
//

import Foundation
import Then

public struct Store {
    public var state: State
    public var info: Info
    public var effects: [String]
    public var palettes: [String]

    public init(state: State, info: Info, effects: [String], palettes: [String]) {
        self.state = state
        self.info = info
        self.effects = effects
        self.palettes = palettes
    }
}

extension Store: Codable {
    enum CodingKeys: String, CodingKey {
        case state = "state"
        case info = "info"
        case effects = "effects"
        case palettes = "palettes"
    }
}

extension Store: Hashable, Then { }
