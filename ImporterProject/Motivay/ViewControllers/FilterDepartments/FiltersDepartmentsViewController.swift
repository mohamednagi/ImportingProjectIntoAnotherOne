//
//  FiltersDepartmentsViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import DZNEmptyDataSet

protocol DepartmentsSelectorDelegate: class {
    func departmentsSelected(_departments: [Department]?)
}

public class FiltersDepartmentsViewController: UIViewController {

    weak var delegate: DepartmentsSelectorDelegate? = nil
    @IBOutlet weak var tableView: UITableView!
    
    
    var filtersDepartmentsTableViewAdapter: FiltersDepartmentsTableViewAdapter!
    var departments : [Department]?
    var selectedDepartments : [Department]? = [Department]()
    var preSelectedDepartments : [Department]? = [Department]()
    
    var searchFieldContainer : UIView!
    var searchField = UITextField()
    
    func filteredDepartments() -> [Department]? {
        if self.searchField.text == "" {
            return departments
        }else{
            return departments?.filter { $0.Name.y_containsIgnoringCase(searchField.text!)}
        }
    }
    
    public init() {
            super.init(nibName: "FiltersDepartmentsViewController",
                       bundle: Bundle(for: FiltersDepartmentsViewController.self))
          }
      required init?(coder: NSCoder) {
              fatalError("init(coder:) has not been implemented")
    }

   public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let bgImageView = UIImageView(frame: tableView.bounds)
        bgImageView.image = UIImage(named: "patternBG")
        bgImageView.contentMode = .scaleAspectFill
        tableView.backgroundView = bgImageView
        filtersDepartmentsTableViewAdapter = FiltersDepartmentsTableViewAdapter(tableView: self.tableView, delegate:self)
        self.title = "Departments".y_localized
        
        let rightButton = UIBarButtonItem(title: "Apply".y_localized, style: .plain, target: self, action: #selector(doSelect))
        
        searchFieldContainer = UIView(frame:CGRect(x:0, y:0/*64*/, width:self.view.frame.size.width, height:44))
        searchFieldContainer.backgroundColor = .searchFieldColor
        
        //        searchField.delegate = self
        
        //                    searchField.addTarget(v1, action: #selector(HomeViewController.textFieldDidChange(_:)), for: .editingChanged)
        searchField.placeholder = "Search".y_localized
        searchField.textAlignment = .center
        searchField.returnKeyType = .search
        
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchField.frame = CGRect(x:16, y:7, width:searchFieldContainer.frame.size.width - 32, height:30)
        searchField.layer.cornerRadius = 10
        
        searchField.backgroundColor = .white//UIColor(hexString: "f1f1f2")
        //        searchField.roundCorners(withRadius: 6)
        
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
        
        
        //         searchField.addTarget(self, action: #selector(pop), for: .editingChanged)
        searchFieldContainer.addSubview(searchField)
        self.view.addSubview(searchFieldContainer)
        
        self.navigationItem.rightBarButtonItem = rightButton
        loadData()
         updateSelectedDepartments()
//        FiltersDepartmentsTableViewAdapter.data = filtersTableViewAdapter.filters
                self.tableView.tableFooterView = UIView()
    }
    
    func loadData(){
//        ProgressUtility.showProgressView()
        LoadingOverlay.shared.showOverlay()
        Backend.getDepartments(completion: { (departments, backendError) in
//            ProgressUtility.dismissProgressView()
            LoadingOverlay.shared.hideOverlayView()
            
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            
            if departments == nil{
                if backendError == .connection {
                    
//                    AlertUtility.showErrorAlert("Unable to connect to the internet, Please try again later".y_localized)
                }
            }else{
                self.departments = departments
                if self.preSelectedDepartments != nil && self.departments != nil {
                    for i in 0 ..< self.departments!.count {
                        if self.preSelectedDepartments!.contains(where: { $0.Id == self.departments![i].Id}) {
                            self.departments![i].isSelectedInFilter = true
                        }
                    }
                }
                if self.filteredDepartments() == nil {
                    self.filtersDepartmentsTableViewAdapter.data = []
                }else{
                    self.filtersDepartmentsTableViewAdapter.data = self.filteredDepartments()!
                }
                self.updateSelectedDepartments()
            }
        })
    }
    
    func updateSelectedDepartments(){
        
//        selectedDepartments = [Department]()
//        for i in 0 ..< tableView.numberOfRows(inSection: 0) {
//            let cell = tableView.cellForRow(at: IndexPath(row:i, section:0)) as! FiltersDepartmentsTableViewCell
//
//            if cell.viewModel.selected {
//                selectedDepartments?.append(filteredDepartments()![i])
//            }
//        }
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        var allIncluded = true
        if departments != nil {
        selectedDepartments = [Department]()
        for i in 0 ..< self.departments!.count {
            if self.departments![i].isSelectedInFilter {
                selectedDepartments!.append(departments![i])
                if (delegate as! FiltersViewController).departments?.contains(where: { departments![i].Id == $0.Id}) == false {
                    allIncluded = false
                }
            }
        }
            var  previouselySelectedCount = (delegate as! FiltersViewController).departments?.count
            if previouselySelectedCount == nil {
                previouselySelectedCount = 0
            }
            if selectedDepartments!.count != previouselySelectedCount ||
                allIncluded == false
                {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
        
    }
    
    func applyChanges(){
        
        updateSelectedDepartments()
//        selectedDepartments = [Department]()
//        for i in 0 ..< tableView.numberOfRows(inSection: 0) {
//            let cell = tableView.cellForRow(at: IndexPath(row:i, section:0)) as! FiltersDepartmentsTableViewCell
//            
//            DeveloperTools.print("mvvm selected :", cell.viewModel.selected)
//            if cell.viewModel.selected {
//                selectedDepartments?.append(filteredDepartments()![i])
//                DeveloperTools.print("X selected selectedDepartments:", selectedDepartments)
//            }
//        }
        DeveloperTools.print("selected selectedDepartments:", selectedDepartments)
        delegate?.departmentsSelected(_departments: selectedDepartments)
    }
    
    @objc func doSelect(){
        applyChanges()
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
extension FiltersDepartmentsViewController: TableViewAdapterDelegate {
}
extension FiltersDepartmentsViewController: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if self.filteredDepartments() == nil {
            self.filtersDepartmentsTableViewAdapter.data = []
        }else{
            self.filtersDepartmentsTableViewAdapter.data = self.filteredDepartments()!
        }
    }
}

extension FiltersDepartmentsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate/*EmptyDataSetSource, EmptyDataSetDelegate*/ {
    
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
}
