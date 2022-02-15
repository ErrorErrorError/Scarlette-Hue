//
//  AppViewModel.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/15/22.
//

import RxSwift
import RxCocoa

struct AppViewModel {
    let navigator: AppNavigatorType
    let useCase: AppUseCaseType
}

// MARK: - ViewModel
extension AppViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
    }

    struct Output { }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        input.loadTrigger
            .drive(onNext: { _ in
                navigator.toDevices()
            })
            .disposed(by: disposeBag)

        return Output()
    }
}
