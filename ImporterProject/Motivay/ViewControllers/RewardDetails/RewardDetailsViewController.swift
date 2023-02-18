//
//  RewardDetailsViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import SDWebImage
import Alamofire
import Gradientable
import Lottie

class RewardDetailsViewController: UIViewController {
    
    @IBOutlet weak var vendorImageView: UIImageView!
    @IBOutlet weak var pointsLabel: ArabicNumbersLabel!
    
    @IBOutlet weak var titleLabel: AutomaticallyLocalizedLabel!
    @IBOutlet weak var vendorLabel: AutomaticallyLocalizedLabel!
    @IBOutlet weak var descriptionLabel: AutomaticallyLocalizedLabel!
    
    @IBOutlet weak var boughtCountLabel: AutomaticallyLocalizedLabel!
    
    @IBOutlet weak var redeemButton: UIButton!//GradientableButton!
    @IBOutlet weak var percentageView: UIView!
//    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var percentageDivider: UIImageView!
    @IBOutlet weak var redeemButtonText: AutomaticallyLocalizedLabel!
    @IBOutlet weak var rewardImageView: UIImageView!
    
    @IBOutlet weak var redeemedView: UIView!
    @IBOutlet weak var redemptionDateLabel: AutomaticallyLocalizedLabel!
    @IBOutlet weak var redemptionCodeLabel: ArabicNumbersLabel!
    @IBOutlet weak var redemptionStateBtn: AutomaticallyLocalizedButton!
    @IBOutlet weak var redemptionStateImageView: UIImageView!
    
    
    var grayView: UIView!
    
    var reward : Reward!
    var fromRedeemed = false
    var redemptionCode: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        self.navigationItem.hidesBackButton = true
//        let backImage: UIImage!
//        if UserSettings.appLanguageIsArabic() {
//            backImage = UIImage(named:"backPinkAr")
//        }else{
//            backImage = UIImage(named:"backPink")
//        }
//        let newBackButton = UIBarButtonItem(image: backImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backAction(sender:)))
//        self.navigationItem.leftBarButtonItem = newBackButton
        redeemedView.isHidden = true
        loadData()
//        if reward.IsBookmarked {
//            bookmarkTitle.text = "Bookmarked"
//        }else{
//            bookmarkTitle.text = "Bookmark"
//        }
        
        DeveloperTools.print("create")
        let grayOffsetWidth = percentageView.frame.size.width
        if grayView != nil {
            grayView.removeFromSuperview()
        }
        grayView = UIView(frame:CGRect(x:0, y:0, width:grayOffsetWidth, height:percentageDivider.frame.size.height))
        grayView.backgroundColor = .whiteThree
        percentageView.sendSubview(toBack: percentageDivider)
        percentageView.sendSubview(toBack: grayView)
        
        percentageView.addSubview(grayView)
        
