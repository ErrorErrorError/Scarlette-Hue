//
//  DeviceViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/22/21.
//

import Foundation
import RxSwift
import RxCocoa

class DeviceViewModel: ViewModelType {
    private let device: Device
    private let deviceData: DeviceData
    private let deviceRepository: DevicesUseCaseProtocol
    private let navigator: DeviceNavigator
    private let deviceDataNetworkService: DeviceDataNetwork

    init(device: Device,
         deviceData: DeviceData,
         deviceDataNetworkService: DeviceDataNetwork,
         deviceRepository: DevicesUseCaseProtocol,
         navigator: DeviceNavigator) {
        self.device = device
        self.deviceData = deviceData
        self.deviceRepository = deviceRepository
        self.deviceDataNetworkService = deviceDataNetworkService
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let effects = input.effectTrigger
            .do(onNext: { self.navigator.toDeviceEffects() })

        let settings = input.settingsTrigger
            .do(onNext: { self.navigator.toDeviceSettings() })

        let info = input.infoTrigger
            .do(onNext: { self.navigator.toDeviceInfo() })

        let device = Driver.just(device)

        let fetchState = input.fetchState
            .flatMapLatest({ self.deviceDataNetworkService.fetchDeviceData(device: self.device)
                .map({ $0.state })
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .asDriverOnErrorJustComplete()
            })
            .startWith(deviceData.state)

        let updateOn = input.updateOn
            .skip(1)                        // Do not want initial state
            .startWith(deviceData.state.on!)

        let updateBrightness = input.updateBrightness
            .skip(1)                        // Do not want initial state
            .startWith(deviceData.state.bri!)

        let updateColors = input.updateColors
            .startWith(deviceData.state.firstSegment!.colors)

        let updated = Driver.combineLatest(updateOn, updateBrightness, updateColors)
            .map { (on, brightness, colors) in
                State(on: on, bri: brightness, segments: [Segment(colors: colors)])
            }
            .flatMapLatest({ self.deviceDataNetworkService.updateState(device: self.device, state: $0)
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .asDriverOnErrorJustComplete()
            })

        return Output(settings: settings,
                      effects: effects,
                      info: info,
                      state: fetchState,
                      device: device,
                      updated: updated)
    }
}

extension DeviceViewModel {
    struct Input {
        let effectTrigger: Driver<Void>
        let infoTrigger: Driver<Void>
        let settingsTrigger: Driver<Void>
        let fetchState: Driver<Void>
        let updateColors: Driver<[[Int]]>
        let updateBrightness: Driver<Int>
        let updateOn: Driver<Bool>
    }

    struct Output {
        let settings: Driver<Void>
        let effects: Driver<Void>
        let info: Driver<Void>
        let state: Driver<State>
        let device: Driver<Device>
        let updated: Driver<Bool>
    }
}
