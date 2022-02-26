//
//  BonjourGateway.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/16/22.
//

import RxSwift
import Foundation

protocol BonjourGatewayType {
    func startScan() -> Void
    func stopScan() -> Void
    func getScannedServices() -> Observable<NetService>
}

class BonjourGateway: NetServiceBrowser, BonjourGatewayType {
    func startScan() {
        searchForServices(ofType: "_http._tcp", inDomain: "")
    }

    func stopScan() {
        stop()
    }

    func getScannedServices() -> Observable<NetService> {
        rx.serviceAdded
            .filter({ $0.firstIPv4Address != nil })
    }
}
