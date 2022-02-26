//
//  DeviceDetailViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/22/21.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import WLEDClient

public struct DeviceDetailViewModel {
    let navigator: DeviceDetailNavigatorType
    let useCase: DeviceDetailUseCaseType
    let deviceStore: DeviceStore
}

extension DeviceDetailViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let moreTrigger: Driver<Void>
        let on: Driver<Bool>
        let brightness: Driver<Float>
        let addSegmentTrigger: Driver<Void>
        let selectedSegment: Driver<IndexPath>
        let deleteSegment: Driver<IndexPath>
    }

    struct Output {
        @Relay var deviceName: String = ""
        @Relay var on: Bool = false
        @Relay var brightness: Float = 0.0
        @Relay var segments = [SegmentItemViewModel]()
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output(deviceName: deviceStore.device.name)

        let storeObservable = deviceStore.wledDevice.storeObservable
            .asDriverOnErrorJustComplete()

        //MARK: - Segment Delegate

        let segmentDelegate = PublishSubject<EditSegmentDelegate>()

        // MARK: - Handle Segment data manipulation and update store

        segmentDelegate
            .flatMapLatest({ editSegmentDelegate -> Driver<Void> in
                switch editSegmentDelegate {
                case .updatedSegment(let segment):
                    return deviceStore.wledDevice.updateSegment(segment: segment)
                        .asDriverOnErrorJustComplete()
                case .addSegment(let segment):
                    return deviceStore.wledDevice.addSegment(segment: segment)
                        .asDriverOnErrorJustComplete()
                case .deleteSegment(let segment):
                    return deviceStore.wledDevice.removeSegment(segment: segment)
                        .asDriverOnErrorJustComplete()
                }
            })
            .asDriverOnErrorJustComplete()
            .drive()
            .disposed(by: disposeBag)

        // MARK: Observe segment changes and output

        storeObservable
            .map {
                $0?.state.segments?.map { SegmentItemViewModel(segment: $0, delegate: segmentDelegate) } ?? []
            }
            .drive(output.$segments)
            .disposed(by: disposeBag)

        // MARK: Set On State

        storeObservable
            .compactMap { $0?.state.on }
            .drive(output.$on)
            .disposed(by: disposeBag)

        // MARK: Set Brightness State

        storeObservable
            .compactMap { $0?.state.bri }
            .map { Float($0) }
            .drive(output.$brightness)
            .disposed(by: disposeBag)

        // MARK: On input changed

        let updatedOn = Driver.merge(
            input.on,
            input.loadTrigger.map { output.on }
        )

        // MARK: Brightness changed

        let updatedBrightness = Driver.merge(
            input.brightness,
            input.loadTrigger.map { output.brightness }
        )
        .debounce(.milliseconds(200))

        Driver.combineLatest(updatedOn, updatedBrightness)
            .map { State(on: $0, bri: UInt8($1)) }
            .flatMapLatest {
                deviceStore.wledDevice.updateState(state: $0)
                    .asDriverOnErrorJustComplete()
            }
            .skip(1)
            .drive()
            .disposed(by: disposeBag)

        // MARK: Handle more clicked

        input.moreTrigger
            .drive()
            .disposed(by: disposeBag)

        // MARK: Handle segment selected

        select(trigger: input.selectedSegment, items: output.$segments.asDriver())
            .withLatestFrom(storeObservable, resultSelector: { segmentViewModel, store in
                (segmentViewModel.segment, store)
            })
            .filter { $0.1 != nil }
            .drive(onNext: { (segment, store) in
                navigator.toEditSegment(
                    delegate: segmentDelegate,
                    device: deviceStore.device,
                    segment: segment,
                    store: store!
                )
            })
            .disposed(by: disposeBag)

        // MARK: Handle add segment trigger

        input.addSegmentTrigger
            .withLatestFrom(storeObservable)
            .compactMap { $0 }
            .drive(onNext: {
                navigator.toAddSegment(
                    delegate: segmentDelegate,
                    store: $0
                )
            })
            .disposed(by: disposeBag)

        // MARK: Handle delete segment

        select(trigger: input.deleteSegment, items: output.$segments.asDriver())
            .filter({ $0.identity != -1 })
            .map { $0.segment }
            .flatMapLatest { segment in
                navigator.confirmDeleteSegment(segment: segment)
                    .map { segment }
            }
            .drive(onNext: { segmentDelegate.onNext(.deleteSegment($0)) })
            .disposed(by: disposeBag)
        
        return output
    }
}
