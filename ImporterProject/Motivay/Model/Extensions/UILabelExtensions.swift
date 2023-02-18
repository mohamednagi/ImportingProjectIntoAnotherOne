//
//  UIViewExtensions.swift
//
//  Created by Yehia Elbehery.
//

import UIKit

extension UILabel {
    func y_adjustTextAlignment() {
        if self.text != nil {
            if self.text!.y_firstAlphabetIsArabic() {
                self.textAlignment = .right
            }else{
                self.textAlignment = .left
            }
        }
    }
    
    func addShadow(withColor color: UIColor) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.masksToBounds = false
    }
}

extension UITapGestureRecognizer {
    
    func getTappedCharacterIndexInLabel() -> Int? {
        
        if let label = self.view as? UILabel {
        
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return indexOfCharacter
        }
        return nil
    }
    
}

extension Range where Bound == String.Index {
    var nsRange:NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                        self.lowerBound.encodedOffset)
    }
}
