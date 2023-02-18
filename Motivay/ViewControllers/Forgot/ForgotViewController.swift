//
//  ForgotViewController.swift
//
//  Created by Yehia Elbehery on 1/28/18.
//

import UIKit
import Material

class ForgotViewController: KeyboardHeightViewController {
    
    @IBOutlet weak var emailTextField : TextField!
    
    var alertContainer: UIView?
    
    @IBOutlet weak var doneButton: AutomaticallyLocalizedButton!
    @IBOutlet weak var backButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doneButton.backgroundColor = .primaryColor
        emailTextField.text = ""
        
        emailTextField.placeholder = "Username/Email".y_localized
        emailTextField.placeholderActiveColor = .primaryColor
        emailTextField.dividerActiveColor = .primaryColor
        if UserSettings.appLanguageIsArabic() {
            emailTextField.textAlignment = .right
        }else{
            emailTextField.textAlignment = .left
        }
        
        if UserSettings.appLanguageIsArabic() {
            backButton.setImage(UIImage(named:"backAr"), for: .normal)
        }else{
            backButton.setImage(UIImage(named:"back"), for: .normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
//    func successAlert(message: String){
//        alert(success:true, message:message)
//    }
    
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
    
    @IBAction func forgot(_ sender: UIButton){
//        if emailTextField.text?.y_trimmedLength() == 0 {
//
//            failureAlert(message: "Please, enter your email".y_localized)
//
//        }else{
//
            sender.isEnabled = false
        
        Backend.forgot(email: emailTextField.text!, validationErrorInInput: { inputIndex in
            sender.isEnabled = true
            if inputIndex == 0 {
                
                self.failureAlert(message: /*"Please, enter your username/email".y_localized*/Constants.errorMessage(.Empty_email_Username))
                
            }
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
                    
                    let reset = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Reset") as! ResetViewController
                    reset.userId = userId
                    reset.email = self.emailTextField.text!
                    self.navigationController?.pushViewController(reset, animated: true)
                }
            })
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        emailTextField.y_addBottomBorderWithColor(color: .black, thickness: 1)
    }
    
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
//        alertContainer?.removeFromSuperview()
    }
}

