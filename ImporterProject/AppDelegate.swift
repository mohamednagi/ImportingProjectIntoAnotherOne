////
////  AppDelegate.swift
////  ImporterProject
////
////  Created by Mohamed Nagi on 16/02/2023.
////
//
//import UIKit
//
//@main
//class AppDelegate: UIResponder, UIApplicationDelegate {
//
//
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//        return true
//    }
//
//    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
//
//
//}
//
//
//  AppDelegate.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import IQKeyboardManagerSwift
import SDWebImage
import UserNotifications
import Firebase
//import FirebaseInstanceID
import FirebaseMessaging
import SlideMenuControllerSwift
import AppCenter
import AppCenterCrashes
import AppCenterAnalytics
import AppCenterDistribute

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    static var deviceToken = ""
    
    static var notificationType: NotificationType!
    static var awardId: Int! = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if isJaiBroken() {
            exit(0)
        }
        
        IQKeyboardManager.shared.enable = true
        DimUtility.setDimViewStyles()
        
    
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.primaryColorWithAlpha], for: UIControlState.disabled)
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name:Constants.regularFont() , size: 17)!
            ], for: UIControlState.disabled)
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name:Constants.regularFont() , size: 17)!
            ], for: UIControlState.highlighted)
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name:Constants.regularFont() , size: 17)!
            ], for: .normal)
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: UIFont(name:Constants.boldFont() , size: 17)!
        ]
        
        #if MOTIVAY_DEV
//        BITHockeyManager.shared().configure(withIdentifier: "a6d59a7579224e8f8393a86cde8f11ca")
        #endif
        #if THIQAH
//        BITHockeyManager.shared().configure(withIdentifier: "4eddf208afa24ab09b27ffcf3e091b61")
//        BITHockeyManager.shared().start()
//        BITHockeyManager.shared().authenticator.authenticateInstallation()
//        BITHockeyManager.shared().updateManager.checkForUpdate()
        #endif
        #if ADAM
        MSAppCenter.start("b563e867-ef5e-4483-b627-c54b9e5b7070", withServices:[
            MSAnalytics.self,
            MSCrashes.self,
            MSDistribute.self
            ])
        #endif
        
//        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return true }
//
//        statusBar.backgroundColor = .white
        
        if ProcessInfo.processInfo.arguments.contains("UITesting_Login") ||
            ProcessInfo.processInfo.arguments.contains("UITesting_Forgot") ||
            ProcessInfo.processInfo.arguments.contains("UITesting_Reset") {
            
            MenuViewController.logoutOps()
        }
        
        SDImageCache.shared.config.shouldCacheImagesInMemory = true
        //        SDImageCache.shared().config.shouldDecompressImages = false
        //        SDImageCache.shared().config.maxCacheSize = 5 * 1024 * 1024
        //        DeveloperTools.findTheOne()
        
        //        for family: String in UIFont.familyNames
        //        {
        //            print("\(family)")
        //            for names: String in UIFont.fontNames(forFamilyName: family)
        //            {
        //                print("== \(names)")
        //            }
        //        }
        
        FirebaseApp.configure()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // Check if application was opened from a notification
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            //handle your notification
            print("Received Notification in didFinishLaunchingWithOptions \(userInfo)")
            handleRemoteNotification(userInfo, launch: false)
        }
        
        //        self.perform(#selector(dotAddToNotificationsTabBarItem), with: nil, afterDelay: 10)
        ////
        //        self.perform(#selector(dotAddToNotificationsTabBarItem), with: nil, afterDelay: 20)
        //        self.perform(#selector(dotAddToNotificationsTabBarItem), with: nil, afterDelay: 30)
        //        self.perform(#selector(dotAddToNotificationsTabBarItem), with: nil, afterDelay: 40)
        //        self.perform(#selector(dotAddToNotificationsTabBarItem), with: nil, afterDelay: 50)
        //        self.perform(#selector(dotAddToNotificationsTabBarItem), with: nil, afterDelay: 60)
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
        dotAddToNotificationsTabBarItem()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokens = deviceToken.map {
            return String(format: "%02.2hhx", $0)
        }
        
        let token = deviceTokens.joined()
        print(token)
//        Messaging.messaging().setAPNSToken(deviceToken, type: .sandbox)
        Messaging.messaging().apnsToken = deviceToken
