//
//  NetworkingController.swift
//
//  Created by Yehia Elbehery.
//

import Alamofire
import UIKit

enum BackendError {
    case server, connection, other, custom
}

class NetworkingController {
    
    static let baseURL: String = {
        switch DeveloperTools.backendInstance {
        case .Dev:
//            return "http://168.61.46.86:3377/Motivay/MotivayService/api/"
//            return "http://40.121.137.251:8091/Motivay/MotivayService/api/"
            return "http://youxeldev.eastus.cloudapp.azure.com/Tremvo/API/api/"
        case .QC:
            return "http://168.61.46.86:4477/Motivay/MotivayService/api/"
        case .Demo:
//            return "http://168.61.46.86:8080/Motivay/MotivayService/api/"
            return "#{MotivayURL}#/MotivayService/api/"
        case .GEA:
            return "http://40.118.26.137:6677/MotivayGEA/MotivayService/api/"
        case .Thiqah:
            return "http://40.118.26.137:6677/Motivay/MotivayService/api/"
        case .ThiqahNew:
            return "http://172.20.239.43/MotivayAPI/api/"
        case .Kafu:
            return "https://kafu.thiqah.sa/MotivayAPI/api/"
        case .MotivayPOC:
            return "http://40.118.26.137:6677/MotivayPOC/apis/api/"
        case .Monshaat:
            return "http://35.243.179.96/Monshaat-Demo/APIs/api/"
        case .MonshaatNew:
            return "http://34.73.103.95/Monshaat-Demo/APIs/api/"
        case .Elm_Demo:
            return "http://35.211.152.226/ELM-Demo/APIs/api/"
        case .Adam:
            return "http://35.239.57.203/Motivay/APIs/api/"
        case .Youxel:
            return "http://35.211.152.226/Youxel/Apis/api/"
        case .Wssel:
            return "http://52.146.44.183/POC/Motivay/Wssel/MotivayService/api/"
        case .GAZT:
            return "http://52.146.44.183/POC/Motivay/Gazt/MotivayService/api/"
        case .Tremvo:
            return "http://52.146.44.183/Tremvo/API/api/"
        case .Phenix:
            return "http://52.146.44.183/POC/Motivay/Phenix/Api/api/"
        case .TremvoDemo:
            return "http://yxdemo.eastus.cloudapp.azure.com/Tremvo/Demo/Youxel/API/api/"
        }
    }()
    
    static let authURL: String = {
        switch DeveloperTools.backendInstance {
        case .Dev:
//            return "http://168.61.46.86:3377/Motivay/MotivayAuth/token"
//            return "http://40.121.137.251:8091/Motivay/MotivayAuth/token"
        return "http://youxeldev.eastus.cloudapp.azure.com/Tremvo/Auth/token"
        case .QC:
            return "http://168.61.46.86:4477/Motivay/MotivayAuth/token"
        case .Demo:
//            return "http://168.61.46.86:8080/Motivay/MotivayAuth/token"
            return "#{MotivayURL}#/MotivayAuth/token"
        case .GEA:
            return "http://40.118.26.137:6677/MotivayGEA/MotivayAuth/token"
        case .Thiqah:
            return "http://40.118.26.137:6677/Motivay/MotivayAuth/token"
        case .ThiqahNew:
            return "http://172.20.239.43/MotivayAuth/token"
        case .Kafu:
            return "https://kafu.thiqah.sa/MotivayAuth/token"
        case .MotivayPOC:
            return "http://40.118.26.137:6677/MotivayPOC/Auth/token"
        case .Monshaat:
            return "http://35.243.179.96/Monshaat-Demo/Auth/token"
        case .MonshaatNew:
            return "http://34.73.103.95/Monshaat-Demo/Auth/token"
        case .Elm_Demo:
            return "http://35.211.152.226/ELM-Demo/Auth/token"
        case .Adam:
            return "http://35.239.57.203/Motivay/Auth/token"
        case .Youxel:
            return "http://35.211.152.226/Youxel/Auth/token"
        case .Wssel:
            return "http://52.146.44.183/POC/Motivay/Wssel/MotivayAuth/token"
        case .GAZT:
            return "http://52.146.44.183/POC/Motivay/Gazt/MotivayAuth/token"
        case .Tremvo:
            return "http://52.146.44.183/Tremvo/Auth/token"
        case .Phenix:
            return "http://52.146.44.183/POC/Motivay/Phenix/Auth/token"
        case .TremvoDemo:
            return "http://yxdemo.eastus.cloudapp.azure.com/Tremvo/Demo/Youxel/Auth/token"
        }
    }()
    
