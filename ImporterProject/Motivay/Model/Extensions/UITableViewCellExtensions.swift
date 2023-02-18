//
//  UITableViewCellExtensions.swift
//
//  Created by Yehia Elbehery.
//

import UIKit

extension UITableViewCell {
    
    var y_tableView: UITableView? {
        var view = self.superview
        while (view != nil && view!.isKind(of: UITableView.self) == false) {
            view = view!.superview
        }
        return view as? UITableView
    }
    
    func y_fullWidthSeparator(){
        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        
    }
}
