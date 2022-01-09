//
//  DevicesUseCase.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import Foundation
import RxSwift

public protocol DevicesUseCaseProtocol {
    func devices() -> Observable<[Device]>
    func save(device: Device) -> Observable<Void>
    func delete(device: Device) -> Observable<Void>
}
