//
//  FiltersPersonsViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import DZNEmptyDataSet
import IQKeyboardManagerSwift

protocol PersonsSelectorDelegate: class {
    func personsSelected(_persons: [Employee]?, type: Int?)
}

class FiltersPersonsViewController: UIViewController {

    weak var delegate: PersonsSelectorDelegate? = nil
    @IBOutlet weak var tableView: UITableView!
    
    
    var filtersPersonsTableViewAdapter: FiltersPersonsTableViewAdapter!
    var persons : [Employee]?
    var selectedPersons : [Employee]? = [Employee]()
    var preSelectedPersons : [Employee]? = [Employee]()
    
    var searchFieldContainer : UIView!
    var searchField = UITextField()
    
    func filteredPersons() -> [Employee]? {
        if self.searchField.text == "" {
            return persons
        }else{
            return persons!.filter { $0.FullName.y_containsIgnoringCase(searchField.text!) || $0.UserName.y_containsIgnoringCase(searchField.text!)}
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        filtersPersonsTableViewAdapter = FiltersPersonsTableViewAdapter(tableView: self.tableView, delegate:self)
        self.title = "Person".y_localized
        
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
        loadData()
        
        self.tableView.tableFooterView = UIView()
//        updateCounters()
        updateSelectedPersons()
    }
    
    func loadData(){
//        ProgressUtility.showProgressView()
        LoadingOverlay.shared.showOverlay()
        Backend.getMentions(searchText: "", pageIndex: 1, pageCount: 500, completion: { (persons, backendError)  in
            
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            
//            ProgressUtility.dismissProgressView()
            LoadingOverlay.shared.hideOverlayView()
            if persons == nil{
                if backendError == .connection {
                    
//                    AlertUtility.showErrorAlert( "Unable to connect to the internet, Please try again later".y_localized)

                }
            }else{
                
                self.persons = persons
                if self.preSelectedPersons != nil && self.persons != nil {
                    for i in 0 ..< self.persons!.count {
                        if self.preSelectedPersons!.contains(where: { $0.Id == self.persons![i].Id}) {
                            self.persons![i].isSelectedInFilter = true
                        }
                    }
                }
                self.updateSelectedPersons()
                if self.filteredPersons() == nil {
                    self.filtersPersonsTableViewAdapter.data = []
                }else{
                    self.filtersPersonsTableViewAdapter.data = self.filteredPersons()!
                }
            }
        })
    }
    
    func updateCounters(){
        
        var buttonTitle = "Apply".y_localized
        if selectedPersons != nil {
            if selectedPersons!.count > 0 {
//                buttonTitle = "\(buttonTitle) (\(selectedPersons!.count))"
            }else{
                tableView.tableHeaderView = UIView()
            }
        }
        let rightButton = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(doSelect))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        var bothAreEmpty = true
        if selectedPersons != nil {
            if selectedPersons!.count > 0 {
                bothAreEmpty = false
            }
        }
        if (delegate as! FiltersViewController).persons != nil {
            if (delegate as! FiltersViewController).persons!.count > 0 {
                bothAreEmpty = false
            }
        }
        if bothAreEmpty {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func updateSelectedPersons(){
        
//        selectedPersons = [Mention]()
//        for i in 0 ..< tableView.numberOfRows(inSection: 0) {
//            if let cell = tableView.cellForRow(at: IndexPath(row:i, section:0)) as? FiltersPersonsTableViewCell {
//
//            if cell.viewModel.selected {
//                selectedPersons?.append(filteredPersons()[i])
////                DeveloperTools.print("X selected hashtags:", selectedPersons)
//            }
//            }
//        }
//        self.navigationItem.rightBarButtonItem?.isEnabled = false
        if persons != nil {
        selectedPersons = [Employee]()
        for i in 0 ..< self.persons!.count {
            if self.persons![i].isSelectedInFilter {
                selectedPersons!.append(persons![i])
            }
        }
        }
        updateCounters()

    }
    
    func applyChanges(personType: Int?){
        
        self.delegate?.personsSelected(_persons: self.selectedPersons, type:personType)
    }
    
    @objc func doSelect(){
        //        updateSelectedPersons()
        //        selectedPersons = [Mention]()
        //        for i in 0 ..< tableView.numberOfRows(inSection: 0) {
        //            let cell = tableView.cellForRow(at: IndexPath(row:i, section:0)) as! FiltersPersonsTableViewCell
        //
        ////            DeveloperTools.print("mvvm selected :", cell.viewModel.selected)
        //            if cell.viewModel.selected {
        //                selectedPersons?.append(filteredPersons()[i])
        ////                DeveloperTools.print("X selected persons:", selectedPersons)
        //            }
        //        }
        if persons != nil {
            if persons!.count > 0 {
                if selectedPersons?.count == 0 {
                    self.applyChanges(personType: nil)
                    self.navigationController?.popViewController(animated: true)
                }else{
                let alert = UIAlertController(title: "", message: "Show posts as".y_localized, preferredStyle : .actionSheet)
                alert.view.tintColor = .primaryColor
                for i in 0 ..< Constants.filterPersonsPostTypes.count {
                    
                    alert.addAction(UIAlertAction(title: Constants.filterPersonsPostTypes[i].y_localized, style: .default, handler: { action in
                        
                        (self.delegate as! FiltersViewController).personsPostType = i
                        self.applyChanges(personType: i)
                        self.navigationController?.popViewController(animated: true)
                        
//                        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//
//                        statusBar.backgroundColor = .white
                    }))
                }
                alert.addAction(UIAlertAction(title: "Cancel".y_localized, style: .cancel, handler: { action in
                    
//                    guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//                    
//                    statusBar.backgroundColor = .white
                }))
                self.present(alert, animated: true, completion: {
                    
                })
                
//                guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//
//                statusBar.backgroundColor = .clear
                }
            }
        }
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
//        self.applyChanges(personType: (delegate as! FiltersViewController).personsPostType)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
}
extension FiltersPersonsViewController: TableViewAdapterDelegate {
}
extension FiltersPersonsViewController: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if filteredPersons() == nil {
            filtersPersonsTableViewAdapter.data = []
        }else{
            filtersPersonsTableViewAdapter.data = filteredPersons()!
        }
    }
}

extension FiltersPersonsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate/*EmptyDataSetSource, EmptyDataSetDelegate*/ {
    
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
