//
//  EditSegmentAssembler.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/23/22.
//

import UIKit
import RxSwift
import WLEDClient

protocol EditSegmentAssembler {
    func resolve(navigationController: UINavigationController, delegate: PublishSubject<EditSegmentDelegate>, device: Device, segment: Segment, store: Store) -> EditSegmentViewController
    func resolve(navigationController: UINavigationController, delegate: PublishSubject<EditSegmentDelegate>, device: Device, segment: Segment, store: Store) -> EditSegmentViewModel
    func resolve(navigationController: UINavigationController) -> EditSegmentNavigatorType
    func resolve() -> EditSegmentUseCaseType
}

extension EditSegmentAssembler {
    func resolve(navigationController: UINavigationController, delegate: PublishSubject<EditSegmentDelegate>, device: Device, segment: Segment, store: Store) -> EditSegmentViewController {
        let vc = EditSegmentViewController()
        let vm: EditSegmentViewModel = resolve(navigationController: navigationController, delegate: delegate, device: device, segment: segment, store: store)
        vc.bindViewModel(to: vm)
        return vc
    }

    func resolve(navigationController: UINavigationController, delegate: PublishSubject<EditSegmentDelegate>, device: Device, segment: Segment, store: Store) -> EditSegmentViewModel {
        return EditSegmentViewModel(
            navigator: resolve(navigationController: navigationController),
            useCase: resolve(),
            device: device,
            segment: segment,
            store: store,
            delegate: delegate
        )
    }
}

extension EditSegmentAssembler where Self: DefaultAssembler {
    func resolve(navigationController: UINavigationController) -> EditSegmentNavigatorType {
        return EditSegmentNavigator(
            assembler: self,
            navigationController: navigationController
        )
    }

    func resolve() -> EditSegmentUseCaseType {
        return EditSegmentUseCase()
    }
}
