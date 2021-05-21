//
//  DevicesNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import UIKit
import ErrorErrorErrorUIKit

protocol DevicesNavigator {
    func toCreateDevice()
    func toDevice(_ device: Device)
    func toDevices()
}

class DefaultDevicesNavigator: DevicesNavigator {
    private let navigationController: UINavigationController
    private let services: UseCaseProvider

    init(services: UseCaseProvider,
         navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }

    func toDevices() {
        let viewController = DevicesViewController()
        viewController.viewModel = DevicesViewModel(useCase: services.makeDevicesUseCase(),
                                                    navigator: self)
        navigationController.pushViewController(viewController, animated: true)
    }

    func toCreateDevice() {
        guard let topViewController = navigationController.topViewController else { return }
        let navigator = DefaultDiscoverDeviceNavigator(navigationController: navigationController)
        let viewModel = DiscoverDeviceViewModel(createDeviceUseCase: services.makeDevicesUseCase(),
                                              navigator: navigator)
        let viewController = DiscoverDeviceViewController()
        let transitionDelegate = CardModalTransitioningDelegate(from: topViewController, to: viewController)
        viewController.viewModel = viewModel
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = transitionDelegate
        topViewController.present(viewController, animated: true)
    }

    func toDevice(_ device: Device) {
        let viewController = DeviceViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
}
