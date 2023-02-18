//
//  ProgressUtility.swift
//
//  Created by Yehia Elbehery.
//


import UIKit
import Foundation
import SVProgressHUD


class ProgressUtility {
    
    class func setProgressViewStyles() {
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.custom)
        SVProgressHUD.setDefaultMaskType(.clear)
        
        SVProgressHUD.setBackgroundColor(UIColor(hexString: "379AE1"))
        SVProgressHUD.setForegroundColor(UIColor(hexString: "EFEFF4"))
    }
    
    class func showProgressView() {
        DimUtility.addDimView()
        
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
    }
    
    class func showProgressViewWithProgress(_ progress: Float) {
        DispatchQueue.main.async {
            SVProgressHUD.showProgress(progress)
        }
    }
    
    class func dismissProgressView() {
        DimUtility.removeDimView()
        
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
    
}
