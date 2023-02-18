//
//  Backend.swift
//
//  Created by Yehia Elbehery.
//


import UIKit

enum ValidationType {
    case email, text, password, motivayPassword//, number
}

class Backend {
    
    static private func validateAndClean(input: Any?, type: ValidationType, onFailure: @escaping () -> Void) -> Any? {
        
        switch type {
        case .email:
            if let input = input as? String {
                if Validation.isValidEmail(input.y_trimmed){
                    return input.y_trimmed
                }
            }
            onFailure()
            break
        case .text:
            if let input = input as? String {
                if input.y_trimmedLength() > 0 {
                    return input.y_trimmed
                }
            }
            onFailure()
            break
            
        case .password:
            if let input = input as? String {
                if input.count > 0 {
                    return input
                }
            }
            onFailure()
            break
            
        case .motivayPassword:
            
            if let input = input as? String {
                if input.count >= 6 &&
                    input.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil &&
                    input.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil &&
                    input.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil {
                        return input
                    
                }
            }
            onFailure()
            break
            //        case .number:
            //            break
        }
        return nil
    }
    
    static func signIn(email: String?, password: String?, validationErrorInInput: @escaping (Int) -> Void, completion: @escaping (Bool, BackendError?, Bool) -> Void, showLoading: Bool = true, useStub : Bool = false) {
        var validationSucceeded = true
        
        NetworkingController.authParams["username"] = Backend.validateAndClean(input: email, type: .text, onFailure: {
            if validationSucceeded {
            validationErrorInInput(0)
            validationSucceeded = false
            }
        }) as? String
        
        NetworkingController.authParams["password"] =  Backend.validateAndClean(input: password, type: .password, onFailure: {
            if validationSucceeded {
                validationErrorInInput(1)
                validationSucceeded = false
            }
        }) as? String
        
        if validationSucceeded {
            NetworkingController.logoutAccessTokenCleanUp()
            
            //        NetworkingController.headers = ["Content-Type":"application/json"]
            if showLoading {
//                LoadingOverlay.shared.showOverlay()
                LoadingOverlay.shared.showOverlay()
            }
            NetworkingController.generateAccessToken { (backendError, deactivated) in
                if showLoading {
                    LoadingOverlay.shared.hideOverlayView()
                }
                if backendError == nil {
                    
                    completion(true, backendError, deactivated)
                    
                }else{
                    
                    completion(false, backendError, deactivated)
                    
                }
            }
        }
    }
    
    
    static func forgot(email: String, validationErrorInInput: @escaping (Int) -> Void, completion: @escaping (String, Bool, BackendError?, String?) -> Void, showLoading: Bool = true, useStub : Bool = false) {
        
        var validationSucceeded = true
        
        var queryParameters = Dictionary<String, String>()
        
        queryParameters["emailOrUserName"] = Backend.validateAndClean(input: email, type: .text, onFailure: {
            if validationSucceeded {
            validationErrorInInput(0)
            validationSucceeded = false
            }
        }) as? String
        
        if validationSucceeded {
            let endpoint = "User/InitResetPassword"
            if showLoading {
                LoadingOverlay.shared.showOverlay()
            }
        NetworkingController.getJSON(endpoint: endpoint, _queryParameters: queryParameters, handler: { response, backendError in
            if showLoading {
                LoadingOverlay.shared.hideOverlayView()
            }
                            DeveloperTools.print("forgot response", response)
            if response == nil {
                completion("", false, backendError, nil)
            }else{
                
                if let success = response!["Success"] as? Bool {
                    
                    if success, let userId = response!["Data"] as? String {
//                        DeveloperTools.print(success, "???", userId)
                        completion(userId, true, backendError, nil)
                    }else{
                        
                        if let errors = response!["Errors"] as? NSArray {
                            var errorType : BackendError = .custom
                            var errorMessage = ""
                            if errors.count > 0 {
                                errorMessage = errors[0] as! String
                            }else{
                                errorType = .other
                            }
                            if UserSettings.appLanguageIsArabic() && errors.count > 1 {
                                errorMessage = errors[1] as! String
                            }
                            completion("", false, errorType, errorMessage)
                        }else{
                            completion("", false, .server, nil)
                        }
                    }
                }else{
                    
                    completion("", false, .server, nil)
                }
            }
            
        }, useStub: useStub)
        }
    }
    
