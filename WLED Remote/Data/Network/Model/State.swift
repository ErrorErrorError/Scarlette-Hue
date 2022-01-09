//
//  State.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/13/21.
//


import Foundation
import Alamofire

// MARK: - State
public struct State {
    var on: Bool? = nil
    var bri: Int? = nil
    var transition: Int? = nil
    var preset: Int? = nil
    var playlist: Int? = nil
    var nightlight: Nightlight? = nil
    var lor: Int? = nil
    var mainseg: Int? = nil
    var segments: [Segment]? = nil
}

// MARK: State convenience initializers and mutators
extension State {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(State.self, from: data)
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

    var firstSegment: Segment? {
        return segments?.first(where: { segment in segment.selected == true }) ?? segments?.first
    }

    var selectedSegments: [Segment]? {
        return segments?.filter({ segment in segment.selected == true }) ?? segments?[0..<1].map({ $0 })
    }
}

//extension State: Equatable {
//    public static func == (lhs: State, rhs: State) -> Bool {
//        return lhs.on == rhs.on &&
//            lhs.bri == rhs.bri &&
//            lhs.transition == rhs.transition &&
//            lhs.preset == rhs.preset &&
//            lhs.playlist == rhs.playlist &&
//            lhs.nightlight == rhs.nightlight &&
//            lhs.lor == rhs.lor &&
//            lhs.mainseg == rhs.mainseg &&
//            lhs.segments == rhs.segments
//    }
//}

extension State: Codable {
    enum CodingKeys: String, CodingKey {
        case on = "on"
        case bri = "bri"
        case transition = "transition"
        case preset = "ps"
        case playlist = "pl"
        case nightlight = "nl"
        case lor = "lor"
        case mainseg = "mainseg"
        case segments = "seg"
    }
}

extension State: Hashable {}
