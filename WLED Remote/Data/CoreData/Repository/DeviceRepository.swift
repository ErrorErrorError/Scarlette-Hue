//
//  DeviceGateway.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import RxSwift
import CoreData

class DeviceRepository {
    private let repository: Repository<Device>

    init() {
        self.repository = Repository<Device>(context: CoreDataStack.shared.context)
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
