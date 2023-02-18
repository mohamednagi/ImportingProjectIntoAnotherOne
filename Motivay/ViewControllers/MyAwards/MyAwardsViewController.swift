//
//  MyAwardsViewController.swift
//  Motivay
//
//  Created by Yasser Osama on 3/4/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import GIFRefreshControl

class MyAwardsViewController: UIViewController, TableViewAdapterDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var totalPointsLabel: ArabicNumbersLabel!
    @IBOutlet weak var thisMonthPointsLabel: ArabicNumbersLabel!
    @IBOutlet weak var myPostsTableView: UITableView!
    
    //MARK: - Properties
    var homeTableViewAdapter: HomeTableViewAdapter!
    var posts = [Post]()
    var searchTerm: String = ""
    var filtersDepartments : [Department]?
    var filtersHashtags : [Hashtag]?
    var filtersStartDate : Date?
    var filtersEndDate : Date?
    var filtersPersons : [Employee]?
    var filtersPersonsPostType = 1
    
    var refreshControl = GIFRefreshControl()//UIRefreshControl()
    var canRefresh = true
    
    var currentPageIndex = 1
    let currentPageSize = 20
    var numberOfPages : Int!
    var noMorePosts = false
    var loading = false
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let bgImageView = UIImageView(frame: myPostsTableView.bounds)
        bgImageView.image = UIImage(named: "patternBG")
        bgImageView.contentMode = .scaleAspectFill
        myPostsTableView.backgroundView = bgImageView
        self.navigationController!.navigationBar.tintColor = .primaryColor
        self.navigationItem.title = "My Appraisals".y_localized
        
        /*if let employee = UserSettings.info {
            if let awardPoints = employee.AwardPointVM {
                
                totalPointsLabel.text = "\(awardPoints.TotalPoints)"
                thisMonthPointsLabel.text = "\(awardPoints.MonthPoints)"
            }
        }*/
        
        myPostsTableView.tableFooterView = UIView()
        
        if let user = UserSettings.info {
            filtersPersons = [user]
            filtersPersons?.first?.Id = filtersPersons?.first?.userID
            homeTableViewAdapter = HomeTableViewAdapter(tableView: myPostsTableView, delegate:self)
            homeTableViewAdapter.sourceView = 2
            loadData()
        }
        
        /*refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".y_localized)
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        myPostsTableView.refreshControl = refreshControl*/
        do {
            let url = Bundle.main.url(forResource: "Motivay_10", withExtension: "gif")
            let data = try Data(contentsOf: url!)
            
            refreshControl.animatedImage = GIFAnimatedImage(data: data)
            refreshControl.contentMode = .scaleAspectFit
            refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
            myPostsTableView.addSubview(refreshControl)
        } catch {
            
        }
        
        myPostsTableView.setShouldShowInfiniteScrollHandler { _ -> Bool in
            // Only show up to 5 pages then prevent the infinite scroll
            return self.currentPageIndex <= self.numberOfPages
        }
        myPostsTableView.addInfiniteScroll { (tableView) -> Void in
            // update table view
            DeveloperTools.print("load more")
            self.loadMoreData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*if UserSettings.info != nil {
            totalPointsLabel.text = "\(UserSettings.info!.Balance)"
            thisMonthPointsLabel.text = "\(UserSettings.info!.EarnedPoints)"
        }*/
        
        if let employee = UserSettings.info {
            if let awardPoints = employee.AwardPointVM {
                
                totalPointsLabel.text = "\(awardPoints.TotalPoints!)"
                thisMonthPointsLabel.text = "\(awardPoints.MonthPoints!)"
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func loadData(){
        loadDataWithPageIndex(1, pageSize: currentPageSize)
        LoadingOverlay.shared.showOverlay()
    }
    
    @objc func refresh(){
        
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
            
            self.myPostsTableView.emptyDataSetSource = self
            self.myPostsTableView.emptyDataSetDelegate = self
            
            if backendError == .connection {
                LoadingOverlay.shared.hideOverlayView()
            } else {
                if pageIndex == 1 {
                    DeveloperTools.print("page index 1")
                    self.posts = posts!
                    LoadingOverlay.shared.hideOverlayView()
                    DispatchQueue.main.async {
                        self.scrollToTop()
                    }
                } else {
                    self.posts.append(contentsOf: posts!)
                    self.myPostsTableView.finishInfiniteScroll()
                }
                
                self.homeTableViewAdapter.data = self.posts
                self.numberOfPages = Int(ceil(CGFloat(numberOfPosts)/CGFloat(self.currentPageSize)))
                self.currentPageIndex = pageIndex
                
            }
//            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
//            }
        }, showLoading: false)
    }
    
    func scrollToTop() {
        
        if self.myPostsTableView.numberOfSections > 0 && self.myPostsTableView.numberOfRows(inSection: 0) > 0 {
            DeveloperTools.print("scroll to top")
            self.myPostsTableView.scrollToRow(at: IndexPath(row:0, section:0), at: .top, animated: false)
        }
    }
}

extension MyAwardsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrText = NSMutableAttributedString()
        let str : String!
        
        str = /*"There’s no awards yet."*/"Uh-oh...looks like you don't have any awards yet!".y_localized
        
        let text = NSAttributedString(string:str, attributes:[NSAttributedStringKey.font : UIFont(name: Constants.boldFont(), size: 24)!, NSAttributedStringKey.foregroundColor : UIColor.greyishBrown])
        attrText.append(text)
        
        return attrText
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named:"awardsEmptystate")
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
