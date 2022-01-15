//
//  CAGradientLayer+Animation.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/14/22.
//

import UIKit

extension CAGradientLayer {
    func changeGradients(_ newColors: [CGColor]? = nil, _ location: [NSNumber]? = nil, animate: Bool) {
        // MARK: Animate color changed

        if colors == nil {
            colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
        }

        if animate {
            let gradientAnimation = CABasicAnimation(keyPath: "colors").then {
                $0.fromValue = colors
                $0.toValue = newColors
                $0.duration = 0.25
                $0.isRemovedOnCompletion = true
                $0.fillMode = .forwards
            }
            add(gradientAnimation, forKey: nil)
        }

        colors = newColors
    }
}
