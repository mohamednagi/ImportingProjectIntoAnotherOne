//
//  GeneralSettings.swift
//  Motivay
//
//  Created by Yasser Osama on 9/19/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import Foundation
import ObjectMapper

class ApplicationSettings: Mappable {
    
    var parameterId: Int!
    var parameterName: String!
    var parameterValue: String!
    var parameterType: Int!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        parameterId <- map["ParameterId"]
        if UserSettings.appLanguageIsArabic() {
            parameterName <- map["ParameterNameAr"]
        } else {
            parameterName <- map["ParameterName"]
        }
        parameterValue <- map["ParameterValue"]
        parameterType <- map["ParameterType"]
    }
}
