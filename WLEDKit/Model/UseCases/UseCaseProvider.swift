//
//  UseCaseProvider.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import Foundation

public protocol UseCaseProvider {
    func makeDevicesUseCase() -> DevicesUseCase
}
