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

public struct DeviceDetailViewModel {
    let navigator: DeviceDetailNavigator
    let deviceRepository: DeviceRepositoryType
    let storeAPI: StoreAPI
    let segmentAPI: SegmentAPI
    let device: Device
    let store: Store
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
        let output = Output(deviceName: device.name)

        // MARK: Latest Store Data

        let storeSubject = BehaviorRelay<Store>(value: store)
        let updatedStoreSubject = PublishSubject<Void>()

        let latestStore = Driver.merge(
            input.loadTrigger.map { store },
            updatedStoreSubject
                .asDriverOnErrorJustComplete()
                .withLatestFrom(storeSubject.asDriver())
        )

        //MARK: Segment Delegate

        let segmentDelegate = PublishSubject<EditSegmentDelegate>()

        // Handle Segment data manipulation and update store

        segmentDelegate
            .asDriverOnErrorJustComplete()
            .do(onNext: { delegate in
                switch delegate {
                case .updatedSegment(let newSegment):
                    handleUpdateSegment(newSegment: newSegment,
                                        storeSubject: storeSubject,
                                        updatedStoreSubject: updatedStoreSubject)
                case .addSegment(let segment):
                    handleAddSegment(segment: segment,
                                     storeSubject: storeSubject,
                                     updatedStoreSubject: updatedStoreSubject)
                case .deleteSegment(let segment):
                    handleDeleteSegment(segment: segment,
                                        storeSubject: storeSubject,
                                        updatedStoreSubject: updatedStoreSubject)
                }
            })
            .flatMapLatest({ editSegmentDelegate -> Driver<Void> in
                switch editSegmentDelegate {
                case .updatedSegment(let segment):
                    return segmentAPI.updateSegment(device: device, segment: segment)
                        .asDriverOnErrorJustComplete()
                        .mapToVoid()
                case .addSegment(let segment):
                    return segmentAPI.addSegment(device: device, segment: segment)
                        .asDriverOnErrorJustComplete()
                        .mapToVoid()
                case .deleteSegment(let segment):
                    return segmentAPI.deleteSegment(device: device, segment: segment)
                        .asDriverOnErrorJustComplete()
                        .mapToVoid()
                }
            })
            .drive()
            .disposed(by: disposeBag)

        latestStore
            .map {
                $0.state.segments.map { SegmentItemViewModel(segment: $0, delegate: segmentDelegate) }
            }
            .drive(output.$segments)
            .disposed(by: disposeBag)

        // MARK: On

        latestStore
            .map { $0.state.on ?? false }
            .drive(output.$on)
            .disposed(by: disposeBag)

        // MARK: Brightness

        latestStore
            .map { Float($0.state.bri ?? 1) }
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

        // MARK: State updated and store needs to be updated

        Driver.combineLatest(
            updatedOn,
            updatedBrightness
        )
        .skip(1)
        .map { (on, brightness) in
            State(
                on: on,
                bri: UInt8(brightness)
            )
        }
        .do(onNext: { newState in
            handleUpdatedState(newState: newState,
                                storeSubject: storeSubject,
                                updatedStoreSubject: updatedStoreSubject)
        })
        .flatMapLatest {
            storeAPI.updateState(device: device, state: $0)
                .asDriverOnErrorJustComplete()
        }
        .drive()
        .disposed(by: disposeBag)

        // MARK: Handle more clicked

        input.moreTrigger
            .drive()
            .disposed(by: disposeBag)

        // MARK: Handle segment selected

        select(trigger: input.selectedSegment, items: output.$segments.asDriver())
            .drive(onNext: { navigator.toSegmentDetails(delegate: segmentDelegate,
                                                        device: device,
                                                        store: storeSubject.value,
                                                        segment: $0.segment) })
            .disposed(by: disposeBag)

        // MARK: Handle add segment trigger

        input.addSegmentTrigger
            .drive(onNext: { navigator.toAddSegment(delegate: segmentDelegate,
                                                    device: device,
                                                    store: storeSubject.value) })
            .disposed(by: disposeBag)

        // MARK: Handle delete segment

        select(trigger: input.deleteSegment, items: output.$segments.asDriver())
            .filter({ $0.identity != -1 })
            .map { $0.segment }
            .flatMapLatest { segment in
                navigator.confirmDeleteSegment(segment: segment)
                    .map { segment }
            }
            .map { Segment(id: $0.id, stop: 0) }
            .drive(onNext: { segmentDelegate.onNext(.deleteSegment($0)) })
            .disposed(by: disposeBag)
        
        return output
    }
}

// Segment Edits

extension DeviceDetailViewModel {
    func handleUpdatedState(newState: State, storeSubject: BehaviorRelay<Store>, updatedStoreSubject: PublishSubject<Void>) {
        let updatedState = storeSubject.value.state.with {
            $0.on = newState.on
            $0.bri = newState.bri
        }

        let updatedStore = storeSubject.value.with {
            $0.state = updatedState
        }

        storeSubject.accept(updatedStore)
        updatedStoreSubject.onNext(())
    }

    func handleAddSegment(segment: Segment, storeSubject: BehaviorRelay<Store>, updatedStoreSubject: PublishSubject<Void>) {
        let store = storeSubject.value

        let updatedSegments = store.state.segments.with {
            $0.append(segment)
            $0.sort(by: { $0.id < $1.id })
        }

        let updatedState = store.state.with {
            $0.segments = updatedSegments
        }

        let updatedStore = store.with {
            $0.state = updatedState
        }

        storeSubject.accept(updatedStore)
        updatedStoreSubject.onNext(())
    }

    func handleDeleteSegment(segment: Segment, storeSubject: BehaviorRelay<Store>, updatedStoreSubject: PublishSubject<Void>) {
        let store = storeSubject.value

        let updatedSegments = store.state.segments.with { segments in
            segments.removeAll(where: { $0.id == segment.id })
        }

        let updatedState = store.state.with {
            $0.segments = updatedSegments
        }

        let updatedStore = store.with {
            $0.state = updatedState
        }

        storeSubject.accept(updatedStore)
        updatedStoreSubject.onNext(())
    }

    func handleUpdateSegment(newSegment: Segment, storeSubject: BehaviorRelay<Store>, updatedStoreSubject: PublishSubject<Void>) {
        let store = storeSubject.value

        let updatedSegments = store.state.segments.with { segments in
            if let index = segments.firstIndex(where: { $0.id == newSegment.id }) {
                let updatedSegment = segments[index].with {
                    $0.copy(with: newSegment)
                }

                segments[index] = updatedSegment
            }
        }

        let updatedState = store.state.with {
            $0.segments = updatedSegments
        }

        let updatedStore = store.with {
            $0.state = updatedState
        }

        storeSubject.accept(updatedStore)
        updatedStoreSubject.onNext(())
    }
}
