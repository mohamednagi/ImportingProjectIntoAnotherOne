//
//  FiltersDepartmentsTableViewAdapter.swift
//
//  Created by Yehia Elbehery.
//

import UIKit

class FiltersDepartmentsTableViewAdapter: TableViewAdapter {
    let cellName = "FiltersDepartmentsTableViewCell"
    
    override func didSetTableView() {
        
            let cellNib = UINib(nibName: cellName, bundle: nil)
            self.tableView.register(cellNib, forCellReuseIdentifier: cellName)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let filtersDepartmentsVC = delegate as! FiltersDepartmentsViewController
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellName) as! FiltersDepartmentsTableViewCell
        let department = self.data[indexPath.row] as! Department
//        var selected = false
//        if filtersDepartmentsVC.selectedDepartments != nil {
//            DeveloperTools.print("selected departments::", department.Name)
//            dump(filtersDepartmentsVC.selectedDepartments!)
//            if filtersDepartmentsVC.selectedDepartments!.contains(where: {$0.Id == department.Id}) {
//                selected = true
//            }
//        }
        
        cell.tag = indexPath.row
        cell.vc = delegate as! FiltersDepartmentsViewController
        cell.viewModel = FiltersDepartmentsTableViewCell.ViewModel(_department:department, _selected: department.isSelectedInFilter)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44+52
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let returnedView = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:44+52))
        returnedView.backgroundColor = .white
        
        var tipLabelX = 16
        var numberLabelX = returnedView.frame.size.width - 75 - 16
        if UserSettings.appLanguageIsArabic() {
            tipLabelX = Int(returnedView.frame.size.width - 125 - 16)
            numberLabelX = 16
        }
        
        let tipLabel = AutomaticallyLocalizedLabel(frame:CGRect(x:tipLabelX, y:44+16, width:125, height:20))
        tipLabel.text = "Select department".y_localized
        tipLabel.font = UIFont(name: Constants.regularFont(), size: 14)
        
        let filtersDepartmentsVC = delegate as! FiltersDepartmentsViewController
        
        var number = 0
        if filtersDepartmentsVC.selectedDepartments != nil {
            number = filtersDepartmentsVC.selectedDepartments!.count
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
