//
//  UINavigationController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit

extension UINavigationController {
    
    func y_removeBackButtonTitle(){
        
        self.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    func y_removeShadow(){
        self.navigationBar.shadowImage = UIImage()
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowImage = UIImage()
            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    func y_showShadow(){
        self.navigationBar.shadowImage = nil
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowImage = nil
            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    func y_whiteBackground(){
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundImage = UIImage()
            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    func y_addShadowWithColor() {
        self.navigationBar.layer.masksToBounds = false
        self.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationBar.layer.shadowOpacity = 0.8
        self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.navigationBar.layer.shadowRadius = 2
    }
    
    func y_deleteShadowWithColor() {
        self.navigationBar.layer.masksToBounds = false
        self.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationBar.layer.shadowOpacity = 0
        self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.navigationBar.layer.shadowRadius = 0
    }
}
