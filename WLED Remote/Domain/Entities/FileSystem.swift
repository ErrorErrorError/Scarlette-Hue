//
//  FileSystem.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/25/21.
//

import Foundation

// MARK: - FileSystem
public struct FileSystem {
    public let used: Int?
    public let total: Int?
    public let pmt: Int?
}

extension FileSystem: Codable {
    enum CodingKeys: String, CodingKey {
        case used = "u"
        case total = "t"
        case pmt = "pmt"
    }
}

extension FileSystem: Hashable { }
