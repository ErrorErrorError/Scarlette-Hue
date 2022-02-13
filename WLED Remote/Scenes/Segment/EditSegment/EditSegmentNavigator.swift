//
//  EditSegmentNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/22/21.
//

import UIKit
import ErrorErrorErrorUIKit
import RxSwift

protocol EditSegmentNavigator {
    func toDeviceDetail()
    func toSegmentSettings(delegate: PublishSubject<EditSegmentDelegate>, device: Device, info: Info, segment: Segment)
}

struct DefaultEditSegmentNavigator: EditSegmentNavigator {
    unowned let services: UseCaseProvider
    unowned let navigationController: UINavigationController

    func toDeviceDetail() {
        navigationController.dismiss(animated: true)
    }

    func toSegmentSettings(delegate: PublishSubject<EditSegmentDelegate>, device: Device, info: Info, segment: Segment) {
        if let topViewController = navigationController.topViewController?.presentedViewController {
            let navigator = DefaultSegmentSettingsNavigator(services: services,
                                                            viewController: topViewController)

            let viewModel = SegmentSettingsViewModel(navigator: navigator,
                                                     device: device,
                                                     info: info,
                                                     segment: segment,
                                                     delegate: delegate)

            let viewController = SegmentSettingsViewController(viewModel: viewModel)
            let cardModalTransitionDelegate = CardModalTransitioningDelegate()
            viewController.transitioningDelegate = cardModalTransitionDelegate
            viewController.modalPresentationStyle = .custom

            topViewController.present(viewController, animated: true)
        }
    }
}
