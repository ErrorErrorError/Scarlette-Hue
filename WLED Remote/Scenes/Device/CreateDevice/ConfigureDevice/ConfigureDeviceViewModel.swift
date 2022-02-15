//
//  ConfigureDeviceViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/21/21.
//

import Foundation
import RxSwift
import RxCocoa
import Then

struct ConfigureDeviceViewModel {
    let devicesRepository: DevicesUseCaseProtocol
    let navigator: ConfigureDeviceNavigator
    let device: Device
}

extension ConfigureDeviceViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let saveTrigger: Driver<Void>
        let exitTrigger: Driver<Void>
        let name: Driver<String>
    }

    struct Output {
        @Relay var canSave = true
        @Relay var name: String
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output(name: device.name)

        let name = Driver.merge(
            input.name,
            input.loadTrigger.map { device.name }
        )

        let nameValidation = Driver.combineLatest(name, devicesRepository.devices().asDriverOnErrorJustComplete())
            .map({ name, devices in
                !name.isEmpty && !devices.contains(where: { $0.name == name })
            })
            .do(onNext: {
                output.canSave = $0
            })

        input.saveTrigger
            .withLatestFrom(nameValidation)
            .filter { $0 }
            .withLatestFrom(name)
            .flatMapLatest({ name in
                let device = device.with {
                    $0.name = name
                }

                return devicesRepository.save(device: device)
                    .asDriverOnErrorJustComplete()
            })
            .do(onNext: navigator.toDevices)
            .drive()
            .disposed(by: disposeBag)

        input.exitTrigger
            .do(onNext: navigator.toDevices)
            .drive()
            .disposed(by: disposeBag)

        return output
    }
}
