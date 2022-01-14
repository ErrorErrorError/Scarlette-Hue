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

final class DeviceItemViewModel {

    // MARK: Network Service

    private let deviceStoreAPI: StoreAPI
    private let heartbeatService: HeartbeatService

    // Properties

    var name: String {
        return device.name
    }

    private(set) var device: Device
    var store: Store?

    // MARK: Rx

    init(with device: Device, storeAPI: StoreAPI, heartbeatService: HeartbeatService) {
        self.deviceStoreAPI = storeAPI
        self.heartbeatService = heartbeatService
        self.device = device
    }
}

extension DeviceItemViewModel: ViewModelType {
    struct Input {
        let heartbeatTrigger: Driver<Void>
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
                    return self.deviceStoreAPI.fetchStore(for: self.device)
                        .map { store -> Store? in store }
                } else {
                    return Observable.just(nil)
                }
            }
            .asDriver(onErrorJustReturn: nil)
            .drive(output.$store)
            .disposed(by: disposeBag)

        // Set store property to the view model so that we pass down to other view models

        output.$store
            .do(onNext: { self.store = $0 })
            .subscribe()
            .disposed(by: disposeBag)

        input.on
            .do(onNext: { newOn in
                let updatedStore = output.store?.with({
                    $0.state.on = newOn
                })
                output.$store.accept(updatedStore)
            })
            .map({ State(on: $0) })
            .flatMapLatest({
                self.deviceStoreAPI.updateState(device: self.device, state: $0)
                    .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                    .asDriverOnErrorJustComplete()
            })
            .drive()
            .disposed(by: disposeBag)

        return output
    }
}
