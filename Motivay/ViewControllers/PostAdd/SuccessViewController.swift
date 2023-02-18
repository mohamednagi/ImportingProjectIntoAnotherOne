//
//  SuccessViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import Lottie

class SuccessViewController: UIViewController {
    
    @IBOutlet weak var mainTitleLabel : AutomaticallyLocalizedLabel!
    @IBOutlet weak var successImageView : UIImageView!
    @IBOutlet weak var backButton : UIButton!
    @IBOutlet weak var messageAndNameLabel : AutomaticallyLocalizedLabel!
    @IBOutlet weak var pointsLabel : ArabicNumbersLabel!
    @IBOutlet weak var animationView: AnimationView!
    
    var animationFile = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.backgroundColor = .primaryColor
        animationView.contentMode = .scaleAspectFit
        animationView.play()
//        animationView.loopAnimation = true
        Backend.getProfileDetails(withID: nil, completion: { (employee, backendError) in
            if backendError != nil {
            } else {
                UserSettings.info = employee
            }
        }, showLoading: false)
        // Do any additional setup after loading the view, typically from a nib.
//        
//        if UserSettings.appLanguageIsArabic() {
//            
//            let myString:NSString = "محمود جابر 2500 نقطة"
//            var myMutableString = NSMutableAttributedString()
//            myMutableString = NSMutableAttributedString(string: myString as String, attributes:nil)
//            myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(r:236, g:19, b:129), range: NSRange(location:10,length:10))
//            nameAndPointsLabel.attributedText = myMutableString
//            
//        }else{
//            
//            let myString:NSString = "Mahmoud Gaber 2500 Points"
//            var myMutableString = NSMutableAttributedString()
//            myMutableString = NSMutableAttributedString(string: myString as String, attributes:nil)
//            myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(r:236 ,g:19 ,b:129), range: NSRange(location:14,length:11))
//            nameAndPointsLabel.attributedText = myMutableString
//        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func back(){
//        self.navigationController?.popViewController(animated: true)
//    }
}

