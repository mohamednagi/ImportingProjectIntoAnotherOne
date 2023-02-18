//
//  HomeViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import DZNEmptyDataSet
//import EmptyDataSet_Swift
import SDWebImage
import Presentr
import SlideMenuControllerSwift
import Cartography
import Alamofire
import GIFRefreshControl

class HomeViewController: KeyboardHeightViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    var homeTableViewAdapter: HomeTableViewAdapter!
    var homePlaceholderTableViewAdapter: HomePlaceholderTableViewAdapter!
    var posts = [Post]()
    var searchFieldContainer : UIView!
    var searchField = UITextField()
    var searchCancelButton = UIButton()
    var dimView = UIButton()//UIView()
    var searchTerm: String = ""
    
    var filtersDepartments : [Department]?
    var filtersHashtags : [Hashtag]?
    var filtersStartDate : Date?
    var filtersEndDate : Date?
    var filtersPersons : [Employee]?
    var filtersPersonsPostType: Int?
    
//    var successSoundUrl = Bundle.main.url(forResource: "success_2", withExtension: "m4a")
    
    
    var refreshControl = GIFRefreshControl()
    var canRefresh = true
    
    var currentPageIndex = 1
    let currentPageSize = 10
    var numberOfPages : Int = 1
    
    var noMorePosts = false
    var loading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        tableView.accessibilityIdentifier = "HomeTableView"
        let bgImageView = UIImageView(frame: tableView.bounds)
        bgImageView.image = UIImage(named: "patternBG")
        bgImageView.contentMode = .scaleAspectFill
        tableView.backgroundView = bgImageView
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
        
        
        searchFieldContainer.y_addBottomBorderWithColor(color: UIColor(r:216, g:221, b:231), thickness: 0.5)
        searchFieldContainer.addSubview(searchField)
        self.view.addSubview(searchFieldContainer)
        
        self.tableView.tableFooterView = UIView()
        
        homePlaceholderTableViewAdapter = HomePlaceholderTableViewAdapter(tableView: self.tableView, delegate:self)
        loadData()
        
        tableView.contentInset = UIEdgeInsets(top: 50,left: 0,bottom: 0,right: 0)
        
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".y_localized)
        do {
        let url = Bundle.main.url(forResource: "Motivay_10", withExtension: "gif")
            let data = try Data(contentsOf: url!)
        
            refreshControl.animatedImage = GIFAnimatedImage(data: data)
        refreshControl.contentMode = .scaleAspectFit
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        } catch {
            
        }
        
