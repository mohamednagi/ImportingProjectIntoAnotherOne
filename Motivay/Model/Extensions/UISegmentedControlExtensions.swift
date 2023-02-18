//
//  UIImageViewExtensions.swift
//  Motivay
//
//  Created by Yasser Osama on 2/26/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    
    func y_circularCorners() {
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.borderColor = self.tintColor.cgColor
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
    }
}
