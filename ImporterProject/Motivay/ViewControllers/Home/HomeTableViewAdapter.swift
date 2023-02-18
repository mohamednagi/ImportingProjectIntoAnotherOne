//
//  HomeTableViewAdapter.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import AVFoundation
import Lottie

class HomeTableViewAdapter: TableViewAdapter {
    let cellName = "PostTableViewCell"
    var searchTerm: String?
    var sourceView = 0
    
    var cachedResizedInPostContentUserImages = [String: UIImage]()
    
    var cellHeights: [IndexPath : CGFloat] = [:]
    
    var player: AVAudioPlayer?
    
    override func didSetTableView() {
        
            let postNib = UINib(nibName: cellName, bundle: nil)
            self.tableView.register(postNib, forCellReuseIdentifier: cellName)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellName) as! PostTableViewCell
        cell.contentTruncate = true
        
        if let post = data[indexPath.row] as? Post {
            cell.tag = indexPath.row
            cell.viewModel = PostTableViewCell.ViewModel(post:post, _searchTerm: searchTerm)
//            cell.bravoButton.removeTarget(delegate as! HomeViewController, action: #selector(HomeViewController.sayBravo), for: .touchUpInside)
//            if post.IsAllowedForBravo {
//                cell.bravoButton.addTarget(delegate as! HomeViewController, action: #selector(HomeViewController.sayBravo), for: .touchUpInside)
//                
//                cell.bravoImageView.alpha = 1.0
//            }else{
//               cell.bravoImageView.alpha = 0.2
//            }
//            cell.bravoButton.tag = indexPath.row
            cell.userImageButton.addTarget(self, action: #selector(profile(_:)), for: .touchUpInside)
            cell.userImageButton.tag = indexPath.row
            
            cell.userFullNameButton.addTarget(self, action: #selector(profile(_:)), for: .touchUpInside)
            cell.userFullNameButton.tag = indexPath.row
            
            
//            if post.ToUserId != UserSettings.info?.userID {
                cell.commentButton.addTarget(self, action: #selector(comment), for: .touchUpInside)
                
//                cell.commentImageView.alpha = 1.0
//            }else{
//                cell.commentImageView.alpha = 0.2
//            }
            cell.commentButton.tag = indexPath.row
            cell.selectionStyle = .none
            
//            let homeVC = delegate as! HomeViewController
//            cell.homeVC = delegate as! HomeViewController
            
            cell.bravoButton.removeTarget(self, action: #selector(sayBravo), for: .touchUpInside)
            cell.bravoButton.tag = indexPath.row
            if post.IsAllowedForBravo {
                DeveloperTools.print("allowed")
                cell.bravoButton.addTarget(self, action: #selector(sayBravo), for: .touchUpInside)
                
                cell.bravoImageView.alpha = 1.0
            } else {
                cell.bravoImageView.alpha = 0.2
            }
            
            updateSayBravoButton(atCell: cell)

            cell.postContentLabel.lineBreakMode = .byTruncatingTail
            
            cell.postContentLabel.isUserInteractionEnabled = true
            cell.postContentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(tap:))))
            cell.postContentLabel.tag = indexPath.row
            
//            if post.FromUserId == UserSettings.info!.userID {
//                cell.moreButton.isHidden = false
//            }else{
//                cell.moreButton.isHidden = true
//            }
            cell.bravoCommentHomeView.isHidden = false
            cell.bravoCommentDetailsView.isHidden = true
        }
        cell.delegate = self
        return cell
    }
    
    @objc func tapLabel(tap: UITapGestureRecognizer) {
        
        tap.cancelsTouchesInView = true
        let label = tap.view as! UILabel
        let index = label.tag
        if let post = data[index] as? Post {
        let indexOfCharacter = tap.getTappedCharacterIndexInLabel()
            if let indexOfCharacter = indexOfCharacter {
        
                DeveloperTools.print("char index:", indexOfCharacter)
                var attachmentFound = false
        label.attributedText!.enumerateAttribute(NSAttributedStringKey.attachment, in: NSRange(location: indexOfCharacter, length: 1), options: []) { (value, range, stop) in
            if value != nil {
                attachmentFound = true
                return
            }
        }
                if attachmentFound {
                    
                    tap.cancelsTouchesInView = true
                    gotoProfile(withID: post.ToUserId)
                    return
                }
                let tappedWord = label.attributedText!.string.y_wordAtIndex(indexOfCharacter)
        if tappedWord != nil {
            DeveloperTools.print("tapped:", tappedWord, " == ", "@\(post.To!)")
                if tappedWord == "@\(post.To!)" {
                    
                    gotoProfile(withID: post.ToUserId)
                    
                    return
                }
        }
            }
            tap.cancelsTouchesInView = false
        }
    }

    
    @objc func sayBravo(_ sender: UIButton){
        DeveloperTools.print("say bravo")
        let index = sender.tag
        
        self.toggleBravo(index: index)
        sender.isEnabled = false
        
        DeveloperTools.print("after toggle")
        if sourceView == 1 {
            let homeVC = delegate as! HomeViewController
            
            Backend.sayBravo(postId: homeVC.posts[index].PostId, isBravo: homeVC.posts[index].iSaidBravo, completion: { response, backendError in
                sender.isEnabled = true
                if backendError == .connection {
                    
                    self.toggleBravo(index: index, withSound: false)
                }else{
                    
                }
            })
        } else if sourceView == 2 {
            let awardsVC = delegate as! MyAwardsViewController
            
            Backend.sayBravo(postId: awardsVC.posts[index].PostId, isBravo: awardsVC.posts[index].iSaidBravo, completion: { response, backendError in
                sender.isEnabled = true
                if backendError == .connection {
                    
                    self.toggleBravo(index: index, withSound: false)
                }else{
                    
                }
            })
        } else if sourceView == 3 {
            if let trendDetails = (delegate as? TrendDetailsViewController) {
            
            Backend.sayBravo(postId: trendDetails.posts[index].PostId, isBravo: trendDetails.posts[index].iSaidBravo, completion: { response, backendError in
                sender.isEnabled = true
                if backendError == .connection {
                    
                    self.toggleBravo(index: index, withSound: false)
                }else{
                    
                }
            })
            }
        }

        DeveloperTools.print("after all")
    }
    
    
    func toggleBravo(index: Int, withSound: Bool = true){
        
        if sourceView == 1 {
            let homeVC = delegate as! HomeViewController
            homeVC.posts[index].iSaidBravo = !homeVC.posts[index].iSaidBravo
            //        let cell = tableView.cellForRow(at: IndexPath(row:index, section:0)) as! PostTableViewCell
            
            if homeVC.posts[index].iSaidBravo == false {
                
                homeVC.posts[index].NumberOfSayBravo = homeVC.posts[index].NumberOfSayBravo - 1
                /*cell.bravoLabel.text = "\(homeVC.posts[index].iSaidBravo) " + "Say Bravo".y_localized
                 cell.bravoLabel.font = UIFont(name:Constants.regularFont, size:12)
                 cell.bravoImageView.image = UIImage(named:"clap")*/
                self.tableView.reloadRows(at:[IndexPath(row:index, section:0)], with: .none)
            } else {
                homeVC.posts[index].NumberOfSayBravo = homeVC.posts[index].NumberOfSayBravo + 1
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.tableView.reloadRows(at:[IndexPath(row:index, section:0)], with: .none)
//                }
                if withSound {
                    self.playSuccessSound(at: index)
                }
                /*cell.bravoLabel.text = "\(homeVC.posts[index].NumberOfSayBravo!) " + "Awesome!".y_localized
                 cell.bravoLabel.font = UIFont(name:Constants.boldFont, size:12)
                 cell.bravoImageView.image = UIImage(named:"clap-1")*/
                //            cell.bravoImageView.image = UIImage.gifImageWithName("clapAnimated")
                //            self.perform(#selector(gifAnimationEnded(cell:)), with: cell, afterDelay: (45 * 100)/1000)
            }
            
//            updateSayBravoButton(atIndexPath: IndexPath(row:index, section:0))
            
        } else if sourceView == 2 {
            let awardsVC = delegate as! MyAwardsViewController
            awardsVC.posts[index].iSaidBravo = !awardsVC.posts[index].iSaidBravo
            
            if awardsVC.posts[index].iSaidBravo == false {
                
                awardsVC.posts[index].NumberOfSayBravo = awardsVC.posts[index].NumberOfSayBravo - 1
                self.tableView.reloadRows(at:[IndexPath(row:index, section:0)], with: .none)
            } else {
                
                awardsVC.posts[index].NumberOfSayBravo = awardsVC.posts[index].NumberOfSayBravo + 1
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.tableView.reloadRows(at:[IndexPath(row:index, section:0)], with: .none)
//                }
                if withSound {
                    self.playSuccessSound(at: index)
                }
            }
            
//            updateSayBravoButton(atIndexPath: IndexPath(row:index, section:0))
            
        } else if sourceView == 3 {
            if let trendDetails = (delegate as? TrendDetailsViewController) {
            trendDetails.posts[index].iSaidBravo = !trendDetails.posts[index].iSaidBravo
            
            if trendDetails.posts[index].iSaidBravo == false {
                
                 trendDetails.posts[index].NumberOfSayBravo = trendDetails.posts[index].NumberOfSayBravo - 1
                self.tableView.reloadRows(at:[IndexPath(row:index, section:0)], with: .none)
            } else {
                trendDetails.posts[index].NumberOfSayBravo = trendDetails.posts[index].NumberOfSayBravo + 1
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.tableView.reloadRows(at:[IndexPath(row:index, section:0)], with: .none)
//                }
                if withSound {
                    self.playSuccessSound(at: index)
                }
            }
        }
//            updateSayBravoButton(atIndexPath: IndexPath(row:index, section:1))
        }

//        var cellsToReload = [IndexPath(row:index, section:0)]        for i in 1 ..< 3 {
//            if self.tableView.numberOfRows(inSection: 0) > index+i {
//                cellsToReload.append(IndexPath(row:index+i, section:0))
//            }
//        }
        //weired bottm cell glitch fix
    }
    
    func updateSayBravoButton(atIndexPath: IndexPath){
        DeveloperTools.print("update without reload")
        let cell = tableView(self.tableView, cellForRowAt: atIndexPath) as! PostTableViewCell
        updateSayBravoButton(atCell: cell)
    }
    
    func updateSayBravoButton(atCell cell: PostTableViewCell){
        
        DispatchQueue.main.async {
        if let post = self.data[cell.tag] as? Post {
            
            if post.iSaidBravo == false {
                cell.bravoLabel.text = "\(post.NumberOfSayBravo!) " + Fonts.sayBravo.y_localized
                cell.bravoLabel.textColor = .battleshipGrey
//                cell.bravoLabel.font = UIFont(name:Constants.regularFont, size:12)
                cell.bravoImageView.image = UIImage(named:"clap")
            } else {
                
                cell.bravoLabel.text = "\(post.NumberOfSayBravo!) " + Fonts.awesome.y_localized
                cell.bravoLabel.textColor = .primaryColor
//                cell.bravoLabel.font = UIFont(name:Constants.boldFont, size:12)
                cell.bravoImageView.image = UIImage(named:"clap-1")
                
            }
            }
        }
    }
    
    func playSuccessSound(at row: Int) {
        //        self.player.removeAllItems()
        //        self.player.insert(AVPlayerItem(url: successSoundUrl!), after: nil)
        //        DeveloperTools.print("calling playsound")
        //        self.player.play()
        
        let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! PostTableViewCell
        cell.bravoAnimationView.isHidden = false
        #if GAZT
        #else
        cell.bravoAnimationView.animation = Animation.named("hand")
        #endif
//        cell.bravoAnimationView.setAnimation(named: "hand")
        cell.bravoAnimationView.play(completion: { (finished) in
            cell.bravoAnimationView.isHidden = true
        })
        
        guard let url = Bundle.main.url(forResource: "success_2", withExtension: "m4a") else { return }
        
        do {
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient, with: AVAudioSessionCategoryOptions.mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            if AVAudioSession.sharedInstance().outputVolume > 0 {
                player.play()
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /*@objc func gifAnimationEnded(cell: PostTableViewCell){
        cell.bravoImageView.image = UIImage(named:"clap-1")
    }*/
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let post = data[indexPath.row] as? Post {
            
            if post.ImagePost != nil {
                return 213 + 158 + 4
            }
        }
        return 213
    }
    
    //fix jumpy scrolling after reloading a single row problem
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = cellHeights[indexPath] else { return 213 }
        return height
    }
    
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
    
    @objc func comment(_ sender: UIButton){
        let index = sender.tag
        if let post = data[index] as? Post {
            gotoPostDetails(post:post/*postId: post.PostId*/, andComment: true)
        }
    }
    
    func gotoPostDetails(post:Post/*postId: Int*/, andComment: Bool = false){
        
        let postDetails = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "PostDetails") as! PostDetailsViewController
        //        postDetails.postId = postId
        postDetails.post = post
        postDetails.commentAddLaunch = andComment
        LoadingOverlay.shared.showOverlay()
        if sourceView == 1 {
            let homeVC = delegate as! HomeViewController
            homeVC.navigationController?.pushViewController(postDetails, animated: true)
        } else if sourceView == 2 {
            let awardsVC = delegate as! MyAwardsViewController
            awardsVC.navigationController?.pushViewController(postDetails, animated: true)
        } else if sourceView == 3 {
            
            if let myTrendsVC = ((delegate as? TrendDetailsViewController)?.delegate) {
            myTrendsVC.navigationController?.pushViewController(postDetails, animated: true)
            }
        }
    }
    
    @objc func profile(_ sender: UIButton) {
        let index = sender.tag
        if let post = data[index] as? Post {
            gotoProfile(withID: post.FromUserId)
        }
    }
    
    func gotoProfile(withID id: String) {
        Backend.getProfileDetails(withID: id, completion: { (employee, backendError) in
            if backendError != nil {
                
            } else {
                let profile = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Profile") as! MyProfileViewController
                profile.profileData = employee
                if id == UserSettings.info!.userID {
                    profile.myProfile = 1
                } else {
                    profile.myProfile = 0
                }
                if self.sourceView == 1 {
                    let homeVC = self.delegate as! HomeViewController
                    homeVC.navigationController?.pushViewController(profile, animated: true)
                } else if self.sourceView == 2 {
                    let awardsVC = self.delegate as! MyAwardsViewController
                    awardsVC.navigationController?.pushViewController(profile, animated: true)
                } else if self.sourceView == 3 {
                    
                    if let myTrendsVC = ((self.delegate as? TrendDetailsViewController)?.delegate) {
                        myTrendsVC.navigationController?.pushViewController(profile, animated: true)
                    }
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let post = data[indexPath.row] as? Post {
            gotoPostDetails(post:post/*postId: post.PostId*/)
        }
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
