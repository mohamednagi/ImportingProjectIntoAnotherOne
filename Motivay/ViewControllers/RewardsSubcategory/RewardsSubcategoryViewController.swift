//
//  RewardsSubcategoryViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import DZNEmptyDataSet
import SDWebImage
import SlideMenuControllerSwift
import GIFRefreshControl
//import Gradientable

class RewardsSubcategoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    var rewardsSubcategoryTableViewAdapter: RewardsSubcategoryTableViewAdapter!
    var headerView : UIView!
    var segmentedControl : UISegmentedControl!
    
    var refreshControl = GIFRefreshControl()//UIRefreshControl()
    var canRefresh = true
    
    var currentPageIndex = 1
    let currentPageSize = 10
    var numberOfPages : Int!
    
    var noMoreRewards = false
    var loading = false
    
    var searchFieldContainer : UIView!
    var searchField = UITextField()
    var searchCancelButton = UIButton()
    var dimView = UIButton()//UIView()
    var searchTerm: String = ""
    
    var rewardsListType: RewardListType?
    var rewardsSubCategory: RewardsSubCategory?
    var rewards : [Reward]!
    var bgImageView = UIImageView()
    var tableBackgroundView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.accessibilityIdentifier = "RewardsSubcategoryTableView"
        bgImageView = UIImageView(frame: tableView.bounds)
        bgImageView.image = UIImage(named: "patternBG")
        bgImageView.contentMode = .scaleAspectFill
        tableView.backgroundView = bgImageView
        
        if rewardsListType != nil {
            tableView.contentInset = UIEdgeInsets(top: 40,left: 0,bottom: 0,right: 0)
            headerView = UIView(frame:CGRect(x:0, y:0, width:self.view.frame.size.width, height:40))
            headerView.backgroundColor = .white
            headerView.y_addBottomBorderWithColor(color: UIColor(r:0,g:0,b:0,a:0.1), thickness: 1)
            segmentedControl = UISegmentedControl(items: ["All".y_localized, "Bookmarked".y_localized, "Redeemed".y_localized])
            segmentedControl.frame = CGRect(x:0, y:6, width:self.view.frame.size.width-28, height:segmentedControl.frame.size.height)
            segmentedControl.accessibilityIdentifier = "RewardsSegmentedControl"
            segmentedControl.center = CGPoint(x:view.center.x, y:segmentedControl.center.y)
            segmentedControl.tintColor = .primaryColor
            if #available(iOS 13.0, *) {
                segmentedControl.selectedSegmentTintColor = .primaryColor
            } else {
                // Fallback on earlier versions
            }
            segmentedControl.y_circularCorners()
            segmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name:Constants.regularFont(), size:14)!,
                                                     NSAttributedStringKey.foregroundColor: UIColor.primaryColor],
                                                    for: .normal)
            segmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name:Constants.regularFont(), size:14)!,
                                                     NSAttributedStringKey.foregroundColor: UIColor.white],
                                                    for: .selected)
            
            if rewardsListType == .Bookmarked {
                segmentedControl.selectedSegmentIndex = 1
            }else {
                segmentedControl.selectedSegmentIndex = 2
            }
            segmentedControl.addTarget((tabBarController?.viewControllers!.first as! HomeViewController), action: #selector(HomeViewController.tabSwitched), for: .valueChanged)
            headerView.addSubview(segmentedControl)
            self.view.addSubview(headerView)
        }else{
            
            tableView.contentInset = UIEdgeInsets(top: 50,left: 0,bottom: 0,right: 0)
            searchFieldContainer = UIView(frame:CGRect(x:0, y:0, width:self.view.frame.size.width, height:52))
            searchFieldContainer.backgroundColor = .white
            
            searchField.font = UIFont(name:Constants.regularFont(), size:searchField.font!.pointSize)
            searchField.delegate = self
            searchField.accessibilityIdentifier = "HomeSearchTextField"
            
            searchField.placeholder = "Search".y_localized
            
            searchField.returnKeyType = .search
            if UserSettings.appLanguageIsArabic(){
                searchField.textAlignment = .right
            }else{
                searchField.textAlignment = .left
            }
            searchField.frame = CGRect(x:16, y:8, width:searchFieldContainer.frame.size.width - 32, height:36)
            searchField.layer.cornerRadius = 10
            
            searchField.backgroundColor = UIColor(hexString: "f1f1f2")
            //        searchField.roundCorners(withRadius: 6)
            
            let iconView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 36))
            let iconImageView = UIImageView(frame: CGRect(x: 8, y: 11, width: 14, height: 14))
            iconImageView.image = UIImage(named:"search")
            iconView.addSubview(iconImageView)
            //                    if UserSettings.appLanguageIsArabic() {
            
            searchField.leftView = iconView
            searchField.leftViewMode = .always
            //                    }else{
            //                        searchField.rightView = iconView
            //                        searchField.rightViewMode = .always
            //                    }
            searchFieldContainer.y_addBottomBorderWithColor(color: UIColor(r:216, g:221, b:231), thickness: 1)
            searchFieldContainer.addSubview(searchField)
            self.view.addSubview(searchFieldContainer)
        }
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.tableFooterView = UIView()
        
        tableBackgroundView = UIView(frame:tableView.frame)
        tableBackgroundView.backgroundColor = .whiteTwo
