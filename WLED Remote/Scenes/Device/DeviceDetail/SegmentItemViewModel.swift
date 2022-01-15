//
//  SegmentItemViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import RxSwift
import RxCocoa
import Then

struct SegmentItemViewModel {
    let segment: Segment
    let delegate: PublishSubject<EditSegmentDelegate>
}

extension SegmentItemViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<()>
        let on: Driver<Bool>
    }

    struct Output {
        @Relay var id: Int
        @Relay var on: Bool
        @Relay var color: [Int]
    }

    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output(id: segment.id ?? 0, on: segment.on ?? false, color: segment.colorsTuple.first)

        let updateOn = Driver.merge(
            input.on,
            input.loadTrigger.map { output.on }
        )
        .do(onNext: { output.on = $0 })

        updateOn
            .map {
                Segment(id: output.id, on: $0)
            }
            .drive(onNext: { newSegment in
                delegate.onNext(.updatedSegment(newSegment))
            })
            .disposed(by: disposeBag)

        return output
    }
}
