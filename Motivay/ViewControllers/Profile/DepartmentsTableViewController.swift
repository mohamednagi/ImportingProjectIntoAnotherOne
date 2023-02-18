//
//  DepartmentsTableViewController.swift
//  Motivay
//
//  Created by Yasser Osama on 2/26/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit

class DepartmentsTableViewController: UITableViewController {

    //MARK: - Properties
    var delegate: DepartmentsSelectorDelegate? = nil
    var departments = [Department]()
    var selectedDepartment: Department?
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = .primaryColor
        
        Backend.getDepartments(completion: { (departments, backendError) in
            if departments == nil {
                
            } else {
                self.departments = departments!
                self.tableView.reloadData()
            }
        })
        
        tableView.tableFooterView = UIView()
        if UserSettings.appLanguageIsArabic() {
            self.navigationItem.title = "Departments".y_localized//Dept.".y_localized
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.navigationController?.navigationBar.layer.shadowRadius = 0
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "departmentsCell", for: indexPath)
        cell.textLabel?.text = departments[indexPath.row].Name
        
        if departments[indexPath.row].Id == selectedDepartment?.Id {
            cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "checkMark"))
        }
        
        if UserSettings.appLanguageIsArabic() {
            cell.textLabel?.textAlignment = .right
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.departmentsSelected(_departments: [departments[indexPath.row]])
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

}

extension UINavigationBar {
    
    func setBottomBorderColor(color: UIColor, height: CGFloat) {
        let bottomBorderRect = CGRect(x: 0, y: frame.height, width: frame.width, height: height)
        let bottomBorderView = UIView(frame: bottomBorderRect)
        bottomBorderView.backgroundColor = color
        addSubview(bottomBorderView)
    }
}
