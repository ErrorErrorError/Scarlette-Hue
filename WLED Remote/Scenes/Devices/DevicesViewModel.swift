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
    private let devicesRepository: DevicesUseCaseProtocol
    private let navigator: DevicesNavigator
    private let deviceDataNetworkService: DeviceDataNetwork

    init(devicesRepository: DevicesUseCaseProtocol, deviceDataNetworkService: DeviceDataNetwork, navigator: DevicesNavigator) {
        self.devicesRepository = devicesRepository
        self.deviceDataNetworkService = deviceDataNetworkService
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let deviceItemViewModels = input.onAppearTrigger.flatMapLatest {
            self.devicesRepository.devices()
                .asDriverOnErrorJustComplete()
                .map { $0.map({ DeviceItemViewModel(with: $0, deviceDataNetworkService: self.deviceDataNetworkService) }) }
        }

        let selectedDevice = input.onSelectionTrigger
            .withLatestFrom(deviceItemViewModels) { indexPath, element in
                element[indexPath.row]
            }
            .filter({ $0.deviceDataRelay.value != nil })
            .map({ ($0.device, $0.deviceDataRelay.value!) })
            .do(onNext: { self.navigator.toDevice($0.0, $0.1)})
            .mapToVoid()

        let createDevice = input.onAddDeviceTrigger
                .do(onNext: navigator.toDiscoverDevice)

        return Output(devices: deviceItemViewModels,
                      createDevice: createDevice,
                      selectedDevice: selectedDevice)
    }
}

extension DevicesViewModel {
    struct Input {
        let onAppearTrigger: Driver<Void>
        let onAddDeviceTrigger: Driver<Void>
        let onSelectionTrigger: Driver<IndexPath>
    }

    struct Output {
        let devices: Driver<[DeviceItemViewModel]>
        let createDevice: Driver<Void>
        let selectedDevice: Driver<Void>
    }
}

private extension Dictionary where Key == String, Value == State {
    static func + (lhs: [String : State], rhs: [String : State]) -> [String : State] {
        return lhs.merging(rhs) { (_, new) in new }
    }
}
