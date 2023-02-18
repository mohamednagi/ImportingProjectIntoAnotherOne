//
//  Networking.swift
//
//  Created by Yehia Elbehery.
//

import Alamofire
//import Crashlytics

typealias JSON = [String : Any]
typealias JSONArray = [JSON]

struct NetworkingManager {

    static let serverTrustPolicies: [String: ServerTrustPolicy] = [
        "kafu.thiqah.sa": .pinPublicKeys(
            publicKeys: ServerTrustPolicy.publicKeys(),
            validateCertificateChain: true,
            validateHost: true
        )
    ]
    static let networkDelegate = NetworkingDelegate()
    static let shared: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        let sessionManager = Alamofire.SessionManager(configuration: configuration, delegate: NetworkingManager.networkDelegate, serverTrustPolicyManager: ServerTrustPolicyManager(policies: NetworkingManager.serverTrustPolicies))
        return sessionManager
    }()
}

class Networking {
    
    static func getJSONArray(baseUrl: String, endpoint: String, queryParameters: Dictionary<String, Any>? = nil, handler: ((JSONArray?, Bool, Any?) -> Void)? = nil) {
        var url  = "\(baseUrl)\(endpoint)"
        if queryParameters != nil {
            var components = URLComponents()
            components.queryItems = queryParameters!.map {
                URLQueryItem(name: "\($0)", value: "\($1)")
            }
            url = "\(url)\(components.url!)"
        }
        /*var request = URLRequest(url: URL(string:url)!)
        request.timeoutInterval = 30
        request.httpMethod = "GET"
        Alamofire.request(request).responseJSON*/NetworkingManager.shared.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON(completionHandler: { response in
//            DeveloperTools.print("---------------get URL request ")
//            DeveloperTools.print(url)
//            DeveloperTools.print(response)
//            DeveloperTools.print("----------------")
            
            switch (response.result) {
            case .success:
                
                if let jsonArray = response.result.value as? JSONArray {
                    handler?(jsonArray, true, nil)
                } else {
                    handler?(nil, false, response.result.value)
                }
                break
            case .failure(let error):
                handler?(nil, false, response.response?.statusCode)
//                if error._code == NSURLErrorTimedOut {
                    //HANDLE TIMEOUT HERE
//                }
                break
            }
        })
    }
    
    static func getJSON(baseUrl: String, endpoint: String, queryParameters: Dictionary<String, Any>? = nil, headers: HTTPHeaders, handler: ((JSON?, Bool, Any?) -> Void)? = nil) {
        var url  = "\(baseUrl)\(endpoint)"
        if queryParameters != nil {
            var components = URLComponents()
            components.queryItems = queryParameters!.map {
                URLQueryItem(name: "\($0)", value: "\($1)")
            }
            url = "\(url)\(components.url!)"
        }
        /*var request = URLRequest(url: URL(string:url)!)
        request.timeoutInterval = 30
        request.httpMethod = "GET"
        Alamofire.request(request)*/NetworkingManager.shared.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { response in
            
//                    DeveloperTools.print("---------------get URL request ")
//            DeveloperTools.print(headers)
//            DeveloperTools.print(url)
//            DeveloperTools.print(response)
//                    DeveloperTools.print("----------------")

            
            switch (response.result) {
            case .success:
                
                if let json = response.result.value as? JSON {
                    handler?(json, true, nil)
                } else {
                    handler?(nil, false, response.result.value)
                }
                break
            case .failure(let error):
                handler?(nil, false, response.response?.statusCode)
                //                if error._code == NSURLErrorTimedOut {
                //HANDLE TIMEOUT HERE
                //                }
                break
            }
        })
    }

    static func post(baseUrl: String, endpoint: String, queryParameters: Dictionary<String, Any>? = nil, headers: HTTPHeaders, handler: ((JSON?, Bool, Any?) -> Void)? = nil) {
        let url  = "\(baseUrl)\(endpoint)"
        
        /*var request = URLRequest(url: URL(string:url)!)
        request.timeoutInterval = 30
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: queryParameters!, options: [])
        
        Alamofire.request(request)*/NetworkingManager.shared.request(url, method: .post, parameters: queryParameters!, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
//            DeveloperTools.print("---------------post URL request ")
//            DeveloperTools.print(headers)
//            DeveloperTools.print(response.result)
//            DeveloperTools.print(queryParameters!)
//            DeveloperTools.print(url)
//            DeveloperTools.print("----------------", response.response?.statusCode)
            
            switch (response.result) {
            case .success:
                
                if let json = response.result.value as? JSON {
                    handler?(json, true, nil)
                } else {
                    handler?(nil, false, response.result.value)
                }
                break
            case .failure(let error):
                handler?(nil, false, response.response?.statusCode)
                //                if error._code == NSURLErrorTimedOut {
                //HANDLE TIMEOUT HERE
                //                }
                break
            }
        }
    }
    
    
    static func postUrlEncoding(url: String, queryParameters: Dictionary<String, Any>? = nil, handler: ((JSON?, Bool, Any?) -> Void)? = nil) {
        
        /*var request = URLRequest(url: URL(string:url)!)
        request.timeoutInterval = 30
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: queryParameters!, options: [])
        Alamofire.request(request)*/NetworkingManager.shared.request(url, method: .post, parameters: queryParameters!, encoding: URLEncoding.default).responseJSON(completionHandler: { response in
            
            DeveloperTools.print("---------------post URL encoding request ")
            
            DeveloperTools.print(response.request?.httpBody)
            DeveloperTools.print(queryParameters!)
            DeveloperTools.print(url)
            DeveloperTools.print("----------------", response.response?.statusCode)

            switch (response.result) {
            case .success:
                
                if let json = response.result.value as? JSON {
                    handler?(json, true, nil)
                } else {
                    handler?(nil, false, response.result.value)
                }
                break
            case .failure(let error):
//                print("posteurl ", error)
//                print("posteurl ", response)
                
                handler?(nil, false, response.response?.statusCode)
                
                //                if error._code == NSURLErrorTimedOut {
                //HANDLE TIMEOUT HERE
                //                }
                break
            }
        })
    }
    
}