    static func reset(token: String, userId: String, newPassword: String, validationErrorInInput: @escaping (Int) -> Void, completion: @escaping (Bool, BackendError?, String?) -> Void, showLoading: Bool = true, useStub : Bool = false) {
        
        var validationSucceeded = true
        
        var queryParameters = Dictionary<String, String>()
        
        queryParameters["UserId"] =  Backend.validateAndClean(input: userId, type: .text, onFailure: {
            if validationSucceeded {
            validationErrorInInput(0)
            validationSucceeded = false
            }
        }) as? String
        queryParameters["Token"] =  Backend.validateAndClean(input: token, type: .text, onFailure: {
            if validationSucceeded {
            validationErrorInInput(1)
            validationSucceeded = false
            }
        }) as? String
        queryParameters["NewPassword"] =  Backend.validateAndClean(input: newPassword, type: .motivayPassword, onFailure: {
            if validationSucceeded {
            validationErrorInInput(2)
            validationSucceeded = false
            }
        }) as? String
        
        if validationSucceeded {
        //        var useStub = true
        let endpoint = "User/ResetPassword"
            if showLoading {
                LoadingOverlay.shared.showOverlay()
            }
            
        NetworkingController.postJSON(endpoint: endpoint, _queryParameters: queryParameters, handler: { response, backendError in
            DeveloperTools.print("reset params:", queryParameters)
            DeveloperTools.print("reset response:", response)
            if showLoading {
                LoadingOverlay.shared.hideOverlayView()
            }
            if response == nil {
                DeveloperTools.print("reset response 1")
                completion(false, backendError, nil)
            }else{
                
                if let success = response!["Success"] as? Bool {
                    if success {
                        DeveloperTools.print("reset response 2")
                        completion(true, backendError, nil)
                    }else{
//                        DeveloperTools.print("reset response 3")
//                        if (response!["Errors"] as? NSArray) != nil {
//
//                            completion(false, .other)
//                        }else{
//                            DeveloperTools.print("reset response 4")
//                            completion(true, .server)
//                        }
                        if let errors = response!["Errors"] as? NSArray {
                            var errorType : BackendError = .custom
                            var errorMessage = ""
                            if errors.count > 0 {
                                errorMessage = errors[0] as! String
                            }else{
                                errorType = .other
                            }
                            if UserSettings.appLanguageIsArabic() && errors.count > 1 {
                                errorMessage = errors[1] as! String
                            }
                            completion(false, errorType, errorMessage)
                        }else{
                            completion(false, .server, nil)
                        }
                    }
                }else{
                    
                    DeveloperTools.print("reset response 5")
                    completion(false, .server, nil)
                }
            }
        }, useStub: useStub)
        }
    }
    
    
    static func getTags(sorted: Int = 0, completion: @escaping ([Hashtag]?, BackendError?) -> Void, useStub : Bool = false) {
//        let useStub = true
        let endpoint = "LookUps/GetTags"

        var _queryParameters = JSON()
        if sorted == 1 {
            _queryParameters["sortOrder"] = sorted
        } else {
            _queryParameters["sortOrder"] = 0
        }
        
        NetworkingController.getJSONWithAuth(endpoint: endpoint, _queryParameters: _queryParameters, handler: { response, backendError in
//            var hashtags = [Hashtag]()
            var hashtags = [Hashtag]()
            
            if let data = response?["Data"] as? JSONArray {
//                DeveloperTools.print("jsonarray count", data.count)
                for i in data
                {
//                    DeveloperTools.print("jsonarray data", i)
                    let hashtag = Hashtag(JSON: i)
                    hashtags.append(hashtag!)
                }
            }
            completion(hashtags, backendError)
            
        }, useStub: useStub)
    }
    
    static func getDepartments(completion: @escaping ([Department]?, BackendError?) -> Void, useStub : Bool = false) {
//        let useStub = true
        let endpoint = "LookUps/GetDepartments"
        
        NetworkingController.getJSONWithAuth(endpoint: endpoint, _queryParameters: nil, handler: { response, backendError in
            
            var departments = [Department]()
            
            if let data = response?["Data"] as? JSONArray {
                //                DeveloperTools.print("jsonarray count", data.count)
                for i in data
                {
                    let department = Department(JSON: i)
                    departments.append(department!)
                }
            }
            completion(departments, backendError)
            
        }, useStub: useStub)
    }
    
    static func getMentions(searchText: String, pageIndex: Int, pageCount: Int, completion: @escaping ([Employee]?, BackendError?) -> Void, useStub : Bool = false) {
//        let useStub = true
        let endpoint = "MotivContacts/GetListOfMyContacts"
        var queryParameters = Dictionary<String, Any>()
        
        queryParameters["searchText"] = searchText
        queryParameters["pageIndex"] = pageIndex
        queryParameters["pageCount"] = pageCount
        
        NetworkingController.getJSONWithAuth(endpoint: endpoint, _queryParameters: queryParameters, handler: { response, backendError in
                        DeveloperTools.print("backend mentions params", queryParameters)
                        DeveloperTools.print("backend mentions response", response)
            
            var mentions = [Employee]()
            if let data = response?["Data"] as? JSON {
                if let contacts = data["Contacts"] as? JSONArray {
                for i in contacts
                {
                    let mention = Employee(JSON: i)
//                    if mention!.allExpectedKeysExist {
                        mentions.append(mention!)
//                    }
                }
                }
            }
            completion(mentions, backendError)
            
        }, useStub: useStub)
    }
    
