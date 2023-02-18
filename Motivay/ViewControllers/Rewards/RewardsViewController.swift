//
//  RewardsViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import DZNEmptyDataSet
import SDWebImage
import SlideMenuControllerSwift
import Gradientable
import GIFRefreshControl

enum RewardListType {
    case All, Bookmarked, Redeemed
}

class RewardsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    var rewardsTableViewAdapter: RewardsTableViewAdapter!
    var headerView : UIView!
    var segmentedControl : UISegmentedControl!
    
    var refreshControl = GIFRefreshControl()//UIRefreshControl()
//    var canRefresh = true
    
//    var currentPageIndex = 1
//    let currentPageSize = 10
//    var numberOfPages : Int!
    
//    var noMorePosts = false
    var loading = true
    var bgImageView = UIImageView()
    var tableBackgroundView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.accessibilityIdentifier = "RewardsTableView"
        
        bgImageView = UIImageView(frame: tableView.bounds)
        bgImageView.image = UIImage(named: "patternBG")
        bgImageView.contentMode = .scaleAspectFill
        tableView.backgroundView = bgImageView
        
        self.tableView.tableFooterView = UIView()
        tableBackgroundView = UIView(frame:tableView.frame)
        tableBackgroundView.backgroundColor = .whiteTwo
//        self.tableView.backgroundView = tableBackgroundView
        
        rewardsTableViewAdapter = RewardsTableViewAdapter(tableView: self.tableView, delegate:self)
        loadData()
        
        tableView.contentInset = UIEdgeInsets(top: 80,left: 0,bottom: 0,right: 0)
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".y_localized)
//        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
//        tableView.refreshControl = refreshControl
        do {
            let url = Bundle.main.url(forResource: "Motivay_10", withExtension: "gif")
            let data = try Data(contentsOf: url!)
            
            refreshControl.animatedImage = GIFAnimatedImage(data: data)
            refreshControl.contentMode = .scaleAspectFit
            refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
            tableView.addSubview(refreshControl)
        } catch {
            
        }
    }
    
    @objc func loadData(){
//        loadDataWithPageIndex(1, pageSize: currentPageSize)
        loading = true
        loadAllDate()
//        LoadingOverlay.shared.showOverlay()
    }
    
    @objc func refresh(){
        loading = false
        self.tableView.emptyDataSetSource = nil
        self.tableView.emptyDataSetDelegate = nil
//        loadDataWithPageIndex(1, pageSize: currentPageSize)
        loadAllDate()
    }
    
//    func loadMoreData(){
//        if currentPageIndex > numberOfPages {
//            noMorePosts = true
//        }else{
//            loadDataWithPageIndex(currentPageIndex+1, pageSize: currentPageSize)
//        }
//    }
    
//    func loadDataWithPageIndex(_ pageIndex:Int, pageSize: Int){
    func loadAllDate() {
    
//        loading = true
        Backend.getRewardsByCategory(completion: { (rewardsSubCategories, backendError)  in
            //            self.loading = false
            
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            
            if backendError == .connection {
                self.tableView.backgroundView = self.bgImageView
                //                LoadingOverlay.shared.hideOverlayView()
                
            }else{
                //                if pageIndex == 1 {
                
                //                    LoadingOverlay.shared.hideOverlayView()
                
                //                    DispatchQueue.main.async {
                //                        self.scrollToTop()
                //                    }
                //                }else{
                //                    self.posts.append(contentsOf: posts!)
                //
                //                    self.tableView.finishInfiniteScroll()
                //                }
                
                self.rewardsTableViewAdapter.data = rewardsSubCategories!
                if rewardsSubCategories!.count > 0 {
                    self.tableView.backgroundView = self.tableBackgroundView
                } else {
                    self.tableView.backgroundView = self.bgImageView
                }
                //                self.numberOfPages = Int(ceil(CGFloat(numberOfPosts)/CGFloat(self.currentPageSize)))
                //                self.currentPageIndex = pageIndex
                
            }
            //            if self.refreshControl.isRefreshing {
                            self.refreshControl.endRefreshing()
            //            }
        }, showLoading: loading)
    }
    
