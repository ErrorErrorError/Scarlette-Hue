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
    let segmentAPI: SegmentAPI
    let device: Device
    var segment: Segment
    var store: Store
    let delegate: PublishSubject<EditSegmentDelegate>
}

extension EditSegmentViewModel: ViewModel {
    struct PalettesSection: Hashable {
        typealias Palette = String
        let sectionTitle = "Palettes"
        var items: [Palette]
    }

    struct EffectsSection: Hashable {
        typealias Effect = String
        let sectionTitle = "Effects"
        var items: [Effect]
    }

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
        @Relay var palettes: PalettesSection
        @Relay var effects: EffectsSection
        @Relay var selectedPalette = IndexPath(row: 0, section: 0)
        @Relay var selectedEffect = IndexPath(row: 0, section: 1)
        @Relay var settings: SegmentSettings
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output(name: "Segment \(segment.id )",
                            on: segment.on ?? false,
                            brightness: Float(segment.brightness ?? 1),
                            colors: segment.colorsTuple,
                            palettes: PalettesSection(items: store.palettes),
                            effects: EffectsSection(items: store.effects),
                            selectedPalette: IndexPath(row: segment.palette ?? -1, section: 0),
                            selectedEffect: IndexPath(row: segment.effect ?? -1, section: 1),
                            settings: .init(from: segment)
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
        .filter({ $0.section == 0 })
        .do(onNext: { output.selectedPalette = $0 } )

        let updatedSelectedEffect = Driver.merge(
            input.selectedEffect,
            input.loadTrigger.map { output.selectedEffect }
        )
        .filter({ $0.section == 1 })
        .do(onNext: { output.selectedEffect = $0 } )


        let segmentSettingsDelegate = PublishSubject<SegmentSettingsDelegate>()

        let updatedSegmentSettings = Driver.merge(
            segmentSettingsDelegate.asDriverOnErrorJustComplete().map({ t in
                switch t {
                case .updatedSettings(let settings):
                    return settings
                }
            }),
            input.loadTrigger.map { output.settings }
        )
        .do(onNext: { output.settings = $0 })

        // Update state with values

        let segmentId = Driver.just(segment.id)

        Driver.combineLatest(
            segmentId,
            updatedOn,
            updatedBrightness,
            updatedColors,
            updatedSelectedPalette,
            updatedSelectedEffect,
            updatedSegmentSettings
        )
        .skip(1)
        .map { (id, on, brightness, colors, palette, effect, settings) in
            Segment(
                id: id,
                start: settings.start,
                stop: settings.stop,
                len: settings.len,
                group: settings.group,
                spacing: settings.spacing,
                on: on,
                brightness: Int(brightness),
                colors: [colors.first, colors.second, colors.third],
                effect: effect.row,
                palette: palette.row,
                reverse: settings.reverse,
                mirror: settings.mirror
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
            .do(onNext: {
                navigator.toSegmentSettings(
                    delegate: segmentSettingsDelegate,
                    info: store.info,
                    settings: output.settings
                )
            })
            .drive()
            .disposed(by: disposeBag)

        return output
    }
}
