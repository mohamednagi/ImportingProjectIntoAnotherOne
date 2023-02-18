//
//  MenuViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import SDWebImage
import Alamofire

class MyTrendsViewController: UIViewController {
    
    @IBOutlet weak var imageFrameImageView: UIImageView!
    @IBOutlet weak var profilePicImageView : UIImageView!
    
    var myTrends = [MyTrend]()
    var trendDetailsView = UIView()
    var trendDetailsHeader = UIView()
    var trendDetailsTableView = UITableView()
    var trendDetails: TrendDetailsViewController!
    var currentTrend : MyTrend?
    var trendDetailsIsInFullScreen = false
    
    var tapGesture = UITapGestureRecognizer()
    var panGesture = UIPanGestureRecognizer()
    
    var balloonFramesAsInZeplin : [CGRect] = [
        CGRect(x:352, y:105, width:17, height:17),
        CGRect(x:307, y:83, width:38, height:38),
        CGRect(x:229, y:71, width:72, height:72),
        CGRect(x:303, y:130, width:72, height:72),
        CGRect(x:231, y:146, width:72, height:72),
        CGRect(x:279, y:204, width:96, height:96),
        CGRect(x:288, y:305, width:72, height:72),
        CGRect(x:226, y:377, width:130, height:130),//width:149, height:149),
        CGRect(x:209, y:491, width:17, height:17),
        CGRect(x:152, y:420, width:72, height:72),
        CGRect(x:120, y:495, width:96, height:96),
        CGRect(x:80, y:438, width:72, height:72),
        CGRect(x:55, y:505, width:35, height:35),
        CGRect(x:17, y:505, width:26, height:26),
        CGRect(x:30, y:456, width:39, height:39),
        CGRect(x:39, y:375, width:72, height:72),
        CGRect(x:17, y:313, width:64, height:64),
        CGRect(x:2, y:215, width:96, height:96),
        CGRect(x:90, y:205, width:17, height:17),
        CGRect(x:16, y:143, width:72, height:72),
        CGRect(x:39, y:101, width:30, height:30),
        CGRect(x:82, y:64, width:130, height:130)
        ]
    let screenWidthAsInZeplin : CGFloat = 374
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = false
//        let backImage: UIImage!
//        if UserSettings.appLanguageIsArabic() {
//            backImage = UIImage(named:"backPinkAr")
//        }else{
//            backImage = UIImage(named:"backPink")
//        }
//        let newBackButton = UIBarButtonItem(image: backImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backAction(sender:)))
//        self.navigationItem.leftBarButtonItem = newBackButton
        
