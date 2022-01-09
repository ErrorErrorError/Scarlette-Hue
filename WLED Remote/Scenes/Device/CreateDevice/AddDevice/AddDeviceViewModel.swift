//
//  AddDeviceViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/21/21.
//

import RxSwift
import RxCocoa

class AddDeviceViewModel: ViewModelType {
    private let devicesRepository: DevicesUseCaseProtocol
    private let navigator: AddDeviceNavigator
    private let device: Device

    init(device: Device, devicesRepository: DevicesUseCaseProtocol, navigator: AddDeviceNavigator) {
        self.device = device
        self.devicesRepository = devicesRepository
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let exit = input.exitTrigger
            .do(onNext: navigator.toDevices)

        let name = input.name
            .skip(1)
            .startWith(self.device.name)

        let device = Driver.combineLatest(Driver.just(device), name) {
            Device(id: $0.id, name: $1.trimmingCharacters(in: .whitespacesAndNewlines), ip: $0.ip, port: $0.port, created: $0.created)
        }
        .startWith(self.device)

        let canSave = name
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            .map({ !$0.isEmpty })

        let saveDevice = Driver.combineLatest(device, input.saveTrigger, canSave)
            .filter({ $2 })
            .flatMapLatest {
                self.devicesRepository.save(device: $0.0)
                    .asDriverOnErrorJustComplete()
            }.do(onNext: navigator.toDevices)

        return Output(canSave: canSave, exit: exit, save: saveDevice, device: device)
    }
}

extension AddDeviceViewModel {
    struct Input {
        let saveTrigger: Driver<Void>
        let exitTrigger: Driver<Void>
        let name: Driver<String>
    }

    struct Output {
        let canSave: Driver<Bool>
        let exit: Driver<Void>
        let save: Driver<Void>
        let device: Driver<Device>
    }
}