//    @objc func reloadTableData(){
//        tableView.reloadData()
//    }
    
    @objc func menu(){
        
        if UserSettings.appLanguageIsArabic() {
            self.tabBarController?.openRight()
        }else{
            self.tabBarController?.openLeft()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Constants.selectedVC = 2
        if Constants.languageChanged {
            Constants.languageChanged = false
            self.perform(#selector(pushSettings), with: nil, afterDelay: 0.1)
        }
        self.slideMenuController()?.addRightGestures()
        self.slideMenuController()?.addLeftGestures()
        
        self.navigationController!.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 17)!]
        
        self.tabBarController?.navigationItem.titleView = nil
        self.tabBarController?.navigationItem.title = "Rewards".y_localized
        self.tabBarController?.navigationItem.backBarButtonItem?.title = ""
        self.tabBarController?.navigationItem.backButton.title = ""
        self.tabBarController?.navigationItem.rightBarButtonItem = nil

        
        tableView.reloadData()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.y_whiteBackground()
        self.navigationController?.y_removeShadow()
        setLeftBarButton()
        self.view.setNeedsLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        SDImageCache.shared().clearMemory()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createHeaderView()
        self.tableView.reloadEmptyDataSet()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createHeaderView() {
        headerView = UIView(frame:CGRect(x:0, y:0, width:self.view.frame.size.width, height:88))
        headerView.backgroundColor = .white
        
        segmentedControl = UISegmentedControl(items: ["All".y_localized, "Bookmarked".y_localized, "Redeemed".y_localized])
        segmentedControl.frame = CGRect(x:0, y:6, width:self.view.frame.size.width-28, height:segmentedControl.frame.size.height)
        segmentedControl.accessibilityIdentifier = "RewardsSegmentedControl"
        segmentedControl.center = CGPoint(x:view.center.x, y:segmentedControl.center.y)
        segmentedControl.tintColor = .primaryColor
        segmentedControl.y_circularCorners()
        segmentedControl.selectedSegmentIndex = 0
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = .primaryColor
        } else {
        }
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name:Constants.regularFont(), size:14)!,
                                                 NSAttributedStringKey.foregroundColor: UIColor.primaryColor],
                                                for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name:Constants.regularFont(), size:14)!,
                                                 NSAttributedStringKey.foregroundColor: UIColor.white],
                                                for: .selected)
        segmentedControl.addTarget((tabBarController?.viewControllers!.first as! HomeViewController), action: #selector(HomeViewController.tabSwitched), for: .valueChanged)
        
        let gradView = UIView(frame:CGRect(x:0, y:44, width:headerView.frame.size.width, height:44))
        //        gradView.backgroundColor = UIColor(patternImage: UIImage(named: "rectangle")!)
        gradView.layer.contents = UIImage(named:"rectangle")!.cgImage
        
        var starX = 15
        var pointsX = starX + 20 + 11
        if UserSettings.appLanguageIsArabic(){
            starX = Int(tableView.frame.size.width - 15 - 20)
            pointsX = starX - 16 - 200
        }
        let starImageView = UIImageView(frame:CGRect(x:starX, y:12, width:20, height:20))
        starImageView.image = UIImage(named:"starEmpty")
        
        let pointsLabel = ArabicNumbersLabel(frame: CGRect(x: pointsX, y:12, width: 200, height: 20))
        if UserSettings.info != nil {
            pointsLabel.text = "\(UserSettings.info!.EarnedPoints)" + " " + /*"Awards points"*/"total points to redeem".y_localized
        }
        pointsLabel.textColor = .white
        if UserSettings.appLanguageIsArabic() {
            pointsLabel.textAlignment = .right
        }else{
            pointsLabel.textAlignment = .left
        }
        pointsLabel.font = UIFont(name: Constants.regularFont(), size: 14)
        
        gradView.addSubview(starImageView)
        gradView.addSubview(pointsLabel)
        
        headerView.addSubview(segmentedControl)
        headerView.addSubview(gradView)
        self.view.addSubview(headerView)
    }
    
    func setLeftBarButton() {
        let leftButton: UIButton = UIButton(type: UIButtonType.custom)
        leftButton.frame = CGRect(x:0, y:0, width:34, height:34)
        leftButton.imageView?.contentMode = .scaleAspectFill
        if UserSettings.info == nil {
            leftButton.sd_setBackgroundImage(with: URL(string:""), for: .normal, placeholderImage: UIImage(named:"profileBig"), options:[])
        } else {
            leftButton.sd_setImage(with: URL(string:UserSettings.info!.ProfilePicture), for: .normal, placeholderImage: UIImage(named:"profileBig"), options:[])
        }
        leftButton.y_roundedCorners()
        leftButton.widthAnchor.constraint(equalToConstant: 34.0).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 34.0).isActive = true
        leftButton.addTarget(self, action: #selector(menu), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        
        tabBarController?.navigationItem.leftBarButtonItem = leftBarButton
    }

    @objc func pushSettings() {
        let settings = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Settings") as! SettingsTableViewController
        self.navigationController?.pushViewController(settings, animated: false)
    }
    
    func scrollToTop(){
        
        if self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 0 {
            DeveloperTools.print("scroll to top")
            self.tableView.scrollToRow(at: IndexPath(row:0, section:0), at: .top, animated: false)
        }
    }
    
    @objc func backToTimeline(_ sender: UIButton){
        sender.superview?.removeFromSuperview()
        self.loadData()
    }
}

extension RewardsViewController : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrText = NSMutableAttributedString()
        let str: String!
//        let str2: String!
        str = "There are no rewards yet".y_localized
//        str2 = "Start by motivating colleagues".y_localized
        
        let text = NSAttributedString(string:str, attributes:[NSAttributedStringKey.font : UIFont(name: Constants.boldFont(), size: 24)!, NSAttributedStringKey.foregroundColor : UIColor.greyishBrown])
//        let text2 = NSAttributedString(string:str2, attributes:[NSAttributedStringKey.font : UIFont(name: Constants.regularFont(), size: 17)!, NSAttributedStringKey.foregroundColor : UIColor(r: 85, g: 85, b: 85)])
        attrText.append(text)
//        attrText.append(NSAttributedString(string:"\n"))
//        attrText.append(text2)
        
        return attrText
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named:"giftIllustration")
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        if Utilities.deviceIs_iPhone5() {
            return 0
        }else{
            return -50
        }
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        scrollView.contentOffset = CGPoint.zero
    }
}

extension RewardsViewController : TableViewAdapterDelegate {
}

//extension RewardsViewController: SlideMenuControllerDelegate {
//    
//    func leftWillOpen() {
//        
//        scrollToTop()
//    }
//
//    func rightWillOpen() {
//        leftWillOpen()
//    }
//    
//    func leftDidOpen() {
//        if let window = UIApplication.shared.keyWindow {
//            window.windowLevel = UIWindowLevelStatusBar + 1
//        }
//    }
//    
//    func rightDidOpen() {
//        leftDidOpen()
//    }
//    
//    func leftDidClose() {
//        
//        if let window = UIApplication.shared.keyWindow {
//            window.windowLevel = UIWindowLevelNormal
//        }
//    }
//    func rightDidClose() {
//        
//        leftDidClose()
//    }
//}

