//
//  Info.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/13/21.
//

import Foundation

// MARK: - Info
public struct Info {
    public var ver: String?
    public var vid: Int?
    public var leds: Leds?
    public var str: Bool?
    public var name: String?
    public var udpport: Int?
    public var live: Bool?
    public var lm: String?
    public var lip: String?
    public var ws: Int?
    public var fxcount: Int?
    public var palcount: Int?
    public var wifi: Wifi?
    public var fs: FileSystem?
    public var ndc: Int?
    public var arch: String?
    public var core: String?
    public var lwip: Int?
    public var freeheap: Int?
    public var uptime: Int?
    public var opt: Int?
    public var brand: String?
    public var product: String?
    public var mac: String?

    internal init(ver: String? = nil, vid: Int? = nil, leds: Leds? = nil, str: Bool? = nil, name: String? = nil, udpport: Int? = nil, live: Bool? = nil, lm: String? = nil, lip: String? = nil, ws: Int? = nil, fxcount: Int? = nil, palcount: Int? = nil, wifi: Wifi? = nil, fs: FileSystem? = nil, ndc: Int? = nil, arch: String? = nil, core: String? = nil, lwip: Int? = nil, freeheap: Int? = nil, uptime: Int? = nil, opt: Int? = nil, brand: String? = nil, product: String? = nil, mac: String? = nil) {
        self.ver = ver
        self.vid = vid
        self.leds = leds
        self.str = str
        self.name = name
        self.udpport = udpport
        self.live = live
        self.lm = lm
        self.lip = lip
        self.ws = ws
        self.fxcount = fxcount
        self.palcount = palcount
        self.wifi = wifi
        self.fs = fs
        self.ndc = ndc
        self.arch = arch
        self.core = core
        self.lwip = lwip
        self.freeheap = freeheap
        self.uptime = uptime
        self.opt = opt
        self.brand = brand
        self.product = product
        self.mac = mac
    }

}

extension Info: Codable, Hashable { }
