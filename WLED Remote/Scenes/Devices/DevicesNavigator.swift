//
//  DevicesNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import UIKit
import ErrorErrorErrorUIKit

protocol DevicesNavigator {
    func toDiscoverDevice()
    func toDevice(_ device: Device, _ deviceData: DeviceStore)
    func toDevices()
}

class DefaultDevicesNavigator: DevicesNavigator {
    private let navigationController: UINavigationController
    private let services: UseCaseProvider

    init(services: UseCaseProvider,
         navigationController: UINavigationController) {
        self.services = services
        self.navigationController = navigationController
    }

    func toDevices() {
        let viewModel = DevicesViewModel(devicesRepository: services.makeDevicesRepository(),
                                                    deviceDataNetworkService: services.makeDeviceDataNetwork(),
                                                    navigator: self)
        let viewController = DevicesViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    func toDiscoverDevice() {
        guard let topViewController = navigationController.topViewController else { return }
        let navigator = DefaultDiscoverDeviceNavigator(services: services,
                                                       navigationController: navigationController)
        let viewModel = DiscoverDeviceViewModel(devicesRepository: services.makeDevicesRepository(),
                                                bonjourService: services.makeDevicesBonjourService(),
                                                stateNetworkService: services.makeStateNetwork(),
                                                navigator: navigator)
        let viewController = DiscoverDeviceViewController(viewModel: viewModel)
        let transitionDelegate = CardModalTransitioningDelegate(from: topViewController, to: viewController)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = transitionDelegate
        topViewController.present(viewController, animated: true)
    }

    func toDevice(_ device: Device, _ deviceData: DeviceStore) {
        let navigator = DefaultDeviceNavigator(services: services,
                                               navigationController: navigationController)
        let viewModel = DeviceViewModel(device: device,
                                        deviceData: deviceData,
                                        deviceDataNetworkService: services.makeDeviceDataNetwork(),
                                        deviceRepository: services.makeDevicesRepository(),
                                        navigator: navigator)
        let viewController = DeviceViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
