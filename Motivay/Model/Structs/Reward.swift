//
//  Reward.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import ObjectMapper


class Reward: ValidatableStruct, Mappable {
    var RewardId : Int!
    var RewardName : String!
//    var RewardNameAr : String!
    var RewardDescription : String?
//    var RewardDescriptionAr : String?
    var RewardTypeId : Int!
    var RewardsPoints : Int!
    var NumberOfRedeemtion: Int?
    
    var VendorId : String!
    var VendorName : String!
//    var VendorNameAr : String!
    var VendorImage: String!
    
    var RewardImage : String!
    
    var IsBookmarked : Bool!
    var IsRedeemed : Bool!
    
    var RedeemDate: String!
    
    var redemptionDate: String!
    var redemptionCode: Int!
    var redemptionState: RedemptionState!
    
    required init(map: Map) {
        super.init(map: map)
    }
    func mapping(map: Map) {
        
        self.RewardId <- map["RewardId"]
        
        if UserSettings.appLanguageIsArabic() {
            self.RewardName <- map["RewardNameAr"]
            self.VendorName <- map["VendorNameAr"]
            self.RewardDescription <- map["RewardDescriptionAr"]
        }else{
            self.RewardName <- map["RewardName"]
            self.RewardDescription <- map["RewardDescription"]
            self.VendorName <- map["VendorName"]
        }
        self.VendorImage <- map["VendorImage"]
        self.RewardTypeId <- map["RewardTypeId"]
        self.RewardsPoints <- map["RewardsPoints"]
        self.NumberOfRedeemtion <- map["NumberOfRedeemtion"]
        
        self.VendorId <- map["VendorId"]
        
        self.RewardImage <- map["RewardImage"]
        
        self.IsBookmarked <- map["IsBookmarked"]
        self.IsRedeemed <- map["IsRedeemed"]
        
        self.RedeemDate <- map["RedeemDate"]
        
        self.redemptionDate <- map["RedemptionDate"]
        self.redemptionCode <- map["RedemptionCode"]
        self.redemptionState <- map["RedemptionState"]
    }
}

enum RedemptionState: Int {
    case requested = 1, inProgress, delivered
}


class RewardsSubCategory: ValidatableStruct, Mappable {
    var RewardTypeId : Int!
    var RewarTypedName : String!
//    var RewardTypeNameAr : String!
    var RewardsList: [Reward]!
    
    required init(map: Map) {
        super.init(map: map)
    }
    func mapping(map: Map) {
        
        self.RewardTypeId <- map["RewardTypeId"]
        if UserSettings.appLanguageIsArabic() {
            self.RewarTypedName <- map["RewardTypeNameAr"]
        }else{
            self.RewarTypedName <- map["RewarTypedName"]
        }
        self.RewardsList <- map["RewardsList"]
        
    }
}
