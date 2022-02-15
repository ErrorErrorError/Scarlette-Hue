//
//  DeviceGateway.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import RxSwift
import CoreData

public protocol DeviceRepositoryType {
    func devices() -> Observable<[Device]>
    func save(device: Device) -> Observable<Void>
    func delete(device: Device) -> Observable<Void>
}

class DeviceRepository: DeviceRepositoryType {
    private let repository: Repository<Device>

    init(context: NSManagedObjectContext) {
        self.repository = Repository<Device>(context: context)
    }

    func devices() -> Observable<[Device]> {
        return repository.query(with: nil, sortDescriptors: [Device.CoreDataType.created.ascending()])
    }

    func save(device: Device) -> Observable<Void> {
        return repository.save(entity: device)
    }

    func delete(device: Device) -> Observable<Void> {
        return repository.delete(entity: device)
    }
}
