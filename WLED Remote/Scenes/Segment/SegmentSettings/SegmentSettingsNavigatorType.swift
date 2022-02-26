//
//  SegmentSettingsNavigator.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/19/22.
//

import UIKit

protocol SegmentSettingsNavigatorType {
    func toEditSegment()
}

struct SegmentSettingsNavigator: SegmentSettingsNavigatorType {
    unowned let assembler: Assembler
    unowned let viewController: UIViewController

    func toEditSegment() {
        viewController.dismiss(animated: true)
    }
}
