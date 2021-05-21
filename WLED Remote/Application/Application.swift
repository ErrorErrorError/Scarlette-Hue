//
//  Application.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/20/21.
//

import Foundation
import UIKit

final class Application {
    static let shared = Application()

    private let coreDataUseCaseProvider: UseCaseProvider

    private init() {
        self.coreDataUseCaseProvider = UseCaseProvider()
    }

    func configureMainInterface(in window: UIWindow) {
        let mainViewController = MainViewController()
        window.rootViewController = mainViewController
    }
}
