//
//  EffectSettingsAssembler.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/25/22.
//

import UIKit
import RxSwift

protocol EffectSettingsAssembler {
    func resolve(viewController: UIViewController, delegate: PublishSubject<EffectSettingsDelegate>, effectSettings: EffectSettings) -> EffectSettingsViewController
    func resolve(viewController: UIViewController, delegate: PublishSubject<EffectSettingsDelegate>, effectSettings: EffectSettings) -> EffectSettingsViewModel
    func resolve(viewController: UIViewController) -> EffectSettingsNavigatorType
    func resolve() -> EffectSettingsUseCaseType
}

extension EffectSettingsAssembler {
    func resolve(viewController: UIViewController, delegate: PublishSubject<EffectSettingsDelegate>, effectSettings: EffectSettings) -> EffectSettingsViewController {
        let vc = EffectSettingsViewController()
        let vm: EffectSettingsViewModel = resolve(viewController: viewController, delegate: delegate, effectSettings: effectSettings)
        vc.bindViewModel(to: vm)
        return vc
    }

    func resolve(viewController: UIViewController, delegate: PublishSubject<EffectSettingsDelegate>, effectSettings: EffectSettings) -> EffectSettingsViewModel {
        return EffectSettingsViewModel(
            navigator: resolve(viewController: viewController),
            useCase: resolve(),
            delegate: delegate,
            effectSettings: effectSettings
        )
    }
}

extension EffectSettingsAssembler where Self: DefaultAssembler {
    func resolve(viewController: UIViewController) -> EffectSettingsNavigatorType {
        return EffectSettingsNavigator(assembler: self, viewController: viewController)
    }
    
    func resolve() -> EffectSettingsUseCaseType {
        return EffectSettingsUseCase()
    }
}
