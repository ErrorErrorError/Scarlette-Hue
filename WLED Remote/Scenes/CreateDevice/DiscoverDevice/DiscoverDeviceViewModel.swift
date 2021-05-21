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
    private let useCase: DevicesUseCaseProtocol
    private let navigator: DiscoverDeviceNavigator

    init(createDeviceUseCase: DevicesUseCaseProtocol, navigator: DiscoverDeviceNavigator) {
        self.useCase = createDeviceUseCase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let devices = input.devicesTrigger.flatMapLatest {
            return self.useCase.devices()
                .asDriverOnErrorJustComplete()
        }

//        let nameIpAndPort = Driver.combineLatest(input.name, input.ip, input.port)

        let next = Driver.of(input.nextTrigger)
            .merge()
            .do(onNext: navigator.toAddDevice)
        
        let dismiss = Driver.of(input.cancelTrigger)
            .merge()
            .do(onNext: navigator.toDevices)

        return Output(devices: devices, next: next, dismiss: dismiss)
    }
}

extension DiscoverDeviceViewModel {
    struct Input {
        let devicesTrigger: Driver<Void>
        let cancelTrigger: Driver<Void>
        let nextTrigger: Driver<Void>
        let name: Driver<String>
        let ip: Driver<String>
        let port: Driver<Int>
    }

    struct Output {
        let devices: Driver<[Device]>           // Returns all devices
        let next: Driver<Void>
        let dismiss: Driver<Void>               // Dismisses Modal
    }
}