    static func imageUpload(isProfile: Int = 0, imageData: Data, completion: @escaping (String?, BackendError?) -> Void, useStub : Bool = false) {
        
        let endpoint = "Image/UploadImage"
        
        NetworkingController.imageUpload(isProfile: isProfile, endpoint: endpoint, imageData: imageData, _queryParameters: nil, handler: { imageUrl, backendError in
            
//            DeveloperTools.print("backend imageUpload response", imageUrl)
            completion(imageUrl, backendError)
            
        }, useStub: useStub)
    }
    
    static func postAdd(content: String, recieverId: String, imageUrl: String?, tagIds: [Int], validationErrorInInput: @escaping (Int) -> Void, completion: @escaping (ThankYouResponse?, String, BackendError?) -> Void, showLoading : Bool = true, useStub : Bool = false) {
        
        var validationSucceeded = true
        
        let endpoint = "Motiv/SayThankYou"
        var queryParameters = Dictionary<String, Any>()
        
        queryParameters["ReceiverId"] = recieverId
        if imageUrl == nil {
            queryParameters["ImageURL"] = ""
        }else{
            queryParameters["ImageURL"] = imageUrl
        }
        queryParameters["TagsId"] = tagIds
        queryParameters["Description"] = Backend.validateAndClean(input: content, type: .text, onFailure: {
            if validationSucceeded {
                validationErrorInInput(0)
                validationSucceeded = false
            }
        }) as? String
        
//        print(queryParameters)
        if validationSucceeded {
        if showLoading {
            LoadingOverlay.shared.showOverlay()
        }
        NetworkingController.postJSONWithAuth(endpoint: endpoint, _queryParameters: queryParameters, handler: { response, backendError in
            
            if showLoading {
                LoadingOverlay.shared.hideOverlayView()
            }
            print("backend postadd params", queryParameters)
            print("backend postadd response", response)
            if response == nil {
                completion(nil, "", backendError)
                return
            }else{
                if let success = response!["Success"] as? Bool {
                    if success {
                        let data = response?["Data"] as? JSON
                        if data != nil {
                            let thankYouResponse = ThankYouResponse(JSON:data!)
                            if thankYouResponse != nil {
                                completion(thankYouResponse, "", nil)
                                return
                            }
                        }
                    } else {
                        if let errors = response!["Errors"] as? [String] {
                            var errorMsg = ""
                            if errors.count > 0 {
                                if UserSettings.appLanguageIsArabic() {
                                    errorMsg = errors[1]
                                } else {
                                    errorMsg = errors[0]
                                }
                            }
                            completion(nil, errorMsg ,nil)
                        }
                    }
                }
                completion(nil, "", .server)
                return
            }
            
        }, useStub: useStub)
        }
    }
    
    static func sayBravo(postId: Int, isBravo: Bool, completion: @escaping (Bool, BackendError?) -> Void, useStub : Bool = false) {
        
        let endpoint = "Motiv/SayBravo"
        var queryParameters = Dictionary<String, Any>()
        
        queryParameters["AwardId"] = postId
        queryParameters["IsBravo"] = isBravo
        
        NetworkingController.postJSONWithAuth(endpoint: endpoint, _queryParameters: queryParameters, handler: { response, backendError in
            
//            DeveloperTools.print("backend saybravo params", queryParameters)
//            DeveloperTools.print("backend saybravo response", response)
            if response == nil {
                completion(false, backendError)
            }else{
                if let success = response!["Success"] as? Bool {
                    if success {
                        
                        completion(true, nil)
                    }else{
                        
                        completion(false, .server)
                    }
                }else{
                    
                    completion(false, .server)
                }
            }
            
        }, useStub: useStub)
    }
    
