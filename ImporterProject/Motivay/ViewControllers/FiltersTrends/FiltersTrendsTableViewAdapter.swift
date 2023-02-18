//
//  FiltersTrendsTableViewAdapter.swift
//
//  Created by Yehia Elbehery.
//

import UIKit

class FiltersTrendsTableViewAdapter: TableViewAdapter {
    let cellName = "FiltersTrendsTableViewCell"
    
    override func didSetTableView() {
        
            let cellNib = UINib(nibName: cellName, bundle: nil)
            self.tableView.register(cellNib, forCellReuseIdentifier: cellName)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let filtersTrendsVC = delegate as! FiltersTrendsViewController
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellName) as! FiltersTrendsTableViewCell
        let hashtag = self.data[indexPath.row] as! Hashtag
//        var selected = false
//        if filtersTrendsVC.selectedHashtags != nil {
//            if filtersTrendsVC.selectedHashtags!.contains(where: { $0.Id == hashtag.Id}) {
//                selected = true
//            }
//        }
        cell.tag = indexPath.row
        cell.vc = filtersTrendsVC
        cell.viewModel = FiltersTrendsTableViewCell.ViewModel(_hashtag:hashtag, _selected: hashtag.isSelectedInFilter)
        
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
        
        let tipLabel = UILabel(frame:CGRect(x:tipLabelX, y:44+16, width:125, height:20))
        tipLabel.text = "Select Trend".y_localized
        tipLabel.font = UIFont(name: Constants.regularFont(), size: 14)
        
        let filtersTrendsVC = delegate as! FiltersTrendsViewController
        
        var number = 0
        if filtersTrendsVC.selectedHashtags != nil {
            number = filtersTrendsVC.selectedHashtags!.count
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
