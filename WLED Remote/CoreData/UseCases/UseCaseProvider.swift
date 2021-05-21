//
//  UseCaseProvider.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation

public final class UseCaseProvider {
    private let coreDataStack = CoreDataStack()
    private let deviceRepository: Repository<Device>

    public init() {
        deviceRepository = Repository<Device>(context: coreDataStack.context)
    }

    func makeDevicesUseCase() -> DevicesUseCaseProtocol {
        return DevicesUseCase(repository: deviceRepository)
    }
}