    static func getPosts(searchTerm: String, departments: [Department]?, hashtags: [Hashtag]?, startDate: Date?, endDate: Date?, persons: [Employee]?, personsPostType: Int?, pageIndex: Int, pageSize: Int, completion: @escaping ([Post]?, Int, BackendError?) -> Void, showLoading : Bool = true, useStub : Bool = false) {
        
//        let useStub = true
        var departmentsIds = [Int]()
        if departments != nil {
            for department in departments! {
                departmentsIds.append(department.Id)
            }
        }
        var hashTagsIds = [Int]()
        if hashtags != nil {
            for hashtag in hashtags! {
                hashTagsIds.append(hashtag.Id)
            }
        }
        
        var personsIds = [String]()
        var personsKey = "ListOfUser"
        if persons != nil {
            for person in persons! {
                personsIds.append(person.userID)
            }
            
            if personsPostType == 0 {
                
                personsKey = "ListFromUser"
                
            }else if personsPostType == 1 {
                
                personsKey = "ListToUser"
                
            }else if personsPostType == 2 {
                
                personsKey = "ListOfUser"
                
            }
        }
        
        let endpoint = "Motiv/GetAllPosts"
        if showLoading {
            LoadingOverlay.shared.showOverlay()
        }
        
        var _queryParameters = JSON()
        _queryParameters["Index"] = pageIndex
        _queryParameters["Size"] = pageSize
        _queryParameters["KeySearch"] = searchTerm
        
        var FromDate = "", ToDate = ""
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if startDate != nil {
            FromDate = "\(dateFormatter.string(from: startDate!))Z"
        }
        if endDate != nil {
            ToDate = "\(dateFormatter.string(from: endDate!))Z"
        }
        
        _queryParameters["CustomFilter"] = ["DepartmentList":departmentsIds, personsKey:personsIds, "ListOfTags": hashTagsIds, "FromDate":FromDate, "ToDate":ToDate]
        
        
        NetworkingController.postJSONWithAuth(endpoint: endpoint, _queryParameters: _queryParameters, handler: { response, backendError in
            
            if showLoading {
                LoadingOverlay.shared.hideOverlayView()
            }
            var posts = [Post]()
            var totalPostsNumber = 0
            
            print("get posts params", _queryParameters)
            print("get posts resonse", response)
            if let data = response?["Data"] as? JSON {
                
                if let list = data["MotivePostsList"] as? JSONArray, let totalNumber = data["TotalNumber"] as? Int {
                    totalPostsNumber = totalNumber
                    
                    for i in list
                    {
                        posts.append(Post(JSON:i)!)
                    }
                }
            }
            completion(posts, totalPostsNumber, backendError)
            
        }, useStub: useStub)
    }
    
    
    static func getPostDetails(postId: Int, completion: @escaping (Post?, BackendError?) -> Void, useStub : Bool = false) {
        
//                let useStub = true
        
        let endpoint = "Motiv/GetPostDetails"
        var _queryParameters = JSON()
        _queryParameters["awardId"] = postId
        
        NetworkingController.getJSONWithAuth(endpoint: endpoint, _queryParameters: _queryParameters, handler: { response, backendError in
            
            var post : Post!
            
            DeveloperTools.print("parameters", _queryParameters)
             DeveloperTools.print("get post details resonse", response)
            if let data = response?["Data"] as? JSON {
                
                post = Post(JSON:data)!
            }
            completion(post, backendError)
            
        }, useStub: useStub)
    }
    
    static func commentAdd(message: String?, postId: Int, validationErrorInInput: @escaping (Int) -> Void, completion: @escaping (Bool, BackendError?) -> Void, showLoading : Bool = true, useStub : Bool = false) {
        
        var validationSucceeded = true
        
        
        var queryParameters = Dictionary<String, Any>()
        
        queryParameters["AwardId"] = postId
        queryParameters["Message"] = Backend.validateAndClean(input: message, type: .text, onFailure: {
            if validationSucceeded {
                validationErrorInInput(0)
                validationSucceeded = false
            }
        }) as? String
        
        if validationSucceeded {
        let endpoint = "Motiv/AddNewComment"
            if showLoading {
                LoadingOverlay.shared.showOverlay()
            }
        NetworkingController.postJSONWithAuth(endpoint: endpoint, _queryParameters: queryParameters, handler: { response, backendError in
            
            if showLoading {
                LoadingOverlay.shared.hideOverlayView()
            }
            if response == nil {
                completion(false, backendError)
            }else{
                if let success = response!["Success"] as? Bool {
                    if success {
                        
                        completion(true, nil)
                    }else{
                        
                        completion(false, .server)
                    }
                }else{
                    
                    completion(false, .server)
                }
            }
            
        }, useStub: useStub)
        }
    }
    
    static func commentEdit(message: String?, postId: Int, messageID: Int, validationErrorInInput: @escaping (Int) -> Void, completion: @escaping (Bool, BackendError?) -> Void, showLoading : Bool = true, useStub : Bool = false) {
        
        var validationSucceeded = true
        
        
        var queryParameters = Dictionary<String, Any>()
        
        queryParameters["AwardId"] = postId
        queryParameters["MessageId"] = messageID
        queryParameters["Message"] = Backend.validateAndClean(input: message, type: .text, onFailure: {
            if validationSucceeded {
                validationErrorInInput(0)
                validationSucceeded = false
            }
        }) as? String
        
        if validationSucceeded {
            let endpoint = "Motiv/EditComment"
            if showLoading {
                LoadingOverlay.shared.showOverlay()
            }
            NetworkingController.postJSONWithAuth(endpoint: endpoint, _queryParameters: queryParameters, handler: { response, backendError in
                
                if showLoading {
                    LoadingOverlay.shared.hideOverlayView()
                }
                if response == nil {
                    completion(false, backendError)
                }else{
                    if let success = response!["Success"] as? Bool {
                        if success {
                            
                            completion(true, nil)
                        }else{
                            
                            completion(false, .server)
                        }
                    }else{
                        
                        completion(false, .server)
                    }
                }
                
            }, useStub: useStub)
        }
    }
    
