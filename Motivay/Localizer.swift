//
//  Localizer.swift
//   
//
//  Created by ioS on 6/6/17.
//  Copyright © 2017 Youxel. All rights reserved.
//


// this class do localization load data from localizable files

import UIKit

class Localizer: NSObject {
    
    class func DoTheSwizzling() {
        MethodSwizzleGivenClassName(cls: Bundle.self, originalSelector: #selector(Bundle.localizedString(forKey:value:table:)), overrideSelector: #selector(Bundle.specialLocalizedStringForKey(key:value:table:)))
    }
    static func currentAppleLanguage() -> String {
        
        let userdef = UserDefaults.standard
        let langArray = userdef.object(forKey: "AppleLanguages") as! NSArray
        let current = langArray.firstObject as! String
        let startIndex = current.startIndex
        let currentWithoutLocale = current.substring(to: current.index(startIndex, offsetBy: 2))
        // print("currentWithoutLocale==\(currentWithoutLocale)")
        return currentWithoutLocale
    }
}
extension Bundle {
    @objc func specialLocalizedStringForKey(key: String, value: String?, table tableName: String?) -> String {
        let currentLanguage = Localizer.currentAppleLanguage()
        var bundle = Bundle();
        if let _path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") {
            bundle = Bundle(path: _path)!
        } else {
            let _path = Bundle.main.path(forResource: "Base", ofType: "lproj")!
            bundle = Bundle(path: _path)!
        }
        return (bundle.specialLocalizedStringForKey(key: key, value: value, table: tableName))
    }
}
/// Exchange the implementation of two methods for the same Class
func MethodSwizzleGivenClassName(cls: AnyClass, originalSelector: Selector, overrideSelector: Selector) {
    let origMethod: Method = class_getInstanceMethod(cls, originalSelector)!;
    let overrideMethod: Method = class_getInstanceMethod(cls, overrideSelector)!;
    if (class_addMethod(cls, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(cls, overrideSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, overrideMethod);
    }

}
