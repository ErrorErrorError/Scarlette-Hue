//
//  ViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import RxSwift

protocol ViewModel {
    associatedtype Input
    associatedtype Output

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output
}
