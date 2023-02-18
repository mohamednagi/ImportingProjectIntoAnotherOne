//
//  ValidatableStruct.swift
//
//  Created by Yehia Elbehery.
//

import Foundation
import ObjectMapper

class ValidatableStruct {
    
    var allExpectedKeysExist: Bool = true
    
    required init(map: Map) {
        let pokeMirror = Mirror(reflecting: self)
        let properties = pokeMirror.children
        
        for property in properties {
            let childMirror = Mirror(reflecting: property.value)
            if childMirror.displayStyle == .optional {
                
            }else{
//                DeveloperTools.print("v: non optional key ", property.label, "equals: ", map.JSON[property.label!])
                if map.JSON[property.label!] == nil {
                    allExpectedKeysExist = false
                }
            }
        }
    }
}
