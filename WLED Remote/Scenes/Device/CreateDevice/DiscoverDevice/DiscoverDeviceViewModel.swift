//
//  DiscoverDeviceViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import RxSwift
import RxCocoa

struct DiscoverDeviceViewModel {
    let navigator: DiscoverDeviceNavigatorType
    let useCase: DiscoverDeviceUseCaseType
}

extension DiscoverDeviceViewModel: ViewModel {
    struct Input {
        let scanDevicesTrigger: Driver<Void>
        let manualDeviceTrigger: Driver<Void>
        let dismissTrigger: Driver<Void>
        let selectedDevice: Driver<IndexPath>
    }

    struct Output {
        @Relay var devices = [DeviceInfoItemViewModel]()
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()

        let devices = useCase.getDevices()
            .asDriverOnErrorJustComplete()

        useCase.getScannedDevices()
            .withLatestFrom(devices) { scannedDevice, devices in
                devices.contains(where: { $0.ip == scannedDevice.ip }) ? nil : scannedDevice
            }
            .compactMap { $0 }
//            .flatMapLatest { scanned in
//                useCase.validate(scanned)
//                    .map { nil ?? $0 }  // Mapped to accept nil
//                    .catchAndReturn(nil)
//                    .compactMap { $0 }
//                    .map { _ in scanned }
//            }
            .map { DeviceInfoItemViewModel(with: .init(name: $0.name, ip: $0.ip, port: $0.port)) }
            .asDriverOnErrorJustComplete()
            .drive {
                output.devices.append($0)
            }
            .disposed(by: disposeBag)

        input.scanDevicesTrigger
            .do(onNext: {
                useCase.startScan()
            })
            .drive()
            .disposed(by: disposeBag)

        input.manualDeviceTrigger
            .drive(onNext: {
                useCase.stopScan()
                navigator.toManuallyAddDevice()
            })
            .disposed(by: disposeBag)

        input.dismissTrigger
            .drive(onNext: {
                useCase.stopScan()
                navigator.toDevices()
            })
            .disposed(by: disposeBag)

        select(trigger: input.selectedDevice, items: output.$devices.asDriver())
            .map({ $0.device })
            .drive {
                useCase.stopScan()
                navigator.toConfigureDevice($0)
            }
            .disposed(by: disposeBag)
        return output
    }
}
