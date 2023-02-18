//
//  Utilities.swift
//
//  Created by Yehia Elbehery.
//


import UIKit

struct Utilities {
    
    static func storyboard(withName name: String, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: bundle)
    }
    
    static func screedHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    static func screedWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    
    static func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
//    public func loadJSON() -> JSON {
//        let defaults = NSUserDefaults.standardUserDefaults()
//        return JSON.parse(defaults.valueForKey("json") as! String))
//        // JSON from string must be initialized using .parse()
//    }
    
    static func saveString(_ str: String, toFile: String){
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let path = dir.appendingPathComponent(toFile)
            
            //writing
            do {
                try str.write(to: path, atomically: false, encoding: String.Encoding.utf8)
            }
            catch {/* error handling here */}
        }
    }
    
    static func readString(fromFile: String) -> String? {
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let path = dir.appendingPathComponent(fromFile)
            //reading
            do {
                return try String(contentsOf: path, encoding: String.Encoding.utf8)
            }
            catch {
               DeveloperTools.print("readString failed")
            }
        }
        
        return nil
    }
    
    static func saveJSON(_ json: Any, toFile: String){
        if FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first != nil {
            var str: String?
            
            do {
                var data1: Data = Data()
                if let jsonObj = json as? JSON {
                    data1 =  try JSONSerialization.data(withJSONObject: jsonObj, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
                } else if let jsonArray = json as? JSONArray {
                    data1 =  try JSONSerialization.data(withJSONObject: jsonArray, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
                    
                } else {
                   DeveloperTools.print("saveJSON not an object not an array")
                }
                
                str = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            }
            catch {
               DeveloperTools.print("saveJSON catch error")
            }
            if str == nil {
               DeveloperTools.print("saveJSON failed")
            }else{
                Utilities.saveString(str!, toFile: toFile)
            }
        }
    }
    
    
    static func readJSON(fromFile: String) -> JSON? {
        
        let str = Utilities.readString(fromFile: fromFile)
        if str == nil {
           DeveloperTools.print("readJSON: readString Failed ")
        }else{
            let data = str!.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            
//            var json: JSON?
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                    return json
                }else{
                   DeveloperTools.print("readJSON json parse failed")
                }
            } catch let error as NSError {
               DeveloperTools.print("readJSON Failed: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    
    static func readJSONArray(fromFile: String) -> JSONArray? {
        
        let str = Utilities.readString(fromFile: fromFile)
        if str == nil {
           DeveloperTools.print("readJSON: readString Failed ")
        }else{
            let data = str!.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSONArray {
                    return json
                }else{
                   DeveloperTools.print("readJSON json parse failed")
                }
            } catch let error as NSError {
               DeveloperTools.print("readJSON Failed: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    static func getAppVersion() -> String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    static func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
    
    static func deviceIs_iPhone5() -> Bool{
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            return true
            break
        default:
            return false
        }
    }
    
    static func getOsVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    static func instantiateType(fromString string: String) -> AnyClass? {
        guard let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String else {
            return nil
        }
        
        return NSClassFromString("\(namespace).\(string)")
    }
    
    static func openAppStoreWith(appId: String){
        
        let url = URL(string: "https://itunes.apple.com/us/app/apple-store/id" + Constants.appStoreId + "?mt=8")
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url!)
        }
    }
    
    static func suffixNumber(number: NSNumber) -> String {
        
        var num:Double = number.doubleValue
        let sign = ((num < 0) ? "-" : "" )
        
        num = fabs(num);
        
        if (num < 1000.0) {
            let intNum = Int(num)
            return "\(sign)\(intNum)"
        }
        
        let exp:Int = Int(log10(num) / 3.0 ); //log10(1000));
        
        var units:[String]
        if UserSettings.appLanguageIsArabic() {
            units  = ["أ",
                      "م",
                      "مل",
                      "ت",
                      "كواد",
                      "كوينت"];
        } else {
            units  = ["K","M","B","TR","Quad","Quint"];
        }
        
        let roundedNum:Double = round(10 * num / pow(1000.0,Double(exp))) / 10
        let roundedInt = Int(roundedNum)
        return "\(sign)\(roundedInt)\(units[exp-1])"
    }
}
