//
//  UIView+Additions.swift
//


import UIKit

extension UIView {
    
    // Adds shadow to layer
    public func shadow() {
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 8.0
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
    }
    
    //Adds animation to layer
    public func animationView() {
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 0.6
        layer.add(animation, forKey: "opacity")
    }
}

