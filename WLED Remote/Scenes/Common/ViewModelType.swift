//
//  ViewModelType.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
