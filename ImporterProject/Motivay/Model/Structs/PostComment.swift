//
//  Post.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import ObjectMapper


class PostComment: ValidatableStruct, Mappable {
    var Id: Int!
    var From : String!
    var UserName : String!
    var FullName : String!
    var UserImage : String?
//    var FromUserId: String!
    var Message : String!
    var CreationDate : String!
    var ModificationDate : String!
    
    //custom
    var isMyComment: Bool = false
    var showMore: Bool = false
    
    required init(map: Map) {
        super.init(map: map)
    }
    func mapping(map: Map) {
        
        self.Id <- map["Id"]
        self.From <- map["From"]
        self.UserName <- map["UserName"]
        self.FullName <- map["FullName"]
        self.UserImage <- map["UserImage"]
        self.Message <- map["Message"]
        
        self.CreationDate <- map["CreationDate"]
        self.ModificationDate <- map["ModificationDate"]
        
    }
}
