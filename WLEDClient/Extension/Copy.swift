//
//  Copy.swift
//  WLEDClient
//
//  Created by Erik Bautista on 2/23/22.
//

import Foundation

public protocol Copying {
    associatedtype T
    mutating func copy(with item: T)
}
