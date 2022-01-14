//
//  EditDeviceViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/22/21.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

public enum EditDeviceDelegate {
    case updatedStore(Store)
    case updatedState(State)
}

public struct EditDeviceViewModel {
    public let navigator: EditDeviceNavigator
    public let deviceRepository: DevicesUseCaseProtocol
    public let deviceStoreAPI: StoreAPI
    public let device: Device
    public var store: Store
    public let delegate: PublishSubject<EditDeviceDelegate>

    public init(navigator: EditDeviceNavigator,
                  deviceRepository: DevicesUseCaseProtocol,
                  deviceStoreAPI: StoreAPI,
                  device: Device,
                  store: Store,
                  delegate: PublishSubject<EditDeviceDelegate>) {

        self.navigator = navigator
        self.deviceRepository = deviceRepository
        self.deviceStoreAPI = deviceStoreAPI
        self.device = device
        self.store = store
        self.delegate = delegate
    }
}

extension EditDeviceViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let effectTrigger: Driver<Void>
        let infoTrigger: Driver<Void>
        let settingsTrigger: Driver<Void>
        let colors: Driver<(first: [Int], second: [Int], third: [Int])>
        let brightness: Driver<Float>
        let on: Driver<Bool>
        let selectedPalette: Driver<IndexPath>
    }

    struct Output {
        @Relay var deviceName: String
        @Relay var colors: (first: [Int], second: [Int], third: [Int])
        @Relay var brightness: Float = 0.0
        @Relay var on: Bool = false
        @Relay var palettes: [String] = []
        @Relay var selectedPalette = IndexPath(row: 0, section: 0)
    }

    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output(deviceName: device.name,
                            colors: store.state.firstSegment?.colorsTuple ?? (first: UIColor.black.intArray,
                                                                              second: UIColor.black.intArray,
                                                                              third: UIColor.black.intArray),
                            brightness: Float(store.state.bri ?? 1),
                            on: store.state.on ?? false,
                            palettes: store.palettes,
                            selectedPalette: IndexPath(row: store.state.firstSegment?.palette ?? -1, section: 0) 
        )

        let updatedOn = Driver.merge(
            input.on,
            input.loadTrigger.map { output.on }
        )
        .do(onNext: { output.on = $0 } )

        let updatedBrightness = Driver.merge(
            input.brightness,
            input.loadTrigger.map { output.brightness }
        )
        .debounce(.milliseconds(200))
        .do(onNext: { output.brightness = $0 } )

        let updatedColors = Driver.merge(
            input.colors,
            input.loadTrigger.map { output.colors }
        )
        .debounce(.milliseconds(200))
        .do(onNext: { output.colors = $0 } )

        let updatedSelectedPalette = Driver.merge(
            input.selectedPalette,
            input.loadTrigger.map { output.selectedPalette }
        )
        .do(onNext: { output.selectedPalette = $0 } )

        let updateState = Driver.combineLatest(
            updatedOn,
            updatedBrightness,
            updatedColors,
            updatedSelectedPalette
        )
        .map { (on, brightness, colors, palette) in
            State(
                on: on,
                bri: UInt8(brightness),
                segments: [Segment(colors: [colors.first, colors.second, colors.third], palette: palette.row)]
            )
        }
        .do(onNext: { newState in
            var updatedState = store.state.with {
                $0.on = newState.on
                $0.bri = newState.bri
            }

            if let newColors = newState.firstSegment?.colors {
                let segments = updatedState.selectedSegments
                let selectedIndices = segments.indices.filter({ segments[$0].selected == true })
                for index in selectedIndices {
                    updatedState.segments[index].colors = newColors
                    updatedState.segments[index].palette = newState.firstSegment?.palette
                }
            }

            var updatedStore = store
            updatedStore.state = updatedState

            delegate.onNext(.updatedState(updatedState))
        })
        .flatMapLatest {
            self.deviceStoreAPI.updateState(device: self.device, state: $0)
                .asDriverOnErrorJustComplete()
        }

        updateState
            .drive()
            .disposed(by: disposeBag)

        input.effectTrigger
            .do(onNext: navigator.toDeviceEffects)
            .drive()
            .disposed(by: disposeBag)

        input.settingsTrigger
            .do(onNext: { navigator.toDeviceSettings() })
            .drive()
            .disposed(by: disposeBag)

        input.infoTrigger
            .do(onNext: { navigator.toDeviceInfo() })
            .drive()
            .disposed(by: disposeBag)

        return output
    }
}
