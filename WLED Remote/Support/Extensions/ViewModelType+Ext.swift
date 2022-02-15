//
//  ViewModel+Ext.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/10/22.
//

import Foundation
import RxSwift
import RxCocoa

extension ViewModel {
    public func select<T>(trigger: Driver<IndexPath>, items: Driver<[T]>) -> Driver<T> {
        return trigger
            .withLatestFrom(items) {
                return ($0, $1)
            }
            .filter { indexPath, items in indexPath.row < items.count }
            .map { indexPath, items in
                return items[indexPath.row]
            }
    }
}
