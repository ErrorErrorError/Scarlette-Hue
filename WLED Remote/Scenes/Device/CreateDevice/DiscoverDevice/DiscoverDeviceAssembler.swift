//
//  DiscoverDeviceAssembler.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/16/22.
//

import UIKit

protocol DiscoverDeviceAssembler {
    func resolve(navigationController: UINavigationController) -> DiscoverDeviceViewController
    func resolve(navigationController: UINavigationController) -> DiscoverDeviceViewModel
    func resolve(navigationController: UINavigationController) -> DiscoverDeviceNavigatorType
    func resolve() -> DiscoverDeviceUseCaseType
}

extension DiscoverDeviceAssembler {
    func resolve(navigationController: UINavigationController) -> DiscoverDeviceViewController {
        let vc = DiscoverDeviceViewController()
        let vm: DiscoverDeviceViewModel = resolve(navigationController: navigationController)
        vc.bindViewModel(to: vm)
        return vc
    }

    func resolve(navigationController: UINavigationController) -> DiscoverDeviceViewModel {
        return DiscoverDeviceViewModel(
            navigator: resolve(navigationController: navigationController),
            useCase: resolve()
        )
    }
}

extension DiscoverDeviceAssembler where Self: DefaultAssembler {
    func resolve(navigationController: UINavigationController) -> DiscoverDeviceNavigatorType {
        return DiscoverDeviceNavigator(
            assembler: self,
            navigationController: navigationController
        )
    }

    func resolve() -> DiscoverDeviceUseCaseType {
        return DiscoverDeviceUseCase(
            deviceGatewayType: resolve()
        )
    }
}