    static func commentDelete(messageId: Int, postId: Int, completion: @escaping (Bool, BackendError?) -> Void, showLoading : Bool = true, useStub : Bool = false) {
        
        var queryParameters = Dictionary<String, Any>()
        
        queryParameters["AwardId"] = postId
        queryParameters["MessageId"] = messageId
        
        let endpoint = "Motiv/DeleteComment"
        if showLoading {
            LoadingOverlay.shared.showOverlay()
        }
        NetworkingController.postJSONWithAuth(endpoint: endpoint, _queryParameters: queryParameters, handler: { response, backendError in
            
            if showLoading {
                LoadingOverlay.shared.hideOverlayView()
            }
            if response == nil {
                completion(false, backendError)
            }else{
                if let success = response!["Success"] as? Bool {
                    if success {
                        
                        completion(true, nil)
                    }else{
                        
                        completion(false, .server)
                    }
                }else{
                    
                    completion(false, .server)
                }
            }
            
        }, useStub: useStub)
    }
    
    static func getProfileDetails(withID id: String?, completion: @escaping (Employee?, BackendError?) -> Void, showLoading : Bool = true, useStub : Bool = false) {
        
        //                let useStub = true
        
        if showLoading {
        LoadingOverlay.shared.showOverlay()
        }
        let endpoint = "Motiv/GetProfileDetails"
        var _queryParameters = JSON()
        if id != nil {
            _queryParameters["userId"] = id!
        } else {
            _queryParameters["userId"] = ""
        }
        
        NetworkingController.getJSONWithAuth(endpoint: endpoint, _queryParameters: _queryParameters, handler: { response, backendError in
//            print("getProfileDetails params:", _queryParameters)
//            print("getProfileDetails response:", response)
//            print("getProfileDetails AccessToken:", NetworkingController.accessToken)

            if showLoading {
            LoadingOverlay.shared.hideOverlayView()
            }
            var profile : Employee!

            if let data = response?["Data"] as? JSON {

                profile = Employee(JSON:data)!
            }
            completion(profile, backendError)

        }, useStub: useStub)
    }
    
    static func editProfileDetails(with data: Dictionary<String,Any>, completion: @escaping (Bool, BackendError?) -> Void, useStub : Bool = false) {
        
        LoadingOverlay.shared.showOverlay()
        let endpoint = "Motiv/EditProfileDetails"
        var _queryParameters = JSON()
        _queryParameters = data
        
        NetworkingController.postJSONWithAuth(endpoint: endpoint, _queryParameters: _queryParameters, handler: { (response, backendError) in
//            print("editProfileDetails params:", _queryParameters)
//            print("editProfileDetails response:", response)
            LoadingOverlay.shared.hideOverlayView()
            var success = false
            if let data = response?["Data"] as? Bool {
                success = data
            }
            completion(success, backendError)
        }, useStub: useStub)
    }
    
    static func getMyTrends(completion: @escaping ([MyTrend]?, BackendError?) -> Void, showLoading : Bool = true, useStub : Bool = false) {
        //        let useStub = true
        let endpoint = "Motiv/GetMyTrends"
        let queryParameters = Dictionary<String, Any>()
        if showLoading {
            LoadingOverlay.shared.showOverlay()
        }
        NetworkingController.getJSONWithAuth(endpoint: endpoint, _queryParameters: queryParameters, handler: { response, backendError in
            
            DeveloperTools.print("getMyTrends params:", queryParameters)
            DeveloperTools.print("getMyTrends response:", response)
            if showLoading {
                LoadingOverlay.shared.hideOverlayView()
            }
            
            var trends = [MyTrend]()
                if let mytrends = response?["Data"] as? JSONArray {
                    for i in mytrends
                    {
                        let trend = MyTrend(JSON: i)
                        //                    if mention!.allExpectedKeysExist {
                        trends.append(trend!)
                        //                    }
                    }
            }
            completion(trends, backendError)
            
        }, useStub: useStub)
    }
    
