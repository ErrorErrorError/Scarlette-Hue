//
//  CDDevice+Ext.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import Foundation
import CoreData


extension CDDevice {
    func asDevice() -> Device {
        return Device(id: id,
                      name: name,
                      ip: ip,
                      port: Int(port),
                      state: nil)
    }
}

extension Device {
    typealias CoreDataType = CDDevice

    func update(entity: CoreDataType) {
        entity.id = id
        entity.name = name
        entity.ip = ip
        entity.port = Int32(port)
    }
}
