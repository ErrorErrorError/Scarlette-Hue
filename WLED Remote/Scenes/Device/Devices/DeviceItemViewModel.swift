//
//  DeviceItemViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import RxSwift
import RxCocoa
import Then
import Differentiator

struct DeviceItemViewModel {
    let device: Device
    let storeAPI: StoreAPI
    let heartbeatService: HeartbeatService
    let storeSubject = BehaviorRelay<Store?>(value: nil)
}

extension DeviceItemViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let on: Driver<Bool>
    }

    struct Output {
        @Relay var name = ""
        @Relay var store: Store?
        @Relay var connection = HeartbeatConnection.ConnectionState.connecting
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output(name: device.name)

        let heartbeat = heartbeatService.getHeartbeat(device: device)

        let updatedState = input.loadTrigger.flatMapLatest {
            heartbeat.connection.asDriver()
        }
        .distinctUntilChanged()

        // Connection State

        updatedState
            .asDriver()
            .drive(output.$connection)
            .disposed(by: disposeBag)

        // Fetch Store on connection = .connected

        updatedState
            .flatMapLatest { state -> Driver<Store?> in
                if state == .connected {
                    return self.storeAPI.fetchStore(for: self.device)
                        .map { $0 }
                        .asDriverOnErrorJustComplete()
                } else {
                    return Driver.just(nil)
                }
            }
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { storeSubject.accept($0) })
            .disposed(by: disposeBag)

        // Set store property to the view model so that we pass down to other view models

        input.on
            .do(onNext: { newOn in
                let updatedStore = storeSubject.value?.with {
                    $0.state.on = newOn
                }

                storeSubject.accept(updatedStore)
            })
            .map({ State(on: $0) })
            .flatMapLatest({
                self.storeAPI.updateState(device: self.device, state: $0)
                    .asDriverOnErrorJustComplete()
            })
            .drive()
            .disposed(by: disposeBag)

        storeSubject
            .asDriver()
            .drive(output.$store)
            .disposed(by: disposeBag)

        return output
    }
}

extension DeviceItemViewModel: IdentifiableType, Equatable {
    static func == (lhs: DeviceItemViewModel, rhs: DeviceItemViewModel) -> Bool {
        lhs.device == rhs.device && lhs.storeSubject.value == rhs.storeSubject.value
//        lhs.device == rhs.device
    }

    typealias Identity = UUID

    var identity: UUID {
        return device.id
    }
}
