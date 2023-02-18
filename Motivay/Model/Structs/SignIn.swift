//
//  Post.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import ObjectMapper

class SignInResponse: ValidatableStruct, Mappable {
    var success : Bool!
    
    required init(map: Map) {
        super.init(map: map)
    }
    func mapping(map: Map) {
        
        self.success <- map["success"]

    }}

class ForgotResponse: ValidatableStruct, Mappable {
    var success : Bool!
    
    required init(map: Map) {
        super.init(map: map)
    }
    func mapping(map: Map) {
        
        self.success <- map["success"]
        
    }}

class ResetResponse: ValidatableStruct, Mappable {
    var success : Bool!
    
    required init(map: Map) {
        super.init(map: map)
    }
    func mapping(map: Map) {
        
        self.success <- map["success"]
        
    }}
