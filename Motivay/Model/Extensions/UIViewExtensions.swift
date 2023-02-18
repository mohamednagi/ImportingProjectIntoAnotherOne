//
//  UIViewExtensions.swift
//
//  Created by Yehia Elbehery.
//

import UIKit

typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)

enum GradientOrientation {
    case topRightBottomLeft
    case topLeftBottomRight
    case horizontal
    case vertical
    
    var startPoint : CGPoint {
        return points.startPoint
    }
    
    var endPoint : CGPoint {
        return points.endPoint
    }
    
    var points : GradientPoints {
        get {
            switch(self) {
            case .topRightBottomLeft:
                return (CGPoint(x: 0.0,y: 1.0), CGPoint(x: 1.0,y: 0.0))
            case .topLeftBottomRight:
                return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 1,y: 1))
            case .horizontal:
                return (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5))
            case .vertical:
                return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 0.0,y: 1.0))
            }
        }
    }
}

extension UIView {
    
    func y_applyGradient(withColours colours: [UIColor], locations: [NSNumber]? = nil) -> Void {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func y_applyGradient(withColours colours: [UIColor], gradientOrientation orientation: GradientOrientation) -> Void {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        self.layer.insertSublayer(gradient, at: 0)
    }
    func y_roundCorners(withRadius radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    func y_roundedCorners() {
        self.layer.cornerRadius = self.bounds.width/2
        self.layer.masksToBounds = true
    }
    func y_fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func y_fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
    func y_slideAnimation(type:String? = kCATransitionFromLeft , duration: TimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromLeftTransition.delegate = delegate as? CAAnimationDelegate
        }
        
        // Customize the animation's properties
        slideInFromLeftTransition.type = kCATransitionPush
        slideInFromLeftTransition.subtype = type
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromLeftTransition.fillMode = kCAFillModeRemoved
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: type)
    }
    
    
    func y_addBottomBorderWithColor(color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height-thickness, width: self.frame.size.width, height: thickness)
        self.layer.addSublayer(border)
    }
    
    func y_addTopBorderWithColor(color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: thickness)
        self.layer.addSublayer(border)
    }
    
    func y_addLeftBorderWithColor(color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func y_addRightBorderWithColor(color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width, y: 0, width: thickness, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func y_dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: -1, height: 0.5)
        layer.shadowRadius = 8
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
