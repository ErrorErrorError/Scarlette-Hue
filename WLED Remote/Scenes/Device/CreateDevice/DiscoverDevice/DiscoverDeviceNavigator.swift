//
//  DiscoverDeviceNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import ErrorErrorErrorUIKit
import UIKit

public protocol DiscoverDeviceNavigatorType {
    func toDevices()
    func toConfigureDevice(_ device: Device)
    func toManuallyAddDevice()
}

struct DiscoverDeviceNavigator: DiscoverDeviceNavigatorType {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController

    func toDevices() {
        navigationController.dismiss(animated: true)
    }

    func toConfigureDevice(_ device: Device) {
        if let presentingViewController = navigationController.topViewController?.presentedViewController {
            let viewController: ConfigureDeviceViewController = assembler.resolve(navigationController: navigationController, device)
            presentingViewController.dismiss(animated: true) {
                let transitionDelegate = CardModalTransitioningDelegate()
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .custom
                viewController.transitioningDelegate = transitionDelegate
                navigationController.present(viewController, animated: true)
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
