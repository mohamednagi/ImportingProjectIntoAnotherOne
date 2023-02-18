//
//  AlertUtility.swift
//
//  Created by Yehia Elbehery.
//


import Foundation
//import SCLAlertView
import Gradientable
import UserNotifications

class AlertUtility {
    
//    static var openAlerts = [SCLAlertView]()
    static var anAlertIsPresented = false
    
//    class func remvoeAllAlerts(){
//        for alert in AlertUtility.openAlerts {
//            alert.dismiss(animated: false, completion: {
//
//            })
//        }
//        AlertUtility.openAlerts.removeAll()
//    }
    
    class func showErrorAlert(_ message: String!, isConnectionError: Bool = false){
        AlertUtility.showErrorAlertWithCallback(message, callback: {
            
        }, isConnectionError: isConnectionError)
    }
    class func showErrorAlertWithCallback(_ message: String!, callback: @escaping () -> Void, isConnectionError: Bool = false) {
//        AlertUtility.remvoeAllAlerts()
        if anAlertIsPresented == false {
            
            var gradientOptions = GradientableOptions(colors: [UIColor(r:255, g:96, b:48), UIColor(r:245, g:52, b:49)], direction: .bottomRightToTopLeft)
            if isConnectionError {
                gradientOptions = GradientableOptions(colors: [UIColor(r:250, g:217, b:97), UIColor(r:255, g:147, b:85)], direction: .bottomRightToTopLeft)
            }
        let appearance = SCLAlertView.SCLAppearance(
            kCircleTopPosition:0,
            kCircleHeight: 81,
            kCircleIconHeight: 61,
            kTitleTop:50,
            kWindowHeight: 153,
            kButtonMargin: 0,
            kButtonGradeintableOptions: gradientOptions,
            kTitleFont: UIFont(name: Constants.regularFont(), size: 15)!,
            kButtonFont:UIFont(name: Constants.boldFont(), size: 16)!,
            showCloseButton: false,
            showCircularIcon: true,
            contentViewCornerRadius: 4, buttonCornerRadius: 0,
            hideWhenBackgroundViewIsTapped: true
        )
        let alert = SCLAlertView(appearance:appearance)
        var alertViewIcon = UIImage(named: "validIco-2")
            if isConnectionError {
                alertViewIcon = UIImage(named:"infoIco")
            }
        alert.addButton("Close".y_localized, backgroundColor: .red, textColor: .white, showTimeout: nil) {
            alert.dismiss(animated: true, completion: {
                
            })
        }
        
            anAlertIsPresented = true
        alert.showTitle(
            message,
            subTitle: "",//No internet connection".y_localized,
            style: .error,
            closeButtonTitle: "Close".y_localized,
            colorStyle: 0xffffff,//0xA71F24,
            colorTextButton: 0xFFFFFF,
            circleIconImage: alertViewIcon
            ).setDismissBlock {
                
                anAlertIsPresented = false
//                guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//
//                statusBar.backgroundColor = .white
                
                callback()
        }
//        AlertUtility.openAlerts.append(alert)
        
//        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//
//        statusBar.backgroundColor = .clear
        /*let appearance = SCLAlertView.SCLAppearance(
            hideWhenBackgroundViewIsTapped: true
        )
        let alert = SCLAlertView(appearance:appearance)
        
        alert.showTitle(
            "Error".y_localized,
            subTitle: message,
            style: .error,
            closeButtonTitle: NSLocalizedString("Dismiss", comment: "Dismiss"),
            colorStyle: 0xA71F24,
            colorTextButton: 0xFFFFFF
            ).setDismissBlock {
                
                guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
                
                statusBar.backgroundColor = .white
                callback()
        }
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        
        statusBar.backgroundColor = .clear*/
        }
    }
    
