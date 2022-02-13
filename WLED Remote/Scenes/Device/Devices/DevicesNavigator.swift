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
    func toDevices()
    func toDeviceDetail(_ device: Device, _ store: Store)
    func confirmDeleteDevice(_ device: Device) -> Driver<Void>
    func toEditDevice(_ device: Device)
}

struct DefaultDevicesNavigator: DevicesNavigator {
    unowned let services: UseCaseProvider
    unowned let navigationController: UINavigationController

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
        let transitionDelegate = CardModalTransitioningDelegate()
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = transitionDelegate
        topViewController.present(viewController, animated: true)
    }

    func toDeviceDetail(_ device: Device, _ store: Store) {
        let navigator = DefaultDeviceDetailNavigator(services: services,
                                                     navigationController: navigationController
        )

        let viewModel = DeviceDetailViewModel(navigator: navigator,
                                              deviceRepository: services.makeDevicesRepository(),
                                              storeAPI: services.makeStoreAPI(),
                                              segmentAPI: services.makeSegmentAPI(),
                                              device: device,
                                              store: store
        )

        let viewController = DeviceDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func toEditDevice(_ device: Device) {
        // TODO: Add option to edit device name, ect..
    }

    func confirmDeleteDevice(_ device: Device) -> Driver<Void> {
        return Observable<Void>.create({ (observer) -> Disposable in
            let alert = UIAlertController(
                title: "Delete device",
                message: "Are you sure you want to delete \(device.name)? You will not be able to retreive your scenes.",
                preferredStyle: .alert)

            let okAction = UIAlertAction(
                title: "Delete",
                style: .destructive) { _ in
                    observer.onNext(())
                    observer.onCompleted()
            }
            alert.addAction(okAction)
            
            let cancel = UIAlertAction(title: "Cancel",
                                       style: UIAlertAction.Style.cancel) { (_) in
                                        observer.onCompleted()
            }
            alert.addAction(cancel)
            
            self.navigationController.present(alert, animated: true, completion: nil)

            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        })
        .asDriverOnErrorJustComplete()
    }
}
