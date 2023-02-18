//
//  PostAddViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import IQKeyboardManagerSwift
import Gradientable
import SlideMenuControllerSwift
import AVFoundation
import Photos
import Lottie

class PostAddViewController : KeyboardHeightViewController {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var pointsLabel: AutomaticallyLocalizedLabel!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    @IBOutlet weak var charCountLabel: UILabel!
    var charLimit = 150
    var tagsNumberLimit = 3
    let mentionNumberLimit = 1
    //    @IBOutlet weak var postButton: UIButton!
    
    private let mentionsTableView = UITableView()
    private var dataManager: SZExampleMentionsTableViewDataManager?
    private var mentionsListener: SZMentionsListener!
    
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var attachmentRemoveButton: UIButton!
    
    var imageUploader : ImageUploader = ImageUploader()
    var contacts: [Employee]?
    var hashtags: [Hashtag]?
    var hashtagImages : [UIImage]? = [UIImage]()
    var tagsScrollView: UIScrollView?
    
    var alertContainer: UIView?
    var hashtagRange: NSRange?
    
    var postAccessory: PostAccessoryViewController!
    var finalDescription = NSMutableAttributedString()
    var jumpToNext = false
    
    var homeVC : HomeViewController!
    
    var tagsScrollViewHeight : Int = {
        
        if Utilities.deviceIs_iPhone5() {
            DeveloperTools.print("i5")
            return 84
        }else{
            DeveloperTools.print("no i5")
            return 168
        }
    }()
    var mentionsTableViewHeight : CGFloat = {
        
        if Utilities.deviceIs_iPhone5() {
            DeveloperTools.print("i5")
            return 104
        }else{
            DeveloperTools.print("no i5")
            return 188
        }
    }()
    
    var lastDescriptionTextViewHeight = 0
    
    let postAccessoryViewHeight = 56
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DeveloperTools.findTheOne(view: view)
        
        let applicationSettings = UserSettings.applicationSettings
        for applicationSetting in applicationSettings {
            if applicationSetting.parameterId == 5 {
                charLimit = Int(applicationSetting.parameterValue) ?? 150
            }
            if applicationSetting.parameterId == 6 {
                tagsNumberLimit = Int(applicationSetting.parameterValue) ?? 3
            }
        }
        
        mentionsListener = SZMentionsListener(mentionTextView: descriptionTextField,
                                              mentionsManager: self,
                                              textViewDelegate: self,
                                              mentionTextAttributes: mentionAttributes(),
                                              defaultTextAttributes: defaultAttributes(),
                                              spaceAfterMention: true)
        setupTextView(descriptionTextField, delegate: mentionsListener)
        
        dataManager = SZExampleMentionsTableViewDataManager(
            mentionTableView: mentionsTableView,
            mentionsListener: mentionsListener)
        mentionsTableView.accessibilityIdentifier = "MentionsTableView"
        setupTableView(mentionsTableView, dataManager: dataManager!)
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //        if alertContainer != nil {
        //            alertContainer!.removeFromSuperview()
        //        }
        //        var alertY = self.view.frame.size.height - 72
        //        if keyboardHeight != nil {
        //            alertY = self.view.frame.size.height-keyboardHeight!-72
        //        }
        //        alertContainer = UIView(frame:CGRect(x:0, y:alertY, width:self.view.frame.size.width, height:72))
        //        self.view.addSubview(alertContainer!)
        imageUploader.delegate = self
        
