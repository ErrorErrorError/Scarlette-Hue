//
//  DeviceItemViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import RxSwift
import RxCocoa
import Then
import Differentiator
import WLEDClient

protocol DeviceItemUpdateState {
    func updateOn(isOn: Bool, for device: Device)
    func updateBrightness(brightness: Int, for device: Device)
}

struct DeviceItemViewModel {
    public var deviceStore: DeviceStore
}

extension DeviceItemViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let on: Driver<Bool>
    }

    struct Output {
        @Relay var name: String
        @Relay var store: Store?
        @Relay var connection = WLEDDevice.ConnectionState.connecting
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output(name: deviceStore.device.name)

        deviceStore.wledDevice.storeObservable
            .asDriverOnErrorJustComplete()
            .drive(output.$store)
            .disposed(by: disposeBag)

        deviceStore.wledDevice.heartbeatStateObservable
            .asDriverOnErrorJustComplete()
            .drive(output.$connection)
            .disposed(by: disposeBag)

        input.on
            .map({ State(on: $0) })
            .flatMapLatest {
                deviceStore.wledDevice.updateState(state: $0)
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: disposeBag)

        return output
    }
}

extension DeviceItemViewModel: IdentifiableType, Equatable {
    static func == (lhs: DeviceItemViewModel, rhs: DeviceItemViewModel) -> Bool {
        lhs.deviceStore.device == rhs.deviceStore.device
    }

    var identity: UUID {
        return deviceStore.device.id
    }
}
