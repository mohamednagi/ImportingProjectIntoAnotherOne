//
//  UserSettings.swift
//
//  Created by Yehia Elbehery.
//


import UIKit

class UserSettings: NSObject {
    
    static var info : Employee?
    static var applicationSettings = [ApplicationSettings]()
//    class func setDefaults() {
//        let defaultPrefsFile: String! = Bundle.main.path(forResource: "defaultPrefs", ofType: "plist") ?? ""
//        let defaultPreferences: [String: AnyObject] = NSDictionary(contentsOfFile: defaultPrefsFile) as! [String: AnyObject]
//        let defaults: UserDefaults = UserDefaults.standard
//        defaults.register(defaults: defaultPreferences)
//        defaults.synchronize()
//    }
    
    class func getUserPreference(_ key: String!) -> AnyObject? {
        let defaults: UserDefaults = UserDefaults.standard
        
        if defaults.value(forKey: key) == nil {
            return nil
        }else{
            return defaults.value(forKey: key) as AnyObject
        }
    }
    
    class func setUserPreference(_ value: AnyObject, key: String!) {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    class func getLanguage() -> String? {
        let defaults: UserDefaults = UserDefaults.standard
        
        if defaults.value(forKey: "language") == nil {
            if Locale.current.languageCode == "ar" {
                UserSettings.setLanguage("ar")
            }else{
                UserSettings.setLanguage("en")
            }
        }
        return defaults.value(forKey: "language") as? String
    }
    
    class func setLanguage(_ value: String) {
        UserSettings.setUserPreference(value as AnyObject, key: "language")
        if value == "ar" {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            UILabel.appearance().semanticContentAttribute = .forceRightToLeft
            UITextField.appearance().semanticContentAttribute = .forceRightToLeft
            UISwitch.appearance().semanticContentAttribute = .forceRightToLeft
            UINavigationBar.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            UILabel.appearance().semanticContentAttribute = .forceLeftToRight
            UITextField.appearance().semanticContentAttribute = .forceLeftToRight
            UISwitch.appearance().semanticContentAttribute = .forceLeftToRight
            UINavigationBar.appearance().semanticContentAttribute = .forceLeftToRight
        }
        UserSettings.setUserPreference([value] as AnyObject, key: "AppleLanguages")
        Bundle.setLanguage(value)
        
        _ = value
    }
    
    class func removeUserPreference(_ key: String!) {
        let defaults: UserDefaults = UserDefaults.standard
         defaults.removeObject(forKey: key)
    }
    
    
    
    static func appLanguageIsArabic() -> Bool{
        if let lang = UserSettings.getUserPreference("language") as? String {
            if lang == "ar" {
                return true
            }
        }
        return false
    }
    
}
