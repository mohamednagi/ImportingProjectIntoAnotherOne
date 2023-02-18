//
//  String.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
extension UnicodeScalar {
    
    var isEmoji: Bool {
        
        switch value {
        case 0x1F600...0x1F64F, // Emoticons
        0x1F300...0x1F5FF, // Misc Symbols and Pictographs
        0x1F680...0x1F6FF, // Transport and Map
        0x1F1E6...0x1F1FF, // Regional country flags
        0x2600...0x26FF,   // Misc symbols
        0x2700...0x27BF,   // Dingbats
        0xFE00...0xFE0F,   // Variation Selectors
        0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
        65024...65039, // Variation selector
        8400...8447: // Combining Diacritical Marks for Symbols
            return true
            
        default: return false
        }
    }
    
    var isZeroWidthJoiner: Bool {
        
        return value == 8205
    }
}
extension String {
    
    
    var y_containsEmoji: Bool {
        
        return unicodeScalars.contains { $0.isEmoji }
    }
    
    var y_trimmed: String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var y_localized: String {
//        return NSLocalizedString(self, comment: self)
        let path = Bundle.main.path(forResource: UserSettings.getLanguage(), ofType: "lproj")
        if path == nil {
            return self
        }else{
            let bundle = Bundle(path: path!)
            
            return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
        }
    }
    
    public func y_replaceFirst(of pattern:String,
                             with replacement:String) -> String {
        if let range = self.range(of: pattern){
            return self.replacingCharacters(in: range, with: replacement)
        }else{
            return self
        }
    }
    
    public func y_replaceFirst(of pattern:String,
                               with replacement:String, inRange: Range<String.Index>) -> String {
        if let range = self.range(of: pattern, options: [], range: inRange){
            return self.replacingCharacters(in: range, with: replacement)
        }else{
            return self
        }
    }
    
    func y_containsIgnoringCase(_ find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    func y_containsNumbers() -> Bool{
        return self.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    func y_getonlyDateFromString() -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone =  TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: self)
        {
            return date
        }
        return dateFormatter.date(from: self)!
    }
    
