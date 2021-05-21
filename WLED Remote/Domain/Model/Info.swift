//
//  Info.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/13/21.
//

import Foundation
import Alamofire

// MARK: - Info
public struct Info: Codable {
    let ver: String?
    let vid: Int?
    let leds: Leds?
    let str: Bool?
    let name: String?
    let udpport: Int?
    let live: Bool?
    let lm: String?
    let lip: String?
    let ws: Int?
    let fxcount: Int?
    let palcount: Int?
    let wifi: Wifi?
    let fs: FileSystem?
    let ndc: Int?
    let arch: String?
    let core: String?
    let lwip: Int?
    let freeheap: Int?
    let uptime: Int?
    let opt: Int?
    let brand: String?
    let product: String?
    let mac: String?

    enum CodingKeys: String, CodingKey {
        case ver = "ver"
        case vid = "vid"
        case leds = "leds"
        case str = "str"
        case name = "name"
        case udpport = "udpport"
        case live = "live"
        case lm = "lm"
        case lip = "lip"
        case ws = "ws"
        case fxcount = "fxcount"
        case palcount = "palcount"
        case wifi = "wifi"
        case fs = "fs"
        case ndc = "ndc"
        case arch = "arch"
        case core = "core"
        case lwip = "lwip"
        case freeheap = "freeheap"
        case uptime = "uptime"
        case opt = "opt"
        case brand = "brand"
        case product = "product"
        case mac = "mac"
    }
}

// MARK: Info convenience initializers and mutators

extension Info {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Info.self, from: data)
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


// MARK: - Leds
struct Leds: Codable {
    let count: Int?
    let rgbw: Bool?
    let wv: Bool?
    let pin: [Int]?
    let pwr: Int?
    let fps: Int?
    let maxpwr: Int?
    let maxseg: Int?
    let seglock: Bool?

    enum CodingKeys: String, CodingKey {
        case count = "count"
        case rgbw = "rgbw"
        case wv = "wv"
        case pin = "pin"
        case pwr = "pwr"
        case fps = "fps"
        case maxpwr = "maxpwr"
        case maxseg = "maxseg"
        case seglock = "seglock"
    }
}

// MARK: Leds convenience initializers and mutators
extension Leds {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Leds.self, from: data)
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

// MARK: - Wifi
struct Wifi: Codable {
    let bssid: String?
    let rssi: Int?
    let signal: Int?
    let channel: Int?

    enum CodingKeys: String, CodingKey {
        case bssid = "bssid"
        case rssi = "rssi"
        case signal = "signal"
        case channel = "channel"
    }
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
