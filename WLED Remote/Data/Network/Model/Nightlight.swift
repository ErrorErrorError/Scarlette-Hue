//
//  Nightlight.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import Foundation

// MARK: - Nightlight
struct Nightlight {
    var on: Bool? = nil   // Enabled
    var dur: Int? = nil   // Duration
    var fade: Bool? = nil // Fade
    var mode: Int? = nil  // Mode
    var tbri: Int? = nil  // Target Brightness
    var rem: Int? = nil   // Remaining
}

// MARK: Nightlight convenience initializers and mutators
extension Nightlight {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Nightlight.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

extension Nightlight: Codable, Hashable { }
