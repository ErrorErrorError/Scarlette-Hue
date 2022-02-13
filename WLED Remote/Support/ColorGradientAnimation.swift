//
//  ColorGradientAnimation.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/17/22.
//

import UIKit

class ColorGradientAnimation {
    class func backgroundGradient(from state: State?) -> [UIColor] {
        var colors = [UIColor]()

        if state?.on == true,
            let segments = state?.segments {
            let newColors = segments
                .filter { $0.on == true }
                .compactMap { $0.colorsTuple.first }
                .filter({ $0.reduce(0, +) != 0 })
                .map({ UIColor(red: $0[0], green: $0[1], blue: $0[2]) })

            colors = newColors

            if colors.count == 1 {
                colors.append(colors.first!)
            }
        }

        if colors.count == 0 {
            colors.append(.clear)
            colors.append(.clear)
        }

        return colors
    }

    class func textColorForBackgroundGradient(from state: State?) -> UIColor {
        var textColor = UIColor.label

        let nextBackgroundGradient = backgroundGradient(from: state)

        if state?.on == true, let first = nextBackgroundGradient.first {
            textColor = first.isLight ? .black : .white
        }

        return textColor
    }

    class func nextBackgroundGradient(from segments: [Segment], on: Bool) -> [UIColor] {
        return backgroundGradient(from: State(on: on, segments: segments))
    }

    class func textColorForBackgroundGradient(from segments: [Segment], on: Bool) -> UIColor {
        return textColorForBackgroundGradient(from: State(on: on, segments: segments))
    }
}

extension CAGradientLayer {
    func gradientChangeAnimation(_ newColors: [CGColor], _ location: [NSNumber]? = nil, animate: Bool) {
        // MARK: Animate color changed

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
