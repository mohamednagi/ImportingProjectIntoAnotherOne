//
//  KeyboardHeightViewController.swift
//
//  Created by Yehia Elbehery.
//

import Foundation
import UIKit


public class KeyboardHeightViewController: UIViewController {
    
    var keyboardHeight: CGFloat?
    var statusBarView: UIView?
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
//        if statusBarView != nil {
//            statusBarView!.removeFromSuperview()
//        }
//        let frame =
//        statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
//        statusBarView!.backgroundColor = .red
//        self.window..addSubview(statusBarView!)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        super.viewWillAppear(animated)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
                DeveloperTools.print("keyboard will show ", keyboardSize.height)
                keyboardHeight = keyboardSize.height
                
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0
        view.layoutIfNeeded()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        DeveloperTools.print("dismiss 1")
//        if sender.view is UIButton {
//            DeveloperTools.print("dismiss button")
            sender.cancelsTouchesInView = false
//        }
//        if sender.view is UIView {
//            if self is HomeViewController {
//                //Search cancel bug fix, I have no idea why
//                sender.cancelsTouchesInView = true
//            }else{
//                sender.cancelsTouchesInView = false
//            }
//        }
        if sender.state == .ended && sender.view is UIButton == false/* && sender.view is UIScrollView == false*/  {
            DeveloperTools.print("dismiss do")
//            dump(sender.view)
            self.view.endEditing(true)
//            let array : [UIColor] = [.red, .yellow, .blue]
//            let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
//
//            sender.view?.backgroundColor = array[randomIndex]
//            print("dismiss 2", sender.view is UIView, sender.view?.frame)
            
        }else{
            DeveloperTools.print("dismiss don't")
//            sender.view?.backgroundColor = .white
            
        }
    }
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch =  touches.first {
            if touch.view is UIButton == false {
                DeveloperTools.print("dismiss 1")
                self.view.endEditing(true)
            }
        }
    }
}
