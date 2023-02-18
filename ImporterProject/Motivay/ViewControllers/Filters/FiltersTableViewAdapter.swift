//
//  FiltersTableViewAdapter.swift
//
//  Created by Yehia Elbehery.
//

import UIKit

class FiltersTableViewAdapter: TableViewAdapter {
    let cellName = "FiltersTableViewCell"
    var searchTerm: String?
    var filters = ["Department", "Trend", "Date", "Person"]
    var filtersData : [String:[String:String]] = [
        "Department": ["title":"Departments".y_localized, "imageName":"department", "placeholder": "Select department(s)".y_localized],
        "Trend": ["title":"Trends".y_localized, "imageName":"trend", "placeholder": "Select trend(s)".y_localized],
        "Date": ["title":"Date".y_localized, "imageName":"date", "placeholder": /*"Select date range".y_localized*/"Date range".y_localized],
        "Person": ["title":"Person".y_localized, "imageName":"person", "placeholder": "Select person(s)".y_localized]
        ]
    override func didSetTableView() {
        
            let cellNib = UINib(nibName: cellName, bundle: nil)
            self.tableView.register(cellNib, forCellReuseIdentifier: cellName)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filtersVC = delegate as! FiltersViewController
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellName) as! FiltersTableViewCell
        let title = filtersData[filters[indexPath.row]]!["title"]
        let imageName = filtersData[filters[indexPath.row]]!["imageName"]
        let placeholder = filtersData[filters[indexPath.row]]!["placeholder"]
        
        cell.filterTitle.text = title
        cell.filterIconImageView.image = UIImage(named:imageName!)
        cell.placeholderLabel.isHidden = false
        cell.selectedContainerScrollView.isHidden = true
        cell.personsView.isHidden = true
        cell.filterIconImageView.isHidden = false
        
        cell.selectedContainerScrollView.subviews.forEach({ $0.removeFromSuperview() })
        
//        if UserSettings.appLanguageIsArabic() {
//             cell.placeholderLabel.textAlignment = .right
//        }else{
//             cell.placeholderLabel.textAlignment = .left
//        }
        
