//
//  Segment.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import Foundation

// MARK: - Segment
struct Segment {
    var id: Int? = nil
    var start: Int? = nil
    var stop: Int? = nil
    var len: Int? = nil
    var group: Int? = nil
    var spacing: Int? = nil
    var on: Bool? = nil
    var brightness: Int? = nil
    var colors: [[Int]]
    var effect: Int? = nil
    var speed: Int? = nil
    var intensity: Int? = nil
    var palette: Int? = nil
    var selected: Bool? = nil
    var reverse: Bool? = nil
    var mirror: Bool? = nil
}

// MARK: Seg convenience initializers and mutators
extension Segment {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Segment.self, from: data)
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

extension Segment: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case start = "start"
        case stop = "stop"
        case len = "len"
        case group = "grp"
        case spacing = "spc"
        case on = "on"
        case brightness = "bri"
        case colors = "col"
        case effect = "fx"
        case speed = "sx"
        case intensity = "ix"
        case palette = "pal"
        case selected = "sel"
        case reverse = "rev"
        case mirror = "mi"
    }
}

extension Segment: Hashable { }
