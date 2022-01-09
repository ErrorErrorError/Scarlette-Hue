//
//  DevicesUseCase.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import RxSwift

class DevicesUseCase<Repository>: DevicesUseCaseProtocol where Repository: AbstractRepository, Repository.T == Device {
    private let repository: Repository

    init(repository: Repository) {
        self.repository = repository
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
