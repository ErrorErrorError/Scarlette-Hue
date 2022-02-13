//
//  SegmentSettingsNavigator.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/19/22.
//

import UIKit

protocol SegmentSettingsNavigator {
    func toEditSegment()
}

struct DefaultSegmentSettingsNavigator: SegmentSettingsNavigator {
    unowned let services: UseCaseProvider
    unowned let viewController: UIViewController

    func toEditSegment() {
        viewController.dismiss(animated: true)
    }
}
