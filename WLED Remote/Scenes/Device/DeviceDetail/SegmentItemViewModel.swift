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
import Differentiator

struct SegmentItemViewModel {
    let segment: Segment
    let delegate: PublishSubject<EditSegmentDelegate>
}

extension SegmentItemViewModel: ViewModel {
    struct Input {
        let loadTrigger: Driver<()>
        let on: Driver<Bool>
    }

    struct Output {
        @Relay var id: Int
        @Relay var on: Bool
        @Relay var color: [Int]
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output(id: segment.id, on: segment.on ?? false, color: segment.colorsTuple.first)

        let updateOn = Driver.merge(
            input.on,
            input.loadTrigger.map { output.on }
        )
        .do(onNext: { output.on = $0 })

        updateOn
            .skip(1)
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

extension SegmentItemViewModel: IdentifiableType, Equatable {
    static func == (lhs: SegmentItemViewModel, rhs: SegmentItemViewModel) -> Bool {
        lhs.identity == rhs.identity
    }

    var identity: Int {
        return segment.id
    }
    
    typealias Identity = Int
}
