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

protocol DeviceItemUpdateState {
    func updateOn(isOn: Bool, for device: Device)
    func updateBrightness(brightness: Int, for device: Device)
}

struct DeviceItemViewModel {
    let deviceStore: DeviceStoreModel
}

extension DeviceItemViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let on: Driver<Bool>
    }

    struct Output {
        @Relay var name: String
        @Relay var store: Store?
        @Relay var connection = HeartbeatConnection.ConnectionState.connecting
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output(name: deviceStore.device.name, store: deviceStore.store, connection: deviceStore.connectionState)

        // Set store property to the view model so that we pass down to other view models

        input.on
            .drive(onNext: {
                output.store?.state.on = $0
            })
            .disposed(by: disposeBag)

//        input.on
//            .do(onNext: { newOn in
//                let updatedStore = storeSubject.value?.with {
//                    $0.state.on = newOn
//                }
//
//                storeSubject.accept(updatedStore)
//            })
//            .map({ State(on: $0) })
//            .flatMapLatest({
//                self.storeAPI.updateState(device: self.device, state: $0)
//                    .asDriverOnErrorJustComplete()
//            })
//            .drive()
//            .disposed(by: disposeBag)

//        storeSubject
//            .asDriver()
//            .drive(output.$store)
//            .disposed(by: disposeBag)

        return output
    }
}

extension DeviceItemViewModel: IdentifiableType, Equatable {
    static func == (lhs: DeviceItemViewModel, rhs: DeviceItemViewModel) -> Bool {
        lhs.deviceStore == rhs.deviceStore
    }

    typealias Identity = UUID

    var identity: UUID {
        return deviceStore.device.id
    }
}
