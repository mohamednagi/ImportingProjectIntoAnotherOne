//
//  IntroViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import SlideMenuControllerSwift
//import Gradientable

class IntroViewController: UIViewController {
    
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var languageButton : UIButton!
    @IBOutlet weak var signInView : UIView!
    @IBOutlet weak var signInButton: AutomaticallyLocalizedButton!
    @IBOutlet weak var kafuLabel: UILabel!
    
    var counter = 0
    var timer = Timer()
    
    func switchToArabic(){
        UIView.appearance().semanticContentAttribute = .forceRightToLeft
        UILabel.appearance().semanticContentAttribute = .forceRightToLeft
        UITextField.appearance().semanticContentAttribute = .forceRightToLeft
        UINavigationBar.appearance().semanticContentAttribute = .forceRightToLeft
    }
    
    func switchToEngish(){
        
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        UILabel.appearance().semanticContentAttribute = .forceLeftToRight
        UITextField.appearance().semanticContentAttribute = .forceLeftToRight
        UINavigationBar.appearance().semanticContentAttribute = .forceLeftToRight
    }
    
//    func adjustButtonTitle(){
//        if UserSettings.appLanguageIsArabic() {
//
//            languageButton.setTitle("English", for: .normal)
//        }else{
//            languageButton.setTitle("عربي", for: .normal)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.backgroundColor = .primaryColor
        kafuLabel.text = Fonts.introLabel.y_localized
        
        if UserSettings.appLanguageIsArabic() && UIView.appearance().semanticContentAttribute != .forceRightToLeft {
            DeveloperTools.print("--------- LangSettings: lang is Arabic but LTR")
            switchToArabic()
            
            DeveloperTools.print("--------- LangSettings: Re-launch")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = Utilities.storyboard(withName: "Main").instantiateInitialViewController()
            
        }else if UserSettings.appLanguageIsArabic() == false && UIView.appearance().semanticContentAttribute == .forceRightToLeft {
            DeveloperTools.print("--------- LangSettings: lang is english but RTL")
            
            switchToEngish()
            DeveloperTools.print("--------- LangSettings: Re-launch")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = Utilities.storyboard(withName: "Main").instantiateInitialViewController()
            
        }else{
            DeveloperTools.print("--------- LangSettings: Direction is consitent with the langauge")
            
            self.navigationController?.navigationBar.isHidden = true
            if let accessTokenExpiryTime = UserSettings.getUserPreference("accessTokenExpiryTime") as? Date, let accessToken =  UserSettings.getUserPreference("accessToken") as? String, let userSource = UserSettings.getUserPreference("userSource") as? String {
                DeveloperTools.print("--------- LangSettings: We have the token")
                
                if accessTokenExpiryTime > Date() {
                    DeveloperTools.print("--------- LangSettings: We have the valid token")
                    
                    NetworkingController.accessToken = accessToken
                    NetworkingController.accessTokenExpiryTime = accessTokenExpiryTime
                    NetworkingController.userSource = userSource
                    
                        SignInViewController.launchHome(onFailure: {
                            
                        })
                    return
                }
            }/*else{
                
                print("--------- LangSettings: Not logged in user device defaults")
                if Locale.current.languageCode == "ar" {
                    self.switchToArabic()
                }else{
                    self.switchToEngish()
                }
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = Utilities.storyboard(withName: "Main").instantiateInitialViewController()
            }*/
            showSignIn()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        counter = 0
        if Constants.fromIntro {
//            timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(animate), userInfo: nil, repeats: true)
            self.logoImageView.alpha = 1
            Constants.fromIntro = false
        } else {
//            logoImageView.isHidden = false
//            logoImageView.alpha = 0
            UIView.animate(withDuration: 0.5) {
                self.logoImageView.alpha = 1
            }
            gifImageView.isHidden = true
        }
    }
    
    @objc func animate() {
        var imageName = "frame_\(counter)_delay-0.04s.gif"
        if counter < 10 {
            imageName = "frame_0\(counter)_delay-0.04s.gif"
        }
        if let image = UIImage(named: imageName) {
            gifImageView.image = image
            counter += 1
        } else {
            timer.invalidate()
//            logoImageView.isHidden = false
//            logoImageView.alpha = 0
            UIView.animate(withDuration: 0.5) {
                self.logoImageView.alpha = 1
            }
            gifImageView.isHidden = true
        }
    }
    
    func showSignIn(){
        
        UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.signInView.alpha = 1
        })
    }

    @IBAction func signIn(){
        let signIn = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
        self.navigationController?.pushViewController(signIn, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

