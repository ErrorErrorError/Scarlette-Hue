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
    func toAddDevice()
    func toManuallyAddDevice()
}

final class DefaultDiscoverDeviceNavigator: DiscoverDeviceNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toDevices() {
        navigationController.dismiss(animated: true)
    }

    func toAddDevice() {
        if let presentingViewController = navigationController.topViewController?.presentedViewController {
            let addDeviceViewController = AddDeviceViewController()
            UIView.transition(with: presentingViewController.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                presentingViewController.view.subviews.forEach { $0.removeFromSuperview() }
                presentingViewController.view.addSubview(addDeviceViewController.view)
            }, completion: {_ in
                presentingViewController.addChild(addDeviceViewController)
                addDeviceViewController.didMove(toParent: presentingViewController)
            })
        }
    }

    func toManuallyAddDevice() {
    }
}
