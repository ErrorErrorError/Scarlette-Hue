//
//  FileSystem.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/25/21.
//

import Foundation

// MARK: - FileSystem
struct FileSystem: Codable {
    let used: Int?
    let total: Int?
    let pmt: Int?

    enum CodingKeys: String, CodingKey {
        case used = "u"
        case total = "t"
        case pmt = "pmt"
    }
}

// MARK: InfoFS convenience initializers and mutators
extension FileSystem {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FileSystem.self, from: data)
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

extension FileSystem: Equatable { }
