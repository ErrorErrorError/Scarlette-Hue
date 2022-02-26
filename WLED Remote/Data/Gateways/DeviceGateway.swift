//
//  DeviceGatewayType.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/15/22.
//

import Foundation
import RxSwift

public protocol DeviceGatewayType {
    func devices() -> Observable<[Device]>
    func save(device: Device) -> Observable<Void>
    func delete(device: Device) -> Observable<Void>
}
