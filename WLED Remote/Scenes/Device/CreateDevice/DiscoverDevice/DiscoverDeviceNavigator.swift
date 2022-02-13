//
//  CreateDeviceNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import ErrorErrorErrorUIKit
import UIKit

public protocol DiscoverDeviceNavigator {
    func toDevices()
    func toConfigureDevice(_ device: Device)
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

    func toConfigureDevice(_ device: Device) {
        if let presentingViewController = navigationController.topViewController?.presentedViewController {
            let navigator = ConfigureDeviceNavigator(navigationController: navigationController)
            let viewModel = ConfigureDeviceViewModel(devicesRepository: services.makeDevicesRepository(),
                                                    navigator: navigator,
                                                    device: device)
            let viewController = ConfigureDeviceViewController(viewModel: viewModel)

            presentingViewController.dismiss(animated: true) { [weak self] () in
                let transitionDelegate = CardModalTransitioningDelegate()
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .custom
                viewController.transitioningDelegate = transitionDelegate
                self?.navigationController.present(viewController, animated: true)
            }
            // TODO: Find a way to replace a view controller without reusing the parent view controller

//            UIView.transition(with: presentingViewController.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
//                presentingViewController.view.subviews.forEach { $0.removeFromSuperview() }
//                presentingViewController.view.addSubview(viewController.view)
//            }, completion: {_ in
//                presentingViewController.addChild(viewController)
//                viewController.didMove(toParent: presentingViewController)
//            })
        }
    }

    func toManuallyAddDevice() {
    }
}
