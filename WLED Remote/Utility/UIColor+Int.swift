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
}



