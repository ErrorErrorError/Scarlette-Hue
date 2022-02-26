//
//  AddSegmentViewModel.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/15/22.
//

import UIKit
import RxSwift
import RxCocoa
import WLEDClient

struct AddSegmentViewModel {
    let navigator: AddSegmentNavigatorType
    let useCase: AddSegmentUseCaseType
    let delegate: PublishSubject<EditSegmentDelegate>
//    let deviceStore: DeviceStore
    let store: Store
}

extension AddSegmentViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let dismissTrigger: Driver<Void>
        let addTrigger: Driver<Void>
        let start: Driver<String>
        let stop: Driver<String>
    }

    struct Output {
        @Relay var start: String = ""
        @Relay var stop: String = ""
        @Relay var isValid = false
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output(start: "0", stop: String(store.info.leds?.count ?? 0))

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

        let startValidation = start
            .map { start -> Bool in
                if start != -1 {
                    let maxLeds = store.info.leds?.count ?? 0
                    return (0..<maxLeds).contains(start)
                }
                return false
            }

        let stopValidation = Driver.combineLatest(start, stop)
            .map { start, stop -> Bool in
                if start != -1 && stop != -1 {
                    let maxLeds = store.info.leds?.count ?? 0
                    return (0...maxLeds).contains(stop) && stop > start
                }
                return false
            }

        let valid = Driver.combineLatest(startValidation, stopValidation)
            .map { $0 && $1 }
            .startWith(true)
            .do(onNext: {
                output.isValid = $0
            })

        input.addTrigger
            .withLatestFrom(valid)
            .filter { $0 }
            .withLatestFrom(Driver.combineLatest(start, stop))
            .do(onNext: { start, stop in
                let usedIds = store.state.segments?.compactMap { $0.id } ?? []
                let maxSegs = store.info.leds?.maxseg ?? 0
                let idsRange = (0..<maxSegs)

                let unusedIds = idsRange.filter { !usedIds.contains($0) }
                if let nextUnused = unusedIds.first {
                    let segment = Segment(
                        id: nextUnused,
                        start: Int(start),
                        stop: Int(stop),
                        len: stop - start,
                        group: 1,
                        spacing: 0,
                        on: true,
                        brightness: 255,
                        colors: [UIColor.red.intArray,
                                 UIColor.black.intArray,
                                 UIColor.black.intArray],
                        effect: 0,
                        speed: 128,
                        intensity: 128,
                        palette: 0,
                        selected: false,
                        reverse: false,
                        mirror: false
                    )

                    delegate.onNext(.addSegment(segment))
                }
            })
            .drive(onNext: { _ in navigator.toDeviceDetail() })
            .disposed(by: disposeBag)

        input.dismissTrigger
            .drive(onNext: { navigator.toDeviceDetail() })
            .disposed(by: disposeBag)

        return output
    }
}
