//
//  AddSegmentNavigatorType.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/15/22.
//

import UIKit

public protocol AddSegmentNavigatorType {
    func toDeviceDetail()
}

struct AddSegmentNavigator: AddSegmentNavigatorType {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController

    func toDeviceDetail() {
        navigationController.dismiss(animated: true)
    }
}
