//
//  PostDetailsViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import Presentr
//import AVFoundation
import IQKeyboardManagerSwift
import Material

class PostDetailsViewController: KeyboardHeightViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var replyFormView: UIView!
    @IBOutlet weak var replyFormInsideView: UIView!
    @IBOutlet weak var replyFormInside2View: UIView!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var replyTextView: AutomaticallyLocalizedTextView!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var charCountLabel: UILabel!
    
    
    var dimView = UIButton()//UIView()
    
    var scrollToMyComment = false
    
    var postDetailsTableViewAdapter: PostDetailsTableViewAdapter!
    //    var postId : Int!
    var post : Post!
    
    var commentAddLaunch = false
    var commentEditLaunch = false
    var messageId = 0
    //    var successSoundUrl = Bundle.main.url(forResource: "success_2", withExtension: "m4a")
    
    //    let player = AVQueuePlayer()
    
    let charLimit = 150
    var firstTime = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Motive post".y_localized
        self.tableView.tableFooterView = UIView()
        
        
        postDetailsTableViewAdapter = PostDetailsTableViewAdapter(tableView: self.tableView, delegate:self)
        loadData()
        
        //        self.player.insert(AVPlayerItem(url: successSoundUrl!), after: nil)
        
        replyLabel.text = ""
        replyTextView.delegate = self
        replyTextView.placeholder = "Type your reply here...".y_localized
        if UserSettings.appLanguageIsArabic() {
            replyTextView.textAlignment = .right
        }else{
            replyTextView.textAlignment = .left
        }
        
        //        self.perform(#selector(commentLaunch), with: nil, afterDelay: 1.0)
        tableView.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: replyFormView.frame.size.height,right: 0)
        
        self.navigationController!.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 17)!]
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController!.navigationBar.tintColor = .primaryColor
        
        if post.ToUserId == UserSettings.info?.userID {
            //            commentAddLaunch = false
            //            self.replyFormView.isHidden = true
        }
        
    }
    
    @objc func commentLaunch(){
        
        if self.commentAddLaunch {
            self.replyTextView.becomeFirstResponder()
            commentAddLaunch = false
        }
    }
    
    func moreButtonTapped(messageID id: Int, message: String) {
        let alert = UIAlertController(title: "Options".y_localized, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit".y_localized, style: .default) { (action) in
            self.editCommentLaunch(withText: message)
            self.messageId = id
        }
        alert.addAction(editAction)
        let deleteAction = UIAlertAction(title: "Delete".y_localized, style: .default) { (action) in
            self.deleteComment(withID: id)
        }
        alert.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel".y_localized, style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.view.tintColor = .primaryColor
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func editCommentLaunch(withText comment: String) {
        if commentEditLaunch {
            replyTextView.text = comment
            replyButton.setTitle("Update".y_localized, for: .normal)
            self.perform(#selector(launchEditCommentAfterChangingButtonTitle), with: nil, afterDelay: 0.2)
            replyButton.isEnabled = true
            replyButton.alpha = 1.0
        }
    }
    
    @objc func launchEditCommentAfterChangingButtonTitle(){
        
        replyTextView.becomeFirstResponder()
    }
    
    func deleteComment(withID id: Int) {
        Backend.commentDelete(messageId: id, postId: post.PostId, completion: { (success, backendError) in
            if success == false {
                if backendError == .connection {
                } else {
                    AlertUtility.showErrorAlert(/*"An error occurred, Please try again later".y_localized*/Constants.errorMessage(.General_Failure))
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.replyTextView.resignFirstResponder()
                    self.resetCommentAddInputs()
                    self.reloadData()
                    self.updatePostInHome()
                }
            }
        })
    }
    
    func loadData(){
        
        loadBackendData(showLoading: true)
    }
    func reloadData(){
        loadBackendData(showLoading: false)
    }
    
    func loadBackendData(showLoading: Bool){
        if showLoading {
            //            ProgressUtility.showProgressView()
            LoadingOverlay.shared.showOverlay()
        }
        
        Backend.getPostDetails(postId: post.PostId, completion: { (post, backendError) in
            if showLoading {
                //                ProgressUtility.dismissProgressView()
                LoadingOverlay.shared.hideOverlayView()
            }
            
            if backendError == .connection {
                //                AlertUtility.showAlertWithOneButton(title: "Error".y_localized, message:  "Unable to connect to the internet, Please try again later".y_localized, buttonTitle: "OK".y_localized, callback: {
                //
                //                })
            }else{
                self.perform(#selector(self.commentLaunch), with: nil, afterDelay: 0.7)
                if post != nil {
                    self.post = post
                    //                    self.updatePostInHome()
                    //                if post!.hasImage == nil {
                    //                    self.perform(#selector(self.checkImagePostWasVerifiedToReload), with: nil, afterDelay: 1)
                    //                }
                    if self.post.From != nil {
                        self.replyLabel.text = "Reply to ".y_localized + "@\(self.post.From!)"
                    }
                    if self.post.ListOfComments != nil {
                        DeveloperTools.printAnyway("List of comments: ")
                        dump(self.post.ListOfComments)
                        self.postDetailsTableViewAdapter.data = self.post.ListOfComments!
                        if self.scrollToMyComment {
                            self.tableView.scrollToRow(at: IndexPath(row:self.tableView.numberOfRows(inSection: self.tableView.numberOfSections-1)-1, section:self.tableView.numberOfSections-1), at: .bottom, animated: true)
                            self.scrollToMyComment = false
                        }
                    }
                    
                    return
                }
                
                self.postDetailsTableViewAdapter.data = []
                
            }
        })
    }
    
    //    @objc func checkImagePostWasVerifiedToReload(){
    //        DeveloperTools.print("whaaaat")
    //        if post.hasImage == nil {
    //            self.perform(#selector(self.checkImagePostWasVerifiedToReload), with: nil, afterDelay: 1)
    //            return
    //        }
    //        tableView.reloadData()
    //    }
    
    @IBAction func replyAdd(_ sender: UIButton){
        if replyTextView.isFirstResponder == false {
            replyTextView.becomeFirstResponder()
            return
        }
        replyButton.isEnabled = false
        if commentEditLaunch {
            Backend.commentEdit(message: replyTextView.text, postId: post.PostId, messageID: messageId, validationErrorInInput: { (inputIndex) in
                self.replyButton.isEnabled = true
            }, completion: { (success, backendError) in
                if success == false {
                    if backendError == .connection {
                    }else{
                        AlertUtility.showErrorAlert(/*"An error occurred, Please try again later".y_localized*/Constants.errorMessage(.General_Failure))
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.replyTextView.resignFirstResponder()
                        self.resetCommentAddInputs()
                        self.commentEditLaunch = false
                        self.reloadData()
                    }
                }
            })
        } else {
            Backend.commentAdd(message: replyTextView.text, postId: post!.PostId, validationErrorInInput: { inputIndex in
                self.replyButton.isEnabled = true
            }, completion: { (success, backendError) in
                self.replyButton.isEnabled = true
                if success == false {
                    
                    if backendError == .connection {
                        //                        AlertUtility.showAlertWithOneButton(title: "Error".y_localized, message: "Unable to connect to the internet, Please try again later".y_localized, buttonTitle: "OK".y_localized, callback: {
                        //
                        //                        })
                    }else{
                        AlertUtility.showErrorAlert(/*"An error occurred, Please try again later".y_localized*/Constants.errorMessage(.General_Failure))
                    }
                }else{
                    //                    AlertUtility.showSuccessAlert("Reply added successfully".y_localized)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.replyTextView.resignFirstResponder()
                        self.resetCommentAddInputs()
                        self.scrollToMyComment = true
                        self.reloadData()
                    }
                }
            })
        }
    }
    
    func resetCommentAddInputs(){
        self.replyTextView.text = ""
        
        self.replyButton.isEnabled = false
        self.replyButton.alpha = 0.4
    }
    
    func updatePostInHome(){
        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
            
            if let tabBar = navController.viewControllers[navController.viewControllers.count - 2] as? UITabBarController {
                
                if let homeVC = tabBar.viewControllers?.first as? HomeViewController {
                    
                    for i in 0 ..< homeVC.posts.count {
                        if homeVC.posts[i].PostId == post.PostId {
                            homeVC.posts[i] = post
                            homeVC.homeTableViewAdapter.data = homeVC.posts
                            homeVC.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    /*
     func toggleBravo(index: Int){
     self.post.iSaidBravo = !self.post.iSaidBravo
     let cell = self.tableView.cellForRow(at: IndexPath(row:index, section:0)) as! PostTableViewCell
     if self.post.iSaidBravo == false {
     cell.bravoLabel.text = "\(cell.viewModel.NumberOfSayBravo!) " + "Say Bravo".y_localized
     cell.bravoLabel.font = UIFont(name:Constants.regularFont, size:12)
     cell.bravoImageView.image = UIImage(named:"clap")
     }else{
     
     self.playSuccessSound()
     cell.bravoLabel.text = "\(cell.viewModel.NumberOfSayBravo!+1) " + "Awesome!".y_localized
     cell.bravoLabel.font = UIFont(name:Constants.boldFont, size:12)
     //            cell.bravoImageView.image = UIImage.gifImageWithName("clapAnimated")
     //            self.perform(#selector(gifAnimationEnded(cell:)), with: cell, afterDelay: (45 * 100)/1000)
     cell.bravoImageView.image = UIImage(named:"clap-1")
     }
     }
     @objc func gifAnimationEnded(cell: PostTableViewCell){
     cell.bravoImageView.image = UIImage(named:"clap-1")
     }
     
     @objc func sayBravo(_ sender: UIButton){
     let index = sender.tag
     
     self.toggleBravo(index: index)
     Backend.sayBravo(postId: post.PostId, isBravo: !post.iSaidBravo, completion: { response, backendError in
     
     if backendError == .connection {
     //                AlertUtility.showErrorAlert( "Unable to connect to the internet, Please try again later".y_localize
     self.toggleBravo(index: index)
     }else{
     
     }
     
     })
     }*/
    
    //    func playSuccessSound(){
    //        self.player.removeAllItems()
    //        self.player.insert(AVPlayerItem(url: successSoundUrl!), after: nil)
    //        self.player.play()
    //    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses = [PostDetailsViewController.self]l
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        replyLabel.textColor = .primaryColor
        charCountLabel.textColor = .primaryColor
        replyButton.backgroundColor = .primaryColor
        self.navigationController?.y_removeBackButtonTitle()
        self.navigationController?.y_showShadow()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstTime {
            firstTime = false
            replyFormView.y_dropShadow()
            replyFormView.layer.cornerRadius = 16
            self.replyButton.translatesAutoresizingMaskIntoConstraints = true
            self.charCountLabel.translatesAutoresizingMaskIntoConstraints = true
            
            let replyFormViewFrame = self.replyFormView.layer.frame
            var replyButtonFrame = self.replyButton.layer.frame
            if UserSettings.appLanguageIsArabic() {
                replyButtonFrame.origin.x = 16
            }else{
                replyButtonFrame.origin.x = replyFormViewFrame.size.width - replyButtonFrame.size.width - 12
            }
            self.replyButton.layer.frame = replyButtonFrame
            var charCountLabelX = self.charCountLabel.center.x
            if UserSettings.appLanguageIsArabic() {
                charCountLabelX = replyFormView.frame.size.width - self.charCountLabel.frame.size.width/2 - 14
            }
            self.charCountLabel.center = CGPoint(x:charCountLabelX, y:self.replyButton.center.y)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func handleTap(sender: UITapGestureRecognizer) {
        super.handleTap(sender: sender)
        sender.cancelsTouchesInView = true
    }
    
}

extension PostDetailsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        charCountLabel.text = "\(charLimit-textView.text.count/*lengthOfBytes(using: .utf8)*/)"//" / \(charLimit)"
        charCountLabel.isHidden = false
        replyTextView.textColor = .black
        
        view.bringSubview(toFront: replyButton)
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        
                        var replyFormViewFrame = self.replyFormView.layer.frame
                        replyFormViewFrame.size.height = 161
                        replyFormViewFrame.origin.y = self.view.frame.size.height - (self.keyboardHeight ?? 216) - replyFormViewFrame.size.height
                        self.replyFormView.layer.frame = replyFormViewFrame
                        
                        var replyButtonFrame = self.replyButton.layer.frame
                        replyButtonFrame.origin.y = replyFormViewFrame.height - replyButtonFrame.size.height - 12
                        if UserSettings.appLanguageIsArabic() {
                            replyButtonFrame.origin.x = 16
                        }else{
                            replyButtonFrame.origin.x = replyFormViewFrame.size.width - replyButtonFrame.size.width - 16
                        }
                        //                        DeveloperTools.print("button Y", replyButtonFrame.origin.y)
                        self.replyButton.layer.frame = replyButtonFrame
                        
                        var charCountLabelX = self.charCountLabel.center.x
                        if UserSettings.appLanguageIsArabic() {
                            charCountLabelX = self.replyFormView.layer.frame.size.width - self.charCountLabel.layer.frame.size.width/2 - 14
                        }
                        self.charCountLabel.center = CGPoint(x:charCountLabelX, y:self.replyButton.center.y)
                        
        }, completion: {success in
            
            self.replyFormView.backgroundColor = .clear
            self.replyFormInsideView.isHidden = false
            self.replyFormInside2View.isHidden = false
            
            //            guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
            //
            //            statusBar.backgroundColor = .clear
            self.dimView.removeFromSuperview()
            var dimViewHeight = self.replyFormView.layer.frame.origin.y + UIApplication.shared.statusBarFrame.size.height
            if self.navigationController != nil {
                dimViewHeight += self.navigationController!.navigationBar.frame.size.height
            }
            self.dimView.layer.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: dimViewHeight)
            self.dimView.addTarget(self, action: #selector(self.dismissKeyboard), for: .touchUpInside)
            self.dimView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
            
            self.navigationController?.view.addSubview(self.dimView)
        })
    }
    
    @objc func dismissKeyboard(){
        self.replyTextView.resignFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        charCountLabel.isHidden = true
        replyTextView.textColor = .white
        
        replyButton.setTitle("Reply".y_localized, for: .normal)
        self.replyFormView.backgroundColor = .white
        self.replyFormInsideView.isHidden = true
        self.replyFormInside2View.isHidden = true
        
        self.dimView.removeFromSuperview()
        //        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        //
        //        statusBar.backgroundColor = .white
        
        //        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        var replyFormViewFrame = self.replyFormView.layer.frame
                        replyFormViewFrame.size.height = 95
                        replyFormViewFrame.origin.y = self.view.frame.size.height - replyFormViewFrame.size.height
                        self.replyFormView.layer.frame = replyFormViewFrame
                        
                        var replyButtonFrame = self.replyButton.layer.frame
                        replyButtonFrame.origin.y = replyFormViewFrame.height - replyButtonFrame.size.height - 12
                        DeveloperTools.print("button Y", replyButtonFrame.origin.y)
                        self.replyButton.layer.frame = replyButtonFrame
                        
                        var charCountLabelX = self.charCountLabel.center.x
                        if UserSettings.appLanguageIsArabic() {
                            charCountLabelX = self.replyFormView.frame.size.width - self.charCountLabel.frame.size.width/2 - 14
                        }
                        self.charCountLabel.center = CGPoint(x:charCountLabelX, y:self.replyButton.center.y)
                        
        }, completion: {success in
        })
        
        if commentEditLaunch {
            resetCommentAddInputs()
            commentEditLaunch = false
            self.replyButton.titleLabel?.text = "Reply".y_localized
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        //        let result = (textView.text as NSString?)?.replacingCharacters(in: range, with: text) ?? ""
        
        let newLength = textView.text.count/*lengthOfBytes(using: .utf8)*/ + text.count/*lengthOfBytes(using: .utf8)*/ - range.length
        
        return newLength <= charLimit
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.y_trimmed.count/*lengthOfBytes(using: .utf8)*/ == 0 {
            replyButton.isEnabled = false
            replyButton.alpha = 0.4
        } else {
            replyButton.isEnabled = true
            replyButton.alpha = 1
        }
        
        charCountLabel.text = "\(charLimit-textView.text.count/*lengthOfBytes(using: .utf8)*/)"//" / \(charLimit)"
    }}

extension PostDetailsViewController : TableViewAdapterDelegate {
}
