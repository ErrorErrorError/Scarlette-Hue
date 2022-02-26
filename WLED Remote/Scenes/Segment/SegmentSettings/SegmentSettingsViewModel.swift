//
//  SegmentSettingsViewModel.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/19/22.
//

import UIKit
import RxSwift
import RxCocoa
import WLEDClient


public enum SegmentSettingsDelegate {
    case updatedSettings(SegmentSettings)
}

struct SegmentSettingsViewModel {
    let navigator: SegmentSettingsNavigatorType
    let useCase: SegmentSettingsUseCaseType
    let delegate: PublishSubject<SegmentSettingsDelegate>
    let info: Info
    let segmentSettings: SegmentSettings
}

extension SegmentSettingsViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let dismissTrigger: Driver<Void>
        let saveTrigger: Driver<Void>
        let start: Driver<String>
        let stop: Driver<String>
        let grouping: Driver<String>
        let spacing: Driver<String>
        let reverse: Driver<Bool>
        let mirror: Driver<Bool>
    }

    struct Output {
        @Relay var start: String
        @Relay var stop: String
        @Relay var grouping: String
        @Relay var spacing: String
        @Relay var reverse: Bool
        @Relay var mirror: Bool
        @Relay var isValid = false
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output(start: String(segmentSettings.start ?? 0),
                            stop: String(segmentSettings.stop ?? 0),
                            grouping: String(segmentSettings.group ?? 0),
                            spacing: String(segmentSettings.spacing ?? 0),
                            reverse: segmentSettings.reverse ?? false,
                            mirror: segmentSettings.mirror ?? false
        )

        let start = Driver.merge(
            input.start,
            input.loadTrigger.map { output.start }
        )
        .map { Int($0) ?? -1 }

        let stop = Driver.merge(
            input.stop,
            input.loadTrigger.map { output.stop }
        )
        .map { Int($0) ?? -1 }

        let grouping = Driver.merge(
            input.grouping,
            input.loadTrigger.map { output.grouping }
        )
        .map { Int($0) ?? -1 }

        let spacing = Driver.merge(
            input.spacing,
            input.loadTrigger.map { output.spacing }
        )
        .map { Int($0) ?? -1 }

        let reverse = Driver.merge(
            input.reverse,
            input.loadTrigger.map { output.reverse }
        )

        let mirror = Driver.merge(
            input.mirror,
            input.loadTrigger.map { output.mirror }
        )

        // MARK: Validation

        let startValidation = start
            .map { start -> Bool in
                if start != -1 {
                    let maxLeds = info.leds?.count ?? 0
                    return (0..<maxLeds).contains(start)
                }
                return false
            }

        let stopValidation = Driver.combineLatest(start, stop)
            .map { start, stop -> Bool in
                if start != -1 && stop != -1 {
                    let maxLeds = info.leds?.count ?? 0
                    return (0...maxLeds).contains(stop) && stop > start
                }
                return false
            }

        let groupingValidation = grouping
            .map { (0..<256).contains($0) }

        let spacingValidation = spacing
            .map { (0..<256).contains($0) }

        let valid = Driver.combineLatest(startValidation, stopValidation, groupingValidation, spacingValidation)
            .map { $0 && $1 && $2 && $3 }
            .startWith(true)
            .do(onNext: {
                output.isValid = $0
            })

        input.saveTrigger
            .withLatestFrom(valid)
            .filter { $0 }
            .withLatestFrom(Driver.combineLatest(start, stop, grouping, spacing, reverse, mirror))
            .do(onNext: { start, stop, grouping, spacing, reverse, mirror in
                let settings = SegmentSettings(
                    start: Int(start),
                    stop: Int(stop),
                    len: stop - start,
                    group: UInt8(grouping),
                    spacing: UInt8(spacing),
                    reverse: reverse,
                    mirror: mirror
                )
                delegate.onNext(.updatedSettings(settings))
            })
            .drive(onNext: { _ in navigator.toEditSegment() })
            .disposed(by: disposeBag)

        input.dismissTrigger
            .drive(onNext: { navigator.toEditSegment() })
            .disposed(by: disposeBag)

        return output
    }
}