    func y_getDateFromString() -> Date?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") //TimeZone.current//
        dateFormatter.locale = Locale(identifier: "en_US")
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: self) {
            return date
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSZ"
        if let date = dateFormatter.date(from: self) {
            return date
        }
        

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
        if let date = dateFormatter.date(from: self) {
//            DeveloperTools.print("raw == ", self)
//            DeveloperTools.print("then == ", dateFormatter.date(from: dateFormatter.string(from: date)))
            return dateFormatter.date(from: dateFormatter.string(from: date))//date
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        if let date = dateFormatter.date(from: self) {
            return date
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = dateFormatter.date(from: self) {
            return date
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: self) {
            return date
        }
        
        
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss ZZ"
        if let date = dateFormatter.date(from: self) {
            return date
        }
        
        
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss ZZ"
        if let date = dateFormatter.date(from: self) {
            return date
        }

        //            DeveloperTools.print("then == ", dateFormatter.date(from: dateFormatter.string(from: date)))
        dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
//        DeveloperTools.print(dateFormatter.string(from: Date()))
        if let date = dateFormatter.date(from: self) {
            return date
        }
        return nil
    }
    func y_toJson() -> [String: Any]?
    {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                return json!
            } catch {
               DeveloperTools.print("Something went wrong")
            }
        }
        return nil
    }
    func y_heightForWithFont() -> CGFloat {
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.text = self
        label.sizeToFit()
        return label.frame.height
    }
    
    
    func y_truncate(toLength: Int, trailing: String = /*"…"*/"...") -> String {
        if self.count > toLength {
            return String(self.characters.prefix(toLength)) + trailing
        } else {
            return self
        }
    }
    
    
    func y_countInstances(of stringToFind: String) -> Int {
        assert(!stringToFind.isEmpty)
        var searchRange: Range<String.Index>?
        var count = 0
        while let foundRange = range(of: stringToFind, options: .diacriticInsensitive, range: searchRange) {
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
            count += 1
        }
        return count
    }
    
    func y_withLanguageDirectionInvisibleMarksAdded() -> String {
        
        var awardDescriptionWords = self.components(separatedBy: " ")
        var currentLangIsArabic = self.y_firstAlphabetIsArabic()
        for i in 0 ..< awardDescriptionWords.count {
            let word = awardDescriptionWords[i]
            if currentLangIsArabic != word.y_firstAlphabetIsArabic() {
                if word.y_firstAlphabetIsArabic() {
                    awardDescriptionWords[i] = "\u{202B}\(awardDescriptionWords[i])"
                    currentLangIsArabic = true
                }else{
                    
                    awardDescriptionWords[i] = "\u{200E}\(awardDescriptionWords[i])"
                    currentLangIsArabic = false
                }
            }
        }
        return awardDescriptionWords.joined(separator: " ")
    }
    
    mutating func y_removeLanguageDirectionInvisibleMarks() {
        self = self.y_replaceRegexMatches(pattern: "\u{202B}", replaceWith: "")
        self = self.y_replaceRegexMatches(pattern: "\u{200E}", replaceWith: "")
    }
    
    func y_firstAlphabetIsArabic() -> Bool! {
        if self.count > 0 {
            var charIndex : Int = 1
            var index = self.index(self.startIndex, offsetBy: 1)
            var isArabic = false
            if(self.range(of:"[ء-يa-zA-Z]", options: .regularExpression) != nil){
                while(self.prefix(upTo:index).range(of:"[ء-يa-zA-Z]", options: .regularExpression) == nil){
                    charIndex += 1
                    index = self.index(self.startIndex, offsetBy: charIndex)
                }
                
                //if(self.substring(to: index).range(of:"[ء-ي]", options: .regularExpression) != nil){
                if(self.prefix(upTo: index).range(of:"[ء-ي]", options: .regularExpression) != nil){
                    isArabic = true
                }
            }
            return isArabic
        }
        return false
    }
    
    func y_firstCharIsArabic() -> Bool! {
        if self.count > 0 {
//            var charIndex : Int = 1
            let index = self.index(self.startIndex, offsetBy: 1)
//            var isArabic = false
            if self.prefix(upTo:index).range(of:"[ء-ي]", options: .regularExpression) == nil {
                return true
            }
        }
        return false
    }
    
    func y_containsArabic() -> Bool! {
        if self.count > 0 {
            
            let index = self.index(self.startIndex, offsetBy: self.count)
            
            if self.prefix(upTo:index).range(of:"[ء-ي]", options: .regularExpression) == nil {
                return true
            }
        }
        return false
    }
    
    func substring(with nsrange: NSRange) -> String? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return String(self[range])
    }
    
    func y_isAlphabet() -> Bool {
        let letters = CharacterSet.letters
        for uni in self.unicodeScalars {
            if letters.contains(uni) == false {
                return false
            }
        }
        return true
    }
    
    func y_trimmedLength() -> Int {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).count//lengthOfBytes(using: .utf8)
    }
    
    func y_wordRangeAtIndex(_ index:Int, inString str:NSString) -> NSRange {
        let tagger = NSLinguisticTagger(tagSchemes: [NSLinguisticTagScheme.tokenType], options: 0)
        var r : NSRange = NSMakeRange(0,0)
        tagger.string = str as String
        tagger.tag(at: index, scheme: NSLinguisticTagScheme.tokenType, tokenRange: &r, sentenceRange: nil )
        return r
    }
    
    func y_wordAtIndex(_ index:Int) -> String? {
        return self.substring(with: y_wordRangeAtIndex(index, inString: self as NSString))
    }
    
    func toArabic() -> String {
        if UserSettings.appLanguageIsArabic() {
            let number = NSNumber(value: Int(self)!)
            let format = NumberFormatter()
            format.locale = Locale(identifier: "ar_SA")
            let arNumber = format.string(from: number)
            return arNumber!
        } else {
            return self
        }
    }
    
    func y_getLinesArrayOfString(in label: UILabel) -> [String] {
        
        /// An empty string's array
        var linesArray = [String]()
        
        guard let text = label.text, let font = label.font else {return linesArray}
        
        let rect = label.frame
        
        let myFont: CTFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        let attStr = NSMutableAttributedString(string: text)
        attStr.addAttribute(kCTFontAttributeName as NSAttributedStringKey, value: myFont, range: NSRange(location: 0, length: attStr.length))
        
        let frameSetter: CTFramesetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
        let path: CGMutablePath = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: rect.size.width, height: 100000), transform: .identity)
        
        let frame: CTFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        guard let lines = CTFrameGetLines(frame) as? [Any] else {return linesArray}
        
        for line in lines {
            let lineRef = line as! CTLine
            let lineRange: CFRange = CTLineGetStringRange(lineRef)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            let lineString: String = (text as NSString).substring(with: range)
            linesArray.append(lineString)
        }
        return linesArray
    }
    
    func y_getRegexMatches(pattern: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSMakeRange(0, self.count)
//            print("\(self) regex results: ", regex.matches(in: self, options: [], range: range).count)
            let matches = regex.matches(in: self, options: [], range: range).map {
                String(self[Range($0.range, in: self)!])}
            
            return matches
        } catch {
            return []
        }
    }
    
    func y_getRegexMatchesRanges(pattern: String) -> [NSRange] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, self.count)
            let matches = regex.matches(in: self, options: [], range: range).map {
                $0.range }
            
            return matches
        } catch {
            return []
        }
    }
    
    func y_replaceRegexMatches(pattern: String, replaceWith: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, self.count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch {
            return self
        }
    }
    
    func indices(of occurrence: String) -> [Int] {
        var indices = [Int]()
        var position = startIndex
        while let range = range(of: occurrence, range: position..<endIndex) {
            let i = distance(from: startIndex,
                             to: range.lowerBound)
            indices.append(i)
            let offset = occurrence.distance(from: occurrence.startIndex,
                                             to: occurrence.endIndex) - 1
            guard let after = index(range.lowerBound,
                                    offsetBy: offset,
                                    limitedBy: endIndex) else {
                                        break
            }
            position = index(after: after)
        }
        return indices
    }
    
    func ranges(of searchString: String) -> [Range<String.Index>] {
        let _indices = indices(of: searchString)
        let count = searchString.count
        return _indices.map({ index(startIndex, offsetBy: $0)..<index(startIndex, offsetBy: $0+count) })
    }
}
