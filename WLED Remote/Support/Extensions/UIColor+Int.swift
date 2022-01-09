//
//  UIColor+Int.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import UIKit


extension UIColor {

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    convenience init(red: Int, green: Int, blue: Int) {
        let div = CGFloat(255)
        self.init(red: CGFloat(red) / div, green: CGFloat(green) / div, blue:  CGFloat(blue) / div, alpha: 1.0)
    }

    var intArray: [Int] {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        if getRed(&red, green: &green, blue: &blue, alpha: nil) {
            let redInt = Int(red * 255)
            let greenInt = Int(green * 255)
            let blueInt = Int(blue * 255)
            return [redInt, greenInt, blueInt]
        }
        return [0, 0, 0]
    }

}

extension UIColor {

    private var luminance: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)

        return (0.2126 * red) + (0.7152 * green) + (0.0722 * blue)
    }

//    var isLight: Bool {
//        return luminance >= 0.6
//    }
}
