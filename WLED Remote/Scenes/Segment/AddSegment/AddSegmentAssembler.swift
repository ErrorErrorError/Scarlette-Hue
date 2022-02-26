//
//  AddSegmentAssembler.swift
//  WLEDClient
//
//  Created by Erik Bautista on 2/23/22.
//

import UIKit
import RxSwift
import WLEDClient

protocol AddSegmentAssembler {
    func resolve(navigationController: UINavigationController, delegate: PublishSubject<EditSegmentDelegate>, store: Store) -> AddSegmentViewController
    func resolve(navigationController: UINavigationController, delegate: PublishSubject<EditSegmentDelegate>, store: Store) -> AddSegmentViewModel
    func resolve(navigationController: UINavigationController) -> AddSegmentNavigatorType
    func resolve() -> AddSegmentUseCaseType
}

extension AddSegmentAssembler {
    func resolve(navigationController: UINavigationController, delegate: PublishSubject<EditSegmentDelegate>, store: Store) -> AddSegmentViewController {
        let vc = AddSegmentViewController()
        let vm: AddSegmentViewModel = resolve(navigationController: navigationController, delegate: delegate, store: store)
        vc.bindViewModel(to: vm)
        return vc
    }

    func resolve(navigationController: UINavigationController, delegate: PublishSubject<EditSegmentDelegate>, store: Store) -> AddSegmentViewModel {
        return AddSegmentViewModel(
            navigator: resolve(navigationController: navigationController),
            useCase: resolve(),
            delegate: delegate,
            store: store
        )
    }
}

extension AddSegmentAssembler where Self: DefaultAssembler {
    func resolve(navigationController: UINavigationController) -> AddSegmentNavigatorType {
        return AddSegmentNavigator(
            assembler: self,
            navigationController: navigationController
        )
    }

    func resolve() -> AddSegmentUseCaseType {
        return AddSegmentUseCase()
    }
}
