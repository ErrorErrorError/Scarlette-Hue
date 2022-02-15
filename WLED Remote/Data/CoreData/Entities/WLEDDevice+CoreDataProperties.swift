//
//  WLEDDevice+CoreDataProperties.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/21/21.
//
//

import CoreData


extension WLEDDevice {
    @NSManaged public var id: UUID
    @NSManaged public var ip: String
    @NSManaged public var name: String
    @NSManaged public var port: Int32
    @NSManaged public var created: Date
}

extension WLEDDevice : Identifiable {}
