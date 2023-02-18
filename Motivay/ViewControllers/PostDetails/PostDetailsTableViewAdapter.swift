//
//  PostDetailsTableViewAdapter.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import AVFoundation
import SDWebImage
import Lottie

class PostDetailsTableViewAdapter: TableViewAdapter {
    let postCellName = "PostTableViewCell"
    let commentCellName = "PostCommentTableViewCell"
    
    var player: AVAudioPlayer?
    var cachedResizedInPostContentUserImages = [String: UIImage]()
    
    override func didSetTableView() {
        
            let postNib = UINib(nibName: postCellName, bundle: nil)
            self.tableView.register(postNib, forCellReuseIdentifier: postCellName)
        
        
        let commentNib = UINib(nibName: commentCellName, bundle: nil)
        self.tableView.register(commentNib, forCellReuseIdentifier: commentCellName)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let postDetailsVC = delegate as! PostDetailsViewController
        
        if indexPath.section == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: postCellName) as! PostTableViewCell
            if let post = postDetailsVC.post {
                
                
                cell.viewModel = PostTableViewCell.ViewModel(post:post, _searchTerm: "")
//                if post.IsAllowedForBravo {
//                    cell.bravoButton.addTarget(delegate as! PostDetailsViewController, action: #selector(PostDetailsViewController.sayBravo), for: .touchUpInside)
//                    cell.bravoImageView.alpha = 1.0
//                }else{
//                    
//                    cell.bravoImageView.alpha = 0.2
//                }
//
//                cell.bravoButton.tag = indexPath.row
                
//                cell.commentButton.removeTarget(self, action: #selector(comment), for: .touchUpInside)
                
                cell.userImageButton.addTarget(self, action: #selector(profile), for: .touchUpInside)
                cell.userFullNameButton.addTarget(self, action: #selector(profile), for: .touchUpInside)
                
                if post.ToUserId != UserSettings.info?.userID {
                    cell.commentButton.addTarget(self, action: #selector(comment), for: .touchUpInside)
                    cell.commentDetailsButton.addTarget(self, action: #selector(comment), for: .touchUpInside)
                    cell.commentImageView.alpha = 1.0
                }else{
//                    cell.commentImageView.alpha = 0.2
                }
                
                cell.selectionStyle = .none
                
                cell.bravoButton.removeTarget(self, action: #selector(sayBravo), for: .touchUpInside)
                cell.bravoDetailsButton.removeTarget(self, action: #selector(sayBravo), for: .touchUpInside)
                if post.IsAllowedForBravo {
                    cell.bravoButton.addTarget(self, action: #selector(sayBravo), for: .touchUpInside)
                    cell.bravoDetailsButton.addTarget(self, action: #selector(sayBravo), for: .touchUpInside)
                    cell.bravoImageView.alpha = 1.0
                } else {
                    cell.bravoImageView.alpha = 0.2
                }
                
                if post.iSaidBravo == false {
                    cell.bravoDetailsLabel.text = Fonts.sayBravo.y_localized
                    cell.bravoDetailsLabel.textColor = .battleshipGrey
                    cell.bravoDetailsLabel.font = UIFont(name:Constants.regularFont(), size:12)
                    cell.bravoDetailsImageView.image = UIImage(named:"clap")
                } else {
                    cell.bravoDetailsLabel.text = Fonts.awesome.y_localized
                    cell.bravoDetailsLabel.textColor = .primaryColor
                    cell.bravoDetailsLabel.font = UIFont(name:Constants.boldFont(), size:12)
                    cell.bravoDetailsImageView.image = UIImage(named:"clap-1")
                }
                cell.commentDetailsLabel.textColor = .primaryColor
                
                cell.numberOfBravosLabel.textColor = .battleshipGrey
                cell.numberOfBravosLabel.font = UIFont(name:Constants.regularFont(), size:12)
                if post.NumberOfSayBravo == 1 {
                    if UserSettings.appLanguageIsArabic() {
                        cell.numberOfBravosLabel.text = "\(post.NumberOfSayBravo!) " + Fonts.bravos.y_localized
                    } else {
                        cell.numberOfBravosLabel.text = "\(post.NumberOfSayBravo!) " + Fonts.bravo
                    }
                } else {
                    cell.numberOfBravosLabel.text = "\(post.NumberOfSayBravo!) " + Fonts.bravos.y_localized
                }
                cell.numberOfBravosButton.addTarget(self, action: #selector(bravosList(_:)), for: .touchUpInside)
            }
            cell.bravoCommentHomeView.isHidden = true
            cell.bravoCommentDetailsView.isHidden = false
            cell.postContentLabel.isUserInteractionEnabled = true
            cell.postContentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(tap:))))
            cell.postContentLabel.tag = indexPath.row
            cell.delegate = self
            
            return cell
        } else {
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: commentCellName) as! PostCommentTableViewCell
            
            if let postComment = data[indexPath.row] as? PostComment {
//                dump(postComment)
                cell.parentAdapter = self
                cell.tag = indexPath.row
                cell.viewModel = PostCommentTableViewCell.ViewModel(postComment:postComment, _post:postDetailsVC.post)
                cell.userImageButton.addTarget(self, action: #selector(commentProfile(_:)), for: .touchUpInside)
                cell.userImageButton.tag = indexPath.row
                cell.userFullNameButton.addTarget(self, action: #selector(commentProfile(_:)), for: .touchUpInside)
                cell.userFullNameButton.tag = indexPath.row
                
                if postComment.From == UserSettings.info!.Id {
                    cell.moreButton.isHidden = false
                    cell.moreButton.addTarget(self, action: #selector(moreTapped(_:)), for: .touchUpInside)
                    cell.moreButton.tag = indexPath.row
                } else {
                    cell.moreButton.isHidden = true
                }
                
                cell.postCommentContentLabel.isUserInteractionEnabled = true
                cell.postCommentContentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapCommentLabel(tap:))))
                cell.postCommentContentLabel.tag = indexPath.row
            }
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    
    @objc func tapLabel(tap: UITapGestureRecognizer) {
        
        let postDetailsVC = delegate as! PostDetailsViewController
        tap.cancelsTouchesInView = true
        let label = tap.view as! UILabel
        let index = label.tag
        if let post = postDetailsVC.post {
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
    
    @objc func tapCommentLabel(tap: UITapGestureRecognizer) {
        
        let label = tap.view as! UILabel
        let index = label.tag
        
        let comment = data[index] as! PostComment
        comment.showMore = !comment.showMore
        data[index] = comment
    }
    
    @objc func sayBravo(_ sender: UIButton){
        let postDetailsVC = delegate as! PostDetailsViewController
        
        self.toggleBravo()
        sender.isEnabled = false
        
        Backend.sayBravo(postId: postDetailsVC.post.PostId, isBravo: postDetailsVC.post.iSaidBravo, completion: { response, backendError in
            sender.isEnabled = true
            if backendError == .connection {
                
                self.toggleBravo(withSound: false)
            }else{
                
                postDetailsVC.updatePostInHome()
            }
            
        })
    }
    
    
    func toggleBravo(withSound: Bool = true){
        
        let postDetailsVC = delegate as! PostDetailsViewController
        postDetailsVC.post.iSaidBravo = !postDetailsVC.post.iSaidBravo
        
        
        if postDetailsVC.post.iSaidBravo == false {
            postDetailsVC.post.NumberOfSayBravo = postDetailsVC.post.NumberOfSayBravo - 1
            self.tableView.reloadRows(at: [IndexPath(row:0, section:0)], with: .none)
        } else {
            postDetailsVC.post.NumberOfSayBravo = postDetailsVC.post.NumberOfSayBravo + 1
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.tableView.reloadRows(at: [IndexPath(row:0, section:0)], with: .none)
//            }
            if withSound {
                self.playSuccessSound()
            }
        }
    }
    
    func playSuccessSound() {
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PostTableViewCell
        cell.bravoDetailsAnimationView.isHidden = false
        #if GAZT
        #else
        cell.bravoAnimationView.animation = Animation.named("hand")
        #endif
        cell.bravoDetailsAnimationView.play(completion: { (finished) in
            cell.bravoDetailsAnimationView.isHidden = true
        })
        
        guard let url = Bundle.main.url(forResource: "success_2", withExtension: "m4a") else { return }
        
        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
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
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            let heightWithoutImageAndTextfield = 162
            var contentTextViewHeight = 42
            let postDetailsVC = delegate as! PostDetailsViewController
            if let post = postDetailsVC.post {
                
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
                //Calculate content height
                let content = NSMutableAttributedString(string:post.AwardDescription, attributes: [
                    NSAttributedStringKey.font: UIFont(name: Constants.regularFont(), size: 14)!
                    ] as [NSAttributedStringKey : Any])
                
                if cell.contentTruncate {
                    cell.postContentLabel.numberOfLines = 2
                    if content.string.components(separatedBy: "\n").count >= 2 {
                        let lines = content.string.components(separatedBy: "\n")
                        let twoLinesLength = lines[0].count + lines[1].count + 1
                        content.replaceCharacters(in: NSMakeRange(twoLinesLength, content.length - twoLinesLength), with: NSAttributedString(string:"..."))
                    }
                }
                let final = NSMutableAttributedString()
                final.append(content)
                
                if post.ToPic == nil {
                    post.ToPic = ""
                }
//                SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string:post.ToPic!), options: [], progress: { (recieved, expected, url) in
//
//                }, completed: { (image, data, error/*, cacheType*/, finished/*, url*/) in
//
                    let image1Attachment = NSTextAttachment()
                    let image1AttachmentBounds = CGRect(x: 0.0, y: -24/2 - cell.postContentLabel.font!.descender + 2, width: 24, height: 24)
//                    if image == nil {
                        image1Attachment.image = UIImage(named:"profileBig")
//                    }else{
//                        image1Attachment.image = image?.y_imageWithRoundedCorners(radius: 12, inFrame: CGRect(x: 0, y: 0, width: 24, height: 24))
//                    }
                    image1Attachment.bounds = image1AttachmentBounds
                    let image1String = NSAttributedString(attachment: image1Attachment)
                    
                    let toUserString = NSAttributedString(string: "@\(post.To!)", attributes: [NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 14)!, NSAttributedStringKey.foregroundColor: UIColor.primaryColor])
                    
                    let user = NSMutableAttributedString()
                    user.append(image1String)
                    user.append(NSAttributedString(string:" "))
                    user.append(toUserString)
                    if final.string.range(of:"@\(post.To!)") != nil {
                        
                        final.replaceCharacters(in: NSRange(final.string.range(of:"@\(post.To!)")!, in:final.string), with: user)
                    }
                    
                    
                    cell.postContentLabel.attributedText = final
                    
                    if cell.contentTruncate == false {
                        cell.postContentLabel.translatesAutoresizingMaskIntoConstraints = true
                        cell.postContentLabel.numberOfLines = 0
                        cell.postContentLabel.sizeToFit()
                    }else{
                        cell.postContentLabel.translatesAutoresizingMaskIntoConstraints = false
                        cell.postContentLabel.numberOfLines = 2
                    }
//                    self.tableView.reloadRows(at: [indexPath], with: .none)
//                })
                
                contentTextViewHeight = Int(cell.postContentLabel.frame.size.height)
                if post.ImagePost != nil {
                    return CGFloat(heightWithoutImageAndTextfield + contentTextViewHeight + 158 + 4)
                }
            }
            return CGFloat(heightWithoutImageAndTextfield + contentTextViewHeight)

        }else{
            var commentContentHeight : CGFloat = 20
            if let postComment = data[indexPath.row] as? PostComment {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: commentCellName) as! PostCommentTableViewCell
                
                if postComment.showMore {
//                    DeveloperTools.print("show more")
                    cell.postCommentContentLabel.numberOfLines = 0
                }else{
//                    DeveloperTools.print("show less")
                    cell.postCommentContentLabel.numberOfLines = 2
                }
                cell.postCommentContentLabel.text = postComment.Message + "\n"
                cell.postCommentContentLabel.sizeToFit()
                commentContentHeight = cell.postCommentContentLabel.frame.size.height
        }
//            DeveloperTools.print("comment cell height \(commentContentHeight)")
            return 68 + commentContentHeight
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return data.count
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    @objc func comment(_ sender: UIButton){
        
        let postDetailsVC = delegate as! PostDetailsViewController
        postDetailsVC.commentAddLaunch = true
        postDetailsVC.commentLaunch()
    }
    
    @objc func moreTapped(_ sender: UIButton) {
        let postDetailsVC = delegate as! PostDetailsViewController
        let index = sender.tag
        if let postComment = data[index] as? PostComment {
            postDetailsVC.moreButtonTapped(messageID: postComment.Id, message: postComment.Message)
            postDetailsVC.commentEditLaunch = true
        }
    }
    
    @objc func profile(_ sender: UIButton) {
        let postDetailsVC = delegate as! PostDetailsViewController
        gotoProfile(withID: postDetailsVC.post.FromUserId)
    }
    
    @objc func commentProfile(_ sender: UIButton) {
        if let postComment = data[sender.tag] as? PostComment {
            gotoProfile(withID: postComment.From)
        }
    }
    
    @objc func bravosList(_ sender: UIButton) {
        sender.isEnabled = false
        let postVC = self.delegate as! PostDetailsViewController
        let bravosListVC = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "BravosList") as! ListOfBravosViewController
        Backend.getPostDetails(postId: postVC.post.PostId, completion: { (post, backendError) in
            sender.isEnabled = true
            if post != nil {
                if let list = post!.listOfBravos {
                    if list.count > 0 {
                        bravosListVC.bravosList = list
                        postVC.navigationController?.pushViewController(bravosListVC, animated: true)
                    }
                }
            } else {
                if let list = postVC.post.listOfBravos {
                    if list.count > 0 {
                        bravosListVC.bravosList = list
                        postVC.navigationController?.pushViewController(bravosListVC, animated: true)
                    }
                }
            }
        })
    }
    
    func gotoProfile(withID id: String) {
        Backend.getProfileDetails(withID: id, completion: { (employee, backendError) in
            if backendError != nil {
                
            } else {
                let postVC = self.delegate as! PostDetailsViewController
                
                let profile = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Profile") as! MyProfileViewController
                profile.profileData = employee
                if id == UserSettings.info!.userID {
                    profile.myProfile = 1
                } else {
                    profile.myProfile = 0
                }
                postVC.navigationController?.pushViewController(profile, animated: true)
            }
        })
    }
}
