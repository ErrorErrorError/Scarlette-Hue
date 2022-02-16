//
//  UseCaseProvider.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation

public final class UseCaseProvider {
    private let coreDataStack = CoreDataStack.shared
    private let apiEndpoint: String

    public init() {
        apiEndpoint = "http://%@:%d"
    }

    public func makeDevicesRepository() -> DeviceGatewayType {
        return DeviceGateway()
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

    public func makeSegmentAPI() -> SegmentAPI {
        let network = Network<Segment>(apiEndpoint)
        return SegmentAPI(network: network)
    }
}
