//
//  SettingsViewModel.swift
//  WLED Hue
//
//  Created by Erik Bautista on 5/29/21.
//

import Foundation
import RxSwift

class SettingsViewModel: ViewModelType {
    let devicesRepository: DevicesUseCaseProtocol
    let navigator: SettingsNavigator

    init(devicesRepository: DevicesUseCaseProtocol, navigator: SettingsNavigator) {
        self.devicesRepository = devicesRepository
        self.navigator = navigator
    }
}

extension SettingsViewModel {
    struct Input {

    }

    struct Output {

    }

    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        return Output()
    }
}