        postAccessory = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "PostAccessory") as! PostAccessoryViewController
        
        postAccessory.view.translatesAutoresizingMaskIntoConstraints = true
        postAccessory.view.frame = CGRect(x:0, y:0, width:Int(self.view.frame.size.width), height:postAccessoryViewHeight)
        
        postAccessory.cameraButton.addTarget(self, action: #selector(camera), for: .touchUpInside)
        postAccessory.galleryButton.addTarget(self, action: #selector(gallery), for: .touchUpInside)
        postAccessory.sendButton.addTarget(self, action: #selector(post), for: .touchUpInside)
        postAccessory.view.y_addTopBorderWithColor(color: UIColor(r:179,g:192,b:203,a:0.6), thickness: 1.0)
        //        formAlert.messageLabel.text = message
        //        alertContainer?.addSubview(formAlert.alertView)
        //        formAlert.alertView.frame = CGRect(x:0, y:0, width:self.view.frame.size.width, height:72)
        descriptionTextField.inputAccessoryView = postAccessory.view
        
        //        descriptionWidth = descriptionTextField.frame.size.width
        //        formAlert.dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        DispatchQueue.global(qos: .background).async {
            
            Backend.getMentions(searchText: "", pageIndex: 1, pageCount: 500, completion: { (mentions, backendError)  in
                
                if backendError == .connection {
                    
                    //                AlertUtility.showErrorAlert( "Unable to connect to the internet, Please try again later".y_localized)
                }else{
                    self.contacts = mentions
                    var szMentions = [SZExampleMention]()
                    for mention in self.contacts! {
                        let szMention = SZExampleMention(_userId: mention.Id, _userName: mention.UserName, _fullName:mention.FullName, _userImage: mention.ProfileURL ?? "")
                        szMentions.append(szMention)
                    }
                    self.dataManager?.mentions = szMentions
                    Backend.getTags(completion: { (hashtags, backendError) in
                        if hashtags == nil{
                            if backendError == .connection {
                                
                                //                            AlertUtility.showErrorAlert( "Unable to connect to the internet, Please try again later".y_localized)
                                
                            }
                        }else{
                            self.hashtags = hashtags
                            
                            for i in 0 ..< self.hashtags!.count {
                                self.hashtagImages!.append(UIImage(cgImage: UIImage(view:self.createTag(index: i)).cgImage!, scale: UIScreen.main.scale, orientation: .up))
                            }
                        }
                    })
                }
            })
        }
        
        if #available(iOS 11.0, *) {
            descriptionTextField.textDragInteraction?.isEnabled = false
        }
        lastDescriptionTextViewHeight = Int(descriptionTextField.frame.size.height)
        
        updateCharactersRemaining()
        if UserSettings.appLanguageIsArabic() {
            descriptionTextField.textAlignment = .right
        }else{
            descriptionTextField.textAlignment = .left
        }
        var pointsLabelExtra = ""
        if UserSettings.info?.Balance != nil {
            pointsLabel.text = "My Balance".y_localized
            if UserSettings.appLanguageIsArabic() {
                pointsLabelExtra = "\(UserSettings.info!.Balance)"
                //                if UserSettings.info!.Balance == 1 {
                //                    pointsLabelExtra = "نقطة واحدة"
                //                }else  if UserSettings.info!.Balance == 2 {
                //                    pointsLabelExtra = "نقطتان"
                //                }else if UserSettings.info!.Balance >= 3 &&
                //                    UserSettings.info!.Balance <= 10 {
                //                    pointsLabelExtra = "\(UserSettings.info!.Balance) نقاط"
                //                }else{
                //                    pointsLabelExtra = "\(UserSettings.info!.Balance) نقطة"
                //                }
            }else{
                if UserSettings.info!.Balance == 1 {
                    pointsLabelExtra = "1 point"
                }else {
                    pointsLabelExtra = "\(UserSettings.info!.Balance) points"
                }
            }
        }
        pointsLabel.text = pointsLabel.text! + " " + pointsLabelExtra
    }
    
    private func setupTableView(_ tableView: UITableView, dataManager: SZExampleMentionsTableViewDataManager) {
        
        
        mentionsTableView.translatesAutoresizingMaskIntoConstraints = false
        //        mentionsTableView.backgroundColor = UIColor.blue
        mentionsTableView.tableFooterView = UIView()
        mentionsTableView.delegate = dataManager
        mentionsTableView.dataSource = dataManager
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        self.navigationController?.navigationBar.shadowImage = UIImage()
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [PostAddViewController.self]
        
        descriptionTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pointsLabel.textColor = .primaryColor
        charCountLabel.textColor = .primaryColor
//        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//
//        statusBar.backgroundColor = .clear
        
        //        pointsLabel.autoAlign = true
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
//        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
//        
//        statusBar.backgroundColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSendButtonStatus(){
        var descriptionTextFieldText = descriptionTextField.text!
        
        
        for mention in mentionsListener.mentions {
            descriptionTextFieldText = descriptionTextFieldText.y_replaceFirst(of: "@\(mention.mentionObject.mentionName)", with: "")
        }
        
        descriptionTextFieldText = descriptionTextFieldText.replacingOccurrences(
            of: "[^A-Za-z0-9ء-ي٠-٩]",
            with: "",
            options: .regularExpression,
            range:nil).trimmingCharacters(in: .whitespacesAndNewlines)
        
        //        DeveloperTools.print("\"\(descriptionTextFieldText)\"(\(descriptionTextFieldText.count)) (\(descriptionTextFieldText == "")) > \(mentionsListener.mentions.count) > \(getInsertedhashtagsIndices().count)")
        
        if descriptionTextFieldText.count > 0 && mentionsListener.mentions.count > 0 && getInsertedhashtagsIndices().count > 0 {
            postAccessory.sendButton.isEnabled = true
            postAccessory.sendButton.alpha = 1
        }else{
            postAccessory.sendButton.isEnabled = false
            postAccessory.sendButton.alpha = 0.4
        }
    }
    
    @objc func post(){
        /*if descriptionTextField.text == "" {
         
         //            failureAlert(message: "Please, enter the post content".y_localized)
         descriptionTextField.resignFirstResponder()
         
         }else{*/
        
        postAccessory.sendButton.isEnabled = false
        self.view.endEditing(true)
        //        ProgressUtility.showProgressView()
        LoadingOverlay.shared.showOverlay()
        
        if imageUploader.selectedImage == nil {
            proceedToPost(imageUrl:nil)
        }else{
            Backend.imageUpload(imageData: imageUploader.imageData(), completion: { imageName, backendError  in
                //                    ProgressUtility.dismissProgressView()
                LoadingOverlay.shared.hideOverlayView()
                
                if imageName == nil {
                    self.postAccessory.sendButton.isEnabled = true
                    if backendError == .connection {
                        
                    }else{
                        AlertUtility.showErrorAlertWithCallback(/*"Some error occurred, Please try again".y_localized*/Constants.errorMessage(.General_Failure), callback: {
                            
                            self.descriptionTextField.becomeFirstResponder()
                        })
                        //                            AlertUtility.showAlertWithOneButton(title: "Error".y_localized, message: "Some error occurred, Please try again".y_localized, buttonTitle: "OK".y_localized, callback: {
                        //                                self.descriptionTextField.becomeFirstResponder()
                        ////                                guard let statusBar = UIApplication.shared.value(forKeyPath: "statuszBarWindow.statusBar") as? UIView else { return }
                        ////
                        ////                                statusBar.backgroundColor = .clear
                        //
                        //                            })
                        
                    }
                }else{
                    DeveloperTools.print("imageuploader response", imageName ?? "")
                    self.proceedToPost(imageUrl: imageName)
                }
            })
        }
        //        }
    }
    
    func proceedToPost(imageUrl: String?){
        
        postAccessory.sendButton.isEnabled = true
        let postSuccess = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Success") as! SuccessViewController
        
        var selectedTagsIds : [Int] = [Int]()
        let tagIndices = getInsertedhashtagsIndices()
        for tagIndex in tagIndices {
            selectedTagsIds.append(hashtags![tagIndex].Id)
        }
        
        let receiver = mentionsListener!.mentions.first!.mentionObject as! SZExampleMention
        
        
        finalDescription = NSMutableAttributedString(attributedString: descriptionTextField.attributedText)
        
        let attributedText = descriptionTextField.attributedText!
        var mentionRange = NSRange()
        attributedText.enumerateAttribute(NSAttributedStringKey.foregroundColor, in: NSRange(0..<attributedText.length), options: .longestEffectiveRangeNotRequired) {
            value, range, stop in
            //Confirm the attribute value is actually a font
            if let color = value as? UIColor {
                //print(font)
                //Check if the font is bold or not
                if  color == .primaryColor {
                    mentionRange = range
                }
            }
        }
        
        
        finalDescription.replaceCharacters(in: mentionRange, with: NSAttributedString(string: "<user=@\(receiver.mentionName)>"))
        
        
        while finalDescription.containsAttachments(in:NSRange(location: 0, length: finalDescription.length)){
            replaceTheNextAttachment()
            jumpToNext = false
        }
        
        
        //        if DeveloperTools.debugMode {
        //                        DeveloperTools.print("final desc: ", finalDescription.string)
        //                        return
        //
        //        }
        Backend.postAdd(content: finalDescription.string, recieverId: receiver.userId, imageUrl: imageUrl, tagIds: selectedTagsIds, validationErrorInInput: { inputIndex in
            self.postAccessory.sendButton.isEnabled = true
            
        }, completion: { thankYouResponse, errorMsg, backendError  in
            self.postAccessory.sendButton.isEnabled = true
            //            ProgressUtility.dismissProgressView()
            LoadingOverlay.shared.hideOverlayView()
            if thankYouResponse == nil {
                if backendError == .connection {
                    //
                } else if backendError == .server {
                    AlertUtility.showErrorAlertWithCallback(/*"Some error occurred, Please try again".y_localized*/Constants.errorMessage(.General_Failure), callback: {
                        
                        self.descriptionTextField.becomeFirstResponder()
                    })
                } else {
                    AlertUtility.showErrorAlertWithCallback(errorMsg, callback: {
                        self.descriptionTextField.becomeFirstResponder()
                    })
                }
            }else{
                
                let numberOfPoints = thankYouResponse!.Points
                let nvc = ((self.presentingViewController as! SlideMenuController).mainViewController as! ExampleNavigationController)
                
                (postSuccess.view.viewWithTag(7) as! UIButton).addTarget(((nvc.viewControllers.first as! UITabBarController).viewControllers!.first as! HomeViewController), action: #selector(HomeViewController.backToTimeline(_:)), for: .touchUpInside)
                
                
                var myMutableString = NSMutableAttributedString()
                let points : NSAttributedString!
                
                if thankYouResponse!.ApprovalStatus == .pending {
                    //                    let pending = NSAttributedString(string: "Your post has been sent and waiting for approval from the Admin.".y_localized, attributes: [NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 14), NSAttributedStringKey.foregroundColor: UIColor(r:74, g:74, b:74)])
                    
                    myMutableString = NSMutableAttributedString(string: "Your post has been sent and waiting for approval from the Admin.".y_localized)
                    postSuccess.mainTitleLabel.text = Fonts.awesome.y_localized
                    postSuccess.messageAndNameLabel.lineBreakMode = .byWordWrapping
                    postSuccess.messageAndNameLabel.numberOfLines = 2
                    postSuccess.messageAndNameLabel.attributedText = myMutableString
                    postSuccess.pointsLabel.text = ""
                }else{
                    
                    let myMutableString1 = NSMutableAttributedString()
                    //                    myMutableString = NSMutableAttributedString(string: myString as String, attributes:nil)
                    let name = NSAttributedString(string: receiver.fullName, attributes: [NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 14)!, NSAttributedStringKey.foregroundColor: UIColor(r:74, g:74, b:74)])
                    
                    myMutableString1.append(NSAttributedString(string:"You've successfully given".y_localized))
                    myMutableString1.append(NSAttributedString(string:" "))
                    myMutableString1.append(name)
                    postSuccess.mainTitleLabel.text = Fonts.awesome.y_localized
                    postSuccess.messageAndNameLabel.attributedText = myMutableString1
                    
                    if UserSettings.appLanguageIsArabic() {
                        var numberOfPointsText = ""
                        if numberOfPoints! == 1 {
                            numberOfPointsText = "نقطة واحدة"
                        }else if numberOfPoints! == 2 {
                            numberOfPointsText = "نقطتان"
                            
                        }else if numberOfPoints! >= 3 && numberOfPoints! <= 10 {
                            
                            numberOfPointsText = "\(numberOfPoints!) نقاط"
                            
                        }else if numberOfPoints! > 11 || numberOfPoints! == 0 {
                            numberOfPointsText = "\(numberOfPoints!) نقطة"
                        }
                        points = NSAttributedString(string: numberOfPointsText, attributes: [NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 14)!, NSAttributedStringKey.foregroundColor: /*UIColor(r:236, g:19, b:129)*/UIColor.primaryColor])
                    }else{
                        points = NSAttributedString(string: "\(numberOfPoints!) points", attributes: [NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 14)!, NSAttributedStringKey.foregroundColor: /*UIColor(r:236, g:19, b:129)*/UIColor.primaryColor])
                    }
                    myMutableString.append(points)
                    if UserSettings.appLanguageIsArabic() {
                        myMutableString.append(NSAttributedString(string:" "))
                        myMutableString.append(NSAttributedString(string:"Successfully".y_localized))
                    }
                    myMutableString.append(NSAttributedString(string:"."))
                    postSuccess.pointsLabel.attributedText = myMutableString
                }
                
                postSuccess.animationView.animation = Animation.named("postSuccess")
                nvc.view.addSubview(postSuccess.view)
                self.dismiss(animated: false) {
                }
            }
        })
        //        }
    }
    
    func replaceTheNextAttachment(){
        
        finalDescription.enumerateAttribute(NSAttributedStringKey.attachment, in: NSRange(location: 0, length: finalDescription.length), options: []) { (value, range, stop) in
            if jumpToNext == false {
                
                if (value is NSTextAttachment){
                    let attachment: NSTextAttachment? = (value as? NSTextAttachment)
                    
                    if ((attachment?.image) != nil) {
                        
                        var replacementHashtagString: String! = ""
                        for i in 0 ..< self.hashtagImages!.count {
                            let hashtagImage = self.hashtagImages![i]
                            if hashtagImage == attachment!.image {
                                replacementHashtagString = hashtags![i].Name
                            }
                        }
                        
                        let mutableAttr = finalDescription.mutableCopy() as! NSMutableAttributedString
                        //Remove the attachment
                        
                        if range.upperBound <= mutableAttr.length {
                            
                            //                        mutableAttr.beginEditing()
                            mutableAttr.replaceCharacters(in: range, with: "")
                            //                        mutableAttr.endEditing()
                            mutableAttr.insert(NSAttributedString(string:"<hashtag=#\(replacementHashtagString!)>"), at: range.location)
                            finalDescription = mutableAttr
                            jumpToNext = true
                        }
                        
                    }else{
                        DeveloperTools.print("No image attched")
                    }
                }
            }
        }
        
    }
    
    @objc func camera(){
        
        if self.imageUploader.selectedImage != nil {
            self.view.endEditing(true)
            AlertUtility.showErrorAlert(/*"You can only attach one image".y_localized*/Constants.errorMessage(.user_mention_more_than_one_image))
        }else{
            self.imageUploader.presentCamera(onFailure: { firstTime in
                if firstTime == false {
                    self.view.endEditing(true)
                    AlertUtility.showErrorAlertWithCallback(/*"Please, allow Motivay to access the camera from the device settings".y_localized*/Constants.errorMessage(.camera_access_from_setting), callback: {
                        
                        self.descriptionTextField.becomeFirstResponder()
                    })
                }
            })
        }
    }
    
    @objc func gallery(){
        if self.imageUploader.selectedImage != nil {
            AlertUtility.showErrorAlert(/*"You can only attach one image".y_localized*/Constants.errorMessage(.user_mention_more_than_one_image))
            self.view.endEditing(true)
        }else{
            self.imageUploader.presentGallery(onFailure: { firstTime in
                if firstTime == false {
                    self.view.endEditing(true)
                    AlertUtility.showErrorAlertWithCallback(/*"Please, allow Motivay to access the gallery from the device settings".y_localized*/Constants.errorMessage(.photos_access_from_setting), callback: {
                        
                        self.descriptionTextField.becomeFirstResponder()
                    })
                }
            })
        }
    }
    
    @IBAction func attachmentRemove(){
        imageUploader.selectedImage = nil
        attachmentImageView.isHidden = true
        attachmentRemoveButton.isHidden = true
    }
    @IBAction func dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissButtonTapped() {
        alertContainer?.removeFromSuperview()
    }
    
    
    func inHashtag(range: NSRange) -> Bool{
        
        var newRange = range
        newRange.location -= 1
        newRange.length = 1
        
        /*var textToInspectForEmojis = descriptionTextField.text!
         //        if let selectedRange = descriptionTextField.selectedTextRange {
         //            textToInspectForEmojis = descriptionTextField.text(in: selectedRange)!
         //        }
         //
         
         if let selectedRange = descriptionTextField.selectedTextRange {
         
         let cursorPosition = descriptionTextField.offset(from: descriptionTextField.beginningOfDocument, to: selectedRange.start)
         print("curpos: \(cursorPosition) : \(descriptionTextField.text.count)")
         if cursorPosition >= descriptionTextField.text.count {
         
         let chrs = textToInspectForEmojis.split(separator: " ")
         if chrs.count > 0{
         
         var hashtagChars = CharacterSet.init(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ")//CharacterSet.alphanumerics
         hashtagChars.formUnion(CharacterSet.init(charactersIn: "#"))
         
         var i = 0
         for uni in descriptionTextField.text.unicodeScalars {
         print(String(uni), "?? ", "QQ", String(uni).utf8.count, " > unipos: \(cursorPosition) : \(i)")
         if hashtagChars.contains(uni) == false && (cursorPosition == i+1 || cursorPosition == i+2) {
         return false
         }
         i += 1
         }
         
         //            if (String(chrs.last!)).rangeOfCharacter(from: hashtagChars) == nil {//.y_containsEmoji {
         //                return false
         //            }
         }
         }
         }*/
        
        
        if newRange.location >= 0 && newRange.location < descriptionTextField.text.count {
            let currentChar: String? = descriptionTextField.text.substring(with: newRange)
            if currentChar == nil {
                
                return false
            }else if currentChar == "#" {
                hashtagRange!.location = newRange.location
                return true
            } else if  currentChar!.y_isAlphabet() {
                
                return inHashtag(range:newRange)
            }
        }
        return false
    }
    
    
    func createTag(index : Int, withAddButton: Bool = false) -> GradientableView {
        let labelX = 16
        let labelY = 6
        let labelHeight = 20
        let fontSize = 14
        let radius = 16
        //        if withAddButton == false {
        //            labelX = 4
        //            labelY = 2
        //            labelHeight = 10
        //            fontSize = 5
        //            radius = 6
        //        }
        let name = self.hashtags![index].Name
        
        let label = UILabel(frame:CGRect(x:labelX, y:labelY, width:50, height:labelHeight))
        label.text = name
        label.font = label.font.withSize(CGFloat(fontSize))
        label.textColor = .white
        label.sizeToFit()
        
        let addButton = UIButton(frame:CGRect(x:label.frame.origin.x+label.frame.size.width+7, y:3, width:26, height:26))
        addButton.setImage(UIImage(named:"add-1"), for: .normal)
        
        var gradViewFrame : CGRect!
        if withAddButton {
            gradViewFrame = CGRect(x:0, y:0, width:addButton.frame.origin.x + addButton.frame.size.width + 3, height:32)
        }else{
            gradViewFrame = CGRect(x:0, y:0, width:label.frame.origin.x + label.frame.size.width + 16, height:32)
        }
        
        let gradView = GradientableView(frame:gradViewFrame)
        //        gradView.set(options: GradientableOptions(colors: [UIColor(r:156, g:204, b:101), UIColor(r:2, g:184, b:117)]))
        
        gradView.set(options: GradientableOptions(colors: [UIColor(hexString:self.hashtags![index].Color, alpha:1), UIColor(hexString:self.hashtags![index].Color, alpha:0.5)]))
        
        let options = GradientableOptions(direction: .bottomLeftToTopRight)
        gradView.set(options: options)
        gradView.layer.cornerRadius = CGFloat(radius)
        gradView.clipsToBounds = true
        //        gradView.backgroundColor = .white
        
        let hiddenButton = UIButton(frame:gradView.frame)
        hiddenButton.tag = index
        hiddenButton.addTarget(self, action: #selector(tagInsert(_:)), for: .touchUpInside)
        hiddenButton.setTitle(name, for: .normal)
        hiddenButton.setTitleColor(.clear, for: .normal)
        gradView.addSubview(label)
        if withAddButton {
            gradView.addSubview(addButton)
        }
        gradView.addSubview(hiddenButton)
        return gradView
    }
    
    @objc func tagInsert(_ sender: UIButton){
        let fullString = NSMutableAttributedString(attributedString:descriptionTextField.attributedText)
        let i = sender.tag
        //        let  hashtag =  sender.title(for: .normal)!
        // create our NSTextAttachment
        let image1Attachment = NSTextAttachment()
        //        let view = createTag(index:i)
        
        //        image1Attachment.image = UIImage(cgImage: UIImage(view:view).cgImage!, scale: 3, orientation: .up)
        image1Attachment.image = hashtagImages![i]
        DeveloperTools.print("descender, ", descriptionTextField.font!.descender)
        image1Attachment.bounds = CGRect(x: 0.0, y: -image1Attachment.image!.size.height/2 - descriptionTextField.font!.descender + 2, width: image1Attachment.image!.size.width, height: image1Attachment.image!.size.height)
        // wrap the attachment in its own attributed string so we can append it
        let image1String = NSAttributedString(attachment: image1Attachment)
        
        fullString.replaceCharacters(in: hashtagRange!, with: image1String)
        fullString.append(NSMutableAttributedString(string:" "))
        // draw the result in a label
        descriptionTextField.attributedText =  fullString
        
        /*let descriptionWidth = descriptionTextField.frame.size.width
         descriptionTextField.sizeToFit()
         
         var frame = descriptionTextField.frame
         frame.size.height = frame.size.height + 30
         frame.size.width = descriptionWidth
         if frame.size.height < 60 {
         frame.size.height = 60
         }
         descriptionTextField.frame = frame*/
        adjustDescriptionTextViewHeight()
        
        self.textViewDidChange(descriptionTextField)
        tagsScrollView?.removeFromSuperview()
    }
    
    func getInsertedhashtagsIndices() -> [Int] {
        var hashtagsIndices = [Int]()
        let range = NSRange(location: 0, length: descriptionTextField.attributedText.length)
        if (descriptionTextField.textStorage.containsAttachments(in: range)) {
            let attrString = descriptionTextField.attributedText
            var location = 0
            while location < range.length {
                var r = NSRange()
                let attrDictionary = attrString?.attributes(at: location, effectiveRange: &r)
                if attrDictionary != nil {
                    // Swift.print(attrDictionary!)
                    let attachment = attrDictionary![NSAttributedStringKey.attachment] as? NSTextAttachment
                    if attachment != nil {
                        if attachment!.image != nil {
                            // your code to use attachment!.image as appropriate
                            for i in 0 ..< self.hashtagImages!.count {
                                let hashtagImage = self.hashtagImages![i]
                                if hashtagImage == attachment!.image {
                                    hashtagsIndices.append(i)
                                }
                            }
                        }
                    }
                    location += r.length
                }
            }
        }
        return hashtagsIndices
    }
    
    func showTagSuggestions(filter: String){
        
        if hashtags != nil {
            if hashtags!.count > 0 && getInsertedhashtagsIndices().count < tagsNumberLimit {
                
                tagsScrollView = UIScrollView(frame:CGRect(x:0, y: 30 + Int(mainScrollView.frame.origin.y + mainScrollView.frame.size.height - CGFloat(tagsScrollViewHeight) - CGFloat(postAccessoryViewHeight)) + 30/*Int(descriptionTextField.frame.origin.y+descriptionTextField.frame.size.height)*/, width:Int(view.frame.size.width), height: tagsScrollViewHeight))
                let filterWithoutHash = filter.replacingOccurrences(of: "#", with: "")
                
                tagsScrollView!.backgroundColor = .white
                var tagViews = [GradientableView]()
                
                for i in 0 ..< hashtags!.count {
                    let tag = hashtags![i].Name!
                    if getInsertedhashtagsIndices().contains(i) == false && (tag.lowercased().hasPrefix(filterWithoutHash.lowercased()) || filterWithoutHash == "") {
                        //                        DeveloperTools.print("contains")
                        tagViews.append(createTag(index: i, withAddButton: true))
                    }
                }
                
                var yOffset : CGFloat = 10
                var xOffset : CGFloat = 10
                var biggestX : CGFloat = 0
                var biggestY : CGFloat = 0
                
                for i in 0 ..< tagViews.count {
                    var frame = tagViews[i].frame
                    frame.origin.y = yOffset
                    frame.origin.x = xOffset
                    xOffset = frame.origin.x + frame.size.width + 10
                    if xOffset > tagsScrollView!.frame.size.width {
                        yOffset += 32+10
                        xOffset = 10
                    }
                    if frame.origin.x + frame.size.width > biggestX {
                        biggestX = frame.origin.x + frame.size.width
                    }
                    if frame.origin.y + frame.size.height + 10 > biggestY {
                        biggestY = frame.origin.y + frame.size.height + 10
                    }
                    tagViews[i].frame = frame
                    tagsScrollView!.addSubview(tagViews[i])
                }
                biggestY += 10
                //                var scrollViewFrame = scrollView.frame
                //                scrollViewFrame.size.height = biggestY
                //                scrollView.frame = scrollViewFrame
                tagsScrollView!.showsHorizontalScrollIndicator = false
                tagsScrollView!.contentSize = CGSize(width:biggestX, height:biggestY)
                
                tagsScrollView?.accessibilityIdentifier = "HashtagScrollView"
                if tagsScrollView != nil {
                    tagsScrollView?.removeFromSuperview()
                }
                if tagViews.count > 0 {
                    view.addSubview(tagsScrollView!)
                }
            }
        }
        adjustDescriptionTextViewHeight()
    }
    
    func adjustDescriptionTextViewHeight(){
        
        //        print("adjustDescriptionTextViewHeight")
        let descriptionWidth = descriptionTextField.frame.size.width
        descriptionTextField.sizeToFit()
        
        var frame = descriptionTextField.frame
        var mentionsExist = false
        var tagsExist = false
        if mentionsTableView.superview != nil {
            mentionsExist = true
        }
        //        mentionsTableView.backgroundColor = .red
        
        if tagsScrollView?.superview != nil {
            tagsExist = true
        }
        
        if mentionsExist {
            frame.size.height = mentionsTableView.frame.origin.y - 55
        }else if tagsExist {
            
            frame.size.height = tagsScrollView!.frame.origin.y - 55
        }else{
            frame.size.height = frame.size.height + 30
        }
        //        descriptionTextField.backgroundColor = .yellow
        frame.size.width = descriptionWidth
        
        if mentionsExist || tagsExist {
            let caret = descriptionTextField.caretRect(for: descriptionTextField.selectedTextRange!.start)
            descriptionTextField.scrollRectToVisible(caret, animated: true)
        }
        
        let minHeight : CGFloat = 60
        let maxHeight = Utilities.screedHeight() - keyboardHeight! - 160
        if frame.size.height < minHeight {
            frame.size.height = minHeight
        }else if frame.size.height > maxHeight {
            frame.size.height = maxHeight
        }
        descriptionTextField.frame = frame
        
        descriptionTextField.translatesAutoresizingMaskIntoConstraints = true
        updateMainScrollViewHeight()
    }
    
    
    
    func updateMainScrollViewHeight(){
        
        mainScrollView.translatesAutoresizingMaskIntoConstraints = true
        
        var mainScrollViewFrame = mainScrollView.frame
        mainScrollViewFrame.size.height = Utilities.screedHeight() - keyboardHeight! - 126
        mainScrollView.frame = mainScrollViewFrame
        //        mainScrollView.backgroundColor = .cyan
        
        var cotentHeight = descriptionTextField.frame.size.height
        if imageUploader.selectedImage != nil {
            cotentHeight += attachmentImageView.frame.size.height + 44
        }
        mainScrollView.contentSize = CGSize(width:mainScrollView.frame.size.width, height:cotentHeight)
        /*if mainScrollView.frame.size.height !=
         (view.frame.size.height * 100/60 - keyboardHeight! - CGFloat(postAccessoryViewHeight)) {
         var mainScrollViewFrame = mainScrollView.frame
         mainScrollViewFrame.size.height = view.frame.size.height * 100/60 - keyboardHeight! - CGFloat(postAccessoryViewHeight)// - mainScrollView.frame.origin.y
         mainScrollView.frame = mainScrollViewFrame
         
         }*/
    }
    
}
extension PostAddViewController: ImageUploaderDelegate {
    func ImageSelected(_ image: UIImage) {
        attachmentImageView.image = image
        attachmentImageView.isHidden = false
        attachmentRemoveButton.isHidden = false
        updateMainScrollViewHeight()
    }
}
extension PostAddViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        adjustDescriptionTextViewHeight()
    }
    
    func updateCharactersRemaining(){
        
        //        DeveloperTools.print("updateCharactersRemaining ")
        var tagsLength = 0
        descriptionTextField.attributedText.enumerateAttribute(NSAttributedStringKey.attachment, in: NSRange(location: 0, length: descriptionTextField.attributedText.length), options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
            if value is NSTextAttachment {
                tagsLength += range.length
            }
        }
        var mentionLength = 0
        if mentionsListener.mentions.count > 0 {
            mentionLength = mentionsListener.mentions.first!.mentionRange.length
        }
        var effectiveLength = 0
        if descriptionTextField.text!.count == mentionLength && tagsLength == 0 && mentionLength != 0 {
            effectiveLength = 1
        } else if descriptionTextField.text!.count == tagsLength && mentionLength == 0 && tagsLength != 0 {
            effectiveLength = 1
        } else {
            effectiveLength = descriptionTextField.text!.count - tagsLength - mentionLength
        }
        //        DeveloperTools.print(descriptionTextField.text!.count, " - ", tagsLength, " - ",  mentionLength)
        let remainingChars = charLimit - effectiveLength
        if remainingChars < 0 {
        } else {
            /*charCountLabel*/postAccessory.charCountLabel.text = "\(remainingChars)"//" / \(charLimit)"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        /*let descriptionWidth = descriptionTextField.frame.size.width
         descriptionTextField.sizeToFit()
         
         var frame = descriptionTextField.frame
         frame.size.height = frame.size.height + 30
         frame.size.width = descriptionWidth
         if frame.size.height < 60 {
         frame.size.height = 60
         }
         descriptionTextField.frame = frame*/
        adjustDescriptionTextViewHeight()
        
        mainScrollView.contentSize = CGSize(width:mainScrollView.contentSize.width, height:descriptionTextField.frame.size.height + attachmentImageView.frame.size.height)
        if tagsScrollView != nil {
            tagsScrollView!.removeFromSuperview()
        }
        
        var textLength = descriptionTextField.text.count + text.count - range.length
        var mentionLength = 0
        if mentionsListener.mentions.count > 0 {
            mentionLength = mentionsListener.mentions.first!.mentionRange.length
        }
        var tagsLength = 0
        descriptionTextField.attributedText.enumerateAttribute(NSAttributedStringKey.attachment, in: NSRange(location: 0, length: descriptionTextField.attributedText.length), options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
            if value is NSTextAttachment {
                tagsLength += range.length
            }
        }
        textLength -= mentionLength
        textLength -= tagsLength
        if textLength <= charLimit {
            if text == "#" || (text.y_isAlphabet() && inHashtag(range: range)) {
                if text == "#" {
                    hashtagRange = range
                    hashtagRange!.length = 1
                }else{
                    hashtagRange!.length = range.location - range.length - hashtagRange!.location + 1
                }
                
                //            }
                //            DeveloperTools.print("last char location: ", range.location)f
                var result = (textView.text as NSString?)?.replacingCharacters(in: range, with: text) ?? ""
                if hashtagRange != nil {
                    if let filter = result.substring(with:hashtagRange!) {
                        result = filter
                    }
                }
                showTagSuggestions(filter:result)
            }else{
                
                //            hashtagRange = nil
            }
        }
        
        updateSendButtonStatus()
        //        return true
        let _ = descriptionTextField.text.count + text.count - range.length
        
        //        DeveloperTools.print("new length", newLength, " <= ", charLimit, " = ", newLength <= charLimit)
        if text == "" {
            return true
        } else {
            return textLength <= charLimit
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateSendButtonStatus()
        //        self.perform(#selector(scrollToText), with: nil, afterDelay:0.1)
        
        updateCharactersRemaining()
        //        charCountLabel.text = "\(charLimit-textView.text.count) / \(charLimit)"
    }
    
    //    @objc func scrollToText(){
    
    //        if descriptionTextField.frame.size.height >= CGFloat(lastDescriptionTextViewHeight) {
    //        descriptionTextField.backgroundColor = .red
    //        mainScrollView.backgroundColor = .yellow
    /*if let cursorPosition = descriptionTextField.selectedTextRange?.start {
     // cursorPosition is a UITextPosition object describing position in the text
     
     // if you want to know its position in textView in points:
     let caretPositionRect = descriptionTextField.caretRect(for: cursorPosition)
     mainScrollView.scrollRectToVisible(caretPositionRect, animated: false)
     //            lastDescriptionTextViewHeight = Int(descriptionTextField.frame.size.height)
     }*/
    //    }
    
}

extension PostAddViewController: MentionsManagerDelegate {
    
    private func setupTextView(_ textView: UITextView, delegate: SZMentionsListener) {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = delegate
    }
    
    private func mentionAttributes() -> [AttributeContainer] {
        var attributes = [AttributeContainer]()
        
        let attribute = SZAttribute(
            attributeName: NSAttributedStringKey.foregroundColor.rawValue,
            attributeValue: UIColor.primaryColor)
        let attribute2 = SZAttribute(
            attributeName: NSAttributedStringKey.font.rawValue,
            attributeValue: UIFont(name: Constants.regularFont(), size: 18)!)
        let attribute3 = SZAttribute(
            attributeName: NSAttributedStringKey.backgroundColor.rawValue,
            attributeValue: UIColor.clear)
        attributes.append(attribute)
        attributes.append(attribute2)
        attributes.append(attribute3)
        
        return attributes
    }
    
    private func defaultAttributes() -> [AttributeContainer] {
        var attributes = [AttributeContainer]()
        
        let attribute = SZAttribute(
            attributeName: NSAttributedStringKey.foregroundColor.rawValue,
            attributeValue: UIColor.greyishBrownTwo)
        let attribute2 = SZAttribute(
            attributeName: NSAttributedStringKey.font.rawValue,
            attributeValue: UIFont(name: Constants.regularFont(), size: 18)!)
        let attribute3 = SZAttribute(
            attributeName: NSAttributedStringKey.backgroundColor.rawValue,
            attributeValue: UIColor.white)
        attributes.append(attribute)
        attributes.append(attribute2)
        attributes.append(attribute3)
        
        return attributes
    }
    
    func showMentionsListWithString(_ mentionsString: String) {
        
        if mentionsTableView.superview == nil/* && mentionsListener?.mentions.count == 0*/ {
            
            self.updateMainScrollViewHeight()
            
            //            removeConstraints(constraints)
            if mentionsListener?.mentions.count == 0 {
                var frame = descriptionTextField.frame
                frame.origin.x = 0
                
                
                frame.origin.y = 20 + mainScrollView.frame.origin.y + mainScrollView.frame.size.height - mentionsTableViewHeight// - CGFloat(postAccessoryViewHeight) - 1//descriptionTextField.frame.origin.y + descriptionTextField.frame.size.height
                frame.size.height = mentionsTableViewHeight
                frame.size.width = self.view.frame.size.width
                mentionsTableView.frame = frame
                //            frame.size.height =
                view.addSubview(mentionsTableView)
            }
            /*addConstraints(
             NSLayoutConstraint.constraints(
             withVisualFormat: "|-5-[tableview]-5-|",
             options: NSLayoutFormatOptions(rawValue: 0),
             metrics: nil,
             views: ["tableview": mentionsTableView]))
             addConstraints(
             NSLayoutConstraint.constraints(
             withVisualFormat: "|-5-[textView]-5-|",
             options: NSLayoutFormatOptions(rawValue: 0),
             metrics: nil,
             views: ["textView": textView]))
             verticalConstraints = NSLayoutConstraint.constraints(
             withVisualFormat: "V:|-5-[tableview(100)][textView(30)]-5-|",
             options: NSLayoutFormatOptions(rawValue: 0),
             metrics: nil,
             views: ["textView": textView, "tableview": mentionsTableView])
             addConstraints(verticalConstraints)*/
        }
        
        
        
        
        dataManager?.filter(mentionsString)
        
        DeveloperTools.print("????", mentionsTableView.numberOfRows(inSection: 0))
        if mentionsTableView.numberOfRows(inSection: 0) > 0 {
            
            var frame = CGRect(x: 0, y: 0, width: mentionsTableView.frame.size.width, height: 1.5)
            let view = UIView(frame: frame)
            frame.origin.y = 1
            frame.size.height = 0.5
            let line = UIView(frame: frame)
            
            view.addSubview(line)
            line.backgroundColor = mentionsTableView.separatorColor
            mentionsTableView.tableHeaderView = view
        }else{
            mentionsTableView.removeFromSuperview()
            mentionsTableView.tableHeaderView = UIView()
            
        }
        adjustDescriptionTextViewHeight()
    }
    
    func hideMentionsList() {
        if mentionsTableView.superview != nil {
            mentionsTableView.removeFromSuperview()
            //            verticalConstraints = NSLayoutConstraint.constraints(
            //                withVisualFormat: "V:|-5-[textView(30)]-5-|",
            //                options: NSLayoutFormatOptions(rawValue: 0),
            //                metrics: nil,
            //                views: ["textView": textView])
            //            addConstraints(verticalConstraints)
        }
        dataManager?.filter(nil)
        adjustDescriptionTextViewHeight()
    }
    
    func didHandleMentionOnReturn() -> Bool {
        return true }
    
    //    override var intrinsicContentSize: CGSize {
    //        return CGSize(width: frame.size.width, height: mentionsTableView.superview == nil ? 40 : 140)
    //    }
}
