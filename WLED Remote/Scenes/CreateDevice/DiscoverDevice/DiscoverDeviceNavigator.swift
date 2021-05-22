//
//  CreateDeviceNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import UIKit

protocol DiscoverDeviceNavigator {
    func toDevices()
    func toAddDevice(_ device: Device)
    func toManuallyAddDevice()
}

final class DefaultDiscoverDeviceNavigator: DiscoverDeviceNavigator {
    private let navigationController: UINavigationController
    private let createDevicesUseCase: DevicesUseCaseProtocol

    init(createDevicesUseCase: DevicesUseCaseProtocol, navigationController: UINavigationController) {
        self.createDevicesUseCase = createDevicesUseCase
        self.navigationController = navigationController
    }

    func toDevices() {
        navigationController.dismiss(animated: true)
    }

    func toAddDevice(_ device: Device) {
        if let presentingViewController = navigationController.topViewController?.presentedViewController {
            let navigator = AddDeviceNavigator(navigationController: navigationController)
            let viewController = AddDeviceViewController()
            let viewModel = AddDeviceViewModel(device: device,
                                               devicesRepository: createDevicesUseCase,
                                               navigator: navigator)
            viewController.viewModel = viewModel

            UIView.transition(with: presentingViewController.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                presentingViewController.view.subviews.forEach { $0.removeFromSuperview() }
                presentingViewController.view.addSubview(viewController.view)
            }, completion: {_ in
                presentingViewController.addChild(viewController)
                viewController.didMove(toParent: presentingViewController)
            })
        }
    }

    func toManuallyAddDevice() {
    }
}
