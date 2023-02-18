//
//  Fonts.swift
//  Motivay
//
//  Created by Yasser Osama on 8/29/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import Foundation

class Fonts {
//    static var regularFont = "TanseekModernProArabic-Light"
//    static var mediumFont = "TanseekModernProArabic-Medium"
//    static var boldFont = "TanseekModernProArabic-Bold"
    
    static var bravo = "Kafu"
    static var bravos = "Kafu"
    static var awesome = "Kafu"
    static var sayBravo = "Kafu"
    static var congratulations = "Kafu"
    static var introLabel = "KAFU"
    static var saidBravo = "Said Kafu"
    
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
