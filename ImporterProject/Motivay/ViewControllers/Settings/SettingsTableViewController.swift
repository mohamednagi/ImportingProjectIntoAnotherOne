//
//  SettingsTableViewController.swift
//  Motivay
//
//  Created by Yasser Osama on 3/7/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var arabicLabel: AutomaticallyLocalizedLabel!
    @IBOutlet weak var emailSwitch: UISwitch!
    @IBOutlet weak var pushSwitch: UISwitch!
    
    @IBOutlet weak var emailSwitchLabel: AutomaticallyLocalizedLabel!
    @IBOutlet weak var pushSwitchLabel: AutomaticallyLocalizedLabel!
    @IBOutlet weak var logoutLabel: AutomaticallyLocalizedLabel!
    
    //MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Settings".y_localized
        self.navigationItem.titleLabel.font = UIFont(name: Constants.boldFont(), size: 17.0)
        
        languageSectionAccessoryView()
        arabicLabel.font = UIFont(name: "GESSTwoLight-Light", size: 17.0)
        logoutLabel.textColor = .logoutButtonColor
        tableView.tableFooterView = UIView()
        self.navigationController!.navigationBar.tintColor = .primaryColor
        Backend.getSettings(completion: { (appSettings, backendError) in
            if appSettings != nil {
                UserSettings.info!.appSettings = appSettings
                
                self.emailSwitch.isOn =  UserSettings.info!.appSettings!.EmailNotification
                self.pushSwitch.isOn =  UserSettings.info!.appSettings!.PushNotification
                self.reloadTable()
            }
        })
        
        reloadTable()
    }
    
    func reloadTable(){
        
        if self.emailSwitch.isOn {
            emailSwitchLabel.text = "You'll be notified by email of all the activities occurring on your profile".y_localized
        }else{
            emailSwitchLabel.text = "You won't be notified by email of any activities occurring on your profile".y_localized
        }
        
        
        if self.pushSwitch.isOn {
            pushSwitchLabel.text = "You'll be notified of all the activities that occurring on your profile".y_localized
        }else{
            pushSwitchLabel.text = "You won't be notified of any activities that occurring on your profile".y_localized
        }
        self.tableView.reloadData()
    }
    
    //MARK: - Actions
    @IBAction func pushNotificationsAction(_ sender: UISwitch) {
        reloadTable()
        if UIApplication.shared.isRegisteredForRemoteNotifications == false && sender.isOn {
            AlertUtility.showAlertWithButton(msg: "Please, allow Motivay to send you push notifications from the device settings".y_localized, title: "Settings".y_localized, buttonTitle: "Settings".y_localized, closeButtonTitle: "Cancel".y_localized, callback: {
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            })
        }
        Backend.updateSettings(EmailNotification: nil, PushNotification: sender.isOn, UserLanguage: nil, completion: { (success, backendError) in
            
            if success == false {
                if backendError == .server {
                    
                    AlertUtility.showErrorAlert(Constants.errorMessage(.General_Failure))
                }
                self.pushSwitch.isOn = !self.pushSwitch.isOn
                self.reloadTable()
            } else {
                
            }
        })
    }
    
    @IBAction func emailNotificationsAction(_ sender: UISwitch) {
        reloadTable()
        Backend.updateSettings(EmailNotification: sender.isOn, PushNotification: nil, UserLanguage: nil, completion: { (success, backendError) in
            if success == false {
                if backendError == .server {
                   
                    AlertUtility.showErrorAlert(Constants.errorMessage(.General_Failure))
                }
                self.emailSwitch.isOn = !self.emailSwitch.isOn
                self.reloadTable()
            }else{
                
            }
        })
    }
    
    //MARK: - tableView delegate
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .slateGrey
            if UserSettings.appLanguageIsArabic() {
                if section == 0 {
                    headerView.textLabel?.text = "LANGUAGE".y_localized
                } else if section == 1 {
                    headerView.textLabel?.text = "NOTIFICATIONS".y_localized
                } else if section == 2 {
                    headerView.textLabel?.text = "TERMS & POLICY".y_localized
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = indexPath.section
        let row = indexPath.row
        if section == 0 {
            if row == 0 {
                if UserSettings.appLanguageIsArabic() {
                    UserSettings.setLanguage("en")
                    Localizer.DoTheSwizzling()
                    Constants.languageChanged = true
                    SignInViewController.launchHome(onFailure: {
                    })
                    Backend.updateSettings(EmailNotification: nil, PushNotification: nil, UserLanguage: 1, completion: { (success, backendError) in
                        
                    })
                }
            } else if row == 1 {
                if !UserSettings.appLanguageIsArabic() {
                    UserSettings.setLanguage("ar")
                    Localizer.DoTheSwizzling()
                    Constants.languageChanged = true
                    SignInViewController.launchHome(onFailure: {
                    })
                    Backend.updateSettings(EmailNotification: nil, PushNotification: nil, UserLanguage: 0, completion: { (success, backendError) in
                    })
                }
            }
            //            tableView.reloadData()
        }
        if section == 2 {
            if row == 1 {
                let contactVC = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "contactUs") as! ContactUsViewController
                self.navigationController?.pushViewController(contactVC, animated: true)
            } else if row == 2 {
                AlertUtility.showAlertWithButton(msg: Constants.errorMessage(.log_out), title: "Yes".y_localized, buttonTitle: "Yes".y_localized, closeButtonTitle: "Cancel".y_localized, callback : {
                    MenuViewController.userActionLogout()
                })
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 78
        }
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                #if GAZT
                return 0
                #endif
            }
        }
        return 48
    }
    
    func languageSectionAccessoryView() {
        var ind = IndexPath()
        if UserSettings.appLanguageIsArabic() {
            ind = IndexPath(row: 1, section: 0)
        } else {
            ind = IndexPath(row: 0, section: 0)
        }
        let cell = tableView(tableView, cellForRowAt: ind)
        cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "checkMark"))
    }
}
