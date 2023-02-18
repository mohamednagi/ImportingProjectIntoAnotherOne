//
//  Star.swift
//  Motivay
//
//  Created by Yasser Osama on 3/15/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import Foundation
import ObjectMapper

class Star: Mappable {
    
    var Title: StarTitle!
    var Rank: Int!
    var Value: Int!
    var UserId: String!
    var UserName: String?
    var UserFullName: String?
    var UserImage: String = ""
    
    required init?(map: Map) {
//        super.init(map: map)
    }
    
    func mapping(map: Map) {
        self.Title <- map["Title"]
        self.Rank <- map["Rank"]
        self.Value <- map["Value"]
        self.UserId <- map["UserId"]
        self.UserName <- map["UserName"]
        self.UserFullName <- map["UserFullName"]
        self.UserImage <- map["UserImage"]
    }
}

enum StarTitle: Int {
    case performer = 0, giver, posting, contributor
}

class MyStats: Mappable {
    
    var EarnedPoints: Int!
    var SentPoints: Int!
    var TotalPosts: Int!
    var SaidBravo: Int!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.EarnedPoints <- map["EarnedPoints"]
        self.SentPoints <- map["SentPoints"]
        self.TotalPosts <- map["TotalPosts"]
        self.SaidBravo <- map["SaidBravo"]
    }
}