//        self.tableView.backgroundView = tableBackgroundView
        
        rewardsSubcategoryTableViewAdapter = RewardsSubcategoryTableViewAdapter(tableView: self.tableView, delegate:self)
        loadData()
        
        /*refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".y_localized)
         refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
         tableView.refreshControl = refreshControl*/
        do {
            let url = Bundle.main.url(forResource: "Motivay_10", withExtension: "gif")
            let data = try Data(contentsOf: url!)
            
            refreshControl.animatedImage = GIFAnimatedImage(data: data)
            refreshControl.contentMode = .scaleAspectFit
            refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
            tableView.addSubview(refreshControl)
        } catch {
            
        }
        
        tableView.setShouldShowInfiniteScrollHandler { _ -> Bool in
            return self.currentPageIndex <= self.numberOfPages
        }

        tableView.addInfiniteScroll { (tableView) in
            DeveloperTools.print("load more")
            self.loadMoreData()
        }
    }
    
    @objc func loadData(){
        loadDataWithPageIndex(1, pageSize: currentPageSize)
        LoadingOverlay.shared.showOverlay()
    }
    
    @objc func refresh(){
        
        self.tableView.emptyDataSetSource = nil
        self.tableView.emptyDataSetDelegate = nil
        loadDataWithPageIndex(1, pageSize: currentPageSize)
//        loadAllDate()
    }
    
    func loadMoreData(){
        if currentPageIndex > numberOfPages {
            noMoreRewards = true
        }else{
            loadDataWithPageIndex(currentPageIndex+1, pageSize: currentPageSize)
        }
    }
    
    func loadDataWithPageIndex(_ pageIndex:Int, pageSize: Int){
//    func loadAllDate() {
        
        loading = true
        Backend.getRewards(rewardListType: rewardsListType, rewardsTypeId:rewardsSubCategory?.RewardTypeId, keyword: searchTerm, pageIndex: pageIndex, pageSize: pageSize, completion: { (rewards, numberOfRewards, backendError)  in
//            self.loading = false
            
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self

            if backendError == .connection {
                
                LoadingOverlay.shared.hideOverlayView()
                self.tableView.backgroundView = self.bgImageView
                
            }else{
                if pageIndex == 1 {
                    self.rewards = rewards!
                    self.rewardsSubcategoryTableViewAdapter.data = self.rewards
                    LoadingOverlay.shared.hideOverlayView()
                
//                    DispatchQueue.main.async {
//                        self.scrollToTop()
//                    }
                }else{
//                    if rewards != nil && rewards!.count > 0 {
                    self.rewards.append(contentsOf: rewards!)
                    self.rewardsSubcategoryTableViewAdapter.data = self.rewards
//                    }

                    self.tableView.finishInfiniteScroll()
                }
                
//                self.rewardsSubcategoryTableViewAdapter.data = rewards!
                self.numberOfPages = Int(ceil(CGFloat(numberOfRewards)/CGFloat(self.currentPageSize)))
                self.currentPageIndex = pageIndex
                if rewards!.count > 0 {
                    self.tableView.backgroundView = self.tableBackgroundView
                } else {
                    self.tableView.backgroundView = self.bgImageView
                }
            }
//            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
//            }
        }, showLoading: false)
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
//        tableView.reloadData()
        self.slideMenuController()?.addRightGestures()
        self.slideMenuController()?.addLeftGestures()
        
        self.navigationController?.navigationBar.tintColor = .primaryColor
        if rewardsListType == nil {
            self.title = rewardsSubCategory?.RewarTypedName
        }
//        self.navigationController!.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: Constants.boldFont, size: 17)!]
//
        self.tabBarController?.navigationItem.titleView = nil
        self.tabBarController?.navigationItem.title = "Rewards".y_localized
        self.tabBarController?.navigationItem.backBarButtonItem?.title = ""
        self.tabBarController?.navigationItem.backButton.title = ""
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        setLeftBarButton()
//
//
//        tableView.reloadData()
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.y_whiteBackground()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        SDImageCache.shared().clearMemory()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.reloadEmptyDataSet()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension RewardsSubcategoryViewController : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrText = NSMutableAttributedString()
        var str: String = ""
        var str2: String = ""
        
        if searchTerm != "" {
            str = "No results found!".y_localized
            str2 = "Try different keywords".y_localized
        }else if rewardsListType == .Bookmarked {
            str = "There are no bookmarked rewards yet".y_localized
        }else if rewardsListType == .Redeemed {
            
            str = /*"There are no redeemed rewards yet"*/"You haven't redeemed any rewards yet".y_localized
        }else{
            str = "There are no rewards yet".y_localized
        }
        
        let text = NSAttributedString(string:str, attributes:[NSAttributedStringKey.font : UIFont(name: Constants.boldFont(), size: 24)!, NSAttributedStringKey.foregroundColor : UIColor.greyishBrown])
        let text2 = NSAttributedString(string:str2, attributes:[NSAttributedStringKey.font : UIFont(name: Constants.regularFont(), size: 17)!, NSAttributedStringKey.foregroundColor : UIColor.greyishBrown])
        attrText.append(text)
        attrText.append(NSAttributedString(string:"\n"))
        attrText.append(text2)
        
        return attrText
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if searchTerm != "" {
            return UIImage(named:"emptyStateIllustration")
        }else{
            return UIImage(named:"giftIllustration")
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


extension RewardsSubcategoryViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        var frame = searchFieldContainer.frame
        frame.origin.y = UIApplication.shared.statusBarFrame.size.height
        searchFieldContainer.frame = frame
        
        var tfFrame = searchField.frame
        if UserSettings.appLanguageIsArabic() {
            tfFrame.size.width = searchFieldContainer.frame.size.width - (9 +  31 + 16 + 16)
            tfFrame.origin.x = (9 +  31 + 16 )
        }else{
            tfFrame.size.width = searchFieldContainer.frame.width - (9 +  53 + 16 + 16)
            
        }
        searchField.frame = tfFrame
        
        dimView.removeFromSuperview()
        dimView.frame = CGRect(x: 0, y: searchFieldContainer.frame.origin.y+searchFieldContainer.frame.size.height, width: Utilities.screedWidth(), height: self.view.frame.size.height)
        dimView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        dimView.addTarget(self, action: #selector(searchCancel), for: .touchUpInside)
        //        dimView.isUserInteractionEnabled = false
        
        //        let dimTopButton = UIButton(frame:CGRect(x:0, y:0, width: Utilities.screedWidth(), height:44))
        //        dimTopButton.backgroundColor = .red
        //        dimTopButton.addTarget(self, action: #selector(searchCancel), for: .touchUpInside)
        //        dimView.addSubview(dimTopButton)
        
        self.navigationController?.view.addSubview(dimView)
        self.view.bringSubview(toFront: searchFieldContainer)
        
        searchCancelButton.removeFromSuperview()
        
        if UserSettings.appLanguageIsArabic() {
            searchCancelButton.frame = CGRect(x: 9, y:searchField.center.y - 22, width:35, height:44)
        }else{
            
            searchCancelButton.frame = CGRect(x: tfFrame.origin.x + tfFrame.size.width + 16, y:searchField.center.y - 22, width:53, height:44)
        }
        searchCancelButton.titleLabel?.textAlignment = .center
        searchCancelButton.setTitle("Cancel".y_localized, for: .normal)
        searchCancelButton.setTitleColor(.primaryColor, for: .normal)
        searchCancelButton.titleLabel?.font = UIFont(name: Constants.regularFont(), size: 17)!
        searchCancelButton.addTarget(self, action: #selector(searchCancel), for: .touchUpInside)
        //        searchFieldContainer.backgroundColor = .gray
        searchFieldContainer.addSubview(searchCancelButton)
        searchFieldContainer.bringSubview(toFront: searchCancelButton)
        
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @objc func searchCancel(){
        DeveloperTools.print("search cancel")
        if searchField.text != "" {
            
            searchField.text = ""
            searchTerm = ""
            loadData()
        }
        
        searchField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var frame = searchFieldContainer.frame
        frame.origin.y = 0// UIApplication.shared.statusBarFrame.size.height+self.tabBarController!.navigationController!.navigationBar.frame.size.height
        searchFieldContainer.frame = frame
        
        var tfFrame = searchField.frame
        tfFrame.size.width = searchFieldContainer.frame.width - 32
        tfFrame.origin.x = 16
        searchField.frame = tfFrame
        
        searchField.text = searchTerm
        dimView.removeFromSuperview()
        searchCancelButton.removeFromSuperview()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    //    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //        if string == "\n" {
    //
    //            textField.resignFirstResponder()
    //            if textField.text! != searchTerm {
    //                self.scrollToTop()
    //                loadData()
    //            }
    //            searchTerm = textField.text!
    //            return false
    //        }
    //        return true
    //    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text! != searchTerm {
            searchTerm = textField.text!
            self.scrollToTop()
            loadData()
        }
        textField.resignFirstResponder()
        return true
    }
}

extension RewardsSubcategoryViewController : TableViewAdapterDelegate {
}
