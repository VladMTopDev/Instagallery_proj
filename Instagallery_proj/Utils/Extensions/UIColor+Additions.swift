//
//  UIColor+Additions.swift
//


import UIKit

extension UIColor {
    
    //MARK: Private
    fileprivate static func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
    }

    fileprivate static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
        return rgba(r, g, b, 1.0)
    }
    
    fileprivate static func whiteAlpha(_ color: CGFloat, _ alpha: CGFloat) -> UIColor {
        return UIColor(white: color, alpha: alpha)
    }
    
    //MARK: Public
    static let purpleColor = rgb(222.0, 53.0, 114.0)
    static let orangeColor = rgb(248, 132, 63.0)
}
