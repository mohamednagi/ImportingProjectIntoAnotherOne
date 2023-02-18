//
//  Fonts.swift
//  Motivay
//
//  Created by Yasser Osama on 8/29/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import Foundation

class Fonts {
    
    static var bravo = "Bravo"
    static var bravos = "Bravos"
    static var awesome = "Awesome!"
    static var sayBravo = "Say Bravo"
    static var congratulations = "Congratulations"
    static var introLabel = ""
    static var saidBravo = "Said Bravo"
    
    static var regularFont: String {
        if UserSettings.appLanguageIsArabic() {
            return "GESSTwoLight-Light"
        } else {
            return "SanFranciscoText-Regular"
        }
    }
    static var mediumFont: String {
        if UserSettings.appLanguageIsArabic() {
            return "GESSTwoMedium-Medium"
        } else {
            return "SanFranciscoText-Medium"
        }
    }
    static var boldFont: String {
        if UserSettings.appLanguageIsArabic() {
            return "GESSTwoBold-Bold"
        } else {
            return "SanFranciscoText-Bold"
        }
    }
}
