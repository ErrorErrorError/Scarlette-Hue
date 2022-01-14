//
//  Store.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/25/21.
//

import Foundation
import Then

public struct Store {
    var state: State
    var info: Info
    var effects: [String]
    var palettes: [String]
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
