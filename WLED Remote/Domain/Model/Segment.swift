//
//  Segment.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import Foundation

// MARK: - Segment
struct Segment: Codable {
    var id: Int? = nil
    var start: Int? = nil
    var stop: Int? = nil
    var len: Int? = nil
    var group: Int? = nil
    var spacing: Int? = nil
    var on: Bool? = nil
    var brightness: Int? = nil
    var colors: [[Int]]? = nil
    var effect: Int? = nil
    var speed: Int? = nil
    var intensity: Int? = nil
    var palette: Int? = nil
    var selected: Bool? = nil
    var reverse: Bool? = nil
    var mirror: Bool? = nil

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

extension Segment: Equatable {
    public static func == (lhs: Segment, rhs: Segment) -> Bool {
        return lhs.id == rhs.id &&
            lhs.start == rhs.start &&
            lhs.stop == rhs.stop &&
            lhs.len == rhs.len &&
            lhs.group == rhs.group &&
            lhs.spacing == rhs.spacing &&
            lhs.on == rhs.on &&
            lhs.brightness == rhs.brightness &&
            lhs.colors == rhs.colors &&
            lhs.effect == rhs.effect &&
            lhs.speed == rhs.speed &&
            lhs.intensity == rhs.intensity &&
            lhs.palette == rhs.palette &&
            lhs.selected == rhs.selected &&
            lhs.reverse == rhs.reverse &&
            lhs.mirror == rhs.mirror
    }
}

extension Segment: Hashable {

}
