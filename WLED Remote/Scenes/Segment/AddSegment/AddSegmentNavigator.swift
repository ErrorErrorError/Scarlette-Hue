//
//  AddSegmentNavigator.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/15/22.
//

import UIKit

public protocol AddSegmentNavigator {
    func toDeviceDetail()
}

struct DefaultAddSegmentNavigator: AddSegmentNavigator {
    unowned let services: UseCaseProvider
    unowned let navigationController: UINavigationController

    func toDeviceDetail() {
        navigationController.dismiss(animated: true)
    }
}
