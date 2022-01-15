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

struct DeviceItemViewModel {
    let device: Device
    let storeAPI: StoreAPI
    let heartbeatService: HeartbeatService
    let storeSubject = BehaviorRelay<Store?>(value: nil)

    // Properties

    var name: String {
        return device.name
    }
}

extension DeviceItemViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let on: Driver<Bool>
    }

    struct Output {
        @Relay var store: Store?
        @Relay var connection = HeartbeatConnection.ConnectionState.connecting
    }

    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()

        let heartbeat = heartbeatService.getHeartbeat(device: device)

        let connectionState = heartbeat.connection
            .distinctUntilChanged()

        // Connection State

        connectionState
            .asDriver(onErrorJustReturn: .unknown)
            .drive(output.$connection)
            .disposed(by: disposeBag)

        // Fetch Store on connection = .connected

        connectionState
            .flatMapLatest { state -> Observable<Store?> in
                if state == .connected {
                    return self.storeAPI.fetchStore(for: self.device)
                        .map { store -> Store? in store }
                } else {
                    return Observable.just(nil)
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
