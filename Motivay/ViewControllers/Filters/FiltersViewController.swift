//
//  FiltersViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import IQKeyboardManagerSwift

class FiltersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var delegate : HomeViewController!
    
    var filtersTableViewAdapter: FiltersTableViewAdapter!
    var departments : [Department]?
    var hashtags : [Hashtag]?
    var startDate: Date?
    var endDate: Date?
    var persons: [Employee]?
    var personsPostType: Int?
    
    var applyButton = AutomaticallyLocalizedButton()
    
    var rightButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        let bgImageView = UIImageView(frame: tableView.bounds)
        bgImageView.image = UIImage(named: "patternBG")
        bgImageView.contentMode = .scaleAspectFill
        tableView.backgroundView = bgImageView
        // Do any additional setup after loading the view, typically from a nib.
        tableView.accessibilityIdentifier = "FiltersTableView"
        filtersTableViewAdapter = FiltersTableViewAdapter(tableView: self.tableView, delegate:self)
        self.title = "Filters".y_localized
        let leftButton = UIBarButtonItem(title: "Cancel".y_localized, style: .plain, target: self, action: #selector(cancel))
        
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = leftButton
        
        
        rightButton = UIBarButtonItem(title: "Reset".y_localized, style: .plain, target: self, action: #selector(reset))
        
        
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = rightButton
        
        self.navigationController?.navigationBar.tintColor = .primaryColor
        filtersTableViewAdapter.data = filtersTableViewAdapter.filters
        
    }
    
    @objc func applyFilters(){
        delegate.applyFilters(departments: departments, hashtags: hashtags, startDate: startDate, endDate: endDate, persons: persons, personsPostType: personsPostType)
        self.dismiss(animated: true) {
            
        }
    }
    
    @objc func reset(){
        AlertUtility.showAlertWithButton(msg: "Are you sure you want to reset all filters?".y_localized, title: "Reset".y_localized, buttonTitle: "Reset".y_localized, closeButtonTitle: "Cancel".y_localized, callback: {
            self.dismiss(animated: true) {
                
                self.departments = nil
                self.hashtags = nil
                self.startDate = nil
                self.endDate = nil
                self.persons = nil
                self.reload()
                self.delegate.resetFilters()
            }
        })
        
    }
    
    
    @objc func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.y_whiteBackground()
        self.navigationController?.y_removeShadow()
        self.navigationController?.navigationBar.isTranslucent = false
        reload()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let applyButtonView = UIView(frame:CGRect(x:0, y:0, width:tableView.frame.size.width, height:156))
        applyButton = AutomaticallyLocalizedButton(frame:CGRect(x:tableView.frame.size.width/2 - 279/2, y:100, width:279, height:56))
        applyButton.titleLabel?.font = UIFont(name:Constants.regularFont(), size:17)!
        var buttonTitle = "Apply"
        if UserSettings.appLanguageIsArabic() {
            buttonTitle = "ApplyF".y_localized
        }
        applyButton.setTitle(/*"Apply filters"*/buttonTitle, for: .normal)
        applyButton.layer.cornerRadius = 28
        applyButton.backgroundColor = .primaryColor
        applyButton.isEnabled = false
        applyButton.alpha = 0.4
        applyButton.addTarget(self, action: #selector(applyFilters), for: .touchUpInside)
        
        applyButtonView.addSubview(applyButton)
        applyButtonView.backgroundColor = .clear
        reload()
        self.tableView.tableFooterView = applyButtonView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func reload(){
        if startDate != delegate.filtersStartDate ||
           endDate != delegate.filtersEndDate ||
            hashtagsArrayIsDifferent() ||
            departmentsArrayIsDifferent() ||
            personsArrayIsDifferent() ||
            personsPostType != delegate.filtersPersonsPostType
        {
            applyButton.isEnabled = true
//            rightButton.isEnabled = true
            applyButton.alpha = 1
            DeveloperTools.print("??")
        }else{
//            rightButton.isEnabled = false
            applyButton.isEnabled = false
            applyButton.alpha = 0.4
            DeveloperTools.print("!!")
        }
        
        if hashtags == nil && departments == nil && startDate == nil && endDate == nil && persons == nil {
            rightButton.isEnabled = false
        }else{
            rightButton.isEnabled = true
        }
        tableView.reloadData()
    }
    
    func hashtagsArrayIsDifferent() -> Bool {
        if hashtags == nil && delegate.filtersHashtags == nil {
            return false
        }else{
            if hashtags == nil || delegate.filtersHashtags == nil {
                return true
            }else{
                if hashtags!.count != delegate.filtersHashtags!.count {
                    return true
                }else{
                    for i in 0 ..< self.hashtags!.count {
                        let hashtag = self.hashtags![i]
                        if delegate.filtersHashtags!.contains(where: { hashtag.Id == $0.Id }) == false {
                            return true
                        }
                    }
                    return false
                }
            }
        }
    }
    
    
    func departmentsArrayIsDifferent() -> Bool {
        if departments == nil && delegate.filtersDepartments == nil {
            return false
        }else{
            if departments == nil || delegate.filtersDepartments == nil {
                return true
            }else{
                if departments!.count != delegate.filtersDepartments!.count {
                    return true
                }else{
                    for i in 0 ..< self.departments!.count {
                        let department = self.departments![i]
                        if delegate.filtersDepartments!.contains(where: { department.Id == $0.Id }) == false {
                            return true
                        }
                    }
                    return false
                }
            }
        }
    }
    
    
    func personsArrayIsDifferent() -> Bool {
        if persons == nil && delegate.filtersPersons == nil {
            return false
        }else{
            if persons == nil || delegate.filtersPersons == nil {
                return true
            }else{
                if persons!.count != delegate.filtersPersons!.count {
                    return true
                }else{
                    for i in 0 ..< self.persons!.count {
                        let person = self.persons![i]
                        if delegate.filtersPersons!.contains(where: { person.Id == $0.Id }) == false {
                            return true
                        }
                    }
                    return false
                }
            }
        }
    }
}
extension FiltersViewController: TableViewAdapterDelegate {
}

extension FiltersViewController: DateRangeSelectedDelegate {
    func userSelectedDateRange(start: Date?, end: Date?) {
        startDate = start
        endDate = end
        reload()
    }
}
extension FiltersViewController: TrendsSelectorDelegate {
    func trendsSelected(_hashtags: [Hashtag]?) {
        
        hashtags = _hashtags
        if hashtags?.count == 0 {
            hashtags = nil
        }
        reload()
    }
}

extension FiltersViewController: DepartmentsSelectorDelegate {
    func departmentsSelected(_departments: [Department]?) {
        departments = _departments
        if departments?.count == 0 {
            departments = nil
        }
        reload()
    }
}
extension FiltersViewController: PersonsSelectorDelegate {
    func personsSelected(_persons: [Employee]?, type: Int?) {
        persons = _persons
        personsPostType = type
        if persons?.count == 0 {
            persons = nil
            personsPostType = nil
        }
        reload()
    }
}
