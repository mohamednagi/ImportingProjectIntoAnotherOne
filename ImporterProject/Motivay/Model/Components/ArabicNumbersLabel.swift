//
//  ArabicNumbersLabel.swift
//
//  Created by Yehia Elbehery.
//

import UIKit

class ArabicNumbersLabel: AutomaticallyLocalizedLabel {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        replaceEnglishNumbersWithArabicNumbers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        replaceEnglishNumbersWithArabicNumbers()
    }
    
    override var text: String? {
        didSet {
            replaceEnglishNumbersWithArabicNumbers()
        }
    }
    
    func replaceEnglishNumbersWithArabicNumbers(){
        
        if text != nil {
        
        if UserSettings.appLanguageIsArabic() {
            
            let arabicNumbers = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
            let englishNumbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
            _ = englishNumbers.enumerated().map({ (index, element) in
                if self.text!.replacingOccurrences(of: element, with: arabicNumbers[index]) != self.text {
                    self.text = self.text!.replacingOccurrences(of: element, with: arabicNumbers[index])
                }
                
            })
        }
        }
    }
    
}
