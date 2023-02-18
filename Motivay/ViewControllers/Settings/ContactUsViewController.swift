//
//  ContactUsViewController.swift
//  Motivay
//
//  Created by Yasser Osama on 3/13/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit
import MessageUI

class ContactUsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var contactUsTableView: UITableView!
    
    let images = [#imageLiteral(resourceName: "mail"), #imageLiteral(resourceName: "phone")] //[#imageLiteral(resourceName: "web"), 
//    let titles = ["kafu@thiqah.sa", "+966 50 011 8867"]
    var titles = ["info@youxel.com", "+9665 370 97017"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Contact us".y_localized
        contactUsTableView.tableFooterView = UIView()
        #if THIQAH
        titles = ["kafu@thiqah.sa", "+966 50 011 8867"]
        #endif
    }
    
    func sendMail(to: String) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        composeVC.setToRecipients([to])
        
        self.present(composeVC, animated: true, completion: nil)
    }
    
    //MARK: - MFMailComposeView Delegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ContactUsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactUsCell", for: indexPath) as! contactUsCell
        cell.cImageView.image = images[indexPath.row]
        
        if indexPath.row == 0 {
            cell.firstLabel.text = titles[indexPath.row]
            cell.secondLabel.isHidden = true
        } else if indexPath.row == 1 {
            cell.firstLabel.text = titles[indexPath.row]
//            cell.secondLabel.text = titles[indexPath.row + 1]
            cell.secondLabel.isHidden = true
        } else if indexPath.row == 2 {
//            cell.firstLabel.text = titles[indexPath.row + 1]
//            cell.secondLabel.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let mail = titles[0]
            sendMail(to: mail)
        } else if indexPath.row == 1 {
            let numberString = titles[1].replacingOccurrences(of: " ", with: "")
            if let url = URL(string: "tel://" + numberString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

class contactUsCell: UITableViewCell {
    
    @IBOutlet weak var cImageView: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
}
