//
//  HomePlaceholderTableViewAdapter.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import AVFoundation

class HomePlaceholderTableViewAdapter: TableViewAdapter {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = UITableViewCell()
        let imageView = UIImageView()
        
        var frame = cell.frame
        frame.origin.y = 26
        imageView.frame = frame
        
        if UserSettings.appLanguageIsArabic() {
            imageView.image = UIImage.gifImageWithName("loader-arabic")
        }else{
            imageView.image = UIImage.gifImageWithName("Motivay-Skeleton")
        }
        imageView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        cell.addSubview(imageView)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Utilities.screedWidth() / 750 * 1072
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    //fix jumpy scrolling after reloading a single row problem
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cellHeights[indexPath] = cell.frame.size.height
//    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return Utilities.screedWidth() * 750 / 1072
//    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if section == tableView.numberOfSections - 1 {
//            return 44
//        }else{
//            return 0
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        
//        if section == tableView.numberOfSections - 1 {
//            
//            let returnedView = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:44))
//            returnedView.backgroundColor = .white
//            
//            return returnedView
//        }else{
//            return UIView()
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
//    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
//        if section == tableView.numberOfSections - 1 {
//            let homeVC = delegate as! HomeViewController
//            DeveloperTools.print("load more", homeVC.loading, "m", homeVC.noMorePosts)
//            if homeVC.noMorePosts == false && homeVC.loading == false {
//                DeveloperTools.print("load more")
//                homeVC.loadMoreData()
//            }
//        }
//    }
}
