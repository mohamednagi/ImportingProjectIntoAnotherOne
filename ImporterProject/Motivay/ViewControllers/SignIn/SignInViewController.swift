//
//  SignInViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import SlideMenuControllerSwift
import Material
import UserNotifications

class SignInViewController: KeyboardHeightViewController {
    
    @IBOutlet weak var emailTextField : TextField!
    @IBOutlet weak var passwordTextField : PasswordTextField!
    
    @IBOutlet weak var signInButton: AutomaticallyLocalizedButton!
    @IBOutlet weak var backButton : UIButton!
    
    var alertContainer: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = ""
        passwordTextField.text = ""
        signInButton.backgroundColor = .primaryColor
        if UserSettings.appLanguageIsArabic() {
            backButton.setImage(UIImage(named:"backAr"), for: .normal)
        }else{
            backButton.setImage(UIImage(named:"back"), for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        emailTextField.placeholder = "Username".y_localized
        emailTextField.placeholderActiveColor = .primaryColor
        emailTextField.dividerActiveColor = .primaryColor
        if UserSettings.appLanguageIsArabic() {
            emailTextField.textAlignment = .right
        }else{
            emailTextField.textAlignment = .left
        }
            
        passwordTextField.placeholder = "Password".y_localized
        passwordTextField.placeholderActiveColor = .primaryColor
        passwordTextField.dividerActiveColor = .primaryColor
        if UserSettings.appLanguageIsArabic() {
            passwordTextField.textAlignment = .right
        }else{
            passwordTextField.textAlignment = .left
        }
        
        let passowrdShowHide = UIButton(frame:CGRect(x:0, y:0, width:33, height:33))
        passowrdShowHide.setImage(UIImage(named:"viewIco"), for: .normal)
        passowrdShowHide.addTarget(self, action: #selector(passwordShowHide(_:)), for: .touchUpInside)
//        if UserSettings.appLanguageIsArabic() {
//            passwordTextField.leftView = passowrdShowHide
//            passwordTextField.leftViewMode = .whileEditing
//        }else{
            passwordTextField.rightView = passowrdShowHide
            passwordTextField.rightViewMode = .always
//        }
//        emailTextField.y_addBottomBorderWithColor(color: .black, thickness: 1)
//        passwordTextField.y_addBottomBorderWithColor(color: .black, thickness: 1)
    }
    
    
    @IBAction func passwordShowHide(_ sender: UIButton){
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        if passwordTextField.isSecureTextEntry {
            sender.setImage(UIImage(named:"viewIco"), for: .normal)
        }else{
            sender.setImage(UIImage(named:"group"), for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func signIn(_ sender: UIButton){
        //        if DeveloperTools.debugMode {
        //            emailTextField.text = "Yehia"
        //            passwordTextField.text = "aA111$"
        //        }
        //        if emailTextField.text?.y_trimmedLength() == 0 {
        //
        //            failureAlert(message: "Please, enter your email".y_localized)
        //
        //        }else if passwordTextField.text?.lengthOfBytes(using: .utf8) == 0 {
        //
        //            failureAlert(message: "Please, enter your password".y_localized)
        //
        //        }else{
        
        sender.isEnabled = false
        
        //            if DeveloperTools.debugMode == true {
        //                self.launchHome()
        //            }else{
        Backend.signIn(email: emailTextField.text, password: passwordTextField.text, validationErrorInInput: { inputIndex in
            sender.isEnabled = true
            
            switch (inputIndex){
            case 0:
                self.failureAlert(message: Constants.errorMessage(.Empty_username)/*"Please, enter your username".y_localized*/)
                break
            case 1:
                self.failureAlert(message: /*"Please, enter your password".y_localized*/Constants.errorMessage(.Empty_login_password))
                break
            default:
                break
            }
            
        }, completion:  { (success, backendError, deactivated) in
            
            
            sender.isEnabled = true
            if success == false/* && DeveloperTools.debugMode == false*/ {
                if backendError == .connection {
                    
                    //                        self.failureAlert(message: "Unable to connect to the internet, Please try again later".y_localized)
                } else if backendError == .server {
                    self.failureAlert(message: /*"An error occurred, Please try again later".y_localized*/Constants.errorMessage(.General_Failure))
                } else {
                    self.failureAlert(message: Constants.errorMessage(.User_input_worng_username_or_password))
                }
                
            }else{
                if deactivated {
                    self.failureAlert(message: Constants.errorMessage(.User_Deactivated))
                } else {
                    Constants.fromIntro = false
                    AppDelegate.registerDevice()
                    SignInViewController.launchHome(onFailure: {})
                }
            }
        })
        //            }
        //        }
    }
    
    static func launchHome(onFailure: @escaping () -> Void) {
//        Backend.registerDevice(true)
        Backend.getProfileDetails(withID: nil, completion: { (employee, backendError) in
            if backendError != nil {
                onFailure()
                DeveloperTools.print("get profile error", backendError)
            }else{
                
                UserSettings.info = employee
                Backend.getSettings(completion: { (appSettings, backendError) in
                    if appSettings != nil {
                        if UserSettings.info != nil {
                            UserSettings.info!.appSettings = appSettings
                        }
                    }
                        if appSettings != nil {
                            DeveloperTools.print("--------- LangSettings: Got the settings \(appSettings)")
                            if UserSettings.info != nil {
                                if UserSettings.info!.appSettings!.UserLanguage == 0 && UserSettings.appLanguageIsArabic() == false {
                                    DeveloperTools.print("--------- LangSettings: Backend settings lang is different is English")
                                    UserSettings.setLanguage("ar")
                                    
                                    DeveloperTools.print("--------- LangSettings: Re-launch")
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.window?.rootViewController = Utilities.storyboard(withName: "Main").instantiateInitialViewController()
                                }else if UserSettings.info!.appSettings!.UserLanguage == 1 && UserSettings.appLanguageIsArabic() {
                                    DeveloperTools.print("--------- LangSettings: Backend settings lang is different is Arabic")
                                    UserSettings.setLanguage("en")
                                    
                                    DeveloperTools.print("--------- LangSettings: Re-launch")
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.window?.rootViewController = Utilities.storyboard(withName: "Main").instantiateInitialViewController()
                                }
                            }
                        }
                })
            }
            Backend.getAppSettings(completion: { (applicationSettings, backendError) in
                UserSettings.applicationSettings = applicationSettings
            })
                let tabBarController = UITabBarController()
                
                tabBarController.tabBar.shadowImage = UIImage(named: "transparent")
                tabBarController.tabBar.backgroundImage = UIImage(named: "transparent")
                tabBarController.tabBar.backgroundColor = .white
            tabBarController.tabBar.accessibilityIdentifier = "HomeTabBar"
            
                
                let v1 = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Home") as! HomeViewController
                let v2 = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Rewards")
                let v3 = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Empty")
                let v4 = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "notifications") as! NotificationsViewController
                let v5 = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "StatsT") as! StatsTableViewController
            
                v1.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "pdfHome")!.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "pdfHome-active")!.withRenderingMode(.alwaysOriginal))
            v1.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
                
                v2.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "pdfrewards")!.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "pdfrewards-active")!.withRenderingMode(.alwaysOriginal))
            v2.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
                
