//
//  Validation.swift
//
//  Created by Yehia Elbehery.
//



import Foundation


class Validation {
    
    
    // ==================================
    // ==== Name validation methods ====
    // ==================================
    
    class func isValidName(_ name: String?) -> Bool {
        if name == nil {
            return false
        }else{
            
            if (name!.count < 3 ||
                name!.count > 25
                ) {
                return false
            }
            
            return  true
        }
    }
    
    // ==================================
    // ==== Email validation methods ====
    // ==================================
    
    class func isValidEmail(_ email: String?) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        guard NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email) else {
            return false
        }
        return true
    }
    
    
    // ==================================
    // ==== Phone validation methods ====
    // ==================================
    
    class func isValidPhoneNo(_ phone: String?) -> Bool {
        if phone == nil {
            return false
        }else{
//            if phone!.characters.count != 11 {
//                return false
//            }else{
            do {
                let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
                let matches = detector.matches(in: phone!, options: [], range: NSMakeRange(0, phone!.count))
                if let res = matches.first {
                    return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == phone!.count/* && self.characters.count == 10*/
                } else {
                    return false
                }
            } catch {
                return false
            }
                
//                let index = phone!.index(phone!.startIndex, offsetBy: 3)
//                let providerPrefix = phone!.substring(to: index)
//            
//                if (providerPrefix != "010" &&
//                    providerPrefix != "011" &&
//                    providerPrefix != "012"
//                ) {
//                    return false
//                }
//                
//                let charcter  = CharacterSet(charactersIn: "0123456789").inverted
//                var filtered: String!
//                let inputString:[String] = phone!.components(separatedBy: charcter)
//                
//                filtered = inputString.joined(separator: "") as String!
//            
//                
//                return  phone == filtered
//             }
        }
    }
    
    // ==================================
    // ==== Number validation methods ====
    // ==================================
    
    class func isValidDecimal(_ number: String?) -> Bool {
        
        if number == nil {
            return false
        }else{
            let regex = "[0-9-]+"
            guard NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: number) else {
                return false
            }
            return true
        }
    }
    
}