    static func getStars(completion: @escaping ([Star]?, BackendError?) -> Void, showLoading: Bool = true, useStub: Bool = false) {
        let endpoint = "Stats/Stars"
        let queryParameters = Dictionary<String, Any>()
        if showLoading {
            LoadingOverlay.shared.showOverlay()
        }
        NetworkingController.getJSONWithAuth(endpoint: endpoint, _queryParameters: queryParameters, handler: { response, backendError in
            
            if showLoading {
                LoadingOverlay.shared.hideOverlayView()
            }
            
            var starsArr = [Star]()
            if let stars = response?["Data"] as? JSONArray {
                for i in stars {
                    let star = Star(JSON: i)
                    starsArr.append(star!)
                }
            }
            completion(starsArr, backendError)
            
        }, useStub: useStub)
    }
    
    static func getMyStats(completion: @escaping (MyStats?, BackendError?) -> Void, showLoading: Bool = true, useStub: Bool = false) {
        let endpoint = "Stats/MyStats"
        let queryParameters = Dictionary<String, Any>()
        if showLoading {
            LoadingOverlay.shared.showOverlay()
        }
        NetworkingController.getJSONWithAuth(endpoint: endpoint, _queryParameters: queryParameters, handler: { response, backendError in
            
            if showLoading {
                LoadingOverlay.shared.hideOverlayView()
            }
            
            var myStats: MyStats?
            if let data = response?["Data"] as? JSON {
                myStats = MyStats(JSON: data)
            }
            completion(myStats, backendError)
            
        }, useStub: useStub)
    }
    
    
    static func getRewardsByCategory(completion: @escaping ([RewardsSubCategory]?, BackendError?) -> Void, showLoading : Bool = true, useStub : Bool = false) {
        
//                        let useStub = true
        
        if showLoading {
            LoadingOverlay.shared.showOverlay()
        }
        let endpoint = "Reward/GetRewardsByCategory"
        var _queryParameters = JSON()
        
//        switch rewardsType {
//        case .All :
//            _queryParameters["userId"] = ""
//            break
//        }
        
        NetworkingController.getJSONWithAuth(endpoint: endpoint, _queryParameters: _queryParameters, handler: { response, backendError in
            
            if showLoading {
                LoadingOverlay.shared.hideOverlayView()
            }
            
            var rewardSubCategories = [RewardsSubCategory]()
            if let resposneRewards = response?["Data"] as? JSONArray {
                for i in resposneRewards
                {
                    let rewardSubCategory = RewardsSubCategory(JSON: i)
                    //                    if mention!.allExpectedKeysExist {
                    rewardSubCategories.append(rewardSubCategory!)
                    //                    }
                }
            }
            completion(rewardSubCategories, backendError)
            
        }, useStub: useStub)
    }
    
    static func getRewards(rewardListType: RewardListType?, rewardsTypeId: Int?, keyword: String?, pageIndex: Int, pageSize: Int, completion: @escaping ([Reward]?, Int, BackendError?) -> Void, showLoading : Bool = true, useStub : Bool = false) {
        
        //                        let useStub = true
        
        if showLoading {
            LoadingOverlay.shared.showOverlay()
        }
        let endpoint = "Reward/GetRewards"
        var _queryParameters = JSON()
        _queryParameters["PaegIndex"] = pageIndex
        _queryParameters["PageSize"] = pageSize
        if rewardListType != nil {
            switch rewardListType! {
            case .Bookmarked :
                _queryParameters["RewardListType"] = "1"
                break
            case .Redeemed :
                _queryParameters["RewardListType"] = "2"
                break
            default:
                _queryParameters["RewardListType"] = "0"
                break
            }
        }
        if rewardsTypeId != nil {
            
            _queryParameters["RewardTypeId"] = "\(rewardsTypeId!)"
        }
        if keyword != nil {
            
            _queryParameters["Keyword"] = "\(keyword!)"
        }
        
        NetworkingController.postJSONWithAuth(endpoint: endpoint, _queryParameters: _queryParameters, handler: { response, backendError in
            DeveloperTools.print("rewards params \(_queryParameters)")
            DeveloperTools.print("rewards response \(response)")
            if showLoading {
                LoadingOverlay.shared.hideOverlayView()
            }
            var numberOfRewards = 0
            var rewards = [Reward]()
            if let resposneRewards = response?["Data"] as? JSON {
                
                if let list = resposneRewards["RewardsList"] as? JSONArray, let RewardCount = resposneRewards["RewardCount"] as? Int {
                    numberOfRewards = RewardCount
                for i in list
                {
                    let reward = Reward(JSON: i)
                    //                    if mention!.allExpectedKeysExist {
                    rewards.append(reward!)
                    //                    }
                }
                }
            }
            completion(rewards, numberOfRewards, backendError)
            
        }, useStub: useStub)
    }
    
