//
//  EffectSettingsNavigator.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/25/22.
//

import UIKit

protocol EffectSettingsNavigatorType {
    func toEditSegment()
}

struct EffectSettingsNavigator: EffectSettingsNavigatorType {
    unowned let assembler: Assembler
    unowned let viewController: UIViewController

    func toEditSegment() {
        viewController.dismiss(animated: true, completion: nil)
    }
}
