//
//  DiscoverDeviceViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import RxSwift
import RxCocoa

final class DiscoverDeviceViewModel: ViewModelType {
    private let devicesRepository: DevicesUseCaseProtocol
    private let navigator: DiscoverDeviceNavigator
    private let bonjourService: NetServiceBrowser
    private let stateNetworkService: StateNetwork

    private var services = BehaviorRelay<[NetService]>(value: [])

    init(devicesRepository: DevicesUseCaseProtocol, bonjourService: NetServiceBrowser, stateNetworkService: StateNetwork, navigator: DiscoverDeviceNavigator) {
        self.devicesRepository = devicesRepository
        self.bonjourService = bonjourService
        self.stateNetworkService = stateNetworkService
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {

        let scanTrigger = input.scanDevicesTrigger
            .do(onNext: { [weak self] in
                self?.bonjourService.searchForServices(ofType: "_http._tcp", inDomain: "")
            })

        let devices = input.devicesTrigger.flatMapLatest {
            return self.devicesRepository.devices()
                .asDriverOnErrorJustComplete()
        }

        let newService = scanTrigger.flatMapLatest({ self.bonjourService.rx.serviceAdded.asDriverOnErrorJustComplete() })
            .withLatestFrom(devices, resultSelector: { service, devices in
                devices.contains(where: { $0.ip == service.firstIPv4Address! }) ? NetService() : service
            })
            .filter({ $0.firstIPv4Address != nil }) // Check if ip address is valid
            .flatMapLatest({ service in
                self.stateNetworkService.validateNetwork(ip: service.firstIPv4Address!, port: service.port)
                    .asDriverOnErrorJustComplete()
                    .withLatestFrom(Driver.just(service))
            })
            .do(onNext: {
                var newArray = self.services.value
                newArray.append($0)
                self.services.accept(newArray)
            })

        let scannedDevices = newService.withLatestFrom(services.asDriverOnErrorJustComplete())
            .map({ $0.map({ Device(name: $0.name, ip: $0.firstIPv4Address!, port: $0.port) }) })
            .map({ $0.map({ DeviceInfoItemViewModel(with: $0) }) })

        let next = input.nextTrigger.withLatestFrom(services.asDriver()) { (indexPath, services) -> NetService in
            return services[indexPath.row]
        }
        .map({ Device(name: $0.name, ip: $0.firstIPv4Address!, port: $0.port) })
        .do(onNext: navigator.toAddDevice)

        let dismiss = Driver.of(input.dismissTrigger)
            .merge()
            .do(onNext: { [weak self] in
                self?.bonjourService.stop()
                self?.navigator.toDevices()
            })

        return Output(scannedDevices: scannedDevices, devices: devices, next: next, dismiss: dismiss)
    }
}

extension DiscoverDeviceViewModel {
    struct Input {
        let scanDevicesTrigger: Driver<Void>
        let devicesTrigger: Driver<Void>
        let dismissTrigger: Driver<Void>
        let nextTrigger: Driver<IndexPath>
    }

    struct Output {
        let scannedDevices: Driver<[DeviceInfoItemViewModel]>
        let devices: Driver<[Device]>
        let next: Driver<Device>
        let dismiss: Driver<Void>
    }
}
