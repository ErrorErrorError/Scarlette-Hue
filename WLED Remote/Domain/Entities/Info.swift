//
//  Info.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/13/21.
//

import Foundation
import Alamofire

// MARK: - Info
public struct Info {
    var ver: String?
    var vid: Int?
    var leds: Leds?
    var str: Bool?
    var name: String?
    var udpport: Int?
    var live: Bool?
    var lm: String?
    var lip: String?
    var ws: Int?
    var fxcount: Int?
    var palcount: Int?
    var wifi: Wifi?
    var fs: FileSystem?
    var ndc: Int?
    var arch: String?
    var core: String?
    var lwip: Int?
    var freeheap: Int?
    var uptime: Int?
    var opt: Int?
    var brand: String?
    var product: String?
    var mac: String?
}

extension Info: Codable, Hashable { }