        switch filters[indexPath.row] {
        case "Date" :
            if filtersVC.startDate == nil {
                cell.placeholderLabel.text = placeholder
            }else{
                cell.filterIconImageView.isHidden = true
                cell.placeholderLabel.text = "\(filtersVC.startDate!.y_asString) - \(filtersVC.endDate!.y_asString)"
            }
            break
            
        case "Trend" :
           
            if filtersVC.hashtags == nil {
                cell.placeholderLabel.text = placeholder
            }else{
                cell.filterIconImageView.isHidden = true
                cell.placeholderLabel.isHidden = true
               
                if filtersVC.hashtags != nil {
                    var xOffset : CGFloat = 0
                    var hashtags = filtersVC.hashtags!
                    if UserSettings.appLanguageIsArabic() {
                        hashtags = filtersVC.hashtags!.reversed()
                    }
                    for hashtag in hashtags {
                        let hashtagView = cell.createHashtagBubbleView(hashtag)
                        var frame = hashtagView.frame
                        frame.origin.x = xOffset
                        hashtagView.frame = frame
                        xOffset = frame.origin.x + frame.size.width + 5
                        cell.selectedContainerScrollView.addSubview(hashtagView)
                    }
                    cell.selectedContainerScrollView.contentSize = CGSize(width:xOffset, height: cell.selectedContainerScrollView.contentSize.height)
                    if UserSettings.appLanguageIsArabic() {
                        cell.selectedContainerScrollView.contentOffset = CGPoint(x: cell.selectedContainerScrollView.contentSize.width - cell.selectedContainerScrollView.frame.width, y:0)
                    }
                    cell.selectedContainerScrollView.isHidden = false
                }
            }
            break
            
        case "Department" :
            
            if filtersVC.departments == nil {
                cell.placeholderLabel.text = placeholder
            }else{
                cell.filterIconImageView.isHidden = true
                cell.placeholderLabel.isHidden = true
                
                if filtersVC.departments != nil {
                    var xOffset : CGFloat = 0
                    var departments = filtersVC.departments!
                    if UserSettings.appLanguageIsArabic() {
                        departments = filtersVC.departments!.reversed()
                    }
                    for department in departments {
                        let departmentView = cell.createDepartmentBubbleView(department.Name)
                        var frame = departmentView.frame
                        frame.origin.x = xOffset
                        departmentView.frame = frame
                        xOffset = frame.origin.x + frame.size.width + 5
                        cell.selectedContainerScrollView.addSubview(departmentView)
                    }
                    cell.selectedContainerScrollView.contentSize = CGSize(width:xOffset, height: cell.selectedContainerScrollView.contentSize.height)
                    if UserSettings.appLanguageIsArabic() {
                        cell.selectedContainerScrollView.contentOffset = CGPoint(x: cell.selectedContainerScrollView.contentSize.width - cell.selectedContainerScrollView.frame.width, y:0)
                    }
                    cell.selectedContainerScrollView.isHidden = false
                }
            }
            break
        case "Person" :
            
            if filtersVC.persons == nil {
                cell.placeholderLabel.text = placeholder
            }else{
                
                cell.filterTitle.text = "\(title!) (\(Constants.filterPersonsPostTypes[filtersVC.personsPostType!].y_localized))"
                cell.placeholderLabel.isHidden = true
                cell.filterIconImageView.isHidden = true
                cell.personsView.isHidden = false
                cell.personsView.subviews.forEach({ $0.removeFromSuperview() })
                var yOffset : CGFloat = 0
                for person in filtersVC.persons! {
                    let pView = UIView(frame:CGRect(x:0, y:Int(yOffset), width:Int(cell.frame.size.width), height:58))
                    
                    var pImageViewFrame = CGRect(x:0, y:11, width:36, height:36)
                    
                    let pImageView = UIImageView(frame:pImageViewFrame)
                    pImageView.y_circularRoundedCorner()
                    pImageView.image = UIImage(named:"profileBig")
                    if person.ProfileURL != nil {
                        pImageView.sd_setImage(with: URL(string:person.ProfileURL!), placeholderImage: UIImage(named:"profileBig"))
                    }
                    let fullNameLabel = AutomaticallyLocalizedLabel(frame:CGRect(x:pImageView.frame.origin.x+pImageView.frame.width+8, y:11, width:200, height:20))
                    fullNameLabel.text = person.FullName
                    let userNameLabel = AutomaticallyLocalizedLabel(frame:CGRect(x:pImageView.frame.origin.x+pImageView.frame.size.width+8, y:fullNameLabel.frame.origin.y+fullNameLabel.frame.size.height, width:200, height:20))
                    userNameLabel.text = "@\(person.UserName)"
                    
                    if UserSettings.appLanguageIsArabic() {
                        pImageViewFrame = CGRect(x: cell.frame.size.width - 36 - 44, y:11, width:36, height:36)
                        pImageView.frame = pImageViewFrame
                        
                        let fullNameLabelFrame = CGRect(x:pImageView.frame.origin.x-200 - 8, y:11, width:200, height:20)
                        fullNameLabel.frame = fullNameLabelFrame
                        
                        let userNameLabelFrame = CGRect(x:pImageView.frame.origin.x - 200 - 8, y:fullNameLabel.frame.origin.y+fullNameLabel.frame.size.height, width:200, height:20)
                        userNameLabel.frame = userNameLabelFrame
                    }
//                    pView.backgroundColor = .red
                    pView.addSubview(pImageView)
                    pView.addSubview(fullNameLabel)
                    pView.addSubview(userNameLabel)
                    
                    cell.personsView.addSubview(pView)
                    yOffset = pView.frame.origin.y + pView.frame.size.height
                }
            }
            break
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let filtersVC = delegate as! FiltersViewController
        if filters[indexPath.row] == "Person" && filtersVC.persons != nil {
            
            return CGFloat(44 + filtersVC.persons!.count*58)
        }else{
            return 88
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filtersVC = delegate as! FiltersViewController
        self.tableView.deselectRow(at: indexPath, animated: true)
        switch (filters[indexPath.row]){
        case "Department":
            let filterTrends = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "FiltersDepartments") as! FiltersDepartmentsViewController
            filterTrends.preSelectedDepartments = filtersVC.departments
            filterTrends.delegate = (delegate as! FiltersViewController)
            (delegate as! FiltersViewController).navigationController?.pushViewController(filterTrends, animated: true)
            break
        case "Trend":
            let filterTrends = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "FiltersTrends") as! FiltersTrendsViewController
            filterTrends.preSelectedHashtags = filtersVC.hashtags
            filterTrends.delegate = (delegate as! FiltersViewController)
            (delegate as! FiltersViewController).navigationController?.pushViewController(filterTrends, animated: true)
            break
        case "Date":
        let filterCalendar = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "FilterCalendar") as! FilterCalendarViewController
        filterCalendar.initialStartDate = filtersVC.startDate
        filterCalendar.initialEndDate = filtersVC.endDate
        
        filterCalendar.delegate = (delegate as! FiltersViewController)
        (delegate as! FiltersViewController).navigationController?.pushViewController(filterCalendar, animated: true)
            break
            
        case "Person":
            let filterPersons = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "FiltersPersons") as! FiltersPersonsViewController
            filterPersons.preSelectedPersons = filtersVC.persons
            filterPersons.delegate = (delegate as! FiltersViewController)
            (delegate as! FiltersViewController).navigationController?.pushViewController(filterPersons, animated: true)
            break
        default:
            break
        }
    }
}