class NetworkingDelegate: SessionDelegate {
    
    override init() {
        super.init()
        
        sessionDidReceiveChallengeWithCompletion = { session, challenge, completion in
            guard let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 else {
                // This case will probably get handled by ATS, but still...
                completion(.cancelAuthenticationChallenge, nil)
                return
            }
            
            // Compare the server certificate with our own stored
            if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0) {
                let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
                
                if NetworkingDelegate.pinnedCertificates().contains(serverCertificateData) {
                    completion(.useCredential, URLCredential(trust: trust))
                    return
                } else {
                    AlertUtility.showErrorAlertWithCallback("Your Network connection is not secure, please check your network connection", callback: {
                        exit(0)
                    })
                }
            }
            
            // Or, compare the public keys
            if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0), let serverCertificateKey = NetworkingDelegate.publicKey(for: serverCertificate) {
                if NetworkingDelegate.pinnedKeys().contains(serverCertificateKey) {
                    completion(.useCredential, URLCredential(trust: trust))
                    return
                } else {
                    AlertUtility.showErrorAlertWithCallback("Your Network connection is not secure, please check your network connection", callback: {
                        exit(0)
                    })
                }
            }
            
            completion(.cancelAuthenticationChallenge, nil)
        }
    }
    
    private static func pinnedCertificates() -> [Data] {
        var certificates: [Data] = []
        
        if let pinnedCertificateURL = Bundle.main.url(forResource: "thiqahsa", withExtension: "crt") {
            do {
                let pinnedCertificateData = try Data(contentsOf: pinnedCertificateURL)
                certificates.append(pinnedCertificateData)
            } catch (_) {
                // Handle error
            }
        }
        
        return certificates
    }
    
    private static func pinnedKeys() -> [SecKey] {
        var publicKeys: [SecKey] = []
        
        if let pinnedCertificateURL = Bundle.main.url(forResource: "thiqahsa", withExtension: "crt") {
            do {
                let pinnedCertificateData = try Data(contentsOf: pinnedCertificateURL) as CFData
                if let pinnedCertificate = SecCertificateCreateWithData(nil, pinnedCertificateData), let key = publicKey(for: pinnedCertificate) {
                    publicKeys.append(key)
                }
            } catch (_) {
                // Handle error
            }
        }
        
        return publicKeys
    }
    
    // Implementation from Alamofire
    private static func publicKey(for certificate: SecCertificate) -> SecKey? {
        var publicKey: SecKey?
        
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        if let trust = trust, trustCreationStatus == errSecSuccess {
            publicKey = SecTrustCopyPublicKey(trust)
        }
        
        return publicKey
    }
}
