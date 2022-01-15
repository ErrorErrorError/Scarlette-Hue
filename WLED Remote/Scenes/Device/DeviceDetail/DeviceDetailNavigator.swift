//
//  DevicDetaileNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/22/21.
//

import UIKit
import RxSwift

public protocol DeviceDetailNavigator {
    func toDevices()
    func toDeviceInfo()
    func toDeviceSettings()
    func toDeviceEffects()
    func toSegmentDetails(delegate: PublishSubject<EditSegmentDelegate>, device: Device, store: Store, segment: Segment)
}

public class DefaultDeviceDetailNavigator: DeviceDetailNavigator {    
    private let navigationController: UINavigationController
    private let services: UseCaseProvider

    public init(services: UseCaseProvider,
                navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.services = services
    }

    public func toDevices() {
        self.navigationController.popToRootViewController(animated: true)
    }

    public func toDeviceInfo() {
    }

    public func toDeviceSettings() {
    }

    public func toDeviceEffects() {
    }

    public func toSegmentDetails(delegate: PublishSubject<EditSegmentDelegate>, device: Device, store: Store, segment: Segment) {
        let navigator = DefaultEditSegmentNavigator(services: services,
                                                    navigationController: navigationController)

        let viewModel = EditSegmentViewModel(navigator: navigator,
                                             deviceRepository: services.makeDevicesRepository(),
                                             segmentAPI: services.makeSegmentAPI(),
                                             device: device,
                                             segment: segment,
                                             store: store,
                                             delegate: delegate
        )

        let viewController = EditSegmentViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .fullScreen
        navigationController.present(viewController, animated: true)
    }
}
