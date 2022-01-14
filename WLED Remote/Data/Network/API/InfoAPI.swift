//
//  InfoNetwork.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/22/21.
//

import RxSwift

public final class InfoAPI {
    private let network: Network<Info>

    init(network: Network<Info>) {
        self.network = network
    }

    public func fetchInfo(device: Device) -> Observable<Info> {
        return network.getItem(device, "json/info")
    }

    public func validateNetwork(ip: String, port: Int) -> Observable<Info> {
        return network.getItem("http://\(ip):\(port)", "json/info")
    }
}