    static var authParams = ["client_id": "54f05e52dd9f44ac8204d73fd5c45782", /*"username": "mmohsen", "password":"Mahmoud@123", */"grant_type": "password"]
    
    static var accessToken: String?
//    static var headers: HTTPHeaders =  ["Content-Type":"application/json"]
    static var accessTokenExpiryTime: Date?
    static var userSource: String?
    
    
    static func getAccessToken() -> String? {
        if NetworkingController.accessTokenExpiryTime != nil {
            if NetworkingController.accessTokenExpiryTime! > Date() {
            
                return NetworkingController.accessToken
                
            }
        }
//        NetworkingController.logoutCleanUp()
        return nil
    }
    
    static func logoutAccessTokenCleanUp(){
        
        NetworkingController.accessToken = nil
        NetworkingController.accessTokenExpiryTime = nil
        UserSettings.removeUserPreference("accessToken")
        UserSettings.removeUserPreference("accessTokenExpiryTime")
    }
    
    static func getHeaders() -> HTTPHeaders {
        if NetworkingController.getAccessToken() != nil {
            return ["Authorization": "bearer \(NetworkingController.getAccessToken()!)", "Content-Type":"application/json"]
        }
        return ["Content-Type":"application/json"]
    }
    
    //handler Bool: true -> Deactivated
    static func generateAccessToken(handler: ((BackendError?, Bool) -> Void)? = nil) {
    
//        if accessTokenExpiryTime != nil {
//
//            if accessTokenExpiryTime! > Date() {
//                handler?(nil)
//                return
//            }
//        }
            Networking.postUrlEncoding(url: NetworkingController.authURL, queryParameters: NetworkingController.authParams) { (response, success, errorStatus) in
                DeveloperTools.print("params: ", NetworkingController.authParams)
                print("sign in response", response ?? [:], success)
                if success {
                    if let accessToken = response?["access_token"] as? String {
                        
                        if let accessTokenExpiryString = response?[".expires"] as? String {
                                            DeveloperTools.print("sign in accessTokenExpiryString", accessTokenExpiryString)
                            NetworkingController.accessTokenExpiryTime = accessTokenExpiryString.y_getDateFromString()
                            DeveloperTools.print("sign in accessTokenExpiryDate", accessTokenExpiryString.y_getDateFromString() ?? "")
                            if NetworkingController.accessTokenExpiryTime != nil {
                                NetworkingController.accessToken = accessToken
                               
        
                                DeveloperTools.print("sign in accesstoken", NetworkingController.accessToken ?? "")
                                UserSettings.setUserPreference(NetworkingController.accessToken as AnyObject, key: "accessToken")
                                UserSettings.setUserPreference(NetworkingController.accessTokenExpiryTime as AnyObject, key: "accessTokenExpiryTime")
                                if let userSource = response?["UserSource"] as? String {
                                    NetworkingController.userSource = userSource
                                    UserSettings.setUserPreference(NetworkingController.userSource as AnyObject, key: "userSource")
                                }
                                handler?(nil, false)
                                return
                            }
                        }
                    }
                    if let error = response?["error"] as? String {
                        if error == "deactivated_user" {
                            handler?(nil, true)
                            return
                        }
                    }
                    handler?(.other, false)
                    return
                }
//                print("sign in error status:", errorStatus)
                if NetworkReachabilityManager()!.isReachable == false {
                    
                    handler?(.connection, false)
                    AlertUtility.showConnectionError()
                    return
                }else{
                    handler?(.server, false)
                    return
                }
            }
    }
    
    static func getJSONArray(endpoint: String, _queryParameters: Dictionary<String, Any>? = nil, handler: @escaping (JSONArray?, BackendError?) -> Void, useStub : Bool) {
        
            var queryParameters : Dictionary<String, Any> =  Dictionary<String, Any>()
            if _queryParameters != nil {
                _queryParameters!.forEach { (k,v) in queryParameters[k] = v }
            }
            
            if(useStub && DeveloperTools.debugMode){
                let jsonArray = DeveloperTools.readJSONArrayFromBundle(fromFile: endpoint.replacingOccurrences(of: "/", with: "", options: .literal, range: nil))!
                handler(jsonArray, nil)
            }else{
                Networking.getJSONArray(baseUrl: self.baseURL, endpoint: endpoint, queryParameters: queryParameters, handler: { response, success, error in
                    if success {
                        if let response = response {
                            handler(response, nil)
                            return
                        }else{
                            handler(nil, .server)
                            return
                        }
                    }else{
                        if NetworkReachabilityManager()!.isReachable == false {
                            
                            handler(nil, .connection)
                            AlertUtility.showConnectionError()
                            return
                        }else{
                            handler(nil, .server)
                            return
                        }
                    }
                })
            }
    }
    
