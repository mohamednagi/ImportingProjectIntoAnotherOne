//
//  SocialMediaTableViewCell.swift
//  Motivay
//
//  Created by Yasser Osama on 2/24/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit

class SocialMediaTableViewCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var linkTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        linkButton.setTitleColor(.primaryColor, for: .normal)
        changeButton.setTitleColor(.primaryColor, for: .normal)
        if UserSettings.appLanguageIsArabic() {
            linkTextField.textAlignment = .right
        } else {
            linkTextField.textAlignment = .left
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func linkAction(_ sender: UIButton) {
        linkButton.isHidden = true
        linkTextField.isHidden = false
        linkTextField.becomeFirstResponder()
    }
    
    @IBAction func changeAction(_ sender: UIButton) {
        linkTextField.isEnabled = true
        linkTextField.becomeFirstResponder()
        changeButton.isHidden = true
    }
}
