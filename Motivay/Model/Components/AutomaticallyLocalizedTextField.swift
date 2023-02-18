//
//  AutomaticallyLocalizedTextField.swift
//  Motivay
//
//  Created by Yasser Osama on 2/26/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit
import Material

class AutomaticallyLocalizedTextField: TextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UserSettings.appLanguageIsArabic() && self.font != nil {
            self.font = UIFont(name:Constants.fontNameConvertedToArabic(fromFontName: self.font!.fontName), size:self.font!.pointSize)
        }
        
        adjustAutoAlignment()
    }
    
    
    func adjustAutoAlignment(){
        if self.textAlignment != .center/* && autoAlign*/ {
            DeveloperTools.print("auto align")
            if UserSettings.appLanguageIsArabic() {
                self.textAlignment = .right
            }else{
                
                self.textAlignment = .left
            }
        }
    }
}
