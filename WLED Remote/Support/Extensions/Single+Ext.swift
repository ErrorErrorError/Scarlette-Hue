//
//  Single+Ext.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/21/21.
//

import Foundation
import RxSwift
import RxCocoa

extension Single {
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }
}
