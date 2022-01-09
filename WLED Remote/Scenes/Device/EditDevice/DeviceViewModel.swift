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
    private let deviceRepository: DevicesUseCaseProtocol
    private let navigator: DeviceNavigator
    private let deviceDataNetworkService: DeviceDataNetwork
    private let deviceDataRelay: BehaviorRelay<DeviceStore>

    init(device: Device,
         deviceData: DeviceStore,
         deviceDataNetworkService: DeviceDataNetwork,
         deviceRepository: DevicesUseCaseProtocol,
         navigator: DeviceNavigator) {
        self.device = device
        self.deviceDataRelay = BehaviorRelay(value: deviceData)
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

        let fetchState = deviceDataRelay.asObservable()
            .skip(1)
            .map({ $0.state})
            .asDriverOnErrorJustComplete()

        let fetchPalettes = deviceDataRelay.asObservable()
            .map({ $0.palettes })
            .map({ $0.map { title in Palette(title: title) } })
            .map({ $0.map { palette in PaletteItemViewModel(with: palette) } })
            .asDriverOnErrorJustComplete()

        let updateOn = input.updateOn
            .skip(1)
            .startWith(deviceDataRelay.value.state.on!)

        let updateBrightness = input.updateBrightness
            .skip(1)
            .startWith(deviceDataRelay.value.state.bri!)

        let updateColors = input.updateColors
            .startWith(deviceDataRelay.value.state.firstSegment!.colors)

        let updatePalette = input.updatePalette
            .map({ $0.row + $0.section })
            .startWith(deviceDataRelay.value.state.firstSegment?.palette)

        let updated = Driver.combineLatest(updateOn, updateBrightness, updateColors, updatePalette)
            .map { (on, brightness, colors, palette) in
                State(on: on, bri: brightness, segments: [Segment(colors: colors, palette: palette)])
            }
            .do(onNext: { newState in
                var oldData = self.deviceDataRelay.value
                var oldState = oldData.state
                if var oldSegments = oldState.selectedSegments, let newColors = newState.firstSegment?.colors {
                    for index in oldSegments.indices {
                        var segment = oldSegments[index]
                        segment.colors = newColors
                        segment.palette = newState.firstSegment?.palette
                        // TODO, modify segments
                        oldSegments[index] = segment
                    }
                    oldState.segments = oldSegments
                }

                oldState.on = newState.on
                oldState.bri = newState.bri
                oldData.state = oldState
                self.deviceDataRelay.accept(oldData)
            })
            .flatMapLatest({ self.deviceDataNetworkService.updateState(device: self.device, state: $0)
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .asDriverOnErrorJustComplete()
            })

        return Output(settings: settings,
                      effects: effects,
                      info: info,
                      state: fetchState,
                      palettes: fetchPalettes,
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
        let updatePalette: Driver<IndexPath>
    }

    struct Output {
        let settings: Driver<Void>
        let effects: Driver<Void>
        let info: Driver<Void>
        let state: Driver<State>
        let palettes: Driver<[PaletteItemViewModel]>
        let device: Driver<Device>
        let updated: Driver<Bool>
    }
}
