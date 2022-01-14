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
        apiEndpoint = "http://%@:%d"
    }

    public func makeDevicesRepository() -> DevicesUseCaseProtocol {
        return DevicesUseCase(repository: deviceRepository)
    }

    public func makeHeartbeatService() -> HeartbeatService {
        return HeartbeatService.shared
    }

    public func makeBonjourService() -> NetServiceBrowser {
        return NetServiceBrowser()
    }

    public func makeStoreAPI() -> StoreAPI {
        let network = Network<Store>(apiEndpoint)
        return StoreAPI(network: network)
    }

    public func makeStateNetwork() -> StateAPI {
        let network = Network<State>(apiEndpoint)
        return StateAPI(network: network)
    }

    public func makeInfoNetwork() -> InfoAPI {
        let network = Network<Info>(apiEndpoint)
        return InfoAPI(network: network)
    }
}
