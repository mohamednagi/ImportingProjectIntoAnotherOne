//
//  TopTrendsCollectionViewCell.swift
//  Motivay
//
//  Created by Yasser Osama on 3/11/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit

class TopTrendsCollectionViewCell: UICollectionViewCell {

    //MARK: Outlets
    @IBOutlet weak var trendImageView: UIImageView!
    @IBOutlet weak var trendNameLabel: AutomaticallyLocalizedLabel!
    @IBOutlet weak var numberOfPostsLabel: ArabicNumbersLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
