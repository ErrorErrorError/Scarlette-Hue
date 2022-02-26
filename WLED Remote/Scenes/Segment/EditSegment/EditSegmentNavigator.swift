//
//  EditSegmentNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/22/21.
//

import UIKit
import ErrorErrorErrorUIKit
import RxSwift
import WLEDClient

protocol EditSegmentNavigatorType {
    func toDeviceDetail()
    func toSegmentSettings(delegate: PublishSubject<SegmentSettingsDelegate>, info: Info, settings: SegmentSettings)
    func toEffectSettings(delegate: PublishSubject<EffectSettingsDelegate>, settings: EffectSettings)
}

struct EditSegmentNavigator: EditSegmentNavigatorType {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController

    func toDeviceDetail() {
        navigationController.dismiss(animated: true)
    }

    func toSegmentSettings(delegate: PublishSubject<SegmentSettingsDelegate>, info: Info, settings: SegmentSettings) {
        if let topViewController = navigationController.topViewController?.presentedViewController {
            let viewController: SegmentSettingsViewController = assembler.resolve(
                viewController: topViewController,
                delegate: delegate,
                segmentSettings: settings,
                info: info
            )
            let cardModalTransitionDelegate = CardModalTransitioningDelegate()
            viewController.transitioningDelegate = cardModalTransitionDelegate
            viewController.modalPresentationStyle = .custom

            topViewController.present(viewController, animated: true)
        }
    }

    func toEffectSettings(delegate: PublishSubject<EffectSettingsDelegate>, settings: EffectSettings) {
        if let topViewController = navigationController.topViewController?.presentedViewController {
            let viewController: EffectSettingsViewController = assembler.resolve(
                viewController: topViewController,
                delegate: delegate,
                effectSettings: settings
            )

            let cardModalTransitionDelegate = CardModalTransitioningDelegate()
            viewController.transitioningDelegate = cardModalTransitionDelegate
            viewController.modalPresentationStyle = .custom

            topViewController.present(viewController, animated: true)
        }
    }
}
