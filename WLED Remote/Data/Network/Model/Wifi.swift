//
//  Wifi.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/25/21.
//

import Foundation

// MARK: - Wifi
struct Wifi {
    let bssid: String?
    let rssi: Int?
    let signal: Int?
    let channel: Int?
}

// MARK: Wifi convenience initializers and mutators
extension Wifi {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Wifi.self, from: data)
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

extension Wifi: Codable, Hashable { }
