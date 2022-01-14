//
//  DevicesViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import RxSwift
import RxCocoa

struct DevicesViewModel {
    let devicesRepository: DevicesUseCaseProtocol
    let heartbeatService: HeartbeatService
    let storeAPI: StoreAPI
    let navigator: DevicesNavigator
}

extension DevicesViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let addDeviceTrigger: Driver<Void>
        let selectedDevice: Driver<IndexPath>
    }

    struct Output {
        @Relay var deviceList = [DeviceItemViewModel]()
    }

    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()

        input.loadTrigger
            .flatMapLatest { _ in devicesRepository.devices().asDriverOnErrorJustComplete() }
            .map({
                $0.map({ device in
                    DeviceItemViewModel(with: device,
                                        storeAPI: self.storeAPI,
                                        heartbeatService: self.heartbeatService)
                })
            })
            .drive(output.$deviceList)
            .disposed(by: disposeBag)

        select(trigger: input.selectedDevice, items: output.$deviceList.asDriver())
            .filter({ $0.store != nil })
            .flatMapLatest { device in
                navigator.toDevice(device.device, device.store!)
                    .map({ ($0, device) })
            }
            .drive(onNext: { tuple in
                switch tuple.0 {
                case .updatedState(_):
                    let _ = output.deviceList
//                    tuple.1.store?.state = state
                    // TODO: Fix value change for data
                case .updatedStore(let store):
                    tuple.1.store = store
                }
            })
            .disposed(by: disposeBag)

        input.addDeviceTrigger
            .drive(onNext: navigator.toDiscoverDevice)
            .disposed(by: disposeBag)

        return output
    }
}