        self.title = "My Trends".y_localized
        DeveloperTools.print("black: did load")
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 17)!, NSAttributedStringKey.foregroundColor : UIColor.black]

        // Do any additional setup after loading the view, typically from a nib
        
        balloonFramesAsInZeplin.sort { (frame1, frame2) -> Bool in
            return frame1.size.width > frame2.size.width
        }
        Backend.getMyTrends(completion: { (myTrends, backendError) in
            if myTrends == nil {
                if backendError == .connection {
                    //                            AlertUtility.showErrorAlert( "Unable to connect to the internet, Please try again later".y_localized)
                }
            } else {
                var biggestScale : Int!
                var biggestDiameter : CGFloat!
                if myTrends != nil {
                    self.myTrends = myTrends!
                    //                    self.myTrends.append(contentsOf: myTrends!)
                    //                    self.myTrends.append(contentsOf: myTrends!)
                    //                    self.myTrends.append(contentsOf: myTrends!)
                    //                    self.myTrends.append(contentsOf: myTrends!)
                    //                    self.myTrends.append(contentsOf: myTrends!)
                    //                    self.myTrends.append(contentsOf: myTrends!)
                    if self.myTrends.count > 0 {
                        self.myTrends.sort(by: { (trend1, trend2) -> Bool in
                            return trend1.Scale > trend2.Scale
                        })
                        
                        
                        biggestScale = self.myTrends.first!.Scale
                        biggestDiameter = self.balloonFramesAsInZeplin.first!.size.width
                    }
                    for i in 0 ..< self.balloonFramesAsInZeplin.count {
                        
                        let balloonView = UIView()
                        let button = AutomaticallyLocalizedButton()
                        let label = AutomaticallyLocalizedLabel()
                        label.font = UIFont(name:Constants.regularFont(), size:14)!
                        
                        var balloonFrame = self.balloonFramesAsInZeplin[i]
                        balloonFrame.origin.y = balloonFrame.origin.y - 64
                        if Utilities.deviceIs_iPhone5() {
                            if balloonFrame.origin.x > self.view.frame.width / 2 {
                                balloonFrame.origin.x = balloonFrame.origin.x - 50
                            }
                        }else{
                            balloonFrame.origin.x = balloonFrame.origin.x + (self.view.frame.width - self.screenWidthAsInZeplin)
                        }
                        
                        //                    label.text = "\(i)"
                        balloonView.backgroundColor = UIColor(r: 242, g: 242, b: 244, a: 1.0)
                        if i < self.myTrends.count && i < 15 {
                            let myTrend = self.myTrends[i]
                            
                            balloonFrame.size.width = biggestDiameter * CGFloat(myTrend.Scale)/CGFloat(biggestScale!)
                            if balloonFrame.size.width < 71 {
                                balloonFrame.size.width = 71
                            }
                            
                            balloonFrame.size.height = balloonFrame.size.width
                            button.addTarget(self, action: #selector(self.showTrendDetails(_:)), for: .touchUpInside)
                            button.tag = i
                            balloonView.backgroundColor = UIColor(hexString:myTrend.Color)
                            
                            label.text = myTrend.Name
                            label.textColor = .white
                            label.adjustsFontSizeToFitWidth = true
                        }
                        
                        balloonView.frame = balloonFrame
                        balloonView.y_roundedCorners()
                        
                        balloonFrame.origin = CGPoint(x:0, y:0)
                        button.frame = balloonFrame
                        button.setBackgroundImage(UIImage(named:"group4"), for: .normal)
                        
                        label.frame = CGRect(x:4, y:balloonView.frame.size.height/2-20/2, width:balloonView.frame.size.width - 8, height:20)
                        label.textAlignment = .center
                        
                        button.alpha = 0.8
                        balloonView.addSubview(button)
                        balloonView.addSubview(label)
                        self.view.addSubview(balloonView)
                        balloonView.center.y += self.view.bounds.height + 100
                        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseInOut, animations: {
                            balloonView.center.y -= self.view.bounds.height + 100
                            self.view.layoutIfNeeded()
                        }, completion: nil)
                    }
                }
            }
        })
    }
    
    @objc func showTrendDetails(_ sender: UIButton) {
        //        if self.currentTrend == nil {
        trendDetailsView.removeFromSuperview()
        currentTrend = self.myTrends[sender.tag]
        
        trendDetails = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "TrendDetails") as! TrendDetailsViewController
        trendDetails.myTrend = currentTrend
        trendDetails.person = UserSettings.info!
        trendDetails.viewDidLoad()
        trendDetails.delegate = self
        
        
        trendDetailsView = trendDetails.view!
        trendDetailsHeader = trendDetails.trendDetailsHeader.view!
        trendDetailsTableView = trendDetails.tableView!
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        trendDetailsHeader.addGestureRecognizer(tapGesture)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        trendDetailsHeader.addGestureRecognizer(panGesture)
        
        trendDetailsView.frame = CGRect(x:0, y:self.view.frame.size.height, width:trendDetailsView.frame.size.width, height:trendDetailsView.frame.size.height)
        self.view.addSubview(trendDetailsView)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.trendDetailsView.frame = CGRect(x:0, y:self.view.frame.size.height - 127, width:self.trendDetailsView.frame.size.width, height:self.trendDetailsView.frame.size.height)
            self.view.addSubview(self.trendDetailsView)
        }, completion: { success in
            
            //            UIView.animate(withDuration: 0.2, animations: {
            //
            //                self.trendDetailsView.frame = CGRect(x:0, y:self.view.frame.size.height - 127, width:self.trendDetailsView.frame.size.width, height:self.trendDetailsView.frame.size.height)
            //                self.view.addSubview(self.trendDetailsView)
            //            }, completion: { success in
            //
            //            })
        })
        //        }
    }
    
    func trendDetailsDraggable() {
        
        //        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        //        trendDetailsView.isUserInteractionEnabled = true
        //        trendDetailsView.addGestureRecognizer(panGesture)
        //
        DeveloperTools.print("black: draggable")
        self.title = "My Trends".y_localized
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 17)!, NSAttributedStringKey.foregroundColor : UIColor.black]
        
        self.trendDetailsView.frame = CGRect(x:0, y:0, width:self.trendDetailsView.frame.size.width, height:self.trendDetailsView.frame.size.height)
        removeDetailsViewHeader()
    }
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        
        if NetworkReachabilityManager()!.isReachable == false {
            AlertUtility.showConnectionError()
        } else {
            self.view.bringSubview(toFront: trendDetailsView)
            let translation = sender.translation(in: self.view)
            trendDetailsView.center = CGPoint(x: trendDetailsView.center.x, y: trendDetailsView.center.y + translation.y)
            
            if (sender.state == .began) {
                sender.setTranslation(CGPoint.zero, in: self.view)
            } else if (sender.state == .changed) {
                
                sender.setTranslation(CGPoint.zero, in: self.view)
                
                if trendDetailsView.frame.origin.y < -40 {
                    trendDetails.delegate.title = trendDetails.myTrend.Name
                    trendDetails.delegate.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 17)!, NSAttributedStringKey.foregroundColor : UIColor.primaryColor]
                } else {
                    trendDetails.delegate.title = "My Trends".y_localized
                    trendDetails.delegate.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 17)!, NSAttributedStringKey.foregroundColor : UIColor.black]
                }
                
            } else if (sender.state == .ended) {
                if self.trendDetailsIsInFullScreen == true {
                    if trendDetailsView.frame.origin.y > 20 {
                        removeDetailsViewHeader()
                        //                    UIView.animate(withDuration: 0.5, animations: {
                        //
                        //                        self.trendDetailsView.frame = CGRect(x:0, y:self.view.frame.size.height - 127, width:self.trendDetailsView.frame.size.width, height:self.trendDetailsView.frame.size.height)
                        //
                        //                    }, completion: { success in
                        //                    })
                    } else {
                        UIView.animate(withDuration: 0.5, animations: {
                            
                            self.trendDetailsView.frame = CGRect(x:0, y:-50, width:self.trendDetailsView.frame.size.width, height:self.trendDetailsView.frame.size.height)
                        }, completion: { success in
                        })
                    }
                } else {
                    if trendDetailsView.frame.origin.y <= self.view.frame.size.height - 127 - 1 {
                        self.trendsFullScreenTakeOver()
                    } else {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.trendDetailsView.frame = CGRect(x:0, y:self.view.frame.size.height - 127, width:self.trendDetailsView.frame.size.width, height:self.trendDetailsView.frame.size.height)
                            self.view.addSubview(self.trendDetailsView)
                        }, completion: { success in
                        })
                    }
                }
            }
        }
    }
    
    func trendsFullScreenTakeOver() {
        self.trendDetailsView.removeGestureRecognizer(self.tapGesture)
        self.trendDetailsView.removeGestureRecognizer(self.panGesture)
        UIView.animate(withDuration: 0.5, animations: {
            self.trendDetailsView.frame = CGRect(x:0, y: -50, width:self.trendDetailsView.frame.size.width, height:self.trendDetailsView.frame.size.height)
            self.view.addSubview(self.trendDetailsView)
        }, completion: { success in
            self.trendDetailsTableView.isScrollEnabled = true
            self.title = self.currentTrend?.Name
            DeveloperTools.print("primaryColor")
            self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 17)!, NSAttributedStringKey.foregroundColor : UIColor.primaryColor]
            self.trendDetailsIsInFullScreen = true
        })
    }
    
    @objc func backAction(sender: UIBarButtonItem){
        if currentTrend != nil && trendDetailsIsInFullScreen {
            removeDetailsViewHeader()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateUserInfo()
        self.navigationController?.navigationBar.tintColor = .primaryColor
        self.navigationController?.y_showShadow()
        if self.trendDetailsIsInFullScreen {
            self.perform(#selector(updateNavBar), with: nil, afterDelay:0.4)
            trendDetails.loadDataWithPageIndex(1, pageSize: trendDetails.currentPageSize)
        }
    }
    
    @objc func updateNavBar(){
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 17)!, NSAttributedStringKey.foregroundColor : UIColor.primaryColor]
    }
    
    func viewWillDisppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.y_removeShadow()
    }
    
    func populateUserInfo() {
        if UserSettings.info != nil {
            self.imageFrameImageView.isHidden = true
            profilePicImageView.sd_setImage(with: URL(string:UserSettings.info!.ProfilePicture), placeholderImage: UIImage(named:"profile"), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, url) in
                if image != nil {
                    self.imageFrameImageView.isHidden = false
                }
            })
            profilePicImageView.y_circularRoundedCorner()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        if NetworkReachabilityManager()!.isReachable == false {
            AlertUtility.showConnectionError()
        } else {
            //        if sender.view is UIButton{
            sender.cancelsTouchesInView = true
            //        }else{
            //            sender.cancelsTouchesInView = false
            //        }
            if sender.state == .ended {//} && sender.view == self.view {
                self.trendsFullScreenTakeOver()
            } else {
            }
        }
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch =  touches.first {
            if touch.view == self.view {
                removeDetailsViewHeader()
            }
        }
    }
    
    func removeDetailsViewHeader(){
        UIView.animate(withDuration: 0.5, animations: {
            self.trendDetailsView.frame = CGRect(x:0, y:self.view.frame.size.height, width:self.trendDetailsView.frame.size.width, height:self.trendDetailsView.frame.size.height)
        }, completion: { success in
            self.title = "My Trends".y_localized
            DeveloperTools.print("black: remove draggable")
            self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 17)!, NSAttributedStringKey.foregroundColor : UIColor.black]

            self.currentTrend = nil
            self.trendDetailsIsInFullScreen = false
        })
    }
}