    static func getRewardDetails(rewardId: Int, completion: @escaping (Reward?, BackendError?) -> Void, showLoading : Bool = true, useStub : Bool = false) {
        
        //                        let useStub = true
        
        if showLoading {
            LoadingOverlay.shared.showOverlay()
        }
        let endpoint = "Reward/GetRewardsDetails"
        var _queryParameters = JSON()
        _queryParameters["rewardId"] = "\(rewardId)"
        
        NetworkingController.getJSONWithAuth(endpoint: endpoint, _queryParameters: _queryParameters, handler: { response, backendError in
            
            DeveloperTools.print("reward details response \(response ?? [:])")
            if showLoading {
                LoadingOverlay.shared.hideOverlayView()
            }
            
            var reward: Reward?
            if let resposneRewards = response?["Data"] as? JSON {
//                for i in resposneRewards
//                {
                    reward = Reward(JSON: resposneRewards)
                    //                    if mention!.allExpectedKeysExist {
//                    rewards.append(reward!)
                    //                    }
//                }
            }
            completion(reward, backendError)
            
        }, useStub: useStub)
    }
    
    
    static func rewardBookmark(rewardId: Int, completion: @escaping (Bool, BackendError?) -> Void, useStub : Bool = false) {
        
        let endpoint = "Reward/ToogleRewardBookmark?rewardId=\(rewardId)"
        var queryParameters = Dictionary<String, Any>()
        
//        queryParameters["rewardId"] = rewardId
        
        NetworkingController.postJSONWithAuth(endpoint: endpoint, _queryParameters: queryParameters, handler: { response, backendError in
            
            //            DeveloperTools.print("backend saybravo params", queryParameters)
                        DeveloperTools.print("backend bookmark response", response)
            if response == nil {
                completion(false, backendError)
            }else{
                if let success = response!["Success"] as? Bool {
                    if success {
                        
                        completion(true, nil)
                    }else{
                        
                        completion(false, .server)
                    }
                }else{
                    
                    completion(false, .server)
                }
            }
            
        }, useStub: useStub)
    }
    
    static func rewardRedeem(rewardId: Int, completion: @escaping (Bool, Dictionary<String, Any>, BackendError?, String) -> Void, showLoading : Bool = true, useStub : Bool = false) {
        if showLoading {
            LoadingOverlay.shared.showOverlay()
        }
        let endpoint = "Reward/RedeemReward?rewardId=\(rewardId)"
        var queryParameters = Dictionary<String, Any>()
        
//        queryParameters["rewardId"] = rewardId
        
        NetworkingController.postJSONWithAuth(endpoint: endpoint, _queryParameters: queryParameters, handler: { response, backendError in
            
            //            DeveloperTools.print("backend saybravo params", queryParameters)
            DeveloperTools.print("backend redeem response", response)
            if showLoading {
                LoadingOverlay.shared.hideOverlayView()
            }
            if response == nil {
                completion(false, [:], backendError, "")
            }else{
                if let success = response!["Success"] as? Bool, let redeemId = response!["Data"] as? Dictionary<String, Any> {
                    if success {
                        
                        completion(true, redeemId, nil, "")
                    }else{
                        
                        completion(false, [:], .server, "")
                    }
                }else{
                    if let errors = response!["Errors"] as? [String] {
                        var errorMsg = ""
                        if errors.count > 0 {
                            if UserSettings.appLanguageIsArabic() {
                                errorMsg = errors[1]
                            } else {
                                errorMsg = errors[0]
                            }
                        }
                        completion(false, [:], .server, errorMsg)
                    }
                }
            }
            
        }, useStub: useStub)
    }
    
    static func registerDevice(_ register: Bool, useStub : Bool = false) {
        var endpoint = ""
        if register {
            endpoint = "User/RegisterDevcie"
        } else {
            endpoint = "User/UnRegisterDevcie"
        }
        
        let queryParameters: Dictionary<String,Any> = ["UDID": AppDelegate.deviceToken, "DevicePlatform": 1]
        
        NetworkingController.postJSONWithAuth(endpoint: endpoint, _queryParameters: queryParameters, handler: { (response, backendError) in
            if response == nil {
                print(backendError ?? "Register device error")
            } else {
                print("device register response")
                print(response!)
            }
        }, useStub: useStub)
    }
    
    static func getNotifications(pageIndex: Int, pageSize: Int, completion: @escaping ([NotificationModel]?, Int, BackendError?) -> Void, showLoading : Bool = true, useStub : Bool = false) {
        let endpoint = "Notification/GetNotificaions"
        var _queryParameters = JSON()
        _queryParameters["pageIndex"] = pageIndex
        _queryParameters["pageCount"] = pageSize
        
        if showLoading {
            LoadingOverlay.shared.showOverlay()
        }
        
        NetworkingController.getJSONWithAuth(endpoint: endpoint, _queryParameters: _queryParameters, handler: { (response, backendError) in
//             print("backend notifications response", response)
            
            if showLoading {
                LoadingOverlay.shared.hideOverlayView()
            }
            var numberOfNotifications : Int!
            var notificationsArr = [NotificationModel]()
            if response != nil {
                if let data = response!["Data"] as? JSON {
                    
                    if let list = data["notificationList"] as? JSONArray, let TotalCount = data["TotalCount"] as? Int {
                        numberOfNotifications = TotalCount
                    for i in list {
                        let notification = NotificationModel(JSON: i)
                        notificationsArr.append(notification!)
                    }
                }
                completion(notificationsArr, numberOfNotifications, backendError)
            } else {
                completion([], 0, backendError)
            }
            }
            
        }, useStub: useStub)
    }
    
