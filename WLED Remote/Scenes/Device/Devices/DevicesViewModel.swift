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
    let navigator: DevicesNavigatorType
    let useCase: DevicesUseCaseType
}

extension DevicesViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let addDeviceTrigger: Driver<Void>
        let selectDevice: Driver<IndexPath>
        let editDevice: Driver<IndexPath>
        let deleteDevice: Driver<IndexPath>
    }

    struct Output {
        @Relay var devices = [DeviceItemViewModel]()
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()

        // Fetch Devices

        input.loadTrigger
            .flatMapLatest {
                useCase.getDevices()
                    .asDriverOnErrorJustComplete()
            }
            .map {
                $0.map { device in
                    DeviceItemViewModel(
                        deviceStore: .init(device: device, connectionState: .connecting, store: nil)
                    )
                }
            }
            .drive(output.$devices)
            .disposed(by: disposeBag)

        // Start heartbeats

        output.$devices
            .map {
                $0.map { vm in
                    vm.deviceStore.device
                }
            }
            .distinctUntilChanged()
            .debug()
            .subscribe(onNext: HeartbeatService.shared.sync)
            .disposed(by: disposeBag)

        // Add

        input.addDeviceTrigger
            .drive(onNext: navigator.toDiscoverDevice)
            .disposed(by: disposeBag)

        // Select

        select(trigger: input.selectDevice, items: output.$devices.asDriver())
            .filter({ $0.deviceStore.store != nil })
            .compactMap({ $0.deviceStore.store != nil ? ($0.deviceStore.device, $0.deviceStore.store!) : nil })
            .drive(onNext: { navigator.toDeviceDetail($0, $1) })
            .disposed(by: disposeBag)

        // Edit

        select(trigger: input.editDevice, items: output.$devices.asDriver())
            .map { $0.deviceStore.device }
            .drive(onNext: { navigator.toEditDevice($0) })
            .disposed(by: disposeBag)

        // Delete

        select(trigger: input.deleteDevice, items: output.$devices.asDriver())
            .map { $0.deviceStore.device }
            .flatMapLatest { device -> Driver<Device> in
                return navigator.confirmDeleteDevice(device)
                    .map { _ in device }
            }
            .flatMapLatest { device -> Driver<Device> in
                return useCase.deleteDevice(device)
                    .map { _ in device }
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: disposeBag)

        return output
    }
}
