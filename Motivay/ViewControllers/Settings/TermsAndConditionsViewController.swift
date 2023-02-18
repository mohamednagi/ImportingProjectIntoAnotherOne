//
//  TermsAndConditionsViewController.swift
//  Motivay
//
//  Created by Yasser Osama on 11/18/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Terms & conditions".y_localized
        
        webView.isHidden = true
        
        var fileName = ""
        if UserSettings.appLanguageIsArabic() {
            fileName = "termsAr"
        } else {
            fileName = "termsEn"
        }
        
        guard let path = Bundle.main.path(forResource: fileName, ofType: "txt") else {
            return
        }
        
        let content = try! String(contentsOfFile: path, encoding: .utf8)
        textView.text = content
        /*
         webView.scalesPageToFit = true
         guard let path = Bundle.main.path(forResource: "Terms", ofType: "html") else {
         return
         }
         
         let url = NSURL(fileURLWithPath: path)
         
         if let data = NSData(contentsOf: url as URL) {
         
         webView.loadHTMLString(NSString(data: data as Data,
         encoding: String.Encoding.utf8.rawValue)! as String, baseURL: nil)
         
         }
         */
    }

}