    class func showConnectionError() {
        AlertUtility.showErrorAlert("No internet connection".y_localized + "\n" + "Please check your internet connection".y_localized, isConnectionError: true)
    }
    
//    class func showAlertWithoutDismiss(title: String, message: String!, buttonTitle: String!, callback: @escaping () -> Void ) {
//        let appearance = SCLAlertView.SCLAppearance(
//            showCloseButton: false,
//            shouldAutoDismiss: false
//        )
//        let alert = SCLAlertView(appearance: appearance)
//        
//        alert.addButton(buttonTitle) {
//            // Your code here
//            
//            callback()
//        }
//        
//        alert.showTitle(
//            title,
//            subTitle: message,
//            style: .info,
//            closeButtonTitle: NSLocalizedString("", comment: "Dismiss"),
//            colorStyle: 0xA71F24,//0x379AE1,
//            colorTextButton: 0xFFFFFF
//            ).setDismissBlock {
//                
//                guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//                
//                statusBar.backgroundColor = .white
//        }
//        
//        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//        
//        statusBar.backgroundColor = .clear
//    }
    
//    class func showAlertWithOneButton(title: String, message: String!, buttonTitle: String!, callback: @escaping () -> Void ) {
//        let appearance = SCLAlertView.SCLAppearance(
//            showCloseButton: false
//
//        )
//        let alert = SCLAlertView(appearance: appearance)
//
//        alert.addButton(buttonTitle) {
//            // Your code here
//
//            callback()
//        }
//
//        alert.showTitle(
//            title,
//            subTitle: message,
//            style: .info,
//            closeButtonTitle: NSLocalizedString("", comment: "Dismiss"),
//            colorStyle: 0xA71F24,//0x379AE1,
//            colorTextButton: 0xFFFFFF
//            ).setDismissBlock {
//
//                guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//
//                statusBar.backgroundColor = .white
//        }
//
//        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//
//        statusBar.backgroundColor = .clear
//    }

    
//    class func scheduleNotification(at date: Date,title: String,body: String) {
//
//        if #available(iOS 10.0, *) {
//            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 2, repeats: false)
//
//
//
//
//        let content = UNMutableNotificationContent()
//        content.title = title
//        content.body = body
//        content.sound = UNNotificationSound.default()
//        content.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground")
//
//        let request = UNNotificationRequest(identifier: "\(date)", content: content, trigger: trigger)
//
////        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        UNUserNotificationCenter.current().add(request) {(error) in
//            if let error = error {
//               DeveloperTools.print("Uh oh! We had an error: \(error)")
//            }
//        }
//        } else {
//            // Fallback on earlier versions
//        }
//    }
    class func showSuccessAlert(_ message: String!) {
        
        AlertUtility.showSuccessAlertWithCallback(message, callback: {
            
        })
    }
    
    class func showSuccessAlertWithCallback(_ message: String!, callback: @escaping () -> Void ) {
//        AlertUtility.remvoeAllAlerts()
        if anAlertIsPresented == false {
        let appearance = SCLAlertView.SCLAppearance(
            kCircleTopPosition:0,
            kCircleHeight: 81,
            kCircleIconHeight: 61,
            kTitleTop:50,
            kWindowHeight: 153,
            kButtonMargin: 0,
            kButtonGradeintableOptions: GradientableOptions(colors: [UIColor(r:35, g:189, b:115), UIColor(r:123, g:200, b:106)], direction: .bottomRightToTopLeft),
            kTitleFont: UIFont(name: Constants.regularFont(), size: 15)!,
            kButtonFont:UIFont(name: Constants.boldFont(), size: 16)!,
            showCloseButton: false,
            showCircularIcon: true,
            contentViewCornerRadius: 4, buttonCornerRadius: 0,
            hideWhenBackgroundViewIsTapped: true
        )
        let alert = SCLAlertView(appearance:appearance)
        let alertViewIcon = UIImage(named: "success")
        alert.addButton("Close".y_localized, backgroundColor: .red, textColor: .white, showTimeout: nil) {
            alert.dismiss(animated: true, completion: {
                
            })
        }
        anAlertIsPresented = true
        alert.showTitle(
            message,
            subTitle: "",
            style: .success,
            closeButtonTitle: "Close".y_localized,
            colorStyle: 0xFFFFFF,//0x379AE1,
            colorTextButton: 0xFFFFFF,
            circleIconImage: alertViewIcon
            ).setDismissBlock {
                
                anAlertIsPresented = false
//                guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//
//                statusBar.backgroundColor = .white
                
                callback()
        }
//        AlertUtility.openAlerts.append(alert)
        
//        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//
//        statusBar.backgroundColor = .clear
        }
    }
    
