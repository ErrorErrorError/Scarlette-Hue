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
}

extension Info: Codable, Hashable { }
