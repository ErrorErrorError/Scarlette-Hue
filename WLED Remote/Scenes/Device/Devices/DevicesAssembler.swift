//
//  DevicesAssembler.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/15/22.
//

import UIKit

protocol DevicesAssembler {
    func resolve(navigationController: UINavigationController) -> DevicesViewController
    func resolve(navigationController: UINavigationController) -> DevicesViewModel
    func resolve(navigationController: UINavigationController) -> DevicesNavigatorType
    func resolve() -> DevicesUseCaseType
}

extension DevicesAssembler {
    func resolve(navigationController: UINavigationController) -> DevicesViewController {
        let vc = DevicesViewController()
        let vm: DevicesViewModel = resolve(navigationController: navigationController)
        vc.bindViewModel(to: vm)
        return vc
    }
    
    func resolve(navigationController: UINavigationController) -> DevicesViewModel {
        return DevicesViewModel(
            navigator: resolve(navigationController: navigationController),
            useCase: resolve()
        )
    }
}

extension DevicesAssembler where Self: DefaultAssembler {
    func resolve(navigationController: UINavigationController) -> DevicesNavigatorType {
        return DevicesNavigator(
            assembler: self,
            navigationController: navigationController
        )
    }
    
    func resolve() -> DevicesUseCaseType {
        return DevicesUseCase(
            deviceGatewayType: resolve(),
            storeGatewayType: resolve()
        )
    }
}