                v3.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "pdfadd")!.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "pdfadd-active")!.withRenderingMode(.alwaysOriginal))
            v3.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            
            var haveWeAnyNotifications = false
            UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
                if notifications.count > 0 {
                    haveWeAnyNotifications = true
                }
            }
            
            var notificationsImage = "pdfNotifications"
            if haveWeAnyNotifications {
                notificationsImage = "Notifications-1"
            }
                v4.tabBarItem = UITabBarItem(title: "", image: UIImage(named: notificationsImage)!.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "pdfNotifications-active")!.withRenderingMode(.alwaysOriginal))
            v4.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
                
                v5.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "pdfAnalytics")!.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "pdfAnalytics-active")!.withRenderingMode(.alwaysOriginal))
            v5.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
                
                
                tabBarController.viewControllers = [v1, v2, v3, v4, v5]
                
//                UINavigationBar.appearance().backgroundColor = .white
                
                
                
            
            tabBarController.slideMenuController()?.removeLeftGestures()
            tabBarController.slideMenuController()?.addLeftGestures()
            tabBarController.slideMenuController()?.removeRightGestures()
            tabBarController.slideMenuController()?.addRightGestures()
                
                let navigationController = ExampleNavigationController.init(rootViewController: tabBarController)
                
                
                
                
                let menuViewController = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Menu")
                
                SlideMenuOptions.contentViewScale = 1
                SlideMenuOptions.hideStatusBar = false
                let slideMenuController: SlideMenuController!
                
                if UserSettings.appLanguageIsArabic() {
                    slideMenuController = SlideMenuController(mainViewController: navigationController, rightMenuViewController: menuViewController)
                }else{
                    slideMenuController = SlideMenuController(mainViewController: navigationController, leftMenuViewController: menuViewController)
                }
                
                slideMenuController.delegate = v1
                
                tabBarController.delegate = v1
                
//                guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//                
//                statusBar.backgroundColor = .white
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = slideMenuController
                appDelegate.window?.makeKeyAndVisible()
//            DeveloperTools.findTheOne()
        })
    }
    
    @IBAction func back(){
        if Constants.fromIntro {
            let introNavController = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "introNavController")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = introNavController
            appDelegate.window?.makeKeyAndVisible()
            Constants.fromIntro = false
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
//    @objc func dismissButtonTapped() {
//        alertContainer?.removeFromSuperview()
//    }
    
    @objc override func keyboardWillHide(notification: NSNotification) {
        super.keyboardWillHide(notification: notification)
//        alertContainer?.removeFromSuperview()
    }
}


