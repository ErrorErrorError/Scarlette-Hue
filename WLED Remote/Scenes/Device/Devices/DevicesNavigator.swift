//
//  DevicesNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import UIKit
import ErrorErrorErrorUIKit
import RxSwift
import RxCocoa

protocol DevicesNavigator {
    func toDiscoverDevice()
    func toDevice(_ device: Device, _ deviceStore: Store) -> Driver<EditDeviceDelegate>
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
                                         heartbeatService: services.makeHeartbeatService(),
                                         storeAPI: services.makeStoreAPI(),
                                         navigator: self)
        let viewController = DevicesViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    func toDiscoverDevice() {
        guard let topViewController = navigationController.topViewController else { return }
        let navigator = DefaultDiscoverDeviceNavigator(services: services,
                                                       navigationController: navigationController)
        let viewModel = DiscoverDeviceViewModel(navigator: navigator,
                                                devicesRepository: services.makeDevicesRepository(),
                                                bonjourService: services.makeBonjourService(),
                                                infoAPIService: services.makeInfoNetwork())

        let viewController = DiscoverDeviceViewController(viewModel: viewModel)
        let transitionDelegate = CardModalTransitioningDelegate(from: topViewController, to: viewController)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = transitionDelegate
        topViewController.present(viewController, animated: true)
    }

    func toDevice(_ device: Device, _ store: Store) -> Driver<EditDeviceDelegate> {
        let delegate = PublishSubject<EditDeviceDelegate>()

        let navigator = DefaultDeviceNavigator(services: services,
                                               navigationController: navigationController)

        let viewModel = EditDeviceViewModel(navigator: navigator,
                                        deviceRepository: services.makeDevicesRepository(),
                                        deviceStoreAPI: services.makeStoreAPI(),
                                        device: device,
                                        store: store,
                                        delegate: delegate)
        let viewController = EditDeviceViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)

        return delegate.asDriverOnErrorJustComplete()
    }
}
