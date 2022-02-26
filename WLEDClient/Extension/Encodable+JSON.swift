//
//  Codable+JSON.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/11/22.
//

import Foundation

extension Encodable {
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
