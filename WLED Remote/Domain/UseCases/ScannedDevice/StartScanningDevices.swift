//
//  StartScanningDevices.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/16/22.
//

import Foundation


protocol StartScanningDevices {
    var bonjourGatewayType: BonjourGatewayType { get }
}

extension StartScanningDevices {
    func startScan() -> Void {
        bonjourGatewayType.startScan()
    }
}
