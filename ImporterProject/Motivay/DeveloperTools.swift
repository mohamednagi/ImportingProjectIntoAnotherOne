//
//  DeveloperTools.swift
//
//  Created by Yehia Elbehery.
//


import Foundation
import UIKit

enum BackendInstance {
    case Dev
    case QC
    case Demo
    case GEA
    case Thiqah //UAT
    case ThiqahNew //Live
    case Kafu
    case MotivayPOC
    case Monshaat
    case MonshaatNew
    case Elm_Demo
    case Adam
    case Youxel
    case Wssel
    case GAZT
    case Tremvo
    case Phenix
    case TremvoDemo
}

class DeveloperTools {

    static var debugMode = false
    
//    static let backendInstance: BackendInstance = .Adam
    #if MOTIVAY_DEV
    static let backendInstance: BackendInstance = .Dev
    #endif
    #if MOTIVAY_QC
    static let backendInstance: BackendInstance = .Phenix
    #endif
    #if MOTIVAY_DEMO
    static let backendInstance: BackendInstance = .Demo
    #endif
    #if THIQAH
    static let backendInstance: BackendInstance = .Kafu
    #endif
    #if ADAM
    static let backendInstance: BackendInstance = .Adam
    #endif
    #if CERQEL
    static let backendInstance: BackendInstance = .Demo
    #endif
    #if GAZT
    static let backendInstance: BackendInstance = .GAZT
    #endif
    #if Tremvo
    static let backendInstance: BackendInstance = .Dev
    #endif
    
//    static let commentOut : Bool = {
//        return debugMode
//    }()
//    static let useQCEnvironment = false
    
    static func findTheOne(view: UIView?){
        if DeveloperTools.debugMode == true && view != nil {
            let theOne = TheOne(frame:CGRect(x:0, y:20, width:44, height:44))
            theOne.isHidden = false
            theOne.backgroundColor = .green
            theOne.accessibilityIdentifier = "TheOne"
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            view!.addSubview(theOne)
            view!.bringSubview(toFront: theOne)
        }
    }
    
    static func readJSONFromBundle(fromFile : String) -> JSON? {
        do {
            if let file = Bundle.main.url(forResource: fromFile, withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? JSON {
                    // json is a dictionary
//                   DeveloperTools.print(object)
                    return object
//                } else if let object = json as? [Any] {
//                    // json is an array
//                    //print(object)
//                    return object
                } else {
                    DeveloperTools.print("JSON is invalid")
                    return nil
                }
            } else {
                DeveloperTools.print("no file")
                return nil
            }
        } catch {
            DeveloperTools.print("JSON Error: "+error.localizedDescription)
            return nil
        }
    }
    
    static func readJSONArrayFromBundle(fromFile : String) -> JSONArray? {
        do {
            if let file = Bundle.main.url(forResource: fromFile, withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? JSONArray {
                    // json is a dictionary
                    //                   DeveloperTools.print(object)
                    return object
                    //                } else if let object = json as? [Any] {
                    //                    // json is an array
                    //                    //print(object)
                    //                    return object
                } else {
                    DeveloperTools.print("JSON is invalid")
                    return nil
                }
            } else {
                DeveloperTools.print("no file")
                return nil
            }
        } catch {
            DeveloperTools.print("JSON Error: "+error.localizedDescription)
            return nil
        }
    }
    
    static func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let output = items.map { "*\($0)" }.joined(separator: separator)
        if debugMode {
            Swift.print(output, terminator: terminator)
        }
    }
    
    static func printAnyway(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let output = items.map { "*\($0)" }.joined(separator: separator)
            Swift.print(output, terminator: terminator)
    }
}
