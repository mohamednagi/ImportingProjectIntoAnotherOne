//
//  Post.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import ObjectMapper
import SDWebImage


class Post: ValidatableStruct, Mappable {
    var PostId: Int!
    var From : String? = ""
    var FromFullName: String = ""
    var FromPic : String?
    var FromUserId: String!
    var ImagePost: String!
    var IsAllowedForBravo: Bool!
    var ListOfComments: [PostComment]?
    var ListOfTags: [Hashtag]?
    var AwardDescription : String!
    var CreationDate : String!
    var To : String!
    var ToFullName : String!
    var ToPic : String?
    var ToUserId: String!
    var NumberOfComments : Int!
    var NumberOfSayBravo : Int!
    var TotalPoints: Int!
    var iSaidBravo: Bool = false
    var IsPinned: Bool = false
    var listOfBravos: [BravoPerson]?
    
    //custom
    var hasImage : Bool?
    
    required init(map: Map) {
        super.init(map: map)
    }
    func mapping(map: Map) {
        
        self.PostId <- map["PostId"]
        self.From <- map["From"]
        self.FromFullName <- map["FromFullName"]
        self.FromPic <- map["FromPic"]
        self.FromUserId <- map["FromUserId"]
        self.ImagePost <- map["ImagePost"]
        self.IsAllowedForBravo <- map["IsAllowedForBravo"]
        self.ListOfComments <- map["ListOfComments"]
        self.ListOfTags <- map["ListOfTags"]
        self.AwardDescription <- map["AwardDescription"]
        self.CreationDate <- map["CreationDate"]
        self.To <- map["To"]
        self.ToFullName <- map["ToFullName"]
        self.ToPic <- map["ToPic"]
        self.ToUserId <- map["ToUserId"]
        self.NumberOfComments <- map["NumberOfComments"]
        self.NumberOfSayBravo <- map["NumberOfSayBravo"]
        self.TotalPoints <- map["TotalPoints"]
        self.iSaidBravo <- map["ILikedPost"]
        self.IsPinned <- map["IsPinned"]
        self.listOfBravos <- map["ListOfBravoes"]
        
        //            if arc4random_uniform(2) == 0 {
//        if self.From == "Yehia" {
//            self.ImagePost = "https://camo.mybb.com/e01de90be6012adc1b1701dba899491a9348ae79/687474703a2f2f7777772e6a71756572797363726970742e6e65742f696d616765732f53696d706c6573742d526573706f6e736976652d6a51756572792d496d6167652d4c69676874626f782d506c7567696e2d73696d706c652d6c69676874626f782e6a7067"
//        }
        /*if self.ImagePost == nil {
            self.hasImage = false
        }else{
            SDWebImageManager.shared().downloadImage(with: URL(string:self.ImagePost!), options: [], progress: { (recieved, expected) in
            }, completed: { (image, error, cacheType, finished, url) in
                if image == nil {
                    
                    self.hasImage = false
                }else{
                    
                    self.hasImage = true
                }
            })
        }*/
        
    }
}

class Hashtag: ValidatableStruct, Mappable {
    var Id : Int!
    var Name : String!
    var Color : String!
    var Image : String!
    var NumberOfPosts: Int!
    
    var isSelectedInFilter: Bool = false
    
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
        self.Image <- map["Image"]
        self.NumberOfPosts <- map["NumberOfPosts"]

    }
}

class Employee: ValidatableStruct, Mappable {
    var Email : String?
    var FullName : String = ""
    var Id : String!
    var ProfileURL : String?
    var UserName : String = ""
    var UserSource : Int?
    var UserStatus : Int?
    
    var DepartmentId : Int = 0
    var ManagerName : String = ""
    var MobileNumber : String = ""
    var PhoneNumber : String = ""
    var ProfilePicture: String = ""
    var TotalPoints: Int = 0
    
    var userID: String!
    var Department: String = ""
    var Position: String = ""
    var ProfileStatus: String = ""
    var JoinDate: String = ""
    var EarnedPoints: Int = 0
    var Balance: Int = 0
    var Facebook: String = ""
    var Twitter: String = ""
    var LinkedIn: String = ""
    
    var AwardPointVM: AwardPointVM?
    
    var appSettings: AppSettings?
    var isSelectedInFilter: Bool = false
    
    required init(map: Map) {
        super.init(map: map)
    }
    func mapping(map: Map) {
        
        self.Email <- map["Email"]
        self.FullName <- map["FullName"]
        
        self.Id <- map["Id"]
        self.userID <- map["UserID"]
        
        self.ProfileURL <- map["ProfileURL"]
        self.UserName <- map["UserName"]
        self.UserSource <- map["UserSource"]
        self.UserStatus <- map["UserStatus"]
        
        self.Department <- map["Department"]
        self.DepartmentId <- map["DepartmentId"]
        self.MobileNumber <- map["MobileNumber"]
        self.Position <- map["Position"]
        self.ProfileStatus <- map["UserFeeling"]
        self.JoinDate <- map["JoinDate"]
        self.EarnedPoints <- map["EarnedPoints"]
//        if DeveloperTools.debugMode {
//                self.EarnedPoints = 500
//        }
        self.Balance <- map["Balance"]
        self.Facebook <- map["faceBook"]
        self.Twitter <- map["Twitter"]
        self.LinkedIn <- map["Linkedin"]
        self.ProfilePicture <- map["ProfileImage"]
        self.AwardPointVM <- map["AwardPointVM"]
        
        //
        if self.Id != nil {
            self.userID = self.Id
        }else if self.userID != nil {
            self.Id = self.userID
        }
    }
}

class AppSettings: ValidatableStruct, Mappable {
    
    var EmailNotification : Bool!
    var PushNotification : Bool!
    var UserLanguage: Int!
    
    required init(map: Map) {
        super.init(map: map)
    }
    func mapping(map: Map) {
        
        self.EmailNotification <- map["EmailNotification"]
        self.PushNotification <- map["PushNotification"]
        self.UserLanguage <- map["UserLanguage"]
        
    }
}

class Department: ValidatableStruct, Mappable {
    var Id : Int!
    var Name : String!
    var NumberOfEmployee: Int!
    var Image : String?
    
    var isSelectedInFilter: Bool = false
    
    required init(map: Map) {
        super.init(map: map)
    }
    func mapping(map: Map) {
        
        self.Id <- map["Id"]
        self.Name <- map["Name"]
        self.Image <- map["Image"]
        self.NumberOfEmployee <- map["NumberOfEmployee"]
        
    }
}

class AwardPointVM: ValidatableStruct, Mappable {
    var TotalPoints: Int!
    var MonthPoints: Int!
    
    required init(map: Map) {
        super.init(map: map)
    }
    
    func mapping(map: Map) {
        self.TotalPoints <- map["TotalPoints"]
        self.MonthPoints <- map["MonthPoints"]
    }
}

enum ThankYouApprovalStatus : Int {
    case approved = 1, pending = 2
}

class ThankYouResponse: ValidatableStruct, Mappable {
    var Points: Int!
    var ApprovalStatus: ThankYouApprovalStatus!
    
    required init(map: Map) {
        super.init(map: map)
    }
    
    func mapping(map: Map) {
        self.Points <- map["Points"]
        self.ApprovalStatus <- map["ApprovalStatus"]
    }
}

class BravoPerson: Mappable {
    var fullName: String!
    var userId: String!
    var userImage: String!
    var userName: String!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        fullName <- map["FullName"]
        userId <- map["From"]
        userImage <- map["UserImage"]
        userName <- map["UserName"]
    }
}
