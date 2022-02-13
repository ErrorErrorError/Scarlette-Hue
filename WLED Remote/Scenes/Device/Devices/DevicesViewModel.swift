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
        let editDevice: Driver<IndexPath>
        let deleteDevice: Driver<IndexPath>
    }

    struct Output {
        @Relay var deviceList = [DeviceItemViewModel]()
    }

    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()

        input.loadTrigger
            .flatMapLatest {
                devicesRepository.devices()
                    .asDriverOnErrorJustComplete()
            }
            .map {
                $0.map { device in
                    DeviceItemViewModel(device: device,
                                        storeAPI: self.storeAPI,
                                        heartbeatService: self.heartbeatService)
                }
            }
            .do(onNext: { output.deviceList = $0 })
            .drive()
            .disposed(by: disposeBag)

        // Add

        input.addDeviceTrigger
            .drive(onNext: navigator.toDiscoverDevice)
            .disposed(by: disposeBag)

        // Select

        select(trigger: input.selectedDevice, items: output.$deviceList.asDriver())
            .filter({ $0.storeSubject.value != nil })
            .drive(onNext: { navigator.toDeviceDetail($0.device, $0.storeSubject.value!) })
            .disposed(by: disposeBag)

        // Edit

        select(trigger: input.editDevice, items: output.$deviceList.asDriver())
            .map { $0.device }
            .drive(onNext: { navigator.toEditDevice($0) })
            .disposed(by: disposeBag)

        // Delete

        select(trigger: input.deleteDevice, items: output.$deviceList.asDriver())
            .map { $0.device }
            .flatMapLatest { device -> Driver<Device> in
                return navigator.confirmDeleteDevice(device)
                    .map { _ in device }
            }
            .flatMapLatest { device -> Driver<Device> in
                return devicesRepository.delete(device: device)
                    .map { _ in device }
                    .asDriverOnErrorJustComplete()
            }
            .drive()
            .disposed(by: disposeBag)

        return output
    }
}
