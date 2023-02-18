//
//  EditProfileTableViewCell.swift
//  Motivay
//
//  Created by Yasser Osama on 2/22/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit

class EditProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if UserSettings.appLanguageIsArabic() {
            titleTextField.textAlignment = .right
        } else {
            titleTextField.textAlignment = .left
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
