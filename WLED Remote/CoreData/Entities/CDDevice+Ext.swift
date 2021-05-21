//
//  CDDevice+Ext.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import Foundation
import CoreData
import QueryKit

extension CDDevice {
    static var id: Attribute<UUID> { return Attribute("id")}
    static var name: Attribute<String> { return Attribute("name")}
    static var ip: Attribute<String> { return Attribute("ip")}
    static var port: Attribute<Int32> { return Attribute("port")}
    static var created: Attribute<Date> { return Attribute("created")}
}

extension CDDevice: DomainConvertibleType {
    func asDomain() -> Device {
        return Device(id: id,
                      name: name,
                      ip: ip,
                      port: Int(port),
                      state: nil)
    }
}

extension CDDevice: Persistable {
    static var entityName: String {
        return "CDDevice"
    }
}

extension Device: CoreDataRepresentable {
    typealias CoreDataType = CDDevice

    func update(entity: CDDevice) {
        entity.id = id
        entity.name = name
        entity.ip = ip
        entity.port = Int32(port)
    }
}