    static func getJSON(endpoint: String, _queryParameters: Dictionary<String, Any>? = nil, handler: @escaping (JSON?, BackendError?) -> Void, useStub : Bool) {
        
            var queryParameters : Dictionary<String, Any> = Dictionary<String, Any>()// ["access_token" : accessToken!]
        if _queryParameters != nil {
            _queryParameters!.forEach { (k,v) in queryParameters[k] = v }
        }
            
            if(useStub/* && DeveloperTools.debugMode*/){
                
                let json = DeveloperTools.readJSONFromBundle(fromFile: endpoint.replacingOccurrences(of: "/", with: "", options: .literal, range: nil))!
                handler(json, nil)
                return
            }else{
                
                Networking.getJSON(baseUrl: self.baseURL, endpoint: endpoint, queryParameters: queryParameters, headers: [:], handler: { response, success, errorStatus in
                    
                    DeveloperTools.print("get  response", endpoint)
                    DeveloperTools.print("get  response", response ?? [:])
                    if success {
                        if let response = response {
                            handler(response, nil)
                            return
                        }else{
                            handler(nil, .other)
                            return
                        }
                    }
                    
                    if NetworkReachabilityManager()!.isReachable == false {
                        
                        handler(nil, .connection)
                        AlertUtility.showConnectionError()
                        return
                    }else{
                        handler(nil, .server)
                        return
                    }
                })
            }
    }
    
