//
//  DeviceDetailAssembler.swift
//  WLEDClient
//
//  Created by Erik Bautista on 2/23/22.
//

import UIKit

protocol DeviceDetailAssembler {
    func resolve(navigationController: UINavigationController, deviceStore: DeviceStore) -> DeviceDetailViewController
    func resolve(navigationController: UINavigationController, deviceStore: DeviceStore) -> DeviceDetailViewModel
    func resolve(navigationController: UINavigationController) -> DeviceDetailNavigatorType
    func resolve() -> DeviceDetailUseCaseType
}

extension DeviceDetailAssembler {
    func resolve(navigationController: UINavigationController, deviceStore: DeviceStore) -> DeviceDetailViewController {
        let vc = DeviceDetailViewController()
        let vm: DeviceDetailViewModel = resolve(navigationController: navigationController, deviceStore: deviceStore)
        vc.bindViewModel(to: vm)
        return vc
    }
    
    func resolve(navigationController: UINavigationController, deviceStore: DeviceStore) -> DeviceDetailViewModel {
        return DeviceDetailViewModel(
            navigator: resolve(navigationController: navigationController),
            useCase: resolve(),
            deviceStore: deviceStore
        )
    }
}

extension DeviceDetailAssembler where Self: DefaultAssembler {
    func resolve(navigationController: UINavigationController) -> DeviceDetailNavigatorType {
        return DeviceDetailNavigator(
            assembler: self,
            navigationController: navigationController
        )
    }
    
    func resolve() -> DeviceDetailUseCaseType {
        return DeviceDetailUseCase()
    }
}
