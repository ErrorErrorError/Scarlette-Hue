//
//  PaletteItemViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/28/21.
//

import Foundation
import RxSwift

public struct PaletteItemViewModel {
    let title: String

    // MARK: Rx

    init(title: String) {
        self.title = title
    }
}
