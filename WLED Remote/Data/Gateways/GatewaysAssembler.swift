//
//  GatewaysAssembler.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/15/22.
//

import Foundation

protocol GatewaysAssembler {
    func resolve() -> DeviceGatewayType
    func resolve() -> BonjourGatewayType
}

extension GatewaysAssembler where Self: DefaultAssembler {
    func resolve() -> DeviceGatewayType {
        return DeviceRepository()
    }

    func resolve() -> BonjourGatewayType {
        return BonjourGateway()
    }
}
