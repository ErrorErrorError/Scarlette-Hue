//
//  DevicesViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import RxSwift
import RxCocoa
import WLEDClient

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

        let devices = useCase.getDevices()
            .asDriverOnErrorJustComplete()

        // Create View Model for devices

        input.loadTrigger
            .flatMapLatest {
                devices
            }
            .withLatestFrom(output.$devices.asDriver()) { devices, devicesVM in
                var viewModels = devicesVM

                let createNewVMs = devices.filter { device in
                    viewModels.first { $0.deviceStore.device == device } == nil
                }

                for device in createNewVMs {
                    let wledDevice = WLEDDevice(host: device.ip)
                    wledDevice.startHeartbeat()
                    let deviceStore = DeviceStore(device: device, wledDevice: wledDevice)
                    viewModels.append(.init(deviceStore: deviceStore))
                }

                let deleteDevicesVM = viewModels.filter { vm in
                    devices.first { $0 == vm.deviceStore.device } == nil
                }

                for deviceVM in deleteDevicesVM {
                    deviceVM.deviceStore.wledDevice.stopHeartbeat()
                    viewModels.removeAll(where: { $0 == deviceVM })
                }

                return viewModels
            }
            .drive(output.$devices)
            .disposed(by: disposeBag)

        // Add

        input.addDeviceTrigger
            .drive(onNext: navigator.toDiscoverDevice)
            .disposed(by: disposeBag)

        // Select

        select(trigger: input.selectDevice, items: output.$devices.asDriver())
            .map { $0.deviceStore }
            .flatMapLatest { deviceStore in
                deviceStore.wledDevice.storeObservable.single()
                    .filter { $0 != nil }
                    .asDriverOnErrorJustComplete()
                    .flatMapLatest { _ in Driver.just(deviceStore) }
            }
            .drive(onNext: navigator.toDeviceDetail)
            .disposed(by: disposeBag)

        // Edit

        select(trigger: input.editDevice, items: output.$devices.asDriver())
            .map { $0.deviceStore.device }
            .drive(onNext: navigator.toEditDevice)
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
