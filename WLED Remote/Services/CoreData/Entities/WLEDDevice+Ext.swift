//
//  WLEDDevice+Ext.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import Foundation
import CoreData
import QueryKit

extension WLEDDevice {
    static var id: Attribute<UUID> { return Attribute("id")}
    static var name: Attribute<String> { return Attribute("name")}
    static var ip: Attribute<String> { return Attribute("ip")}
    static var port: Attribute<Int32> { return Attribute("port")}
    static var created: Attribute<Date> { return Attribute("created")}
}

extension WLEDDevice: DomainConvertibleType {
    func asDomain() -> Device {
        return Device(id: id,
                      name: name,
                      ip: ip,
                      port: Int(port))
    }
}

extension WLEDDevice: Persistable {
    static func createFetchRequest() -> NSFetchRequest<WLEDDevice> {
        return NSFetchRequest<WLEDDevice>(entityName: WLEDDevice.entityName)
    }

    static var entityName: String {
        return "WLEDDevice"
    }
}

extension Device: CoreDataRepresentable {

    func update(entity: WLEDDevice) {
        entity.id = id
        entity.name = name
        entity.ip = ip
        entity.port = Int32(port)
    }
}
