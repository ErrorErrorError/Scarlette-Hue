//
//  ConfigureDeviceAssembler.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/16/22.
//

import UIKit

protocol ConfigureDeviceAssembler {
    func resolve(navigationController: UINavigationController, _ device: Device) -> ConfigureDeviceViewController
    func resolve(navigationController: UINavigationController, _ device: Device) -> ConfigureDeviceViewModel
    func resolve(navigationController: UINavigationController) -> ConfigureDeviceNavigatorType
    func resolve() -> ConfigureDeviceUseCaseType
}

extension ConfigureDeviceAssembler {
    func resolve(navigationController: UINavigationController, _ device: Device) -> ConfigureDeviceViewController {
        let vc = ConfigureDeviceViewController()
        let vm: ConfigureDeviceViewModel = resolve(navigationController: navigationController, device)
        vc.bindViewModel(to: vm)
        return vc
    }

    func resolve(navigationController: UINavigationController, _ device: Device) -> ConfigureDeviceViewModel {
        return ConfigureDeviceViewModel(
            navigator: resolve(navigationController: navigationController),
            useCase: resolve(),
            device: device
        )
    }
}

extension ConfigureDeviceAssembler where Self: DefaultAssembler {
    func resolve(navigationController: UINavigationController) -> ConfigureDeviceNavigatorType {
        return ConfigureDeviceNavigator(
            assembler: self,
            navigationController: navigationController
        )
    }

    func resolve() -> ConfigureDeviceUseCaseType {
        return ConfigureDeviceUseCase(
            deviceGatewayType: resolve()
        )
    }
}
