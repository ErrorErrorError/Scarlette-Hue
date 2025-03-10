//
//  WLEDDevice+CoreDataProperties.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/21/21.
//
//

import Foundation
import CoreData


extension WLEDDevice {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WLEDDevice> {
        return NSFetchRequest<WLEDDevice>(entityName: "WLEDDevice")
    }

    @NSManaged public var id: UUID
    @NSManaged public var ip: String
    @NSManaged public var name: String
    @NSManaged public var port: Int32
    @NSManaged public var created: Date
}

extension WLEDDevice : Identifiable {

}
