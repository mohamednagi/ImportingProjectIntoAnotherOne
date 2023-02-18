//
//  ResestViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import IQKeyboardManagerSwift
import Material

class ResetViewController: KeyboardHeightViewController {
    
    @IBOutlet weak var userIdTextField: TextField!
    @IBOutlet weak var newPasswordTextField : PasswordTextField!
    @IBOutlet weak var confirmPasswordTextField : PasswordTextField!
    @IBOutlet weak var resendButton: AutomaticallyLocalizedButton!
    @IBOutlet weak var doneButton: AutomaticallyLocalizedButton!
    
    @IBOutlet weak var scrollView : UIScrollView!
    
    var alertContainer: UIView?
    var emailSentMessageDisplayed = false
    
    var userId: String!
    var email: String!
    
    @IBOutlet weak var backButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        userIdTextField.placeholder = "Passcode".y_localized
        userIdTextField.placeholderActiveColor = .primaryColor
        userIdTextField.dividerActiveColor = .primaryColor
        if UserSettings.appLanguageIsArabic() {
            userIdTextField.textAlignment = .right
        }else{
            userIdTextField.textAlignment = .left
        }
        
        newPasswordTextField.placeholder = "Password".y_localized
        newPasswordTextField.placeholderActiveColor = .primaryColor
        newPasswordTextField.dividerActiveColor = .primaryColor
        if UserSettings.appLanguageIsArabic() {
            newPasswordTextField.textAlignment = .right
        }else{
            newPasswordTextField.textAlignment = .left
        }
        
        confirmPasswordTextField.placeholder = "Confirm Password".y_localized
        confirmPasswordTextField.placeholderActiveColor = .primaryColor
        confirmPasswordTextField.dividerActiveColor = .primaryColor
        if UserSettings.appLanguageIsArabic() {
            confirmPasswordTextField.textAlignment = .right
        }else{
            confirmPasswordTextField.textAlignment = .left
        }
        