        if UserSettings.appLanguageIsArabic() {
            percentageDivider.image = UIImage(named:"btn-edge-ar")
        }
    }
    
    func loadData(){
        if fromRedeemed {
            Backend.getRedeemedRewardDetails(redemptionCode: "\(redemptionCode!)", completion: { (reward, backendError) in
                if backendError == .connection {
                    
                } else {
                    if reward != nil {
                        self.reward = reward
                        self.populateRewardData()
                        self.animateRedeemButton()
                    }
                }
            })
        } else {
            Backend.getRewardDetails(rewardId: reward.RewardId, completion: { (reward, backendError) in
                //            if showLoading {
                //                LoadingOverlay.shared.hideOverlayView()
                //            }
                
                if backendError == .connection {
                    
                }else{
                    if reward != nil {
                        self.reward = reward
                        self.populateRewardData()
                        self.animateRedeemButton()
                    }
                    
                }
            })
        }
    }
    
    func populateRewardData() {
        titleLabel.text = reward.RewardName
        if reward.RewardDescription != nil {
            descriptionLabel.text = reward.RewardDescription
            descriptionLabel.sizeToFit()
        }
        vendorLabel.text = reward.VendorName
        if reward.NumberOfRedeemtion != nil {
            boughtCountLabel.text = "\(reward.NumberOfRedeemtion!) " + "bought it!".y_localized
        }
        pointsLabel.text = "\(reward.RewardsPoints!)"
        
        if reward.VendorImage == nil {
            vendorImageView.sd_setImage(with: URL(string:"rectangle2"))
        } else {
            vendorImageView.sd_setImage(with: URL(string:reward.VendorImage), placeholderImage:UIImage(named:"rectangle2"))
        }
        
        if reward.RewardImage == nil {
            rewardImageView.sd_setImage(with: URL(string:"rectangle2"))
        } else {
            rewardImageView.sd_setImage(with: URL(string:reward.RewardImage), placeholderImage:UIImage(named:"rectangle2"))
        }
        
        rewardImageView.layer.cornerRadius = 4
        rewardImageView.clipsToBounds = true
        
        if fromRedeemed {
            redeemedView.isHidden = false
            
            if reward.redemptionCode != nil {
                redemptionCodeLabel.text = "\(reward.redemptionCode!)"
            }
            if reward.redemptionDate != nil {
                if let date = reward.redemptionDate.y_getDateFromString() {
                    let dateFormatter = DateFormatter()
                    if UserSettings.appLanguageIsArabic() {
                        dateFormatter.locale = Locale(identifier: "ar")
                    } else {
                        dateFormatter.locale = Locale(identifier: "en")
                    }
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    let dateStr = dateFormatter.string(from: date)
                    redemptionDateLabel.text = dateStr
                } else {
                    redemptionDateLabel.text = ""
                }
            }
            if reward.redemptionState != nil {
                switch reward.redemptionState! {
                case .requested:
                    if UserSettings.appLanguageIsArabic() {
                        redemptionStateImageView.image = #imageLiteral(resourceName: "RequestedAr")
                    } else {
                        redemptionStateImageView.image = #imageLiteral(resourceName: "Requested")
                    }
                case .inProgress:
                    if UserSettings.appLanguageIsArabic() {
                        redemptionStateImageView.image = #imageLiteral(resourceName: "InProgressAr")
                    } else {
                        redemptionStateImageView.image = #imageLiteral(resourceName: "InProgress")
                    }
                case .delivered:
                    if UserSettings.appLanguageIsArabic() {
                        redemptionStateImageView.image = #imageLiteral(resourceName: "DeliveredAr")
                    } else {
                        redemptionStateImageView.image = #imageLiteral(resourceName: "Delivered")
                    }
                default:
                    redemptionStateImageView.isHidden = true
                }
            } else {
                if UserSettings.appLanguageIsArabic() {
                    redemptionStateImageView.image = #imageLiteral(resourceName: "RequestedAr")
                } else {
                    redemptionStateImageView.image = #imageLiteral(resourceName: "Requested")
                }
            }
        }
        
        let path = UIBezierPath(roundedRect: vendorImageView.bounds, byRoundingCorners: [.bottomRight, .bottomLeft], cornerRadii: CGSize(width: 10, height: 10))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        vendorImageView.layer.mask = mask
        
        let rightButton: UIButton = UIButton(type: UIButtonType.custom)
        //set image for button
        if reward.IsBookmarked {
            
            rightButton.setImage(UIImage(named: "bookmarked"), for: .normal)
        } else {
            rightButton.setImage(UIImage(named: "bookmarkStroke"), for: .normal)
        }
        //set frame
        rightButton.frame = CGRect(x:0, y:0, width:25, height:25)
        
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        
        rightBarButton.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bookmarkToggle)))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        if UserSettings.info!.EarnedPoints < reward.RewardsPoints {
            var str :  String!
            let neededPoints : Int! = reward.RewardsPoints - UserSettings.info!.EarnedPoints
            str = numberFormatter(points: neededPoints)
            str = "\(str!) " + "to Redeem this item".y_localized
            redeemButtonText.text = str!//redeemButton.setTitle(str!, for: .normal)
            redeemButton.setTitle("", for: .normal)
//            redeemButton.isEnabled = false
//            redeemButton.alpha = 0.4
            percentageView.layer.cornerRadius = 28
            percentageView.clipsToBounds = true
            
            
            percentageView.isHidden = false
            
            if UserSettings.appLanguageIsArabic() {
                redeemButton.y_applyGradient(withColours: [.macaroniAndCheese, .primaryColor], gradientOrientation: .horizontal)
//                redeemButton.set(options: GradientableOptions(colors: [.primaryColor, .macaroniAndCheese], direction:.topRightToBottomLeft))
            } else {
                redeemButton.y_applyGradient(withColours: [.primaryColor, .macaroniAndCheese], gradientOrientation: .horizontal)
//                redeemButton.set(options: GradientableOptions(colors: [.primaryColor, .macaroniAndCheese], direction:.topLeftToBottomRight))
            }
            redeemButton.layer.cornerRadius = 28
            redeemButton.clipsToBounds = true
            redeemButton.isEnabled = false
        } else {
            redeemButton.setTitle(/*"Redeem item"*/"Redeem now".y_localized, for: .normal)
            redeemButton.titleLabel?.font = UIFont(name: Constants.boldFont(), size: 15)!
            redeemButton.isEnabled = true
            redeemButton.alpha = 1
            percentageView.isHidden = true
        }
    }
    
    @objc func bookmarkToggle(sender: UIButton){
        self.reward.IsBookmarked = !self.reward.IsBookmarked
        self.populateRewardData()
        Backend.rewardBookmark(rewardId: reward.RewardId, completion: { (success, backendError) in
            if !success {
//                AlertUtility.showErrorAlert(Constants.errorMessage(.General_Failure))
                self.reward.IsBookmarked = !self.reward.IsBookmarked
                self.populateRewardData()
            }else{
                
                if let tabBar = self.previousViewController as? UITabBarController {
                    
                if let rewardSubcategoryVC = tabBar.viewControllers?[1] as? RewardsSubcategoryViewController {
                    
                    for i in 0 ..< rewardSubcategoryVC.rewardsSubcategoryTableViewAdapter.data.count {
                        
                        if let srcReward = rewardSubcategoryVC.rewardsSubcategoryTableViewAdapter.data[i] as? Reward {
                            
                                if self.reward.RewardId == srcReward.RewardId {
//                                    rewardSubcategoryVC.rewardsSubcategoryTableViewAdapter.data[i] = self.reward
                            
                            if rewardSubcategoryVC.rewardsListType != nil {
                            if rewardSubcategoryVC.rewardsListType! == .Bookmarked {
                               
                                DeveloperTools.print("remove from parent")
                                rewardSubcategoryVC.rewardsSubcategoryTableViewAdapter.data.remove(at: i)
                                break
                            }
                                    }
                            }
                        }
                    }
                }
            }
            }
        })

    }
    
    func numberFormatter(points: Int) -> String{
        var str = ""
        if UserSettings.appLanguageIsArabic() {
            if points == 1 {
                str = "نقطة واحدة"
            }else if points == 2 {
                str = "تقطتان"
            }else if points >= 3 && points <= 10 {
                str = "\(points) نقاط"
            }else{
                str = "\(points) نقطة"
            }
        }else{
            str = "\(points) points"
        }
        return str
    }
    
    @objc func backToRewards(sender: UIButton){
        sender.superview?.removeFromSuperview()
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    
    @IBAction func rewardRedeem(sender: UIButton){
        
        if NetworkReachabilityManager()!.isReachable == false {
            AlertUtility.showConnectionError()
        } else {
        let successVC = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Success") as! SuccessViewController

        AlertUtility.showAlertWithButton(msg: "Are you sure you want to redeem".y_localized + " \(reward.RewardName!) " + "with".y_localized + " \(numberFormatter(points: (reward.RewardsPoints!)))" + "?".y_localized, title: "", buttonTitle: "Yes".y_localized, closeButtonTitle: "Cancel".y_localized, callback : {
            
            Backend.rewardRedeem(rewardId: self.self.reward.RewardId, completion: { (success, redeemResponse, backendError, errorMsg) in
                if success == false {
                    if errorMsg.isEmpty {
                        AlertUtility.showErrorAlert(Constants.errorMessage(.General_Failure))
                    } else {
                        AlertUtility.showErrorAlert(errorMsg)
                    }
                }else{
                    //                    let nvc = ((self.presentingViewController as! SlideMenuController).mainViewController as! ExampleNavigationController)
                    
                    Backend.getProfileDetails(withID: nil, completion: { (employee, backendError) in
                        if backendError != nil {
                        }else{
                            //                                dump(employee)
                            UserSettings.info = employee
                        }
                    }, showLoading: false)
                    (successVC.view.viewWithTag(7) as! UIButton).addTarget(self, action: #selector(self.backToRewards), for: .touchUpInside)
                    successVC.mainTitleLabel.text = Fonts.congratulations.y_localized
                    
                    var myMutableString1 = NSMutableAttributedString()
                    let youHave = NSAttributedString(string: "You've successfully redeemed".y_localized, attributes: [NSAttributedStringKey.font: UIFont(name: Constants.regularFont(), size: 17)!, NSAttributedStringKey.foregroundColor: UIColor.greyishBrownTwo])
                    
                    myMutableString1.append(youHave)
                    myMutableString1.append(NSAttributedString(string:"\n"))
                    
                    var redeemMsg = ""
                    if UserSettings.appLanguageIsArabic() {
                        redeemMsg = redeemResponse["RedemptionMessageAr"] as! String
                    } else {
                        redeemMsg = redeemResponse["RedemptionMessage"] as! String
                    }
                    
                    let redemptionMessage = NSAttributedString(string: redeemMsg, attributes: [NSAttributedStringKey.font: UIFont(name: Constants.regularFont(), size: 14)!, NSAttributedStringKey.foregroundColor: UIColor.greyishBrownTwo])
                    
                    myMutableString1.append(redemptionMessage)
                    myMutableString1.append(NSAttributedString(string:"\n"))
                    
                    let name = NSAttributedString(string: self.reward.RewardName!, attributes: [NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 17)!, NSAttributedStringKey.foregroundColor: UIColor.greyishBrownTwo])
                    
                    myMutableString1.append(name)
                    myMutableString1.append(NSAttributedString(string:"\n"))
//                    if UserSettings.appLanguageIsArabic() {
//                        let successfullyAr = NSAttributedString(string: " بنجاح.", attributes: [NSAttributedStringKey.font: UIFont(name: Constants.regularFont(), size: 17)!, NSAttributedStringKey.foregroundColor: UIColor(r:74, g:74, b:74)])
//                        myMutableString1.append(successfullyAr)
//                    }
                    
                    let redeemCode = NSAttributedString(string:"Your code is".y_localized, attributes: [NSAttributedStringKey.font: UIFont(name: Constants.regularFont(), size: 17)!, NSAttributedStringKey.foregroundColor: UIColor.greyishBrownTwo])
                    myMutableString1.append(redeemCode)
                    
                    let points = NSAttributedString(string: " " + "\(redeemResponse["RedemptionId"]!)", attributes: [NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 14)!, NSAttributedStringKey.foregroundColor: UIColor.primaryColor])
                    
                    myMutableString1.append(points)
                    myMutableString1.append(NSAttributedString(string:"."))
                    
                    successVC.messageAndNameLabel.attributedText = myMutableString1
                    successVC.backButton.setTitle(/*"Back to rewards"*/"Back".y_localized, for: .normal)
                    successVC.backButton.titleLabel?.font = UIFont(name:Constants.boldFont(), size:15)
                    successVC.successImageView.image = UIImage(named:"giftIllustration")
//                    successVC.animationView.setAnimation(named: "rewardSuccess")
                    successVC.animationView.animation = Animation.named("rewardSuccess")

//                    successVC.animationFile = "rewardSuccess"
//                    var myMutableString = NSMutableAttributedString()
//                    let points : NSAttributedString!
//
//
//                        points = NSAttributedString(string: "\(self.numberFormatter(points: points)!) points", attributes: [NSAttributedStringKey.font: UIFont(name: Constants.boldFont, size: 14)!, NSAttributedStringKey.foregroundColor: UIColor(r:236, g:19, b:129)])
//                    myMutableString.append(points)
//                    myMutableString.append(NSAttributedString(string:" "))
//                    myMutableString.append(NSAttributedString(string:"Successfully".y_localized))
//                    myMutableString.append(NSAttributedString(string:"."))
//
//                    postSuccess.pointsLabel.attributedText = myMutableString
                    
                    
                    self.navigationController?.view.addSubview(successVC.view)
                }
            })
        }, colors: GradientableOptions(colors: [UIColor.lightMustard, UIColor.pastelOrange], direction: .bottomRightToTopLeft), imageName:"infoIco")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        redeemButton.backgroundColor = .primaryColor
        self.title = /*"Card details"*/"Details".y_localized
        self.navigationController?.navigationBar.tintColor = .primaryColor
        self.navigationController?.y_showShadow()
        
        
    }
    
    func animateRedeemButton(){
        
        if UserSettings.info!.EarnedPoints < reward.RewardsPoints {
            
        percentageDivider.translatesAutoresizingMaskIntoConstraints = true
        let percentage = Int(CGFloat(UserSettings.info!.EarnedPoints)/CGFloat(reward.RewardsPoints) * 100)
            
        var position = (CGFloat(percentage) * redeemButton.frame.size.width) / 100
        
            if UserSettings.appLanguageIsArabic() {
                position = percentageView.frame.size.width - position - 57
            }
        
        var dividerOffsetX = -percentageDivider.frame.size.width + 20
            if UserSettings.appLanguageIsArabic() {
                dividerOffsetX = percentageView.frame.size.width - 40
            }
        percentageDivider.frame = CGRect(x: CGFloat(dividerOffsetX), y:percentageDivider.frame.origin.y, width:percentageDivider.frame.size.width,height: percentageDivider.frame.size.height)
        
        
            DeveloperTools.print("create")
            let grayOffsetWidth = percentageView.frame.size.width
            if grayView != nil {
                grayView.removeFromSuperview()
            }
            grayView = UIView(frame:CGRect(x:0, y:0, width:grayOffsetWidth, height:percentageDivider.frame.size.height))
            grayView.backgroundColor = .whiteThree
            percentageView.addSubview(grayView)
            percentageView.sendSubview(toBack: grayView)
            percentageView.bringSubview(toFront: redeemButtonText)
            
        var grayX = position + 57
        var grayWidth = percentageView.frame.size.width - position
        if UserSettings.appLanguageIsArabic() {
            grayX = 0
            grayWidth = position
        }
            
            var percentageDividerAnimationDuration : TimeInterval =  0.9
            var grayViewAnimationDuration : TimeInterval = 1
            if UserSettings.appLanguageIsArabic() {
                percentageDividerAnimationDuration = 1.1
            }
        
        UIView.animate(withDuration: percentageDividerAnimationDuration, delay: 0, animations: {
            DeveloperTools.print("position: \(position)")
            
            self.percentageDivider.frame = CGRect(x: position - 57, y:self.percentageDivider.frame.origin.y, width:self.percentageDivider.frame.size.width,height: self.percentageDivider.frame.size.height)
            
        }, completion: { finished in
            
        })
        UIView.animate(withDuration: grayViewAnimationDuration, delay: 0, animations: {
            DeveloperTools.print("position: \(position)")
            
            DeveloperTools.print("alter")
            self.grayView.frame = CGRect(x:grayX, y:0, width:grayWidth , height:self.percentageDivider.frame.size.height)
            
        }, completion: { finished in
            
        })
        }
    }
    
    func viewWillDisppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.y_removeShadow()
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        populateRewardData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

