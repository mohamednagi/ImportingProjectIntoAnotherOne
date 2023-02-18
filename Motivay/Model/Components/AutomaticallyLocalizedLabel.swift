//
//  AutomaticallyLocalizedLabel.swift
//  Motivay
//
//  Created by Yasser Osama on 2/26/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit

class AutomaticallyLocalizedLabel: UILabel {
    
    override func awakeFromNib() {
        self.text =  self.text!.y_localized
        //self.adjustAutoAlignment()
        adjustFont()
        adjustAutoAlignment()
    }
    
    func adjustFont(){
        
        if UserSettings.appLanguageIsArabic() {
            self.font = UIFont(name:Constants.fontNameConvertedToArabic(fromFontName: self.font.fontName), size:self.font.pointSize)
        }else{
            
//            self.font = UIFont(name:Constants.fontNameConvertedToEnglish(fromFontName: self.font.fontName), size:self.font.pointSize)
            self.font = UIFont.systemFont(ofSize: self.font.pointSize)
        }
    }
    
    /*override var text: String? {
        didSet {
            adjustFont()
        }
    }*/
    
    /*var autoAlign: Bool = false {
        didSet {
//            if let text = text {
//                println("Text changed.")
//            } else {
//                println("Text not changed.")
//            }
            self.adjustAutoAlignment()
        }
    }*/
    
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
