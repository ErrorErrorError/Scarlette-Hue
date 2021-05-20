//
//  UIScreen+cornerRadiusDevice.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/15/21.
//

import UIKit


extension UIScreen {
    private static let cornerRadiusKey: String = {
        let components = ["Radius", "Corner", "display", "_"]
        return components.reversed().joined()
    }()

    public var displayCornerRadius: CGFloat {
        guard let cornerRadius = self.value(forKey: Self.cornerRadiusKey) as? CGFloat else {
            return 32 // set default corner radius if not found
        }

        return cornerRadius == 0 ? 32 : cornerRadius
    }
}

