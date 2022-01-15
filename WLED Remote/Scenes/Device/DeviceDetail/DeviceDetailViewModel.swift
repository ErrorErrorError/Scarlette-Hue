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
    let deviceRepository: DevicesUseCaseProtocol
    let storeAPI: StoreAPI
    let segmentAPI: SegmentAPI
    let device: Device
    let store: Store
}

extension DeviceDetailViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let moreTrigger: Driver<Void>
        let on: Driver<Bool>
        let brightness: Driver<Float>
        let selectedSegment: Driver<IndexPath>
    }

    struct Output {
        @Relay var deviceName: String = ""
        @Relay var on: Bool = false
        @Relay var brightness: Float = 0.0
        @Relay var segments = [SegmentItemViewModel]()
    }

    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output(deviceName: device.name)

        // Latest Store

        let storeSubject = BehaviorRelay<Store>(value: store)
        let updatedStoreSubject = PublishSubject<Void>()

        let latestStore = Driver.merge(
            Driver.just(store),
            updatedStoreSubject
                .asDriverOnErrorJustComplete()
                .withLatestFrom(storeSubject.asDriver())
        )

        // Segment

        let segmentDelegate = PublishSubject<EditSegmentDelegate>()

        // Handle Segment data changed and update store

        segmentDelegate
            .asDriverOnErrorJustComplete()
            .do(onNext: { delegate in
                switch delegate {
                case .updatedSegment(let newSegment):
                    let store = storeSubject.value

                    let updatedSegments = store.state.segments.with {
                        if let index = $0.firstIndex(where: { $0.id == newSegment.id && $0.id != nil }) {
                            let updatedSegment = $0[index].with {
                                $0.id = newSegment.id

                                // We want to only copy non null values from the new segment

                                if let on = newSegment.on {
                                    $0.on = on
                                }

                                if let brightness = newSegment.brightness {
                                    $0.brightness = brightness
                                }

                                if let colors = newSegment.colors {
                                    $0.colors = colors
                                }

                                if let effect = newSegment.effect {
                                    $0.effect = effect
                                }

                                if let palette = newSegment.palette {
                                    $0.palette = palette
                                }
                            }

                            $0[index] = updatedSegment
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
            })
            .flatMapLatest({ editSegmentDelegate -> Driver<Void> in
                switch editSegmentDelegate {
                case .updatedSegment(let newSegment):
                    return segmentAPI.updateSegment(device: device, segment: newSegment)
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

        // On

        latestStore
            .map { $0.state.on ?? false }
            .drive(output.$on)
            .disposed(by: disposeBag)

        // Brightness

        latestStore
            .map { Float($0.state.bri ?? 1) }
            .drive(output.$brightness)
            .disposed(by: disposeBag)

        // State On

        let updatedOn = Driver.merge(
            input.on,
            input.loadTrigger.map { output.on }
        )

        // State brightness

        let updatedBrightness = Driver.merge(
            input.brightness,
            input.loadTrigger.map { output.brightness }
        )
        .debounce(.milliseconds(200))

        // State updated and data needs to be updated

        let updateState = Driver.combineLatest(
            updatedOn,
            updatedBrightness
        )
        .map { (on, brightness) in
            State(
                on: on,
                bri: UInt8(brightness)
            )
        }
        .do(onNext: { newState in
            let updatedState = storeSubject.value.state.with {
                $0.on = newState.on
                $0.bri = newState.bri
            }

            let updatedStore = storeSubject.value.with {
                $0.state = updatedState
            }

            storeSubject.accept(updatedStore)
            updatedStoreSubject.onNext(())
        })
        .flatMapLatest {
            storeAPI.updateState(device: device, state: $0)
                .asDriverOnErrorJustComplete()
        }

        updateState
            .drive()
            .disposed(by: disposeBag)

        input.moreTrigger
            .drive()
            .disposed(by: disposeBag)

        select(trigger: input.selectedSegment, items: output.$segments.asDriver())
            .drive(onNext: { navigator.toSegmentDetails(delegate: segmentDelegate,
                                                        device: device,
                                                        store: storeSubject.value,
                                                        segment: $0.segment) })
            .disposed(by: disposeBag)

        return output
    }
}
