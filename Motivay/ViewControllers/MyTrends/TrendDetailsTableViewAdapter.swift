//
//  TrendDetailsTableViewAdapter.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import AVFoundation

class TrendDetailsTableViewAdapter : HomeTableViewAdapter {
    let myTrendsHeaderCellName = "MyTrendsHeaderTableViewCell"
    
    override func didSetTableView() {
        super.didSetTableView()
        let postNib = UINib(nibName: myTrendsHeaderCellName, bundle: nil)
        self.tableView.register(postNib, forCellReuseIdentifier: myTrendsHeaderCellName)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*if indexPath.section == 0 {
            let vc = delegate as! TrendDetailsViewController
            let cell = self.tableView.dequeueReusableCell(withIdentifier: myTrendsHeaderCellName) as! MyTrendsHeaderTableViewCell
            cell.hashtagTitleLabel.text = vc.myTrend.Name
            cell.taggedTimesLabel.text = "\(vc.myTrend.TaggedTime!)"
            cell.totalPointsLabel.text = "\(vc.myTrend.TotalPoints!)"
            cell.thisMonthLabel.text = "\(vc.myTrend.PointsPerMonth!)"
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            cell.backgroundColor = .clear
            
            return cell
        }else{*/
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
//            cell.clipsToBounds = true
            cell.backgroundColor = .clear
            cell.selectionStyle = .default
            return cell
        //}
    }
    
    /*func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 127
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let trendDetailsHeader = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "TrendDetailsHeader") as! TrendDetailsHeaderViewController
//            let view = UIView(frame:CGRect(x:0, y:0, width:tableView.frame.size.width, height:127))
            
            trendDetailsHeader.view!.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            trendDetailsHeader.view!.addSubview(blurEffectView)
//            trendDetailsHeader.view!.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
            return trendDetailsHeader.view!
            
        }
        return UIView()
    }*/
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1//2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return 1
//        }else{
            return super.tableView(tableView, numberOfRowsInSection: section)
//        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            return 127
//        }else{
            if let post = data[indexPath.row] as? Post {
                
                if post.ImagePost != nil {
                    return 213/* - 44 */+ 158 + 4
                }
            }
            return 213/* - 44*/
//        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        DeveloperTools.print("did select")
//        if indexPath.section == 1 {
        if let post = data[indexPath.row] as? Post {
            gotoPostDetails(post:post/*postId: post.PostId*/)
        }
//        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let vc = delegate as! TrendDetailsViewController
        /*if scrollView.contentOffset.y < -10 {
            vc.delegate.title = "My Trends".y_localized
            vc.delegate.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: Constants.boldFont, size: 17)!, NSAttributedStringKey.foregroundColor : UIColor.black]

        }else if (tableView.isScrollEnabled == true) {
            vc.delegate.title = vc.myTrend.Name
            vc.delegate.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: Constants.boldFont, size: 17)!, NSAttributedStringKey.foregroundColor : UIColor.primaryColor]

        }*/
        if scrollView.contentOffset.y < -50 {
            tableView.isScrollEnabled = false
            vc.delegate.trendDetailsDraggable()
        }
    }
}
