//
//  RewardsHorizontalCollectionViewCell.swift
//
//  Created by Yehia Elbehery.
//

import UIKit

class RewardsHorizontalCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var rewardImageView: UIImageView!
    @IBOutlet weak var redeemButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var delegate : RewardTableViewCell!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //        rewardImageView.clipsToBounds = true
        //        rewardImageView.layer.cornerRadius = 10
        //        if #available(iOS 11.0, *) {
        //            rewardImageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        //        } else {
        // Fallback on earlier versions
        let path = UIBezierPath(roundedRect: rewardImageView.bounds, byRoundingCorners: [.bottomRight, .bottomLeft], cornerRadii: CGSize(width: 10, height: 10))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        rewardImageView.layer.mask = mask
        redeemButton.setTitleColor(.primaryColor, for: .normal)
        //        }
    }
}
