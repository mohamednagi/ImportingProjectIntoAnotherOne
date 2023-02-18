//
//  RewardsHorizontalCollectionViewAdapter.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import Alamofire

class RewardsHorizontalCollectionViewAdapter: CollectionViewAdapter {
    let cellName = "RewardsHorizontalCollectionViewCell"
    
    override func didSetCollectionView() {
        
        let nib = UINib(nibName:cellName, bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier:cellName)
        
    }
}

extension RewardsHorizontalCollectionViewAdapter {
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! RewardsHorizontalCollectionViewCell
        
        if let reward = data[indexPath.row] as? Reward {
            cell.delegate = delegate as! RewardTableViewCell
            if reward.VendorImage == nil {
                cell.rewardImageView.sd_setImage(with: URL(string:"rectangle2"))
            }else{
                cell.rewardImageView.sd_setImage(with: URL(string:reward.VendorImage), placeholderImage:UIImage(named:"rectangle2"))
            }
            let x = Utilities.suffixNumber(number: NSNumber(integerLiteral: reward.RewardsPoints))
            cell.pointsLabel.text = x //"\(reward.RewardsPoints!)"
            cell.titleLabel.text = "\(reward.RewardName!)"
            if reward.VendorName != nil {
                cell.descriptionLabel.text = "\(reward.VendorName!)"
            }
            cell.redeemButton.addTarget(self, action: #selector(goToRewardDetails(sender:)), for: .touchUpInside)
        }
        return cell
    }
    
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 5
//    }
    
    @objc func goToRewardDetails(sender: UIButton) {
        let index = sender.tag
        
        if let reward = data[index] as? Reward {
             goToRewardDetails(reward)
        }
    }
    
    func goToRewardDetails(_ reward: Reward){
        
        if NetworkReachabilityManager()!.isReachable == false {
            AlertUtility.showConnectionError()
        } else {
        let rewardDetailsVC = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "RewardDetails") as! RewardDetailsViewController
        
//        dump(reward)
        rewardDetailsVC.reward = reward
        (delegate as! RewardTableViewCell).rewardsVC?.navigationController?.pushViewController(rewardDetailsVC, animated: true)
        }
    }

    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:200, height:184)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let reward = data[indexPath.row] as? Reward {
            goToRewardDetails(reward)
        }
    }
    
//    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
//        if scrollView.contentOffset.y < -70 { //change 100 to whatever you want
//
//            if (delegate as! FoodPostsViewController).canRefresh && !(delegate as! FoodPostsViewController).refreshControl.isRefreshing {
//
//                (delegate as! FoodPostsViewController).canRefresh = false
//                (delegate as! FoodPostsViewController).refreshControl.beginRefreshing()
//
//                (delegate as! FoodPostsViewController).loadData() // your viewController refresh function
//            }
//        }else if scrollView.contentOffset.y >= 0 {
//
//            (delegate as! FoodPostsViewController).canRefresh = true
//        }
    }
}
