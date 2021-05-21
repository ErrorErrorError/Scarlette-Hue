//
//  DevicesViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import RxSwift
import RxCocoa

final class DevicesViewModel: ViewModelType {
    struct Input {
        let trigger: Driver<Void>
        let createDeviceTrigger: Driver<Void>
        let selection: Driver<IndexPath>
    }

    struct Output {
        let devices: Driver<[DeviceItemViewModel]>
        let createDevice: Driver<Void>
        let selectedDevice: Driver<Device>
    }

    private let useCase: DevicesUseCaseProtocol
    private let navigator: DevicesNavigator

    init(useCase: DevicesUseCaseProtocol, navigator: DevicesNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let devices = input.trigger.flatMapLatest {
            return self.useCase.devices()
                .asDriverOnErrorJustComplete()
                .map { $0.map({ DeviceItemViewModel(with: $0) }) }
        }

        let selectedDevice = input.selection
            .withLatestFrom(devices) { indexPath, devices in
                return devices[indexPath.row].device
            }

        let createDevice = input.createDeviceTrigger
            .do(onNext: navigator.toCreateDevice)

        return Output(devices: devices,
                      createDevice: createDevice,
                      selectedDevice: selectedDevice)
    }
}
