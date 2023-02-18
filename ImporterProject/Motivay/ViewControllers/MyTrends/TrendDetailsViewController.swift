//
//  TrendDetailsViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit

class TrendDetailsViewController: UIViewController {

    /*@IBOutlet weak */var tableView : UITableView!
    var trendDetailsHeader: TrendDetailsHeaderViewController!
    
    
    var trendDetailsTableViewAdapter: TrendDetailsTableViewAdapter!
    var posts = [Post]()
    
    var refreshControl = UIRefreshControl()
    var canRefresh = true
    
    var currentPageIndex = 1
    let currentPageSize = 20
    var numberOfPages : Int!
    
    var noMorePosts = false
    var loading = false
    
    let receivingPersonPostType = 1
    
    var myTrend: MyTrend!
    var person: Employee!
    
    var panGesture       = UIPanGestureRecognizer()
    
    var delegate :MyTrendsViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView = self.view.viewWithTag(1) as! UITableView
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.tableFooterView = UIView()
        
        trendDetailsTableViewAdapter = TrendDetailsTableViewAdapter(tableView: self.tableView, delegate:self)
        loadData()
        
        
        trendDetailsHeader = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "TrendDetailsHeader") as! TrendDetailsHeaderViewController
        //            let view = UIView(frame:CGRect(x:0, y:0, width:tableView.frame.size.width, height:127))
        
        
        trendDetailsHeader.view!.frame = CGRect(x:0, y:0, width:Utilities.screedWidth(), height:127)
        trendDetailsHeader.view!.backgroundColor = .clear
        let blurEffect1 = UIBlurEffect(style: .regular)
        let blurEffectView1 = UIVisualEffectView(effect: blurEffect1)
        blurEffectView1.frame = trendDetailsHeader.view!.bounds
        blurEffectView1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        trendDetailsHeader.view!.addSubview(blurEffectView1)
        trendDetailsHeader.view!.sendSubview(toBack: blurEffectView1)
        
        trendDetailsHeader.hashtagTitleLabel.text = myTrend.Name
        trendDetailsHeader.taggedTimesLabel.text = "\(myTrend.TaggedTime!)"
        trendDetailsHeader.totalPointsLabel.text = "\(myTrend.TotalPoints!)"
        trendDetailsHeader.thisMonthLabel.text = "\(myTrend.PointsPerMonth!)"
        //            trendDetailsHeader.view!.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
        self.view.addSubview(trendDetailsHeader.view!)
        self.view.bringSubview(toFront: trendDetailsHeader.view!)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        trendDetailsHeader.view!.isUserInteractionEnabled = true
        trendDetailsHeader.view!.addGestureRecognizer(panGesture)
        
        tableView.frame = CGRect(x:tableView.frame.origin.x, y: 127, width:tableView.frame.size.width, height:tableView.frame.size.height)
 
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".y_localized)
//        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
//        tableView.refreshControl = refreshControl
        
        tableView.setShouldShowInfiniteScrollHandler { _ -> Bool in
            
            return self.currentPageIndex <= self.numberOfPages
        }
        tableView.addInfiniteScroll { (tableView) -> Void in
            
            
            self.loadMoreData()
        }
        tableView.isScrollEnabled = false
        
        view.backgroundColor = .clear
        tableView.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        tableView.backgroundView = blurEffectView
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
        
//        let trendDetailsHeader = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "TrendDetailsHeader") as! TrendDetailsHeaderViewController
//        trendDetailsHeader.view.frame = CGRect(x:0, y:0, width:tableView.frame.size.width, height:127)
//        tableView.tableHeaderView = trendDetailsHeader.view!
//        tableView.tableHeaderView?.frame = CGRect(x:0, y:0, width:tableView.frame.size.width, height:127)
        
    }
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        
    }
    
    @objc func loadData(){
        loadDataWithPageIndex(1, pageSize: currentPageSize)
//        ProgressUtility.showProgressView()
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
        let hashtag = Hashtag(JSON:JSON())!
        hashtag.Id = myTrend.Id
        hashtag.Name = myTrend.Name
        hashtag.Color = myTrend.Color
        
        loading = true
        Backend.getPosts(searchTerm: "", departments: nil, hashtags: [hashtag], startDate: nil, endDate: nil, persons: [person], personsPostType: receivingPersonPostType, pageIndex:pageIndex, pageSize: pageSize, completion: { (posts, numberOfPosts, backendError)  in
            self.loading = false

            if backendError == .connection {
                LoadingOverlay.shared.hideOverlayView()
            }else{
                if pageIndex == 1 {
                    DeveloperTools.print("page index 1")
                    self.posts = posts!
                    
                    LoadingOverlay.shared.hideOverlayView()
                    
                    DispatchQueue.main.async {
                        self.scrollToTop()
                    }
                }else{
                    self.posts.append(contentsOf: posts!)
                    
                    self.tableView.finishInfiniteScroll()
                }
                
                self.trendDetailsTableViewAdapter.data = self.posts
                self.trendDetailsTableViewAdapter.sourceView = 3
                
                self.numberOfPages = Int(ceil(CGFloat(numberOfPosts)/CGFloat(self.currentPageSize)))
                self.currentPageIndex = pageIndex
                
            }
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }, showLoading: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollToTop(){
        
        if self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 0 {
            DeveloperTools.print("scroll to top")
            self.tableView.scrollToRow(at: IndexPath(row:0, section:0), at: .top, animated: false)
        }
    }
}

extension TrendDetailsViewController : TableViewAdapterDelegate {
}
