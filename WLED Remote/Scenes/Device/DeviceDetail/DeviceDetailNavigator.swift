//
//  DevicDetaileNavigator.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/22/21.
//

import UIKit
import RxSwift
import RxCocoa
import ErrorErrorErrorUIKit

public protocol DeviceDetailNavigator {
    func toDevices()
    func toSegmentDetails(delegate: PublishSubject<EditSegmentDelegate>, device: Device, store: Store, segment: Segment)
    func toAddSegment(delegate: PublishSubject<EditSegmentDelegate>, device: Device, store: Store)
    func confirmDeleteSegment(segment: Segment) -> Driver<Void>
}

public struct DefaultDeviceDetailNavigator: DeviceDetailNavigator {
    unowned let services: UseCaseProvider
    unowned let navigationController: UINavigationController

    public func toDevices() {
        self.navigationController.popToRootViewController(animated: true)
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
        let encapsulatingNavigationController = UINavigationController(rootViewController: viewController)
        encapsulatingNavigationController.modalPresentationStyle = .fullScreen

        navigationController.present(encapsulatingNavigationController, animated: true)
    }

    public func toAddSegment(delegate: PublishSubject<EditSegmentDelegate>, device: Device, store: Store) {
        guard let topViewController = navigationController.topViewController else { return }

        let navigator = DefaultAddSegmentNavigator(services: services,
                                                   navigationController: navigationController)

        let viewModel = AddSegmentViewModel(navigator: navigator,
                                            device: device,
                                            store: store,
                                            delegate: delegate)

        let viewController = AddSegmentViewController(viewModel: viewModel)
        let transitionDelegate = CardModalTransitioningDelegate()
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = transitionDelegate
        topViewController.present(viewController, animated: true)
    }

    public func confirmDeleteSegment(segment: Segment) -> Driver<Void> {
        let observable = Observable<Void>.create { observer -> Disposable in
            let alert = UIAlertController(
                title: "Delete Segment",
                message: "Are you sure you want to delete Segment \(segment.id)?",
                preferredStyle: .alert
            )

            let cancel = UIAlertAction(
                title: "Cancel",
                style: .cancel
            ) {_ in
                observer.onCompleted()
            }

            alert.addAction(cancel)

            let delete = UIAlertAction(
                title: "Delete",
                style: .destructive
            ) {_ in
                observer.onNext(())
                observer.on(.completed)
            }

            alert.addAction(delete)

            self.navigationController.present(alert, animated: true, completion: nil)

            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        }
        return observable.asDriverOnErrorJustComplete()
    }
}
