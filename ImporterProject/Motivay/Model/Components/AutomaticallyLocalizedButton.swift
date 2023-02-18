//
//  AutomaticallyLocalizedButton.swift
//  Motivay
//
//  Created by Yasser Osama on 2/26/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit

class AutomaticallyLocalizedButton: UIButton {
    
    override func awakeFromNib() {
        self.setTitle(self.currentTitle!.y_localized, for: .normal)
        
        if UserSettings.appLanguageIsArabic() && self.titleLabel != nil {
//            print(Constants.fontNameConvertedToArabic(fromFontName: self.titleLabel!.font.fontName), " [", self.titleLabel!.font.pointSize, "]")
            self.titleLabel!.font = UIFont(name:Constants.fontNameConvertedToArabic(fromFontName: self.titleLabel!.font.fontName), size:self.titleLabel!.font.pointSize)!
        }
    }
}
