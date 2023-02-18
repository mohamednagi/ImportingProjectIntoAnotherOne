//
//  RewardsSubcategoryTableViewAdapter.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import Alamofire

class RewardsSubcategoryTableViewAdapter: TableViewAdapter {
    let cellName = "RewardsSubcategoryTableViewCell"
    
    override func didSetTableView() {
        
            let rewardNib = UINib(nibName: cellName, bundle: nil)
            self.tableView.register(rewardNib, forCellReuseIdentifier: cellName)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellName) as! RewardsSubcategoryTableViewCell
        
        let rewardsSubcategoryVC = self.delegate as! RewardsSubcategoryViewController
        if rewardsSubcategoryVC.rewardsListType == .Redeemed {
            cell.isRedeemedVC = true
        }else{
            cell.isRedeemedVC = false
        }
        if let reward = data[indexPath.row] as? Reward {
            
            cell.reward = reward
        }
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        cell.redeemButton.addTarget(self, action: #selector(goToRewardDetails(sender:)), for: .touchUpInside)
        cell.bookmarkButton.addTarget(self, action: #selector(bookmark(sender:)), for: .touchUpInside)
        cell.redeemButton.tag = indexPath.row
        cell.bookmarkButton.tag = indexPath.row
        
        
        
        return cell
    }
    
    @objc func bookmark(sender: UIButton){
        let index = sender.tag
        
        let rewardsSubcategoryVC = self.delegate as! RewardsSubcategoryViewController
        if let reward = data[index] as? Reward {
            
            reward.IsBookmarked = !reward.IsBookmarked
            if rewardsSubcategoryVC.rewardsListType != .Bookmarked || reward.IsBookmarked == true {
                data[index] = reward
            }
            
//            tableView.reloadRows(at: [IndexPath(row:index, section:0)], with: .none)
            Backend.rewardBookmark(rewardId: reward.RewardId, completion: { (success, backendError) in
                if success == false {
//                    AlertUtility.showErrorAlert(Constants.errorMessage(.General_Failure))
                    
                    reward.IsBookmarked = !reward.IsBookmarked
                    self.data[index] = reward
//                    self.tableView.reloadRows(at: [IndexPath(row:index, section:0)], with: .none)
                }else{
                    if rewardsSubcategoryVC.rewardsListType == .Bookmarked && reward.IsBookmarked == false {
                        self.data.remove(at: index)
                    }
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 296
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 296
    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 64
//    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let returnedView = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:64))
//        returnedView.backgroundColor = UIColor(r:247, g:247, b:247)
//
//        if let rewardSubCategory = data[section] as? RewardSubCategory {
//            let titleLabel = UILabel(frame:CGRect(x:16, y:16, width:125, height:32))
//            titleLabel.text = rewardSubCategory.Name
//            titleLabel.font = UIFont(name: Constants.boldFont, size: 24)
//
//
//            let moreButton = AutomaticallyLocalizedButton(frame:CGRect(x:returnedView.frame.size.width - 85 - 16, y:16, width:85, height:32))
//            moreButton.setTitle("See All".y_localized, for: .normal)
//            moreButton.titleLabel?.font = UIFont(name: Constants.boldFont, size: 14)
//            moreButton.contentHorizontalAlignment = .right
//            moreButton.setTitleColor(.primaryColor, for: .normal)
//
//            returnedView.addSubview(titleLabel)
//            returnedView.addSubview(moreButton)
//        }
//
//        return returnedView
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return CGFloat.leastNormalMagnitude
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    //fix jumpy scrolling after reloading a single row problem
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cellHeights[indexPath] = cell.frame.size.height
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard let height = cellHeights[indexPath] else { return 204 }
//        return height
//    }
    
    
//    func gotoPostDetails(post:Post/*postId: Int*/, andComment: Bool = false){
//
//        let postDetails = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "PostDetails") as! PostDetailsViewController
//        //        postDetails.postId = postId
//        postDetails.post = post
//        postDetails.commentAddLaunch = andComment
//
//        if sourceView == 1 {
//            let homeVC = delegate as! HomeViewController
//            homeVC.navigationController?.pushViewController(postDetails, animated: true)
//        } else if sourceView == 2 {
//            let awardsVC = delegate as! MyAwardsViewController
//            awardsVC.navigationController?.pushViewController(postDetails, animated: true)
//        } else if sourceView == 3 {
//
//            if let myTrendsVC = ((delegate as? TrendDetailsViewController)?.delegate) {
//            myTrendsVC.navigationController?.pushViewController(postDetails, animated: true)
//            }
//        }
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
            rewardDetailsVC.reward = reward
            if reward.redemptionCode != nil {
                rewardDetailsVC.fromRedeemed = true
                rewardDetailsVC.redemptionCode = reward.redemptionCode
            } else {
            }
            (delegate as! RewardsSubcategoryViewController).navigationController?.pushViewController(rewardDetailsVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let reward = data[indexPath.row] as? Reward {
            goToRewardDetails(reward)
        }
    }
}
