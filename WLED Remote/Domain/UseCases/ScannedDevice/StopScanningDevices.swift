//
//  StopScanningDevices.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/16/22.
//

import Foundation

protocol StopScanningDevices {
    var bonjourGatewayType: BonjourGatewayType { get }
}

extension StopScanningDevices {
    func stopScan() -> Void {
        bonjourGatewayType.stopScan()
    }
}
