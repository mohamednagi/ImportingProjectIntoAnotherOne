//
//  NotificationsViewController.swift
//  Motivay
//
//  Created by Yasser Osama on 3/18/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import GIFRefreshControl
import UserNotifications

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    var notifications = [NotificationModel]()
    var post: Post!
    
    var refreshControl = GIFRefreshControl()//UIRefreshControl()
    var canRefresh = true
    
    var currentPageIndex = 1
    let currentPageSize = 10
    var numberOfPages : Int = 1
    
    var noMoreNotifications = false
    var loading = false
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let bgImageView = UIImageView(frame: tableView.bounds)
        bgImageView.image = UIImage(named: "patternBG")
        bgImageView.contentMode = .scaleAspectFill
        tableView.backgroundView = bgImageView
        tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "notificationCell")
        
        
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
        
        tableView.setShouldShowInfiniteScrollHandler { _ -> Bool in
            // Only show up to 5 pages then prevent the infinite scroll
            return self.currentPageIndex <= self.numberOfPages
        }
        tableView.addInfiniteScroll { (tableView) -> Void in
            // update table view
            DeveloperTools.print("load more")
            self.loadMoreData()
        }
        
//        tableView.emptyDataSetSource = self
//        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllDeliveredNotifications()
        
        Constants.selectedVC = 4
        if Constants.languageChanged {
            Constants.languageChanged = false
            self.perform(#selector(pushSettings), with: nil, afterDelay: 0.1)
        }
        self.slideMenuController()?.addRightGestures()
        self.slideMenuController()?.addLeftGestures()
        
        loadData()
        setLeftBarButton()
        self.tabBarController?.navigationItem.titleView = nil
        self.tabBarController?.navigationItem.title = "Notifications".y_localized
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationController?.y_showShadow()//y_addShadowWithColor()
        
//        self.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "pdfNotifications")!.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "pdfNotifications-active")!.withRenderingMode(.alwaysOriginal))
        self.tabBarItem.image = UIImage(named: "pdfNotifications")!.withRenderingMode(.alwaysOriginal)
//        self.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.y_deleteShadowWithColor()
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
    
    @objc func menu() {
        if UserSettings.appLanguageIsArabic() {
            self.tabBarController?.openRight()
        } else {
            self.tabBarController?.openLeft()
        }
    }
    
    @objc func pushSettings() {
        let settings = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Settings") as! SettingsTableViewController
        self.navigationController?.pushViewController(settings, animated: false)
    }
    
    @objc func loadData(){
        loadDataWithPageIndex(1, pageSize: currentPageSize)
        //        ProgressUtility.showProgressView()
        LoadingOverlay.shared.showOverlay()
    }
    
    @objc func refresh(){
        
        if self.tableView != nil {
            self.tableView.emptyDataSetSource = nil
            self.tableView.emptyDataSetDelegate = nil
            
            loadDataWithPageIndex(1, pageSize: currentPageSize)
        }
    }
    
    func loadMoreData(){
        if currentPageIndex > numberOfPages {
            noMoreNotifications = true
        }else{
            loadDataWithPageIndex(currentPageIndex+1, pageSize: currentPageSize)
        }
    }
    
    //MARK: - Methods
    func loadDataWithPageIndex(_ pageIndex:Int, pageSize: Int){
        
        loading = true
        Backend.getNotifications(pageIndex: pageIndex, pageSize: pageSize, completion: { (notifications, notificationsCount, backendError) in
            self.loading = false
            
            DeveloperTools.print("dnz set")
            
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            
            if backendError == .connection {
                
                LoadingOverlay.shared.hideOverlayView()
                self.tableView.setContentOffset(CGPoint.zero, animated:false)
                
            }else if notifications == nil {
                //                print(backendError ?? "get notifications error")
            }else {
                if pageIndex == 1 {
                    
                    self.notifications = notifications!
                    LoadingOverlay.shared.hideOverlayView()
                    
                    DispatchQueue.main.async {
                        self.scrollToTop()
                    }
                }else{
                    self.notifications.append(contentsOf: notifications!)
                    
                    self.tableView.finishInfiniteScroll()
                }
//                dump(self.notifications)
                                self.tableView.reloadData()
                
                self.numberOfPages = Int(ceil(CGFloat(notificationsCount)/CGFloat(self.currentPageSize)))
                self.currentPageIndex = pageIndex
                
            }
//            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
//            }
        }, showLoading: false)
//            if notifications != nil {
//                self.notifications = notifications!
//                self.tableView.reloadData()
//            } else {
//                print(backendError ?? "get notifications error")
//            }
//        })
    }
    
    
    func scrollToTop(){
        
        if self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 0 {
            DeveloperTools.print("scroll to top")
            
            self.tableView.scrollToRow(at: IndexPath(row:0, section:0), at: .top, animated: false)
        }
    }
    
    func getPostDetails(postId: Int) {
        LoadingOverlay.shared.showOverlay()
        Backend.getPostDetails(postId: postId, completion: { (post, backendError) in
            LoadingOverlay.shared.hideOverlayView()
            if backendError == .connection {
                
            } else {
                if post != nil {
                    self.post = post
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

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
        let notification = notifications[indexPath.row]
        cell.viewModel = NotificationTableViewCell.ViewModel(notification: notification)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 136
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let notification = notifications[indexPath.row]
        switch notification.type {
        case .star?:
//            print("star")
            let tab = self.tabBarController
            let shouldSelect = tab?.delegate?.tabBarController!(tab!, shouldSelect: (tab?.viewControllers![4])!)
            if shouldSelect! {
                self.tabBarController?.selectedIndex = 4
            }
        case .sendThreshold?:
//            print("send threshold")
            let tab = self.tabBarController
            tab?.selectedIndex = 2
            tab?.delegate?.tabBarController!(tab!, didSelect: (tab?.viewControllers![2])!)
        case .receiveThreshold?:
            print("receive threshold")
        case .rejected?:
            break
        default:
            getPostDetails(postId: notification.awardId)
        }
    }
}

extension NotificationsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrText = NSMutableAttributedString()
        
        let str = "There's no notification yet,".y_localized
        let str2 = "Check back later for updates".y_localized
        
        let text = NSAttributedString(string:str, attributes:[NSAttributedStringKey.font : UIFont(name: Constants.boldFont(), size: 24)!, NSAttributedStringKey.foregroundColor : UIColor.greyishBrown])
        let text2 = NSAttributedString(string:str2, attributes:[NSAttributedStringKey.font : UIFont(name: Constants.regularFont(), size: 17)!, NSAttributedStringKey.foregroundColor : UIColor.greyishBrown])
        attrText.append(text)
        attrText.append(NSAttributedString(string:"\n"))
        attrText.append(text2)
        
        return attrText
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named:"notiEmptystate")
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        scrollView.frame = CGRect.zero
    }
}
