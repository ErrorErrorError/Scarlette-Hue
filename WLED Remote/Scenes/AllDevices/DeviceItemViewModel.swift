//
//  DeviceItemViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import RxSwift
import RxCocoa

final class DeviceItemViewModel {
    // MARK: Network Service
    private let deviceDataNetworkService: DeviceDataNetwork
    private let concurrentScheduler = ConcurrentDispatchQueueScheduler(qos: .background)

    let name: String
    let ip: String
    let device: Device

    // MARK: Rx
    var deviceDataRelay = BehaviorRelay<DeviceData?>(value: nil)
    private let connectionStateRelay = BehaviorRelay<String>(value: "")
    private let restartRelay = BehaviorRelay<Int>(value: 0)

    init(with device: Device, deviceDataNetworkService: DeviceDataNetwork) {
        self.deviceDataNetworkService = deviceDataNetworkService
        self.device = device
        self.name = device.name
        self.ip = device.ip
    }
}

extension DeviceItemViewModel: ViewModelType {
    struct Input {
        let heartbeat: Driver<Void>
        let brightness: Driver<Int>
        let on: Driver<Bool>
    }

    struct Output {
        let heartbeat: Driver<Void>
        let connection: Driver<String>
        let state: Driver<State?>
        let update: Driver<Bool>
    }

    func transform(input: Input) -> Output {
        let connectionNetworkObservable = deviceDataNetworkService.fetchDeviceData(device: device)
            .do(onNext: { [weak self] deviceData in
                self?.deviceDataRelay.accept(deviceData)
                self?.connectionStateRelay.accept("Connected")
            }, onError: { [weak self] error in
                if let self = self {
                    self.deviceDataRelay.accept(nil)
                    if error.asAFError?.isSessionTaskError == true {
                        self.connectionStateRelay.accept("Unreachable")
                    } else {
                        self.connectionStateRelay.accept("Reconnecting")
                    }
                    self.restartRelay.accept(self.restartRelay.value + 1)
                }
            }, onCompleted: { [weak self] in
                if let self = self {
                    self.restartRelay.accept(self.restartRelay.value + 1)
                }
            })
            .share()

        let heartbeat = connectionNetworkObservable
            .do(onSubscribe: { [weak self] in
                self?.deviceDataRelay.accept(nil)
                self?.connectionStateRelay.accept("Connecting")
            })
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let connection = connectionStateRelay
            .distinctUntilChanged()
            .asDriverOnErrorJustComplete()

        let state = deviceDataRelay
            .map({ $0?.state })
            .distinctUntilChanged()
            .asDriverOnErrorJustComplete()

        let updateOn = input.on
            .skip(1)
            .filter { _ in self.deviceDataRelay.value != nil }
            .map({ State(on: $0) })
            .do(onNext: { newState in
                if var deviceData = self.deviceDataRelay.value {
                    var state = deviceData.state
                    state.on = newState.on
                    deviceData.state = state
                    self.deviceDataRelay.accept(deviceData)
                }
            })
            .flatMapLatest({ self.deviceDataNetworkService.updateState(device: self.device, state: $0)
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .asDriverOnErrorJustComplete()
            })

        let updateBrightness = input.brightness
            .skip(1)
            .map({ State(bri: $0) })
            .filter { _ in self.deviceDataRelay.value != nil }
            .do(onNext: { newState in
                if var deviceData = self.deviceDataRelay.value {
                    var state = deviceData.state
                    state.bri = newState.bri
                    deviceData.state = state
                    self.deviceDataRelay.accept(deviceData)
                }
            })
            .flatMapLatest({ self.deviceDataNetworkService.updateState(device: self.device, state: $0)
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
                .asDriverOnErrorJustComplete()
            })

        let updated = Driver.merge(updateOn, updateBrightness)

        return Output(heartbeat: heartbeat, connection: connection, state: state, update: updated)
    }
}