    static func getJSONWithAuth(endpoint: String, _queryParameters: Dictionary<String, Any>? = nil, handler: @escaping (JSON?, BackendError?) -> Void, useStub : Bool) {
        DeveloperTools.print("Logout or not")
        if NetworkingController.getAccessToken() == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                MenuViewController.logoutOps()
                DeveloperTools.print("Logout")
            }
            return
        }
        
        var queryParameters : Dictionary<String, Any> = Dictionary<String, Any>()// ["access_token" : accessToken!]
        if _queryParameters != nil {
            _queryParameters!.forEach { (k,v) in queryParameters[k] = v }
        }
        
        if(useStub/* && DeveloperTools.debugMode*/){
            
            let json = DeveloperTools.readJSONFromBundle(fromFile: endpoint.replacingOccurrences(of: "/", with: "", options: .literal, range: nil))!
            handler(json, nil)
            return
        }else{
            
            Networking.getJSON(baseUrl: self.baseURL, endpoint: endpoint, queryParameters: queryParameters, headers: NetworkingController.getHeaders(), handler: { response, success, errorStatus in
                
                DeveloperTools.print("get profile response", response ?? [:])
                if success {
                    if let response = response {
                        handler(response, nil)
                        return
                    }else{
                        handler(nil, .other)
                        return
                    }
                }
                
                if NetworkReachabilityManager()!.isReachable == false {
                    
                    handler(nil, .connection)
                    AlertUtility.showConnectionError()
                    return
                }else{
                    handler(nil, .server)
                    return
                }
            })
        }
    }
    
    static func postJSON(endpoint: String, _queryParameters: Dictionary<String, Any>? = nil, handler: @escaping (JSON?, BackendError?) -> Void, useStub : Bool) {
        
            var queryParameters : Dictionary<String, Any> =  Dictionary<String, Any>()
        
        if _queryParameters != nil {
            _queryParameters!.forEach { (k,v) in queryParameters[k] = v }
        }
            if(useStub/* && DeveloperTools.debugMode*/){
                let json = DeveloperTools.readJSONFromBundle(fromFile: endpoint.replacingOccurrences(of: "/", with: "", options: .literal, range: nil))!
                handler(json, nil)
                return
            }else{
                
                Networking.post(baseUrl: self.baseURL, endpoint: endpoint, queryParameters: queryParameters, headers: [:], handler: { response, success, errorStatus  in
                    
                    if success {
                        if let response = response {
                            handler(response, nil)
                            return
                        }
                        handler(nil, .other)
                        return
                    }
                    if NetworkReachabilityManager()!.isReachable == false {
                        
                        handler(nil, .connection)
                        AlertUtility.showConnectionError()
                        return
                    }else{
                        handler(nil, .server)
                        return
                    }
                })
            }
//        }
    }
    
    static func postJSONWithAuth(endpoint: String, _queryParameters: Dictionary<String, Any>? = nil, handler: @escaping (JSON?, BackendError?) -> Void, useStub : Bool) {
                if NetworkingController.getAccessToken() == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                MenuViewController.logoutOps()
            }
        }
        var queryParameters : Dictionary<String, Any> =  Dictionary<String, Any>()
        
        if _queryParameters != nil {
            _queryParameters!.forEach { (k,v) in queryParameters[k] = v }
        }
        if(useStub/* && DeveloperTools.debugMode*/){
            let json = DeveloperTools.readJSONFromBundle(fromFile: endpoint.replacingOccurrences(of: "/", with: "", options: .literal, range: nil))!
            handler(json, nil)
            return
        }else{
            
            Networking.post(baseUrl: self.baseURL, endpoint: endpoint, queryParameters: queryParameters, headers: NetworkingController.getHeaders(), handler: { response, success, errorStatus  in
                DeveloperTools.print("posts params ", queryParameters)
                DeveloperTools.print("posts response ", response ?? [:])
                //                    DeveloperTools.print("reset status ", errorStatus)
                if success {
                    if let response = response {
                        handler(response, nil)
                        return
                    }
                    handler(nil, .other)
                    return
                }
                if NetworkReachabilityManager()!.isReachable == false {
                    
                    handler(nil, .connection)
                    AlertUtility.showConnectionError()
                    return
                }else{
                    handler(nil, .server)
                    return
                }
            })
        }
        //        }
    }
    
    static func createBody(boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
    
    static func imageUpload(isProfile: Int, endpoint: String, imageData: Data, _queryParameters: Dictionary<String, Any>? = nil, handler: @escaping (String?, BackendError?) -> Void, useStub : Bool){
        
            var urlString = "\(self.baseURL)\(endpoint)"
            if isProfile == 1 {
               urlString += "?isProfile=\(isProfile)"
            }
            let url = URL(string: urlString)
            let boundary = "Boundary-\(NSUUID().uuidString)"
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.httpBody = NetworkingController.createBody(boundary: boundary, data: imageData, mimeType: "image/jpg", filename: "image1.jpg")
            request.addValue("bearer \(NetworkingController.accessToken!)", forHTTPHeaderField: "Authorization")
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { (data,
                response, error) in
                DispatchQueue.main.async {
                if error != nil {
                    DeveloperTools.print("handler 5")
                    if NetworkReachabilityManager()!.isReachable == false {
                        
                        handler(nil, .connection)
                        AlertUtility.showConnectionError()
                        return
                    }else{
                        handler(nil, .server)
                        return
                    }
//                    DeveloperTools.print("image upload step 2")
//                    DeveloperTools.print(error ?? "error")
                } else if response != nil {
                    DeveloperTools.print("image upload step 3")
                    DeveloperTools.print(response ?? "response")
                    if let responseData = data {
                        do {
                            DeveloperTools.print("image upload step 4", responseData)
                            if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? Dictionary<String,Any> {
                                if let data = jsonResponse["Data"] as? Dictionary<String,String> {
                                    let imageUrl = data["ImageName"]
                                    DeveloperTools.print(imageUrl!)
//                                    DispatchQueue.main.async {
                                    
                                        handler(imageUrl, nil)
                                        DeveloperTools.print("image upload step 5")
                                        //                                    self.uploadingActivityIndicator.isHidden = true
                                        //                                    self.doneButtonOutlet.isEnabled = true
//                                    }
                                    //                                AnnouncementTableViewController.imagesPaths.append(imageUrl!)
                                }else{
                                    
                                    DeveloperTools.print("handler 6")
                                    handler(nil, .server)
                                }
                            }else{
                                
                                DeveloperTools.print("handler 7")
                                handler(nil, .server)
                            }
                        } catch {
                            handler(nil, .server)
                            DeveloperTools.print("handler 8")
                            DeveloperTools.print("JSON Processing failed.")
                        }
                        
                    }else{
                        
                        DeveloperTools.print("handler 9")
                        handler(nil, .server)
                    }
                }else{
                    
                    DeveloperTools.print("handler 10")
                    handler(nil, .server)
                }
                }
            }
            task.resume()
    }
}
