//
//  PaletteItemViewModel.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/28/21.
//

import Foundation

class PaletteItemViewModel: ViewModelType {
    // MARK: Network Service

    let title: String
    let palette: Palette

    // MARK: Rx

    init(with palette: Palette) {
        self.palette = palette
        self.title = palette.title
    }
}

extension PaletteItemViewModel {
    struct Input {
    }

    struct Output {
    }

    func transform(input: Input) -> Output {
        return Output()
    }
}
