//
//  RewardTableViewCell.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import SDWebImage

class RewardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var rewardsHorizontalCollectionViewAdapter : RewardsHorizontalCollectionViewAdapter!
    
    var rewards: [Reward] = [] {
        didSet {
            rewardsHorizontalCollectionViewAdapter.data = rewards
        }
    }
    var rewardsVC : RewardsViewController!
//    var postDetailsVC: PostDetailsViewController?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        rewardsHorizontalCollectionViewAdapter = RewardsHorizontalCollectionViewAdapter(collectionView:self.collectionView, delegate:self, dataSource: self)
        
        let tableBackgroundView = UIView(frame:collectionView.frame)
        tableBackgroundView.backgroundColor = .whiteTwo
        self.collectionView.backgroundView = tableBackgroundView
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension RewardTableViewCell : CollectionViewAdapterDelegate, CollectionViewAdapterDataSource {
    
}
