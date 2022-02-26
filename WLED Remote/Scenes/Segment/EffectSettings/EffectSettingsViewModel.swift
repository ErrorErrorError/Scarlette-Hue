//
//  EffectSettingsViewModel.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/25/22.
//

import RxSwift
import RxCocoa

enum EffectSettingsDelegate {
    case updatedEffect(EffectSettings)
}

struct EffectSettingsViewModel {
    let navigator: EffectSettingsNavigatorType
    let useCase: EffectSettingsUseCaseType
    let delegate: PublishSubject<EffectSettingsDelegate>
    let effectSettings: EffectSettings
}

// MARK: - ViewModel
extension EffectSettingsViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<Void>
        let exitTrigger: Driver<Void>
        let speed: Driver<Int>
        let intensity: Driver<Int>
        let saveTrigger: Driver<Void>
    }

    struct Output {
        @Relay var speed: Int
        @Relay var intensity: Int
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output(speed: effectSettings.speed ?? 0, intensity: effectSettings.intensity ?? 0)

        let speed = Driver.merge(
            input.speed,
            input.loadTrigger.map { output.speed }
        )

        let intensity = Driver.merge(
            input.intensity,
            input.loadTrigger.map { output.intensity }
        )

        speed
            .drive(output.$speed)
            .disposed(by: disposeBag)

        intensity
            .drive(output.$intensity)
            .disposed(by: disposeBag)

        input.saveTrigger
            .asDriver()
            .withLatestFrom(Driver.combineLatest(output.$speed.asDriver(), output.$intensity.asDriver()))
            .map { EffectSettings(speed: $0, intensity: $1) }
            .drive(onNext: {
                delegate.onNext(.updatedEffect($0))
                navigator.toEditSegment()
            })
            .disposed(by: disposeBag)

        input.exitTrigger
            .drive(onNext: {
                navigator.toEditSegment()
            })
            .disposed(by: disposeBag)

        return output
    }
}