//        tableView.tableFooterView = UIView(frame:CGRect(x:0, y:0, width:tableView.frame.size.width, height:44))
        tableView.setShouldShowInfiniteScrollHandler { _ -> Bool in
            // Only show up to 5 pages then prevent the infinite scroll
            return self.currentPageIndex <= self.numberOfPages
        }
        tableView.addInfiniteScroll { (tableView) -> Void in
            // update table view
            DeveloperTools.print("load more")
            self.loadMoreData()
        }
        
        //DZN problem hacky fix
        self.edgesForExtendedLayout = []
    }
    
    @objc func filters(){
        
        let filters = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Filters") as! FiltersViewController
        filters.delegate = self
        filters.departments = filtersDepartments
        filters.hashtags = filtersHashtags
        filters.startDate = filtersStartDate
        filters.endDate = filtersEndDate
        filters.persons = filtersPersons
        filters.personsPostType = filtersPersonsPostType
        let nvc = UINavigationController(rootViewController: filters)
        self.present(nvc, animated: true, completion: nil)
//        }
    }
    
    func applyFilters(departments: [Department]?, hashtags: [Hashtag]?, startDate: Date?, endDate: Date?, persons: [Employee]?, personsPostType: Int!){
        filtersDepartments = departments
        filtersHashtags = hashtags
        filtersStartDate = startDate
        filtersEndDate = endDate
        filtersPersons = persons
        filtersPersonsPostType = personsPostType
        
        self.scrollToTop()
        loadData()
        
        let rightButton: UIButton = UIButton(type: UIButtonType.custom)
        //set image for button
        rightButton.setImage(UIImage(named: "filterApplied"), for: .normal)
        //set frame
        rightButton.frame = CGRect(x:0, y:0, width:20, height:18)
        
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        
        rightBarButton.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filters)))
        self.tabBarController?.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func resetFilters(){
        filtersDepartments = nil
        filtersHashtags = nil
        filtersStartDate = nil
        filtersEndDate = nil
        filtersPersons = nil
        filtersPersonsPostType = nil
        
        self.scrollToTop()
        loadData()
        
        let rightButton: UIButton = UIButton(type: UIButtonType.custom)
        //set image for button
        rightButton.setImage(UIImage(named: "filter"), for: .normal)
        //set frame
        rightButton.frame = CGRect(x:0, y:0, width:20, height:18)
        
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        
        rightBarButton.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filters)))
        self.tabBarController?.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func loadData(){
        loadDataWithPageIndex(1, pageSize: currentPageSize)
//        ProgressUtility.showProgressView()
        LoadingOverlay.shared.showOverlay()
    }
    
    @objc func refresh(){
        
        self.tableView.emptyDataSetSource = nil
        self.tableView.emptyDataSetDelegate = nil
        loadDataWithPageIndex(1, pageSize: currentPageSize)
    }
    
    func loadMoreData(){
        if currentPageIndex > numberOfPages {
            noMorePosts = true
        }else{
            loadDataWithPageIndex(currentPageIndex+1, pageSize: currentPageSize)
        }
    }
    
    func loadDataWithPageIndex(_ pageIndex:Int, pageSize: Int){
        
        loading = true
        Backend.getPosts(searchTerm: searchTerm, departments: filtersDepartments, hashtags: filtersHashtags, startDate: filtersStartDate, endDate: filtersEndDate, persons: filtersPersons, personsPostType:filtersPersonsPostType, pageIndex:pageIndex, pageSize: pageSize, completion: { (posts, numberOfPosts, backendError)  in
            self.loading = false
            
            DeveloperTools.print("dnz set")
            
            if self.homeTableViewAdapter == nil {
                self.homeTableViewAdapter = HomeTableViewAdapter(tableView: self.tableView, delegate:self)
                self.homeTableViewAdapter.sourceView = 1
            }
            
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self

            if backendError == .connection {
//                ProgressUtility.dismissProgressView()
                LoadingOverlay.shared.hideOverlayView()
//                AlertUtility.showErrorAlert("Unable to connect to the internet, Please try again later".y_localized)

                            self.tableView.setContentOffset(CGPoint.zero, animated:false)
                self.homeTableViewAdapter.data = []
            }else{
                if pageIndex == 1 {
                    DeveloperTools.print("page index 1")
                    self.posts = posts!
                    self.homeTableViewAdapter.data = self.posts
//                    ProgressUtility.dismissProgressView()
                    LoadingOverlay.shared.hideOverlayView()
                    
                    DispatchQueue.main.async {
                        self.scrollToTop()
                    }
                }else{
                    self.posts.append(contentsOf: posts!)
                    self.homeTableViewAdapter.data = self.posts
                    
                    self.tableView.finishInfiniteScroll()
//                    self.tableView.es.stopLoadingMore()
                }
//                self.perform(#selector(self.checkImagePostsWereVerifiedToReload), with: nil, afterDelay: 1)
                
//                self.perform(#selector(self.reloadTableData), with: nil, afterDelay: 0.01)
                
                self.numberOfPages = Int(ceil(CGFloat(numberOfPosts)/CGFloat(self.currentPageSize)))
                self.currentPageIndex = pageIndex
                
            }
//            self.tableView.es.stopPullToRefresh(ignoreDate: true)
//            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
//            }
        }, showLoading: false)
    }
    @objc func reloadTableData(){
        tableView.reloadData()
    }
//    @objc func checkImagePostsWereVerifiedToReload(){
//        for post in self.posts.reversed() {
//            if post.hasImage == nil {
//                self.perform(#selector(self.checkImagePostsWereVerifiedToReload), with: nil, afterDelay: 1)
//                return
//            }
//        }
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
        
        if AppDelegate.awardId != 0 {
            handleNotification(type: AppDelegate.notificationType, awardId: AppDelegate.awardId)
        }
        
        
        //        tabBarController?.navigationItem.titleLabel.textColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 17)!]