        let newPassowrdShowHide = UIButton(frame:CGRect(x:0, y:0, width:33, height:33))
        newPassowrdShowHide.setImage(UIImage(named:"viewIco"), for: .normal)
        newPassowrdShowHide.addTarget(self, action: #selector(newPasswordShowHide(_:)), for: .touchUpInside)
//        if UserSettings.appLanguageIsArabic() {
//            newPasswordTextField.leftView = newPassowrdShowHide
//            newPasswordTextField.leftViewMode = .whileEditing
//        }else{
            newPasswordTextField.rightView = newPassowrdShowHide
            newPasswordTextField.rightViewMode = .always
//        }
        
        
        let confirmPassowrdShowHide = UIButton(frame:CGRect(x:0, y:0, width:33, height:33))
        confirmPassowrdShowHide.setImage(UIImage(named:"viewIco"), for: .normal)
        confirmPassowrdShowHide.addTarget(self, action: #selector(confirmPasswordShowHide(_:)), for: .touchUpInside)
//        if UserSettings.appLanguageIsArabic() {
//            confirmPasswordTextField.leftView = confirmPassowrdShowHide
//            confirmPasswordTextField.leftViewMode = .whileEditing
//        }else{
            confirmPasswordTextField.rightView = confirmPassowrdShowHide
            confirmPasswordTextField.rightViewMode = .always
//        }
        
        userIdTextField.becomeFirstResponder()
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        super.keyboardWillShow(notification: notification)
        if emailSentMessageDisplayed == false {
            userIdTextField.resignFirstResponder()
            AlertUtility.showSuccessAlertWithCallback(/*"We sent you an email with the passcode".y_localized*/Constants.errorMessage(.Email_sent_to_reset_password), callback: {
                
                self.userIdTextField.becomeFirstResponder()
            })
            
            emailSentMessageDisplayed = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resendButton.setTitleColor(.primaryColor, for: .normal)
        doneButton.backgroundColor = .primaryColor
        if UserSettings.appLanguageIsArabic() {
            backButton.setImage(UIImage(named:"backAr"), for: .normal)
        }else{
            backButton.setImage(UIImage(named:"back"), for: .normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func newPasswordShowHide(_ sender: UIButton){
        newPasswordTextField.isSecureTextEntry = !newPasswordTextField.isSecureTextEntry
        if newPasswordTextField.isSecureTextEntry {
            sender.setImage(UIImage(named:"viewIco"), for: .normal)
        }else{
            sender.setImage(UIImage(named:"group"), for: .normal)
        }
    }
    
    @IBAction func confirmPasswordShowHide(_ sender: UIButton){
        confirmPasswordTextField.isSecureTextEntry = !confirmPasswordTextField.isSecureTextEntry
        if confirmPasswordTextField.isSecureTextEntry {
            sender.setImage(UIImage(named:"viewIco"), for: .normal)
        }else{
            sender.setImage(UIImage(named:"group"), for: .normal)
        }
    }
    
    
    @IBAction func passCodeResend(_ sender: UIButton){
        sender.isEnabled = false
        
        Backend.forgot(email: email, validationErrorInInput: { inputIndex in
            
        }, completion:  { (userId, success, backendError, message) in
            sender.isEnabled = true
            
            if success == false {
                
                if backendError == .connection {
                    
                } else if backendError == .custom && message != nil {
                    
                    self.failureAlert(message:message!)
                    //                        self.failureAlert(message: "Username/email does not exist".y_localized)
                }else {
                    
                    self.failureAlert(message: /*"An error occurred, Please try again later".y_localized*/Constants.errorMessage(.General_Failure))
                }
            }else{
                AlertUtility.showSuccessAlertWithCallback("We resent you the email with the passcode".y_localized, callback: {
                    
                    self.userIdTextField.becomeFirstResponder()
                })
            }
        })
    }
    
    func successAlert(message: String){
        
        AlertUtility.showSuccessAlert(message)
//        alert(success:true, message:message)
    }
    
    func failureAlert(message: String){
//        alert(success:false, message:message)
        
        AlertUtility.showErrorAlert(message)
    }
    
    
//    func alert(success:Bool, message: String){
//
//        if alertContainer != nil {
//            alertContainer!.removeFromSuperview()
//        }
//        var alertY = self.view.frame.size.height - 72
//        if keyboardHeight != nil {
//            alertY = self.view.frame.size.height-keyboardHeight!-72
//        }
//        alertContainer = UIView(frame:CGRect(x:0, y:alertY, width:self.view.frame.size.width, height:72))
//        self.view.addSubview(alertContainer!)
//
//        let formAlert = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "FormAlert") as! FormAlertViewController
//        formAlert.isSuccessAlert = success
//
//        formAlert.view.frame = CGRect(x:0, y:0, width:self.view.frame.size.width, height:72)
//        formAlert.messageLabel.text = message
//        alertContainer?.addSubview(formAlert.alertView)
//        formAlert.alertView.translatesAutoresizingMaskIntoConstraints = true
//        formAlert.alertView.frame = CGRect(x:0, y:0, width:self.view.frame.size.width, height:72)
//
//        formAlert.dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
//    }
    
    //    func isPasswordValid(_ password : String) -> Bool{
    //        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-zA-Z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{6,}")
    //        return passwordTest.evaluate(with: password)
    //    }
    
    @IBAction func reset(_ sender: UIButton){
        if userIdTextField.text != "" && newPasswordTextField.text != "" && confirmPasswordTextField.text == "" {
            
            failureAlert(message: /*"Passwords don't match".y_localized*/Constants.errorMessage(.Empty_confirm_password))
            
        }else if newPasswordTextField.text != "" && confirmPasswordTextField.text != "" && newPasswordTextField.text != confirmPasswordTextField.text {

            failureAlert(message: /*"Passwords don't match".y_localized*/Constants.errorMessage(.Not_matching_password))

        }else{
        
            sender.isEnabled = false
            Backend.reset(token: userIdTextField.text!, userId: userId, newPassword:newPasswordTextField.text!, validationErrorInInput: { inputIndex in
                sender.isEnabled = true
                
                switch (inputIndex){
                case 0:
                    self.failureAlert(message: /*"An error occurred, Please try again later".y_localized*/Constants.errorMessage(.General_Failure))
                    break
                case 1:
                    self.failureAlert(message: /*"Please, enter the passcode".y_localized*/Constants.errorMessage(.Empty_Passcode))
                    break
                case 2:
                    self.failureAlert(message: /*"Password must be at least 6 characters long and contain at least one digit and one uppercase letter and one non-letter or digit character".y_localized*/Constants.errorMessage(.Password_less_than_6_character_and_doesnt_contain_special_character_or_numbers))
                    break
                default:
                    break
                }
                
            }, completion:  { (success, backendError, message
                ) in
                sender.isEnabled = true
                if success == false {
                    
                    if backendError == .connection {
                        
//                        self.failureAlert(message: "Unable to connect to the internet, Please try again later".y_localized)
                        
                    } else if backendError == .custom && message != nil {
                        
                        self.failureAlert(message:message!)
                        //                        self.failureAlert(message: "Username/email does not exist".y_localized)
                    }else {
                        
                        self.failureAlert(message: /*"An error occurred, Please try again later".y_localized*/Constants.errorMessage(.General_Failure))
                    }/* else if backendError == .server {
                        
                        self.failureAlert(message: Constants.errorMessage(.General_Failure)/*"An error occurred, Please try again later".y_localized*/)
                    }else{
                        self.failureAlert(message: "Invalid passcode".y_localized)
                    }*/
                    
                }else{
                    
                    self.successAlert(message: /*"Password changed successfully".y_localized*/Constants.errorMessage(.Pasword_setting_success))
                   
                    self.perform(#selector(self.gotoSignin), with: nil, afterDelay: 1)
                }
            })
        }
    }
    
    @objc func gotoSignin(){
        
    self.navigationController?.popToViewController(self.navigationController!.viewControllers[1], animated: true)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width:scrollView.frame.size.width, height:667)
//        self.perform(#selector(drawBottomLines), with: nil, afterDelay: 0.1)
    }
    
//    @objc func drawBottomLines(){
//        userIdTextField.y_addBottomBorderWithColor(color: .black, thickness: 1)
//        newPasswordTextField.y_addBottomBorderWithColor(color: .black, thickness: 1)
//        confirmPasswordTextField.y_addBottomBorderWithColor(color: .black, thickness: 1)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(){
        self.navigationController?.popViewController(animated: true)
    }
    
//    @objc func dismissButtonTapped() {
//        alertContainer?.removeFromSuperview()
//    }
    
    @objc override func keyboardWillHide(notification: NSNotification) {
        super.keyboardWillHide(notification: notification)
//        alertConstainer?.removeFromSuperview()
    }
    
}

