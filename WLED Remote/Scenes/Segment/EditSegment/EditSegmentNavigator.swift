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
    func toSegmentSettings(delegate: PublishSubject<SegmentSettingsDelegate>, info: Info, settings: SegmentSettings)
}

struct DefaultEditSegmentNavigator: EditSegmentNavigator {
    unowned let services: UseCaseProvider
    unowned let navigationController: UINavigationController

    func toDeviceDetail() {
        navigationController.dismiss(animated: true)
    }

    func toSegmentSettings(delegate: PublishSubject<SegmentSettingsDelegate>, info: Info, settings: SegmentSettings) {
        if let topViewController = navigationController.topViewController?.presentedViewController {
            let navigator = DefaultSegmentSettingsNavigator(services: services,
                                                            viewController: topViewController)

            let viewModel = SegmentSettingsViewModel(navigator: navigator,
                                                     info: info,
                                                     segmentSettings: settings,
                                                     delegate: delegate)

            let viewController = SegmentSettingsViewController(viewModel: viewModel)
            let cardModalTransitionDelegate = CardModalTransitioningDelegate()
            viewController.transitioningDelegate = cardModalTransitionDelegate
            viewController.modalPresentationStyle = .custom

            topViewController.present(viewController, animated: true)
        }
    }
}