//        if UserSettings.getUserPreference("OpenSettingsAfterLanguageChange") != nil {
//            UserSettings.removeUserPreference("OpenSettingsAfterLanguageChange")
//            let settings = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Settings") as! SettingsTableViewController
//            
//            self.navigationController?.pushViewController(settings, animated: false)
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        AlertUtility.showErrorAlert(Constants.regularFont())
        
        super.viewWillAppear(animated)
        
        if Constants.languageChanged {
            if Constants.selectedVC == 1 {
                Constants.languageChanged = false
                self.perform(#selector(pushSettings), with: nil, afterDelay: 0.1)
            } else {
                self.tabBarController?.selectedIndex = Constants.selectedVC - 1
            }
        }
        Constants.selectedVC = 1
        self.slideMenuController()?.addRightGestures()
        self.slideMenuController()?.addLeftGestures()
        
        let rightButton: UIButton = UIButton(type: UIButtonType.custom)
        //set image for button
        if filtersEndDate != nil ||
            filtersPersons != nil ||
            filtersHashtags != nil ||
            filtersDepartments != nil {
            rightButton.setImage(UIImage(named: "filterApplied"), for: .normal)
        }else{
            rightButton.setImage(UIImage(named: "filter"), for: .normal)
        }
        //set frame
        rightButton.frame = CGRect(x:0, y:0, width:20, height:18)
        
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        
        rightBarButton.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filters)))
        
        self.tabBarController?.navigationItem.rightBarButtonItem = rightBarButton
        self.tabBarController?.navigationItem.rightBarButtonItem?.accessibilityIdentifier = "FiltersButton"
        
        
//        let logoImageView = UIImageView(frame:CGRect(x:0, y:0, width:91, height:26))
//        logoImageView.image = UIImage(named:"logoGradient")
//        let logoImageViewContainter = UIView(frame:logoImageView.frame)
//        logoImageViewContainter.addSubview(logoImageView)
//        tabBarController?.navigationItem.titleView = logoImageViewContainter
//        tabBarController?.navigationItem.title = " "
//        tabBarController?.navigationItem.titleView?.frame = logoImageView.frame
        tabBarController?.navigationItem.title = "Home".y_localized
        
        self.tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.reloadData()
        
        setLeftBarButton()
        tabBarController?.navigationItem.leftBarButtonItem?.accessibilityIdentifier = "MenuButton"
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.y_whiteBackground()
        self.navigationController?.y_removeShadow()
        
        
    }
    
//    @objc func adjustStatusbar(){
    
//        guard let statusBar = UIApplication.shared.value(forKeyPath: "statuszBarWindow.statusBar") as? UIView else { return }
//        
//        statusBar.backgroundColor = .white
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        SDImageCache.shared().clearMemory()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let iconView = UIView()
        let iconImageView = UIImageView(frame: CGRect(x: 8, y: 11, width: 14, height: 14))
        iconImageView.image = UIImage(named:"search")
        iconView.addSubview(iconImageView)
        
//        if UserSettings.appLanguageIsArabic() {
//            iconView.frame = CGRect(x: searchField.frame.size.width - 30, y: 0, width: 30, height: 36)
//            iconView.backgroundColor = .red
//            searchField.rightView = iconView
//            searchField.rightViewMode = .always
//        }else{
            iconView.frame = CGRect(x: 0, y: 0, width: 30, height: 36)
            searchField.leftView = iconView
            searchField.leftViewMode = .always
//        }
        self.tableView.reloadEmptyDataSet()
