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
import WLEDClient

public protocol DeviceDetailNavigatorType {
    func toDevices()
    func toEditSegment(delegate: PublishSubject<EditSegmentDelegate>, device: Device, segment: Segment, store: Store)
    func toAddSegment(delegate: PublishSubject<EditSegmentDelegate>, store: Store)
    func confirmDeleteSegment(segment: Segment) -> Driver<Void>
}

public struct DeviceDetailNavigator: DeviceDetailNavigatorType {
    unowned let assembler: Assembler
    unowned let navigationController: UINavigationController

    public func toDevices() {
        self.navigationController.popToRootViewController(animated: true)
    }

    public func toEditSegment(delegate: PublishSubject<EditSegmentDelegate>, device: Device, segment: Segment, store: Store) {
        let viewController: EditSegmentViewController = assembler.resolve(
            navigationController: navigationController,
            delegate: delegate,
            device: device,
            segment: segment,
            store: store
        )

        let encapsulatingNavigationController = UINavigationController(rootViewController: viewController)
        encapsulatingNavigationController.modalPresentationStyle = .fullScreen

        navigationController.present(encapsulatingNavigationController, animated: true)
    }

    public func toAddSegment(delegate: PublishSubject<EditSegmentDelegate>, store: Store) {
        guard let topViewController = navigationController.topViewController else { return }

        let viewController: AddSegmentViewController = assembler.resolve(
            navigationController: navigationController,
            delegate: delegate,
            store: store
        )

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
