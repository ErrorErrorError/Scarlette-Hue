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
    let navigator: DiscoverDeviceNavigator
    let devicesRepository: DevicesUseCaseProtocol
    let bonjourService: NetServiceBrowser
    let infoAPIService: InfoAPI
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
        let output = Output()

        let devices = devicesRepository.devices()
            .asDriverOnErrorJustComplete()

        let serviceAdded = bonjourService.rx.serviceAdded
            .filter({ $0.firstIPv4Address != nil })
            .asDriverOnErrorJustComplete()

        serviceAdded
            .withLatestFrom(devices) { service, devices in
                devices.contains(where: { $0.ip == service.firstIPv4Address! }) ? nil : service
            }
            .compactMap({ $0 })
            .flatMapLatest({ service in
                // If it is unable to fetch info, handle error by returning nil
                // since we are on Driver.
                infoAPIService.validateNetwork(ip: service.firstIPv4Address!, port: service.port)
                    .map({ nil ?? $0 }) // Mapped to accept nil
                    .asDriver(onErrorRecover: { _ in Driver.just(nil) })
                    .map({ $0 != nil ? service : nil })
            })
            .compactMap({ $0 })
            .map({ Device(name: $0.name, ip: $0.firstIPv4Address!, port: $0.port) })
            .map({ DeviceInfoItemViewModel(with: $0) })
            .do(onNext: {
                var newArray = output.devices
                newArray.append($0)
                output.$devices.accept(newArray)
            })
            .drive()
            .disposed(by: disposeBag)

        input.scanDevicesTrigger
            .do(onNext: {
                bonjourService.searchForServices(ofType: "_http._tcp", inDomain: "")
            })
            .drive()
            .disposed(by: disposeBag)

        input.manualDeviceTrigger
            .drive(onNext: {
                bonjourService.stop()
                navigator.toManuallyAddDevice()
            })
            .disposed(by: disposeBag)

        input.dismissTrigger
            .drive(onNext: {
                bonjourService.stop()
                navigator.toDevices()
            })
            .disposed(by: disposeBag)

        select(trigger: input.selectedDevice, items: output.$devices.asDriver())
            .map({ $0.device })
            .drive {
                bonjourService.stop()
                navigator.toConfigureDevice($0)
            }
            .disposed(by: disposeBag)
        return output
    }
}