//        var refreshControlFrame = refreshControl.frame
//        refreshControlFrame.origin.y = 400
//        refreshControl.frame = refreshControlFrame
//        refreshControl.superview?.sendSubview(toBack: refreshControl)
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
        leftButton.addTarget(self, action: #selector(HomeViewController.menu), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        
        tabBarController?.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc func pushSettings() {
        let settings = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Settings") as! SettingsTableViewController
        self.navigationController?.pushViewController(settings, animated: false)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        /*if textField.text?.lengthOfBytes(using: .utf8) == 0 {
            DimUtility.addDimView()
        }else{
            DimUtility.removeDimView()
        }
//        print("search text:", textField.text!.lengthOfBytes(using: .utf8), textField.text)
        if textField.text!.y_trimmedLength() == 1 {
            loadData()
            self.homeTableViewAdapter.data = [self.homeTableViewAdapter.data.first!]
        }else if textField.text!.lengthOfBytes(using: .utf8) >= 2 {
            self.homeTableViewAdapter.data = []
        }else{
            loadData()
            self.homeTableViewAdapter.searchTerm = textField.text
        }*/
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
    
    override func handleTap(sender: UITapGestureRecognizer) {
        super.handleTap(sender: sender)
        if searchTerm != "" {
            sender.cancelsTouchesInView = true
        }
    }
    
    func getPostDetails(postId: Int) {
        LoadingOverlay.shared.showOverlay()
        Backend.getPostDetails(postId: postId, completion: { (post, backendError) in
            LoadingOverlay.shared.hideOverlayView()
            if backendError == .connection {
                
            } else {
                if post != nil {
//                    self.post = post
                    self.gotoPostDetails(post: post!)
                }
            }
        })
    }
    
    func gotoPostDetails(post: Post, andComment: Bool = false) {
        let postDetails = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "PostDetails") as! PostDetailsViewController
        
        postDetails.post = post
        postDetails.commentAddLaunch = andComment
        self.navigationController?.pushViewController(postDetails, animated: true)
    }
    
    func handleNotification(type: NotificationType, awardId: Int) {
        AppDelegate.awardId = 0
        switch type {
        case .like, .comment, .thanks, .approved, .pinned:
            print("")
            getPostDetails(postId: awardId)
        case .star:
            print("star")
            self.tabBarController?.selectedIndex = 4
        case .sendThreshold:
            print("send thresh")
            let tab = self.tabBarController
            tab?.selectedIndex = 2
            tab?.delegate?.tabBarController!(tab!, didSelect: (tab?.viewControllers![2])!)
        default:
            break
        }
    }
}

extension HomeViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate/*EmptyDataSetSource, EmptyDataSetDelegate*/ {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrText = NSMutableAttributedString()
        let str : String!
        let str2: String!
        if searchTerm != "" ||
        filtersEndDate != nil ||
        filtersPersons != nil ||
        filtersHashtags != nil ||
            filtersDepartments != nil {
//            str = "No results found!".y_localized
            str = "Sorry! We can't find what you're looking for".y_localized
//            str2 = "Try different keywords or filters".y_localized
            str2 = "Try something different and we'll look again".y_localized
        }else{
            str = /*"There are no posts yet"*/"Uh-oh...looks like there aren't any posts yet!".y_localized
            str2 = /*"Start by motivating colleagues"*/"Go ahead and start posting".y_localized
        }
        
        let text = NSAttributedString(string:str, attributes:[NSAttributedStringKey.font : UIFont(name: Constants.boldFont(), size: 20)!, NSAttributedStringKey.foregroundColor : UIColor.greyishBrown])
        let text2 = NSAttributedString(string:str2, attributes:[NSAttributedStringKey.font : UIFont(name: Constants.regularFont(), size: 17)!, NSAttributedStringKey.foregroundColor : UIColor.greyishBrown])
        attrText.append(NSAttributedString(string:"\n"))
        attrText.append(text)
        attrText.append(NSAttributedString(string:"\n"))
        attrText.append(NSAttributedString(string:"\n"))
        attrText.append(text2)
        
        return attrText
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if searchTerm != "" ||
            filtersEndDate != nil ||
            filtersPersons != nil ||
            filtersHashtags != nil ||
            filtersDepartments != nil {
            return UIImage(named:"emptyStateIllustration")
        }else{
            return UIImage(named:"homeEmptystate")
        }
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

extension HomeViewController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        DeveloperTools.print("tabBAr did select", tabBarController.selectedIndex)
        if tabBarController.selectedIndex == 2 {
            scrollToTop()
            tabBarController.selectedIndex = 0
            let width = ModalSize.full
            let height = ModalSize.fluid(percentage: Float(0.60))
            let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: 60))
            let customType = PresentationType.custom(width: width, height: height, center: center)
            
            let presenter = Presentr(presentationType: customType)
            presenter.roundCorners = true
            presenter.cornerRadius = 16
