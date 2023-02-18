//
//  NotificationModel.swift
//  Motivay
//
//  Created by Yasser Osama on 4/10/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import Foundation
import ObjectMapper

class NotificationModel: Mappable {
    
    var receiverId: String!
    var senderId: String!
    var receiverName: String!
    var senderName: String!
    var senderImage: String!
    var awardId: Int!
    var type: NotificationType!
    
    var actionerId: String!
    var actionerName: String!
    var actionerImage: String!
    var actionerCount: Int!
    
    var tags: [String]?
    var points: Int!
    var date: String!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        receiverId <- map["AwardReceiverId"]
        senderId <- map["AwardSenderId"]
        receiverName <- map["AwardReceiverName"]
        senderName <- map["AwardSenderName"]
        senderImage <- map["AwardSenderImage"]
        awardId <- map["AwardId"]
        type <- map["Type"]
        actionerId <- map["ActionerId"]
        actionerName <- map["ActionerName"]
        actionerCount <- map["ActionerCount"]
        tags <- map["Tags"]
        points <- map["Points"]
        actionerImage <- map["ActionerProfile"]
        date <- map["Date"]
    }
}

enum NotificationType: Int {
    case approved = 0, pinned, thanks, comment, like, star, sendThreshold, receiveThreshold, rejected
}