    static func getSettings(completion: @escaping (AppSettings?, BackendError?) -> Void, useStub : Bool = false) {
        
        let endpoint = "User/Setting"
        let queryParameters = Dictionary<String, Any>()
        
        NetworkingController.getJSONWithAuth(endpoint: endpoint, _queryParameters: queryParameters, handler: { response, backendError in
            
//                        print("get settings params", queryParameters)
//                        print("get settings response", response)
            if response == nil {
                completion(nil, backendError)
            }else{
                if let success = response!["Success"] as? Bool {
                    if success {
                            if let data = response!["Data"] as? JSON {
                                let appSettings = AppSettings(JSON:data)
                                completion(appSettings, backendError)
                            } else {
                                completion(nil, backendError)
                            }
                    }else{
                        
                        completion(nil, .server)
                    }
                }else{
                    
                    completion(nil, .server)
                }
            }
            
        }, useStub: useStub)
    }
    
    static func updateSettings(EmailNotification: Bool?, PushNotification: Bool?, UserLanguage: Int?, completion: @escaping (Bool, BackendError?) -> Void, useStub : Bool = false) {
        
        let endpoint = "User/SetSetting"
        var queryParameters = Dictionary<String, Any>()
        
        if EmailNotification != nil {
            queryParameters["EmailNotification"] = EmailNotification
        }
        if PushNotification != nil {
            queryParameters["PushNotification"] = PushNotification
        }
        if UserLanguage != nil {
            queryParameters["UserLanguage"] = UserLanguage
        }
        
        NetworkingController.postJSONWithAuth(endpoint: endpoint, _queryParameters: queryParameters, handler: { response, backendError in
            
//                        print("set settings params", queryParameters)
//                        print("set settings response", response)
            if response == nil {
                completion(false, backendError)
            }else{
                if let success = response!["Success"] as? Bool {
                    if success {
                        if response != nil {
                            completion(true, backendError)
                        }else{
                            completion(false, backendError)
                        }
                    }else{
                        
                        completion(false, .server)
                    }
                }else{
                    
                    completion(false, .server)
                }
            }
            
        }, useStub: useStub)
    }

    static func getAppSettings(completion: @escaping ([ApplicationSettings], BackendError?) -> Void, useStub : Bool = false) {
        let endpoint = "Settings/GetAppSettings"
        let queryParameters = Dictionary<String, Any>()
        
        NetworkingController.getJSONWithAuth(endpoint: endpoint, _queryParameters: queryParameters, handler: { (response, backendError) in
            
            if response == nil {
                completion([], backendError)
            } else {
                if let success = response!["Success"] as? Bool {
                    if success {
                        var applicationSettings = [ApplicationSettings]()
                        if let data = response!["Data"] as? [JSON] {
                            for d in data {
                                applicationSettings.append(ApplicationSettings(JSON: d)!)
                            }
                            completion(applicationSettings, nil)
                        } else {
                            completion([], backendError)
                        }
                    } else {
                        completion([], .server)
                    }
                } else {
                    completion([], .server)
                }
            }
        }, useStub: useStub)
    }
    
    static func getRedeemedRewardDetails(redemptionCode: String, completion: @escaping (Reward?, BackendError?) -> Void, showLoading : Bool = true, useStub : Bool = false) {
        let endpoint = "Reward/GetRedeemedRewardsDetails"
        var queryparameters = JSON()
        queryparameters["RewardRedemptionCode"] = redemptionCode
        
        NetworkingController.getJSONWithAuth(endpoint: endpoint, _queryParameters: queryparameters, handler: { (response, backendError) in
            DeveloperTools.print("reward details response \(response ?? [:])")
            if showLoading {
                LoadingOverlay.shared.hideOverlayView()
            }
            
            var reward: Reward?
            if let resposneRewards = response?["Data"] as? JSON {
                reward = Reward(JSON: resposneRewards)
            }
            completion(reward, backendError)
        }, useStub: useStub)
    }
    
    static func logout() {
        let endpoint = "Account/logout"
        
        NetworkingController.getJSONWithAuth(endpoint: endpoint, handler: { (response, backendError) in
            if response == nil {
                
            } else {
                print(response as Any)
            }
        }, useStub: false)
    }
}
