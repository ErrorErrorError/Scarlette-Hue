//
//  EditSegmentViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/22/21.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

public enum EditSegmentDelegate {
    case updatedSegment(Segment)
    case addSegment(Segment)
    case deleteSegment(Segment)
}

public struct EditSegmentViewModel {
    let navigator: EditSegmentNavigator
    let deviceRepository: DevicesUseCaseProtocol
    let segmentAPI: SegmentAPI
    let device: Device
    var segment: Segment
    var store: Store
    let delegate: PublishSubject<EditSegmentDelegate>
}

extension EditSegmentViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let exitTrigger: Driver<Void>
        let settingsTrigger: Driver<Void>
        let on: Driver<Bool>
        let brightness: Driver<Float>
        let colors: Driver<(first: [Int], second: [Int], third: [Int])>
        let selectedPalette: Driver<IndexPath>
        let selectedEffect: Driver<IndexPath>
    }

    struct Output {
        @Relay var name = ""
        @Relay var on = false
        @Relay var brightness: Float = 0.0
        @Relay var colors: (first: [Int], second: [Int], third: [Int])
        @Relay var palettes: [PaletteItemViewModel] = []
        @Relay var effects: [EffectItemViewModel] = []
        @Relay var selectedPalette = IndexPath(row: 0, section: 0)
        @Relay var selectedEffect = IndexPath(row: 0, section: 0)
    }

    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output(name: "Segment \(segment.id )",
                            on: segment.on ?? false,
                            brightness: Float(segment.brightness ?? 1),
                            colors: segment.colorsTuple,
                            palettes: store.palettes.compactMap { PaletteItemViewModel(title: $0) },
                            effects: store.effects.compactMap { EffectItemViewModel(title: $0) },
                            selectedPalette: IndexPath(row: segment.palette ?? -1, section: 0),
                            selectedEffect: IndexPath(row: segment.effect ?? -1, section: 0)
        )

        let segmentId = Driver.just(segment.id)

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

        let updatedSelectedEffect = Driver.merge(
            input.selectedEffect,
            input.loadTrigger.map { output.selectedEffect }
        )
        .do(onNext: { output.selectedEffect = $0 } )

        // Update state with values

        Driver.combineLatest(
            segmentId,
            updatedOn,
            updatedBrightness,
            updatedColors,
            updatedSelectedPalette,
            updatedSelectedEffect
        )
        .skip(1)
        .map { (id, on, brightness, colors, palette, effect) in
            Segment(
                id: id,
                on: on,
                brightness: Int(brightness),
                colors: [colors.first, colors.second, colors.third],
                effect: effect.row,
                palette: palette.row
            )
        }
        .do(onNext: { newSegment in
            delegate.onNext(.updatedSegment(newSegment))
        })
        .drive()
        .disposed(by: disposeBag)

        input.exitTrigger
            .do(onNext: navigator.toDeviceDetail)
            .drive()
            .disposed(by: disposeBag)

        input.settingsTrigger
                .do(onNext: { navigator.toSegmentSettings(delegate: delegate,
                                                          device: device,
                                                          info: store.info,
                                                          segment: segment)
                })
                .drive()
                .disposed(by: disposeBag)

        return output
    }
}
