//
//  RewardsTableViewAdapter.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import Alamofire

class RewardsTableViewAdapter: TableViewAdapter {
    let cellName = "RewardTableViewCell"
    
    override func didSetTableView() {
        
            let rewardNib = UINib(nibName: cellName, bundle: nil)
            self.tableView.register(rewardNib, forCellReuseIdentifier: cellName)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellName) as! RewardTableViewCell
        if UserSettings.appLanguageIsArabic() {
//            cell.collectionView.sc
        }
        
        if let rewardSubCategory = data[indexPath.section] as? RewardsSubCategory {
            
            cell.rewards = rewardSubCategory.RewardsList
            cell.rewardsVC = delegate as! RewardsViewController
        }
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 194
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let returnedView = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:64))
        returnedView.backgroundColor = .whiteTwo
        
        if let rewardSubCategory = data[section] as? RewardsSubCategory {
            
            var titleLabelX = 16
            var moreX = returnedView.frame.size.width - 85 - 16
            if UserSettings.appLanguageIsArabic() {
                titleLabelX = Int(returnedView.frame.size.width - 250 - 16)
                moreX = 16
            }
            let titleLabel = AutomaticallyLocalizedLabel(frame:CGRect(x:titleLabelX, y:16, width:250, height:32))
            titleLabel.text = rewardSubCategory.RewarTypedName
            titleLabel.font = UIFont(name: Constants.boldFont(), size: 24)
            
            
            let moreButton = AutomaticallyLocalizedButton(frame:CGRect(x:moreX, y:16, width:85, height:32))
            moreButton.setTitle("See All".y_localized, for: .normal)
            moreButton.titleLabel?.font = UIFont(name: Constants.boldFont(), size: 14)
            moreButton.contentHorizontalAlignment = .right
            moreButton.setTitleColor(.primaryColor, for: .normal)
            moreButton.tag = section
            moreButton.addTarget(self, action: #selector(goToRewardSubcategory), for: .touchUpInside)
            
            returnedView.addSubview(titleLabel)
            returnedView.addSubview(moreButton)
        }
        
        return returnedView
    }
    
    @objc func goToRewardSubcategory(sender: UIButton) {
        
        if NetworkReachabilityManager()!.isReachable == false {
            AlertUtility.showConnectionError()
        } else {
        let index = sender.tag
        
        if let rewardsSubCategory = data[index] as? RewardsSubCategory {
            let rewardsSubcategoryVC = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "RewardsSubcategory") as! RewardsSubcategoryViewController
            rewardsSubcategoryVC.rewardsSubCategory = rewardsSubCategory
            (delegate as! RewardsViewController).navigationController?.pushViewController(rewardsSubcategoryVC, animated: true)
        }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.data.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        if let post = data[indexPath.row] as? Post {
//            gotoPostDetails(post:post/*postId: post.PostId*/)
//        }
//    }
}
