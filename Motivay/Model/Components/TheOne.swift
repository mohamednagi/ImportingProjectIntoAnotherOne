//
//  TheOne.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import Toaster

class TheOne : UITextView {
    
    // Initialize
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(textChange(_:)), name: .UITextViewTextDidEndEditing, object: nil)
    }
    
    @objc func textChange(_ sender: NSNotification)  {
        
        guard let textView = sender.object as? TheOne, textView == self else {
            return
        }
        
                if self.text != nil && self.text != "" {
        ToastView.appearance().bottomOffsetPortrait = 400
        Toast(text: self.text, duration: 10).show()
                }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
