//
//  ViewModelType.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input, disposeBag: DisposeBag) -> Output
}
