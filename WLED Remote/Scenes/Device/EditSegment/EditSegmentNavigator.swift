//
//  EditSegmentNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/22/21.
//

import UIKit

public protocol EditSegmentNavigator {
    func toDeviceDetail()
    func toSegmentSettings()
}

public class DefaultEditSegmentNavigator: EditSegmentNavigator {
    private let navigationController: UINavigationController
    private let services: UseCaseProvider

    public init(services: UseCaseProvider,
                navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.services = services
    }

    public func toDeviceDetail() {
        navigationController.dismiss(animated: true) {
        }
    }

    public func toSegmentSettings() {
    }
}
