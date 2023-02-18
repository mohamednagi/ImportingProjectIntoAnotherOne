//
//  ChangeProfileImageTableViewCell.swift
//  Motivay
//
//  Created by Yasser Osama on 2/22/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit

class ChangeProfileImageTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imageFrameImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var changePhotoView: UIStackView!
    @IBOutlet weak var changePhotoLabel: AutomaticallyLocalizedLabel!
    @IBOutlet weak var removePhotoView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        changePhotoLabel.textColor = .primaryColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
