//
//  SettingsViewModel.swift
//  WLED Hue
//
//  Created by Erik Bautista on 5/29/21.
//

import Foundation
import RxSwift

class SettingsViewModel: ViewModel {
    let devicesRepository: DeviceGatewayType
    let navigator: SettingsNavigator

    init(devicesRepository: DeviceGatewayType, navigator: SettingsNavigator) {
        self.devicesRepository = devicesRepository
        self.navigator = navigator
    }
}

extension SettingsViewModel {
    struct Input {

    }

    struct Output {

    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        return Output()
    }
}
