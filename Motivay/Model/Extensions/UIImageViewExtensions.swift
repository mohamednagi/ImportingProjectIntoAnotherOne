//
//  UIImageViewExtensions.swift
//  Motivay
//
//  Created by Yasser Osama on 2/26/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func y_circularRoundedCorner() {
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.clipsToBounds = true
    }
    
    func y_roundCornersForAspectFitAlignRightOrLeft(radius: CGFloat, alignedRight: Bool = false)
    {
        if let image = self.image {
            
            //calculate drawingRect
            let boundsScale = self.bounds.size.width / self.bounds.size.height
            let imageScale = image.size.width / image.size.height
            
            var drawingRect: CGRect = self.bounds
            
            if boundsScale > imageScale {
                drawingRect.size.width =  drawingRect.size.height * imageScale
                
//                drawingRect.origin.x = (self.bounds.size.width - drawingRect.size.width) / 2
                if alignedRight {
                    
                    drawingRect.origin.x = (self.bounds.size.width - drawingRect.size.width)
                }else{
                    drawingRect.origin.x = 0
                }
            } else {
                drawingRect.size.height = drawingRect.size.width / imageScale
                drawingRect.origin.y = (self.bounds.size.height - drawingRect.size.height) / 2
            }
            let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}
