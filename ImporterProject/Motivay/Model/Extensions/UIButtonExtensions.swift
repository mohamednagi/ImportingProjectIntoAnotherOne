//
//  UIButtonExtensions.swift
//
//  Created by Yehia Elbehery.
//

import UIKit

extension UIButton {
    func y_disable(withAlpha alpha: CGFloat = 0.4) {
        if !self.isEnabled {
            return
        }
        self.isEnabled = false
        self.alpha = alpha
    }
    
    func y_enable(withAlpha alpha: CGFloat = 1.0) {
        if self.isEnabled {
            return
        }
        self.isEnabled = true
        self.alpha = alpha
    }
    
    func roundedCornersWithBorder(_ color: UIColor) {
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
    }
}
