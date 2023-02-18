//
//  FiltersTrendsViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import DZNEmptyDataSet

protocol TrendsSelectorDelegate: class {
    func trendsSelected(_hashtags: [Hashtag]?)
}

class FiltersTrendsViewController: UIViewController {

    weak var delegate: TrendsSelectorDelegate? = nil
    @IBOutlet weak var tableView: UITableView!
    
    
    var filtersTrendsTableViewAdapter: FiltersTrendsTableViewAdapter!
    var hashtags : [Hashtag]?
    var selectedHashtags : [Hashtag]? = [Hashtag]()
    var preSelectedHashtags : [Hashtag]? = [Hashtag]()
    
    var searchFieldContainer : UIView!
    var searchField = UITextField()
    
    func filteredHashtags() -> [Hashtag]? {
        if self.searchField.text == "" {
            return hashtags
        }else{
            return hashtags?.filter { $0.Name.y_containsIgnoringCase(searchField.text!)}
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let bgImageView = UIImageView(frame: tableView.bounds)
        bgImageView.image = UIImage(named: "patternBG")
        bgImageView.contentMode = .scaleAspectFill
        tableView.backgroundView = bgImageView
        filtersTrendsTableViewAdapter = FiltersTrendsTableViewAdapter(tableView: self.tableView, delegate:self)
        self.title = "Trends".y_localized
        
        
        searchFieldContainer = UIView(frame:CGRect(x:0, y:0/*64*/, width:self.view.frame.size.width, height:44))
        searchFieldContainer.backgroundColor = .searchFieldColor
        
        searchField.placeholder = "Search".y_localized
        searchField.textAlignment = .center
        searchField.returnKeyType = .search
        
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchField.frame = CGRect(x:16, y:7, width:searchFieldContainer.frame.size.width - 32, height:30)
        searchField.layer.cornerRadius = 10
        
        searchField.backgroundColor = .white
        
        let iconView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 36))
        var imageIconOffset : CGFloat = -50
        if UserSettings.appLanguageIsArabic() {
            imageIconOffset = 20
        }
        let iconImageView = UIImageView(frame: CGRect(x: searchField.center.x + imageIconOffset, y: 11, width: 14, height: 14))
        iconImageView.image = UIImage(named:"search")
        iconView.addSubview(iconImageView)
        if UserSettings.appLanguageIsArabic() {
            searchField.rightView = iconView
            searchField.rightViewMode = .unlessEditing
            
        }else{
            searchField.leftView = iconView
            searchField.leftViewMode = .unlessEditing
        }
        
        
        searchFieldContainer.addSubview(searchField)
        
        self.view.addSubview(searchFieldContainer)
        
        let rightButton = UIBarButtonItem(title: "Apply".y_localized, style: .plain, target: self, action: #selector(doSelect))
        self.navigationItem.rightBarButtonItem = rightButton
        
        loadData()
        updateSelectedTrends()
        self.tableView.tableFooterView = UIView()
    }
    
    func loadData(){
//        ProgressUtility.showProgressView()
        LoadingOverlay.shared.showOverlay()
        Backend.getTags(completion: { (hashtags, backendError) in
//            ProgressUtility.dismissProgressView()
            
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            
            LoadingOverlay.shared.hideOverlayView()
            if hashtags == nil{
                if backendError == .connection {
                    
//                    AlertUtility.showErrorAlert("Error".y_localized, message:  "Unable to connect to the internet, Please try again later".y_localized)

                }
            }else{
                self.hashtags = hashtags
                if self.preSelectedHashtags != nil && self.hashtags != nil {
                    for i in 0 ..< self.hashtags!.count {
                        if self.preSelectedHashtags!.contains(where: { $0.Id == self.hashtags![i].Id}) {
                            self.hashtags![i].isSelectedInFilter = true
                        }
                    }
                }
                if self.filteredHashtags() == nil {
                    self.filtersTrendsTableViewAdapter.data = []
                }else{
                    self.filtersTrendsTableViewAdapter.data = self.filteredHashtags()!
                }
                self.updateSelectedTrends()
            }
        })
    }
    
    func updateSelectedTrends(){
        
//        selectedHashtags = [Hashtag]()
//        for i in 0 ..< tableView.numberOfRows(inSection: 0) {
//            let cell = tableView.cellForRow(at: IndexPath(row:i, section:0)) as! FiltersTrendsTableViewCell
//
//            DeveloperTools.print("mvvm selected :", cell.viewModel.selected)
//            if cell.viewModel.selected {
//                selectedHashtags?.append(filteredHashtags()![i])
////                DeveloperTools.print("X selected hashtags:", selectedHashtags)
//            }
//        }
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        var allIncluded = true
        if hashtags != nil {
            selectedHashtags = [Hashtag]()
            for i in 0 ..< self.hashtags!.count {
                if self.hashtags![i].isSelectedInFilter {
                    selectedHashtags!.append(hashtags![i])
                    if (delegate as! FiltersViewController).hashtags?.contains(where: { hashtags![i].Id == $0.Id}) == false {
                        allIncluded = false
                    }
                }
            }
            
            var  previouselySelectedCount = (delegate as! FiltersViewController).hashtags?.count
            if previouselySelectedCount == nil {
                previouselySelectedCount = 0
            }
            if selectedHashtags!.count != previouselySelectedCount ||
                allIncluded == false
            {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            
        }
    }
    
    func applyChanges(){
        
        updateSelectedTrends()
        delegate?.trendsSelected(_hashtags: selectedHashtags)
    }
    
    @objc func doSelect(){
        applyChanges()
//        DeveloperTools.print("selected hashtags:", selectedHashtags)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.navigationController?.y_whiteBackground()
//        self.navigationController?.y_removeShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        var frame = searchFieldContainer.frame
//        frame.origin.y = UIApplication.shared.statusBarFrame.size.height+self.navigationController!.navigationBar.frame.size.height+10
//        searchFieldContainer.frame = frame
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        applyChanges()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
}
extension FiltersTrendsViewController: TableViewAdapterDelegate {
}
extension FiltersTrendsViewController: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if self.filteredHashtags() == nil {
            self.filtersTrendsTableViewAdapter.data = []
        }else{
            self.filtersTrendsTableViewAdapter.data = self.filteredHashtags()!
        }
    }
}

extension FiltersTrendsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate/*EmptyDataSetSource, EmptyDataSetDelegate*/ {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrText = NSMutableAttributedString()
        
            let str = "No results found!".y_localized
            let str2 = "Try different keywords".y_localized
            
        let text = NSAttributedString(string:str, attributes:[NSAttributedStringKey.font : UIFont(name: Constants.boldFont(), size: 24)!, NSAttributedStringKey.foregroundColor : UIColor.greyishBrown])
        let text2 = NSAttributedString(string:str2, attributes:[NSAttributedStringKey.font : UIFont(name: Constants.regularFont(), size: 17)!, NSAttributedStringKey.foregroundColor : UIColor.greyishBrown])
        attrText.append(text)
        attrText.append(NSAttributedString(string:"\n"))
        attrText.append(text2)
        
        return attrText
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named:"emptyStateIllustration")
        
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        if Utilities.deviceIs_iPhone5() {
            return 0
        }else{
            return -50
        }
    }
    
//    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
//        return true
//    }
//
//    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
//        return true
//    }
//    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
//        scrollView.contentOffset = CGPoint.zero
//    }
}
