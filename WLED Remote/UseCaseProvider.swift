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
    private let apiEndpoint: String

    public init() {
        deviceRepository = Repository<Device>(context: coreDataStack.context)
        apiEndpoint = "http://%@:%d/json"
    }

    func makeDevicesRepository() -> DevicesUseCaseProtocol {
        return DevicesUseCase(repository: deviceRepository)
    }

    func makeDevicesBonjourService() -> NetServiceBrowser {
        return NetServiceBrowser()
    }

    public func makeStateNetwork() -> StateNetwork {
        let network = Network<State>(apiEndpoint)
        return StateNetwork(network: network)
    }

    public func makeInfoNetwork() -> InfoNetwork {
        let network = Network<Info>(apiEndpoint)
        return InfoNetwork(network: network)
    }
}
