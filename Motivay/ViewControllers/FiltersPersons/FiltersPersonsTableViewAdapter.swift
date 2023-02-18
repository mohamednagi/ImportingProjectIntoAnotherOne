//
//  FiltersPersonsTableViewAdapter.swift
//
//  Created by Yehia Elbehery.
//

import UIKit

class FiltersPersonsTableViewAdapter: TableViewAdapter {
    let cellName = "FiltersPersonsTableViewCell"
    
    override func didSetTableView() {
        
            let cellNib = UINib(nibName: cellName, bundle: nil)
            self.tableView.register(cellNib, forCellReuseIdentifier: cellName)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let filtersPersonsVC = delegate as! FiltersPersonsViewController
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellName) as! FiltersPersonsTableViewCell
        
        let person = self.data[indexPath.row] as! Employee
//        DeveloperTools.print("person \(indexPath.row):", person)
//        dump(person)
//        var selected = false
//        print("and the crash is here 3")
//        if filtersPersonsVC.selectedPersons != nil {
//
//            if filtersPersonsVC.selectedPersons!.contains(where: { $0.Id == person.Id}) {
//                selected = true
//            }
//        }
        
        cell.tag = indexPath.row
        cell.vc = filtersPersonsVC
        cell.viewModel = FiltersPersonsTableViewCell.ViewModel(_person:person, _selected: person.isSelectedInFilter)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let filtersPersonsVC = delegate as! FiltersPersonsViewController
        if filtersPersonsVC.selectedPersons != nil {
            if filtersPersonsVC.selectedPersons!.count > 0 {
                return 44+54+92
            }
        }
        return 44+54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let returnedView = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:44+54))
        returnedView.backgroundColor = .white
        
        let filtersPersonsVC = delegate as! FiltersPersonsViewController
        if filtersPersonsVC.selectedPersons != nil {
            if filtersPersonsVC.selectedPersons!.count > 0 {
                let scrollView = UIScrollView(frame:CGRect(x:0, y:54+44, width:tableView.frame.size.width, height:92))
                scrollView.showsHorizontalScrollIndicator = false
                
                var maxX : CGFloat = 16
                
                var selectedPersons : [Employee] = filtersPersonsVC.selectedPersons!
                if UserSettings.appLanguageIsArabic() {
                    selectedPersons = filtersPersonsVC.selectedPersons!.reversed()
                }
                for i in 0 ..< selectedPersons.count {
                    let person = selectedPersons[i]
                    
                    let personView = UIView(frame:CGRect(x:maxX, y:0, width:76, height:79))
                    scrollView.addSubview(personView)
                    
                    let personImageView = UIImageView(frame:CGRect(x:0, y:0, width:60, height:60))
                    personImageView.contentMode = .scaleAspectFill
                    personImageView.y_circularRoundedCorner()
                    if let profileURL = person.ProfileURL {
                        personImageView.sd_setImage(with: URL(string: profileURL), placeholderImage: UIImage(named:"profileBig"))
                    } else {
                        personImageView.image = UIImage(named:"profileBig")
                    }
                    
                    let personDeleteButton = UIButton(frame:CGRect(x:personImageView.frame.size.width-24, y:0, width:24, height:24))
                    personDeleteButton.setImage(UIImage(named:"delete"), for: .normal)
                    personDeleteButton.tag = i
                    personDeleteButton.addTarget(self, action: #selector(deselectPerson(_:)), for: .touchUpInside)
                    
                    let personNameLabel = UILabel(frame:CGRect(x:0, y:personImageView.frame.size.height+5, width: personImageView.frame.size.width, height:20))
                    personNameLabel.text = person.FullName.components(separatedBy: .whitespaces).first!
                    personNameLabel.textAlignment = .center
                    personNameLabel.adjustsFontSizeToFitWidth = false
                    
                    personView.addSubview(personNameLabel)
                    personView.addSubview(personImageView)
                    personView.addSubview(personDeleteButton)
                    
                    scrollView.addSubview(personView)
                    maxX += 76
                }
                
                scrollView.contentSize = CGSize(width:maxX, height:scrollView.contentSize.height)
                
                if UserSettings.appLanguageIsArabic() {
                if scrollView.contentSize.width < scrollView.frame.size.width {
                    scrollView.frame = CGRect(x:returnedView.frame.size.width - (maxX), y:scrollView.frame.origin.y, width:maxX, height:scrollView.frame.size.height)
                }else{
                    scrollView.contentOffset = CGPoint(x: scrollView.contentSize.width - scrollView.frame.width, y:0)
                }
                }
                scrollView.backgroundColor = .white
                returnedView.addSubview(scrollView)
                
                var frame = returnedView.frame
                frame.size.height = 44+54+92
                returnedView.frame = frame
            }
        }
        
        var tipLabelX = 16
        var numberLabelX = returnedView.frame.size.width - 75 - 16
        if UserSettings.appLanguageIsArabic() {
            tipLabelX = Int(returnedView.frame.size.width - 125 - 16)
            numberLabelX = 16
        }
        
        let tipLabel = UILabel(frame:CGRect(x:tipLabelX, y:44+16, width:125, height:20))
        tipLabel.text = "Select Person".y_localized
        tipLabel.font = UIFont(name: Constants.regularFont(), size: 14)
        
        var number = 0
        if filtersPersonsVC.selectedPersons != nil {
            number = filtersPersonsVC.selectedPersons!.count
        }
        let numberLabel = ArabicNumbersLabel(frame:CGRect(x:numberLabelX, y:44+16, width:75, height:20))
        if UserSettings.appLanguageIsArabic() {
            numberLabel.text = "تم إختيار (\(number))"
        }else{
            numberLabel.text = "\(number) selected"
        }
        numberLabel.textAlignment = .right
        numberLabel.font = UIFont(name: Constants.regularFont(), size: 14)
        
        returnedView.addSubview(tipLabel)
        returnedView.addSubview(numberLabel)

        
        return returnedView
    }
    
    @objc func deselectPerson(_ sender: UIButton){
        let filtersPersonsVC = delegate as! FiltersPersonsViewController
        let index = sender.tag
        
//        var row : Int!
        for i in 0 ..< filtersPersonsVC.persons!.count {
            let person = filtersPersonsVC.persons![i]
            if person.Id == filtersPersonsVC.selectedPersons![index].Id {
                filtersPersonsVC.persons![i].isSelectedInFilter = false
            }
        }
//        let cell = tableView.cellForRow(at: IndexPath(row:row, section:0)) as! FiltersPersonsTableViewCell
//
//        cell.viewModel.selected = !cell.viewModel.selected
//        if cell.viewModel.selected {
//            (cell.accessoryView as! UIButton).setImage(UIImage(named:"checkFilled"), for: .normal)
//        }else{
//
//            (cell.accessoryView as! UIButton).setImage(UIImage(named:"checkEmpty"), for: .normal)
//        }
        
        filtersPersonsVC.updateSelectedPersons()
        filtersPersonsVC.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
