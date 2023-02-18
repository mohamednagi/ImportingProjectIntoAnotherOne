//
//  MenuViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import SDWebImage
import Alamofire

class MenuViewController: UIViewController {
    
    @IBOutlet weak var imageFrameImageView: UIImageView!
    @IBOutlet weak var profilePicImageView : UIImageView!
    @IBOutlet weak var userNameLabel : UILabel!
    @IBOutlet weak var fullNameLabel : UILabel!
    @IBOutlet weak var balanceLabel : UILabel!
    @IBOutlet weak var pointsLabel : UILabel!
    @IBOutlet weak var earnedPointsLabel: AutomaticallyLocalizedLabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        earnedPointsLabel.textColor = .primaryColor
        pointsLabel.textColor = .primaryColor
        populateUserInfo()
        
        if UserSettings.appLanguageIsArabic() {
            artworkImageView.image = UIImage(named: "pattern2Flipped")
        } else {
            artworkImageView.image = UIImage(named: "pattern2")
        }
        
        Backend.getProfileDetails(withID: nil, completion: { (employee, backendError) in
            if backendError != nil {
            }else{
//                                dump(employee)
                UserSettings.info = employee
                self.populateUserInfo()
            }
        }, showLoading: false)
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        profilePicImageView.isUserInteractionEnabled = true
        profilePicImageView.addGestureRecognizer(imageTap)
        
        let nameTap = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        fullNameLabel.addGestureRecognizer(nameTap)
        fullNameLabel.isUserInteractionEnabled = true
        
        let userNameTap = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        userNameLabel.addGestureRecognizer(userNameTap)
        userNameLabel.isUserInteractionEnabled = true
        
    }
    
    func populateUserInfo(){
        
        if UserSettings.info != nil {
            self.imageFrameImageView.isHidden = true
            profilePicImageView.sd_setImage(with: URL(string:UserSettings.info!.ProfilePicture), placeholderImage: UIImage(named:"profile"), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, url) in
                if image != nil {
                    self.imageFrameImageView.isHidden = false
                }
            })
            profilePicImageView.y_circularRoundedCorner()
            userNameLabel.text = "@\(UserSettings.info!.UserName)"
            fullNameLabel.text = UserSettings.info!.FullName
            pointsLabel.text = "\(UserSettings.info!.EarnedPoints)"
            balanceLabel.text = "\(UserSettings.info!.Balance)"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func disableMenu(){
        
        self.slideMenuController()?.closeLeft()
        self.slideMenuController()?.closeRight()
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
    }
    
    @IBAction func myAwards(){
        DeveloperTools.print("My Awards")
        if NetworkReachabilityManager()!.isReachable == false {
            AlertUtility.showConnectionError()
        } else {
            let awards = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Awards") as! MyAwardsViewController
            open(viewController: awards)
            disableMenu()
        }
    }
    
    @IBAction func myTrends(){
        
        DeveloperTools.print("My Trends")
        if NetworkReachabilityManager()!.isReachable == false {
            AlertUtility.showConnectionError()
        }else {
        let myTrends = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "MyTrends") as! MyTrendsViewController
        
        (self.slideMenuController()?.mainViewController as! ExampleNavigationController).pushViewController(myTrends, animated: true)
        
        disableMenu()
        }
    }
    
    @IBAction func myProfile(){
        DeveloperTools.print("My Profile")
    }
    
    @IBAction func logoutPrompt(){
        let alert = UIAlertController(title: "ni", message: "soi", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = AppDelegate.deviceToken
        }
//        self.present(alert, animated: true, completion: nil)
//        return
        AlertUtility.showAlertWithButton(msg: /*"Are you sure you want to logout?".y_localized*/Constants.errorMessage(.log_out), title: "Logout".y_localized, buttonTitle: "Yes".y_localized, closeButtonTitle: "No".y_localized, callback: {
            if UserSettings.appLanguageIsArabic() {
                self.slideMenuController()?.closeRightNonAnimation()
            }else{
                self.slideMenuController()?.closeLeftNonAnimation()
            }
            MenuViewController.userActionLogout()
        })
    }
    
    @IBAction func settings(_ sender: UIButton) {
        let settings = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Settings") as! SettingsTableViewController
        
        (self.slideMenuController()?.mainViewController as! ExampleNavigationController).pushViewController(settings, animated: true)
        
        self.slideMenuController()?.closeLeft()
        self.slideMenuController()?.closeRight()
    }
    
    static func logoutOps() {
        let intro = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Intro") as! IntroViewController
        if NetworkingController.getAccessToken() != nil {
            Backend.logout()
        }
        NetworkingController.logoutAccessTokenCleanUp()
        let nvc = UINavigationController(rootViewController: intro)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = nvc
        appDelegate.window?.makeKeyAndVisible()
//        DeveloperTools.findTheOne()
    }
    
    static func userActionLogout(){
        Backend.registerDevice(false)
        MenuViewController.logoutOps()
    }
    
    @objc func openProfile() {
        if NetworkReachabilityManager()!.isReachable == false {
            AlertUtility.showConnectionError()
        } else {
            let profile = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Profile") as! MyProfileViewController
            
            profile.myProfile = 1
            profile.profileData = UserSettings.info
            self.disableMenu()
            open(viewController: profile)
        }
    }
    
    func open(viewController: UIViewController) {
        (self.slideMenuController()?.mainViewController as! ExampleNavigationController).pushViewController(viewController, animated: true)
        
        self.slideMenuController()?.closeLeft()
        self.slideMenuController()?.closeRight()
    }
}