    class func showAlertWithButton(msg: String ,title: String , buttonTitle: String, closeButtonTitle: String!, callback: @escaping () -> Void, colors: GradientableOptions? = GradientableOptions(colors: [UIColor(r:255, g:96, b:48), UIColor(r:245, g:52, b:49)], direction: .bottomRightToTopLeft), imageName: String? = "validIco-2")
    {
//        AlertUtility.remvoeAllAlerts()
        if anAlertIsPresented == false {
        let appearance = SCLAlertView.SCLAppearance(
            kCircleTopPosition:0,
            kCircleHeight: 81,
            kCircleIconHeight: 61,
            kTitleTop:50,
            kWindowHeight: 153,
            kButtonMargin: 0,
            kButtonGradeintableOptions: colors!,
            kTitleFont: UIFont(name: Constants.regularFont(), size: 15)!,
            kButtonFont:UIFont(name: Constants.boldFont(), size: 16)!,
            showCloseButton: false,
            showCircularIcon: true,
            contentViewCornerRadius: 4, buttonCornerRadius: 0,
            hideWhenBackgroundViewIsTapped: true,
            buttonsLayout: .horizontal
        )
        let alertView = SCLAlertView(appearance:appearance)
        
        let alertViewIcon = UIImage(named: imageName!)
        
            if UserSettings.appLanguageIsArabic() == false {
        alertView.addButton(closeButtonTitle.y_localized, backgroundColor: .red, textColor: .white, showTimeout: nil) {
            alertView.dismiss(animated: true, completion: {
                
            })
        }
            }
            alertView.addButton(buttonTitle, backgroundColor: .red, textColor: .white, showTimeout: nil) {
                callback()
                }.accessibilityIdentifier = "ConfirmButton"
            
            if UserSettings.appLanguageIsArabic() {
                alertView.addButton(closeButtonTitle.y_localized, backgroundColor: .red, textColor: .white, showTimeout: nil) {
                    alertView.dismiss(animated: true, completion: {
                        
                    })
                }
            }
            
            anAlertIsPresented = true
        alertView.showTitle(
            msg,
            subTitle: "",
            style: .notice,
            closeButtonTitle: NSLocalizedString(closeButtonTitle, comment: "Dismiss"),
            colorStyle: 0xFFFFFF,//0xA71F24,//0x379AE1,
            colorTextButton: 0xFFFFFF,
            circleIconImage: alertViewIcon
            ).setDismissBlock {
                anAlertIsPresented = false

//                guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//
//                statusBar.backgroundColor = .white
        }
//        AlertUtility.openAlerts.append(alertView)

//        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//
//        statusBar.backgroundColor = .clear
        }
    }
    
//    class func showAlertWithTwoButton(msg: String ,title: String , buttonTitle: String, callback: @escaping () -> Void , buttonTwoTitle: String, callbackTwo: @escaping () -> Void)
//    {
//        let alertView = SCLAlertView()
//        alertView.addButton(buttonTitle) {
//            callback()
//            //            AlertUtility.showErrorAlert("sss")
//        }
//        alertView.addButton(buttonTwoTitle) {
//            callbackTwo()
//            //            AlertUtility.showErrorAlert("sss")
//        }
//        alertView.showTitle(
//            title,
//            subTitle: msg,
//            style: .notice,
//            closeButtonTitle: NSLocalizedString("Dismiss", comment: "Dismiss"),
//            colorStyle: 0xA71F24,//0x1E9D2B,//0x379AE1,
//            colorTextButton: 0xFFFFFF
//            ).setDismissBlock {
//
//                guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//
//                statusBar.backgroundColor = .white
//        }
//
//        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//
//        statusBar.backgroundColor = .clear
//
//    }
    
//    class func showTwoButtonsAlertWithoutDismiss(title: String , message: String, buttonTitle: String, callback: @escaping () -> Void , buttonTwoTitle: String, callbackTwo: @escaping () -> Void)
//    {
//        let appearance = SCLAlertView.SCLAppearance(
//            showCloseButton: false,
//            shouldAutoDismiss: false
//
//        )
//        let alertView = SCLAlertView(appearance: appearance)
//        alertView.addButton(buttonTitle) {
//            callback()
//        }
//        alertView.addButton(buttonTwoTitle) {
//            callbackTwo()
//        }
//        alertView.showInfo(title, subTitle: message).setDismissBlock {
//
//            guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//
//            statusBar.backgroundColor = .white
//        }
//
//        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//
//        statusBar.backgroundColor = .clear
//
//    }
   
    
}
