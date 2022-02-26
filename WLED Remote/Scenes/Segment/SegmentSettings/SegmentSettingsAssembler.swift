//
//  SegmentSettingsAssembler.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/24/22.
//

import UIKit
import WLEDClient
import RxSwift

protocol SegmentSettingsAssembler {
    func resolve(viewController: UIViewController, delegate: PublishSubject<SegmentSettingsDelegate>, segmentSettings: SegmentSettings, info: Info) -> SegmentSettingsViewController
    func resolve(viewController: UIViewController, delegate: PublishSubject<SegmentSettingsDelegate>, segmentSettings: SegmentSettings, info: Info) -> SegmentSettingsViewModel
    func resolve(viewController: UIViewController) -> SegmentSettingsNavigatorType
    func resolve() -> SegmentSettingsUseCaseType
}

extension SegmentSettingsAssembler {
    func resolve(viewController: UIViewController, delegate: PublishSubject<SegmentSettingsDelegate>, segmentSettings: SegmentSettings, info: Info) -> SegmentSettingsViewController {
        let vc = SegmentSettingsViewController()
        let vm: SegmentSettingsViewModel = resolve(
            viewController: viewController,
            delegate: delegate,
            segmentSettings: segmentSettings,
            info: info
        )
        vc.bindViewModel(to: vm)
        return vc
    }

    func resolve(viewController: UIViewController, delegate: PublishSubject<SegmentSettingsDelegate>, segmentSettings: SegmentSettings, info: Info) -> SegmentSettingsViewModel {
        return SegmentSettingsViewModel(
            navigator: resolve(viewController: viewController),
            useCase: resolve(),
            delegate: delegate,
            info: info,
            segmentSettings: segmentSettings
        )
    }
}

extension SegmentSettingsAssembler where Self: DefaultAssembler {
    func resolve(viewController: UIViewController) -> SegmentSettingsNavigatorType {
        return SegmentSettingsNavigator(
            assembler: self,
            viewController: viewController
        )
    }

    func resolve() -> SegmentSettingsUseCaseType {
        return SegmentSettingsUseCase()
    }
}
