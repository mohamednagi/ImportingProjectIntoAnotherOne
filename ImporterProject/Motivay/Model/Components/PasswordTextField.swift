//
//  PasswordTextField.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import Material

class PasswordTextField: AutomaticallyLocalizedTextField {
    
    private var barier = true
    
    override var isSecureTextEntry: Bool {
        didSet {
            if isFirstResponder {
                _ = becomeFirstResponder()
            }
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        let success = super.becomeFirstResponder()
        if isSecureTextEntry, let text = self.text, barier {
            deleteBackward()
            insertText(text)
        }
        barier = !isSecureTextEntry
        return success
    }
    
}
