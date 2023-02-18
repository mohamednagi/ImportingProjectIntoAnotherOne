//
//  ListOfBravosViewController.swift
//  Motivay
//
//  Created by Yasser Osama on 9/19/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit

class ListOfBravosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var bravosList = [BravoPerson]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(Fonts.bravo) said by".y_localized
        self.navigationController?.y_removeBackButtonTitle()
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bravosList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "saidBravoCell", for: indexPath) as! SaidBravoCell
        let person = bravosList[indexPath.row]
        cell.personFullNameLabel.text = person.fullName
        cell.personUserNameLabel.text = "@" + person.userName
        if (person.userImage) != nil {
            cell.personImageView.sd_setImage(with: URL(string: person.userImage), placeholderImage: #imageLiteral(resourceName: "profile"))
        } else {
            cell.personImageView?.image = #imageLiteral(resourceName: "profile")
        }
        cell.personImageView?.y_circularRoundedCorner()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let person = bravosList[indexPath.row]
        gotoProfile(withID: person.userId)
    }
    
    func gotoProfile(withID id: String) {
        Backend.getProfileDetails(withID: id, completion: { (employee, backendError) in
            if backendError != nil {
            } else {
                let profile = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Profile") as! MyProfileViewController
                profile.profileData = employee
                if id == UserSettings.info!.userID {
                    profile.myProfile = 1
                } else {
                    profile.myProfile = 0
                }
                self.navigationController?.pushViewController(profile, animated: true)
            }
        })
    }
}

class SaidBravoCell: UITableViewCell {
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personFullNameLabel: UILabel!
    @IBOutlet weak var personUserNameLabel: UILabel!
    
    override func awakeFromNib() {
        personFullNameLabel.font = UIFont(name: Constants.boldFont(), size: 14)
        personUserNameLabel.font = UIFont(name: Constants.regularFont(), size: 14)
    }
}