//            presenter.keyboardTranslationType = .none
//            presenter.keyboardTranslationType = .moveUp
            presenter.keyboardTranslationType = .compress
//            presenter.keyboardTranslationType = .stickToTop
//            presenter.viewControllerForContext = self
            let mainViewController = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "PostAdd") as! PostAddViewController
            mainViewController.homeVC = self
            tabBarController.navigationController?.customPresentViewController(presenter, viewController: mainViewController, animated: true, completion: {
                
            }
            )
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let statsVC = tabBarController.viewControllers![4] as? StatsTableViewController {
            if viewController == statsVC {
                if NetworkReachabilityManager()!.isReachable {
                    return true
                } else {
                    AlertUtility.showConnectionError()
                    return false
                }
            }
        }
        if tabBarController.viewControllers![1] == viewController || tabBarController.viewControllers![3] == viewController {
                if NetworkReachabilityManager()!.isReachable {
                    return true
                } else {
                    AlertUtility.showConnectionError()
                    return false
                }
        }
        
        return true
    }
    
    
    @objc func tabSwitched(sender: UISegmentedControl){
        DeveloperTools.print("selected segment ", sender.selectedSegmentIndex)
        switch sender.selectedSegmentIndex {
        case 0:
            let rewardsVC = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Rewards") as! RewardsViewController
            rewardsVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "pdfrewards")!.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "pdfrewards-active")!.withRenderingMode(.alwaysOriginal))
            rewardsVC.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            
            self.tabBarController?.viewControllers?[1] = rewardsVC
            break
        case 1:
            
            if NetworkReachabilityManager()!.isReachable == false {
                sender.selectedSegmentIndex = 0
                AlertUtility.showConnectionError()
            } else {
            let rewardsSubcategoryVC = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "RewardsSubcategory") as! RewardsSubcategoryViewController
            rewardsSubcategoryVC.rewardsListType = .Bookmarked
            
            rewardsSubcategoryVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "pdfrewards")!.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "pdfrewards-active")!.withRenderingMode(.alwaysOriginal))
            rewardsSubcategoryVC.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            self.tabBarController?.viewControllers?[1] = rewardsSubcategoryVC
            }
            break
        case 2:
            
            if NetworkReachabilityManager()!.isReachable == false {
                sender.selectedSegmentIndex = 0
                AlertUtility.showConnectionError()
            } else {
            let rewardsSubcategoryVC = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "RewardsSubcategory") as! RewardsSubcategoryViewController
            rewardsSubcategoryVC.rewardsListType = .Redeemed
            
            rewardsSubcategoryVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "pdfrewards")!.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "pdfrewards-active")!.withRenderingMode(.alwaysOriginal))
            rewardsSubcategoryVC.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            self.tabBarController?.viewControllers?[1] = rewardsSubcategoryVC
            }
            break
        default:
            break
        }
    }
}
extension HomeViewController : UITextFieldDelegate {
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

extension HomeViewController : TableViewAdapterDelegate {
}

extension HomeViewController: SlideMenuControllerDelegate {
//    func leftWillClose() {
//
//    }
//
//    func rightWillClose() {
//        leftWillClose()
//    }
    
    
    func leftWillOpen() {
        
        scrollToTop()
//        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//        statusBar.backgroundColor = .clear
    }

    func rightWillOpen() {
        leftWillOpen()
    }
    
    func leftDidOpen() {
//        if let window = UIApplication.shared.keyWindow {
//            window.windowLevel = UIWindowLevelStatusBar + 1
//        }
    }
    
    func rightDidOpen() {
        leftDidOpen()
    }
    
    func leftDidClose() {
        
//        if let window = UIApplication.shared.keyWindow {
//            window.windowLevel = UIWindowLevelNormal
//        }
//        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//        
//        statusBar.backgroundColor = .white
    }
    func rightDidClose() {
        
        leftDidClose()
    }
}