//        InstanceID.instanceID().instanceID(handler: { (result, error) in
//            if error != nil {
//
//            } else if let result = result {
//                AppDelegate.deviceToken = result.token
//            }
//        })
//        if let token = InstanceID.instanceID().token() {
//            AppDelegate.deviceToken = token
//            Backend.registerDevice(true)
//        }
        
        connectToFcm()
    }
    
    static func registerDevice() {
        /// commented from first commit by Omar Ibrahim
        /*
        InstanceID.instanceID().instanceID { (result, error) in
            if let token = result?.token {
                AppDelegate.deviceToken = token
                Backend.registerDevice(true)
                Backend.updateSettings(EmailNotification: nil, PushNotification: true, UserLanguage: nil, completion: { (success, backendError) in
                })
            }
        }
         */
//        if let token = InstanceID.instanceID().token() {
//
//        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Push notification received:")
        if application.applicationState == .active {
            print("active")
            if let urlString = userInfo["url"] as? String {
                if let url = URL(string: urlString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        } else {
            print("inactive")
            handleRemoteNotification(userInfo, launch: true)
        }
        print(userInfo)
    }
    
    
    @objc func dotAddToNotificationsTabBarItem(){
        print("oone")
        DispatchQueue.main.async {
            if let slideMenu = self.window?.rootViewController as? SlideMenuController {
                print("twoo")
                if let navBar = slideMenu.mainViewController as? ExampleNavigationController {
                    print("thththtree")
                    if let tabBar = navBar.viewControllers.first as? UITabBarController {
                        print("fffour")
                        if let notificationsVC = tabBar.viewControllers?[3] as? NotificationsViewController {
                            print("fivvvve")
                            //                        notificationsVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "Notifications-1")!.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "pdfNotifications-active")!.withRenderingMode(.alwaysOriginal))
                            //                        notificationsVC.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
                            notificationsVC.tabBarItem.image = UIImage(named: "Notifications-1")!.withRenderingMode(.alwaysOriginal)
                            //                        notificationsVC.loadData()
                        }
                    }
                }
            }
        }
    }
    
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any], launch: Bool) {
        if let x = userInfo as? Dictionary<String, Any> {
            print(x)
            dotAddToNotificationsTabBarItem()
            if let urlString = x["url"] as? String {
                if let url = URL(string: urlString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            var type = ""
            var id = ""
            if let notificationType = x["NotificationType"] as? String {
                type = notificationType
            }
            if let awardId = x["AwardId"] as? String {
                id = awardId
            }
            if type != "7" {
                if type == "5" {
                    AppDelegate.notificationType = .star
                } else if type == "6" {
                    AppDelegate.notificationType = .sendThreshold
                } else {
                    AppDelegate.notificationType = .thanks
                }
                if id.isEmpty {
                    AppDelegate.awardId = 0
                } else {
                    AppDelegate.awardId = Int(id)!
                }
//                AlertUtility.show
                if launch {
                    SignInViewController.launchHome(onFailure: {
                        //                    self.showSignIn()
                    })
                }
            }
        }
    }
    
    func connectToFcm() {
//        Messaging.messaging().connect { (error) in
//            if (error != nil) {
//                print("Unable to connect with FCM. \(String(describing: error))")
//            } else {
//                print("Connected to FCM.")
//            }
//        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
            if notifications.count > 0 {
                self.dotAddToNotificationsTabBarItem()
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
//        if let _ = UserSettings.getUserPreference("accessTokenExpiryTime") as? Date, let _ =  UserSettings.getUserPreference("accessToken") as? String, let _ = UserSettings.getUserPreference("userSource") as? String {
//            DeveloperTools.print("--------- LangSettings: We have the token")
//            Backend.getAppSettings(completion: { (applicationSettings, backendError) in
//                UserSettings.applicationSettings = applicationSettings
//            })
//        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        AppDelegate.deviceToken = fcmToken ?? ""
        print("FCMTOKEN \(fcmToken)")
        let dataDict: [String: String] = ["token": (fcmToken ?? "")]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func isJaiBroken() -> Bool {
        if TARGET_IPHONE_SIMULATOR != 1 {
            // Check 1 : existence of files that are common for jailbroken devices
            if FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
                || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
                || FileManager.default.fileExists(atPath: "/bin/bash")
                || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
                || FileManager.default.fileExists(atPath: "/etc/apt")
                || FileManager.default.fileExists(atPath: "/private/var/lib/apt/")
                || UIApplication.shared.canOpenURL(URL(string:"cydia://package/com.example.package")!)
            {
                return true
            }
            // Check 2 : Reading and writing in system directories (sandbox violation)
            let stringToWrite = "Jailbreak Test"
            do {
                try stringToWrite.write(toFile:"/private/JailbreakTest.txt", atomically:true, encoding:String.Encoding.utf8)
                //Device is jailbroken
                return true
            } catch {
                return false
            }
        } else {
            return false
        }
    }
    
}
