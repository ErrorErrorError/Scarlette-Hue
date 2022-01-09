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
    private let services: UseCaseProvider

    init(services: UseCaseProvider, navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }

    func toDevices() {
        navigationController.dismiss(animated: true)
    }

    func toAddDevice(_ device: Device) {
        if let presentingViewController = navigationController.topViewController?.presentedViewController {
            let navigator = AddDeviceNavigator(navigationController: navigationController)
            let viewModel = AddDeviceViewModel(device: device,
                                               devicesRepository: services.makeDevicesRepository(),
                                               navigator: navigator)
            let viewController = AddDeviceViewController(viewModel: viewModel)

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
