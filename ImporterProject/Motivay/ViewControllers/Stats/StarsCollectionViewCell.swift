//
//  StarsCollectionViewCell.swift
//  Motivay
//
//  Created by Yasser Osama on 3/11/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit

class StarsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var userTitleLabel: AutomaticallyLocalizedLabel!
    @IBOutlet weak var valueNameLabel: AutomaticallyLocalizedLabel!
    
    @IBOutlet var starsDetails: [UIView]!
    @IBOutlet var rankLabels: [UILabel]!
    @IBOutlet var userImageViews: [UIImageView]!
    @IBOutlet var userNameLabels: [UILabel]!
    @IBOutlet var valueLabels: [ArabicNumbersLabel]!
    @IBOutlet var userImageButtons: [UIButton]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
