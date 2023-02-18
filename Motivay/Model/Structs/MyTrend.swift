//
//  Post.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import ObjectMapper


class MyTrend: ValidatableStruct, Mappable {
    var Id : Int!
    var Name : String!
    var Color : String!
    
    var PointsPerMonth : Int!
    var Scale : Int!
    var TaggedTime : Int!
    var TotalPoints : Int!
    
    required init(map: Map) {
        super.init(map: map)
    }
    func mapping(map: Map) {
        
        self.Id <- map["Id"]
        if UserSettings.appLanguageIsArabic() {
            self.Name <- map["NameAr"]
            if self.Name == nil {
                //temp fix
                self.Name <- map["Name"]
            }
        }else{
            self.Name <- map["Name"]
        }
        self.Color <- map["Color"]
        
        self.PointsPerMonth <- map["PointsPerMonth"]
        self.Scale <- map["Scale"]
        self.TaggedTime <- map["TaggedTime"]
        self.TotalPoints <- map["TotalPoints"]
        
    }
}
