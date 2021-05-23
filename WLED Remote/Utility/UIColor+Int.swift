//
//  UIColor+Int.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/18/21.
//

import UIKit


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue:  CGFloat(blue) / 255, alpha: 1.0)
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



