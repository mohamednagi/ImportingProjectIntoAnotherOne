//
//  PostTableViewCell.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import SDWebImage
import Gradientable
import UIImageViewAlignedSwift
import Lottie

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userImageButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var userFullNameButton: UIButton!
    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageViewAligned!
    @IBOutlet weak var postImageContainerView: UIView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var hashtagContainerContainer: UIView!
    @IBOutlet weak var hashtagContainer: UIScrollView!
    @IBOutlet weak var hashtagContainerStack: UIStackView!
    var dynamicHashtagContainer : UIView!
    
    @IBOutlet weak var bravoButton: UIButton!
    @IBOutlet weak var bravoImageView: UIImageView!
    @IBOutlet weak var bravoLabel: ArabicNumbersLabel!
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var commentLabel: ArabicNumbersLabel!
    
    @IBOutlet weak var pinnedImageView: UIImageView!
    @IBOutlet weak var bravoCommentHomeView: UIView!
    
    @IBOutlet weak var bravoAnimationView: AnimationView!
    
    //New Post Details view
    @IBOutlet weak var bravoCommentDetailsView: UIView!
    @IBOutlet weak var bravoDetailsButton: UIButton!
    @IBOutlet weak var bravoDetailsImageView: UIImageView!
    @IBOutlet weak var bravoDetailsLabel: ArabicNumbersLabel!
    @IBOutlet weak var numberOfBravosButton: UIButton!
    @IBOutlet weak var numberOfBravosImageView: UIImageView!
    @IBOutlet weak var numberOfBravosLabel: ArabicNumbersLabel!
    @IBOutlet weak var commentDetailsButton: UIButton!
    @IBOutlet weak var commentDetailsImageView: UIImageView!
    @IBOutlet weak var commentDetailsLabel: ArabicNumbersLabel!
    @IBOutlet weak var bravoDetailsAnimationView: AnimationView!
    
    
    var delegate : TableViewAdapter?
    var postDetailsVC: PostDetailsViewController?
    var contentTruncate = false
    var imageLoadToken : UInt32!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        pointsLabel.textColor = .primaryColor
    }
    
    //    @IBAction func sayBravo(_ sender: Any) {
    //
    //    }
    @IBAction func comment(_ sender: Any) {
        
    }
    @IBAction func gotoProfile(_ sender: Any) {
        
    }
    
    override func prepareForReuse() {
        
    }
    
    var viewModel: ViewModel = ViewModel() {
        didSet {
            if viewModel.IsPinned {
                self.pinnedImageView.isHidden = false
            } else {
                self.pinnedImageView.isHidden = true
            }
            if viewModel.FromPic == nil {//image download 1
                self.userImageView.image = UIImage(named:"profileBig")
            } else {
                self.userImageView.sd_setImage(with: URL(string:viewModel.FromPic!), placeholderImage: UIImage(named:"profileBig"))
            }
            
            if UserSettings.appLanguageIsArabic() && replaceHashtagTags(str:self.viewModel.AwardDescription!).y_firstAlphabetIsArabic() {
                //                print("\(viewModel.AwardDescription) > right")
                self.postContentLabel.textAlignment = .right
            } else {
                self.postContentLabel.textAlignment = .left
            }
            
            self.userImageView.y_roundedCorners()
            let awardDescription = replaceHashtagTags(str:self.viewModel.AwardDescription!).y_withLanguageDirectionInvisibleMarksAdded()
            
            let content = NSMutableAttributedString(string:awardDescription, attributes: [
                NSAttributedStringKey.font: UIFont(name: Constants.regularFont(), size: 14)!
                ] as [NSAttributedStringKey : Any])
            
            
            if self.contentTruncate {
                self.postContentLabel.numberOfLines = 2
                if content.string.components(separatedBy: "\n").count >= 2 {
                    let lines = content.string.components(separatedBy: "\n")
                    let twoLinesLength = lines[0].count + lines[1].count + 1
                    content.replaceCharacters(in: NSMakeRange(twoLinesLength, content.length - twoLinesLength), with: NSAttributedString(string:"..."))
                }
            }
            let final = NSMutableAttributedString()
            final.append(content)
            let tempFinal = NSMutableAttributedString(attributedString:final)
            
            imageLoadToken = arc4random_uniform(99999) + 1
            self.postContentLabel.attributedText = final
            reloadPostWithDownloadedUserImage(cell: self, final:tempFinal, image: nil, token: imageLoadToken)
            //            self.postContentLabel.attributedText = final
            //            reloadPostWithDownloadedUserImage(cell: self, final:final, image: nil)
            //            SDWebImageManager.shared().cachedImageExists(for: URL(string:viewModel.ToPic!)) { (cached) in
            //                DeveloperTools.print("cached or not cached: ", cached)
            //            }
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            var cachedResizedInPostContentUserImages = [String: UIImage]()
            if let homeDelegate = delegate as? HomeTableViewAdapter {
                
                cachedResizedInPostContentUserImages = homeDelegate.cachedResizedInPostContentUserImages
                
            } else if let postDetailsDelegate = delegate as? PostDetailsTableViewAdapter {
                
                cachedResizedInPostContentUserImages = postDetailsDelegate.cachedResizedInPostContentUserImages
                
            }
            if let image : UIImage = cachedResizedInPostContentUserImages[viewModel.ToPic!] {// = SDImageCache.shared().imageFromDiskCache(forKey: viewModel.ToPic!) {
                //use image
                //                print("exists \(viewModel.ToPic!)")
                self.reloadPostWithDownloadedUserImage(cell: self, final:final, image: image, token: self.imageLoadToken, imagePath: viewModel.ToPic!)
            } else {
                //                print("not exists \(viewModel.ToPic!)")
                SDWebImageManager.shared().loadImage(with: URL(string:self.viewModel.ToPic!), options: [], progress: { (recieved, expected, url) in//image download 2
                    
                }, completed: { (image, data, error, cacheType, finished, url) in
                    
                    var awardDescription = self.replaceHashtagTags(str: self.viewModel.AwardDescription!)
                    
                    //                print("before: \(self.viewModel.AwardDescription!)")
                    //                print("after: \(awardDescription)")
                    //                print("-----------------------------------")
                    /*let motivayHashtagTags : [String] = self.viewModel.AwardDescription.y_getRegexMatches(pattern: "<hashtag[^>]+>").reversed()
                     let motivayHashtagTagsRanges : [NSRange] = self.viewModel.AwardDescription.y_getRegexMatchesRanges(pattern: "<hashtag[^>]+>").reversed()
                     for i in 0 ..< motivayHashtagTags.count {
                     var tagStripped = motivayHashtagTags[i]
                     let range = motivayHashtagTagsRanges[i]
                     
                     tagStripped = tagStripped.replacingOccurrences(of: "<hashtag=", with: "")
                     tagStripped = tagStripped.replacingOccurrences(of: ">", with: "").trimmed
                     awardDescription = (awardDescription as NSString).replacingCharacters(in: range, with: tagStripped)
                     //.y_replaceRegexMatches(pattern: "<[hashtag=]\\p{Other}\(tagStripped)[^>]+>", replaceWith: tagStripped)
                     //                    }
                     }*/
                    //                if self.postContentLabel.textAlignment == .right {
                    awardDescription = awardDescription.y_withLanguageDirectionInvisibleMarksAdded()
                    //                }
                    let content = NSMutableAttributedString(string:awardDescription, attributes: [
                        NSAttributedStringKey.font: UIFont(name: Constants.regularFont(), size: 14)!
                        ] as [NSAttributedStringKey : Any])
                    
                    if self.contentTruncate {
                        self.postContentLabel.numberOfLines = 2
                        if content.string.components(separatedBy: "\n").count >= 2 {
                            let lines = content.string.components(separatedBy: "\n")
                            let twoLinesLength = lines[0].count + lines[1].count + 1
                            content.replaceCharacters(in: NSMakeRange(twoLinesLength, content.length - twoLinesLength), with: NSAttributedString(string:"..."))
                        }
                    }
                    let finalfinal = NSMutableAttributedString()
                    finalfinal.append(content)
                    
                    self.reloadPostWithDownloadedUserImage(cell: self, final:finalfinal, image: image, token:self.imageLoadToken, imagePath: self.viewModel.ToPic!)
                })
            }
            //            }
            if viewModel.ImagePost == nil {
                self.postImageView.image = nil
                self.postImageContainerView.isHidden = true
            } else {
                if UserSettings.appLanguageIsArabic()  {
                    //                    self.postContentLabel.textAlignment = .right
                    self.userFullNameLabel.textAlignment = .right
                    self.postImageView.alignRight = true
                } else {
                    //                    self.postContentLabel.textAlignment = .left
                    self.userFullNameLabel.textAlignment = .left
                    self.postImageView.alignLeft = true
                }
                self.postImageContainerView.isHidden = false
                
                self.postImageView.layer.mask = nil
                self.postImageView.sd_setImage(with: URL(string:viewModel.ImagePost), placeholderImage:UIImage(named:"imagePlaceholder"), options:[], completed:{ (image, error, cacheType, finished) in//image download 3
                    if image != nil {
                        let cornerRadiusAfterFitting = 4
                        
                        self.postImageView.y_roundCornersForAspectFitAlignRightOrLeft(radius: CGFloat(cornerRadiusAfterFitting), alignedRight:UserSettings.appLanguageIsArabic())
                        
                    }
                })
            }
            
            let attributes = [
                NSAttributedStringKey.foregroundColor : UIColor.battleshipGrey, NSAttributedStringKey.font: UIFont(name: Constants.regularFont(), size: 14)!
                ] as [NSAttributedStringKey : Any]
            
            //            print(viewModel.FromFullName, " <> ", viewModel.From)
            let string = NSMutableAttributedString(string: "\(viewModel.FromFullName) @\(viewModel.From)", attributes: [NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 14)!])
            self.userFullNameLabel.attributedText = string
            string.addAttributes(attributes, range:NSRange(self.userFullNameLabel.text!.range(of: "@\(viewModel.From)")!, in: self.userFullNameLabel.text!))
            self.userFullNameLabel.attributedText = string
            
            
            
            self.pointsLabel.text = "\(viewModel.TotalPoints!)"
            
            if UserSettings.appLanguageIsArabic() {
                self.timeLabel.text = viewModel.CreationDate.y_getDateFromString()!.y_timeAgoTodayOnlySinceDateInArabic()
                self.timeLabel.textAlignment = .left
            } else {
                self.timeLabel.text = viewModel.CreationDate.y_getDateFromString()!.y_timeAgoTodayOnlySinceDate(numericDates: true)
                self.timeLabel.textAlignment = .right
            }
            //
            self.hashtagContainer.subviews.forEach({ $0.removeFromSuperview() })
            
            //            if dynamicHashtagContainer != nil {
            //            dynamicHashtagContainer.removeFromSuperview()
            //            }
            //            var dynamicHashtagContainerX : CGFloat = 0
            //            if UserSettings.appLanguageIsArabic() {
            //                dynamicHashtagContainerX = 0
            //            }
            
            //            dynamicHashtagContainer = UIView(frame:CGRect(x:dynamicHashtagContainerX, y:0, width:hashtagContainerContainer.frame.size.width - 76, height:hashtagContainerContainer.frame.size.height))
            
            self.hashtagContainer.isUserInteractionEnabled = false
            //            dynamicHashtagContainer.isUserInteractionEnabled = false
            if viewModel.ListOfTags != nil {
                if viewModel.ListOfTags!.count > 0 {
                    self.hashtagContainer.isUserInteractionEnabled = true
                    //                    dynamicHashtagContainer.isUserInteractionEnabled = true
                }
                
                var xOffset : CGFloat = 0
                for hashtag in viewModel.ListOfTags! {
                    
                    let hashtagView = createHashtagView(hashtag.Name, hexColor: hashtag.Color)
                    var frame = hashtagView.frame
                    frame.origin.y = 16
                    frame.origin.x = xOffset
                    hashtagView.frame = frame
                    xOffset += hashtagView.frame.size.width + 10
                    
                    self.hashtagContainer.contentSize = CGSize(width: xOffset, height: self.hashtagContainer.contentSize.height)
                    //                self.hashtagContainer.addSubview(hashtagView)
                    self.hashtagContainer.addSubview(hashtagView)
                    //                dynamicHashtagContainer.contentSize = CGSize(width: xOffset, height: dynamicHashtagContainer.contentSize.height)
                    
                    //                dynamicHashtagContainer.addSubview(hashtagView)
                    
                }
                if self.hashtagContainer.contentSize.width < self.hashtagContainer.frame.size.width {
                    self.hashtagContainer.translatesAutoresizingMaskIntoConstraints = true
                    self.hashtagContainer.frame = CGRect(x:0, y:self.hashtagContainer.frame.origin.y, width:xOffset, height:self.hashtagContainer.frame.size.height)
                } else {
                    self.hashtagContainer.translatesAutoresizingMaskIntoConstraints = true
                    self.hashtagContainer.frame = CGRect(x:0, y:self.hashtagContainer.frame.origin.y, width:Utilities.screedWidth()-67, height:self.hashtagContainer.frame.size.height)
                }
                
                //                hashtagContainerContainer.addSubview(dynamicHashtagContainer)
                if UserSettings.appLanguageIsArabic() {
                    //                    if self.hashtagContainer.subviews.count > 0 {
                    
                    self.hashtagContainer.contentSize = CGSize(width: xOffset-10, height: self.hashtagContainer.contentSize.height)
                    //                    self.hashtagContainer.backgroundColor = .red
                    self.hashtagContainer.contentOffset = CGPoint(x: self.hashtagContainer.contentSize.width - self.hashtagContainer.frame.width, y:0)
                    //                    dynamicHashtagContainer.contentOffset = CGPoint(x: dynamicHashtagContainer.contentSize.width - dynamicHashtagContainer.frame.width, y:0)
                }
                //                }
            }
            
            self.commentLabel.text = "\(viewModel.NumberOfComments!) " + "Comment".y_localized
            self.commentDetailsLabel.text = "\(viewModel.NumberOfComments!) " + "Comment".y_localized
        }
    }
    
    func replaceHashtagTags(str: String) ->  String {
        if str.contains("<hashtag=") {
            var result = str
            let startRange = str.range(of: "<hashtag=")
            
            let myRange: Range<String.Index> = startRange!.lowerBound ..< result.endIndex
            //            print(result, " \(startRange!.upperBound.encodedOffset) to \(result.count - startRange!.upperBound.encodedOffset)")
            result = result.y_replaceFirst(of: ">", with: "", inRange: myRange)
            //            print(result)
            return replaceHashtagTags(str: result.y_replaceFirst(of: "<hashtag=", with:""
            ))
            /*var result = str
             let motivayHashtagTags : [String] = str.y_getRegexMatches(pattern: "<hashtag[^>]+>").reversed()
             
             for i in 0 ..< motivayHashtagTags.count {
             var tagStripped = motivayHashtagTags[i]
             
             tagStripped = tagStripped.replacingOccurrences(of: "<hashtag=", with: "")
             tagStripped = tagStripped.replacingOccurrences(of: ">", with: "").trimmed
             result = result.replacingOccurrences(of: motivayHashtagTags[i], with: tagStripped)
             }*/
        }
        return str
    }
    
    func reloadPostWithDownloadedUserImage(cell: PostTableViewCell, final: NSMutableAttributedString, image: UIImage?, token: UInt32?, imagePath: String? = nil){
        var cachedResizedInPostContentUserImages = [String: UIImage]()
        if let homeDelegate = delegate as? HomeTableViewAdapter {
            
            cachedResizedInPostContentUserImages = homeDelegate.cachedResizedInPostContentUserImages
            
        } else if let postDetailsDelegate = delegate as? PostDetailsTableViewAdapter {
            
            cachedResizedInPostContentUserImages = postDetailsDelegate.cachedResizedInPostContentUserImages
            
        }
        if self.imageLoadToken == token {
            //                print("load then")
            let image1Attachment = NSTextAttachment()
            let image1AttachmentBounds = CGRect(x: 0.0, y: -24/2 - cell.postContentLabel.font!.descender + 2, width: 24, height: 24)
            if image == nil || imagePath == nil {
                image1Attachment.image = UIImage(named:"profileBig")//!.y_imageWithRoundedCorners(radius: 12, inFrame: CGRect(x: 0, y: 0, width: 24, height: 24))
            } else {
                if cachedResizedInPostContentUserImages[imagePath!] == nil {
                    cachedResizedInPostContentUserImages[imagePath!]  = image!.y_resizedImage(newWidth: 24).y_imageWithRoundedCorners(radius: 12, inFrame: CGRect(x: 0, y: 0, width: 24, height: 24))
                    //                print("not cached ",  cachedResizedInPostContentUserImages.count)
                } else {
                    //                 print("cached")
                }
                image1Attachment.image = cachedResizedInPostContentUserImages[imagePath!]
            }
            image1Attachment.bounds = image1AttachmentBounds
            let image1String = NSAttributedString(attachment: image1Attachment)
            
            let toUserString = NSAttributedString(string: "@\(self.viewModel.To!)", attributes: [NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 14)!, NSAttributedStringKey.foregroundColor: UIColor.primaryColor])
            
            let user = NSMutableAttributedString()
            //                user.append(NSAttributedString(string:"\u{202B}"))
            //        user.append(image1String)
            user.append(NSAttributedString(string:" "))
            user.append(toUserString)
            
            //                let motivayUserTag : [String] = final.string.y_getRegexMatches(pattern: "<user[^>]+>")
            //                let motivayHashtagTagsRange : [NSRange] = final.string.y_getRegexMatchesRanges(pattern: "<user[^>]+>")
            
            //                                for motivayTag in motivayHashtagTags {
            //                                print("final str \(final.string)")
            let tagStartRange = final.string.range(of: "<user")
//            let tagEndRange = final.string.range(of: ">")
            var tagEndRange = final.string.range(of: ">")
            let tagEndRanges = final.string.ranges(of: ">")
            if tagEndRanges.count > 1 {
                for range in tagEndRanges {
                    if tagStartRange != nil {
                        if range.lowerBound.encodedOffset > tagStartRange!.lowerBound.encodedOffset {
                            tagEndRange = range
                            continue
                        }
                    }
                }
            }
            var finalRange : NSRange?
            if tagStartRange != nil && tagEndRange != nil {
                finalRange = NSRange(location:tagStartRange!.lowerBound.encodedOffset, length:tagEndRange!.upperBound.encodedOffset - tagStartRange!.lowerBound.encodedOffset)
            }
            //                let userRange =
            if finalRange != nil {
                final.replaceCharacters(in:finalRange!, with: user)
            }
            //                                }
            cell.postContentLabel.attributedText = final
            
            if cell.contentTruncate == false {
                cell.postContentLabel.translatesAutoresizingMaskIntoConstraints = true
                cell.postContentLabel.numberOfLines = 0
                
                cell.postContentLabel.sizeToFit()
                //bug fix: if want to change height remove constrains and lose the rtl automatic swith
                
                var frame = cell.postContentLabel.frame
                frame.size.width = Utilities.screedWidth() - cell.userImageView.frame.size.width - 16 - 8 - 10
                if UserSettings.appLanguageIsArabic() {
                    frame.origin.x = 10
                }
                cell.postContentLabel.frame = frame
            } else {
                cell.postContentLabel.translatesAutoresizingMaskIntoConstraints = false
                cell.postContentLabel.numberOfLines = 2
            }
        }
        
    }
    
    func createHashtagView(_ hashtagName : String, hexColor: String) -> GradientableView {
        let labelX = 16
        let labelY = 6
        let labelHeight = 20
        let fontSize = 14
        let radius = 16
        
        let name = hashtagName
        
        let label = UILabel(frame:CGRect(x:labelX, y:labelY, width:50, height:labelHeight))
        label.text = name
        label.font = label.font.withSize(CGFloat(fontSize))
        label.textColor = .white
        label.sizeToFit()
        
        var gradViewFrame : CGRect!
        
        gradViewFrame = CGRect(x:0, y:0, width:label.frame.origin.x + label.frame.size.width + 16, height:28)
        
        let gradView = GradientableView(frame:gradViewFrame)
        gradView.set(options: GradientableOptions(colors: [UIColor(hexString:hexColor, alpha:1), UIColor(hexString:hexColor, alpha:0.5)]))
        
        let options = GradientableOptions(direction: .bottomLeftToTopRight)
        gradView.set(options: options)
        gradView.layer.cornerRadius = CGFloat(radius)
        gradView.clipsToBounds = true
        
        
        gradView.addSubview(label)
        
        return gradView
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

extension PostTableViewCell {
    struct ViewModel {
        var PostId: Int!
        var From : String = ""
        var FromFullName : String = ""
        var FromPic : String?
        var FromUserId: String!
        var ImagePost: String!
        var IsAllowedForBravo: Bool!
        var ListOfComments: [PostComment]?
        var ListOfTags: [Hashtag]?
        var AwardDescription : String!
        var CreationDate : String!
        var To : String!
        var ToPic : String?
        var ToUserId: String!
        var NumberOfComments : Int!
        var NumberOfSayBravo : Int!
        var TotalPoints: Int!
        var IsPinned: Bool!
        
        let hasImage : Bool!
        //        let searchTerm : String?
    }
}

extension PostTableViewCell.ViewModel {
    init(post: Post, _searchTerm: String?) {
        PostId = post.PostId
        if post.From != nil {
            From = post.From!
        }
        FromFullName = post.FromFullName
        FromPic = post.FromPic
        FromUserId = post.FromUserId
        ImagePost = post.ImagePost
        IsAllowedForBravo = post.IsAllowedForBravo
        ListOfComments = post.ListOfComments
        
        if UserSettings.appLanguageIsArabic() {
            ListOfTags = post.ListOfTags?.reversed()
        }else{
            ListOfTags = post.ListOfTags
        }
        AwardDescription = post.AwardDescription
        CreationDate = post.CreationDate
        To = post.To
        if post.ToPic == nil {
            ToPic = ""
        }else{
            ToPic = post.ToPic
        }
        //            viewModel.ToPic = "https://griffonagedotcom.files.wordpress.com/2016/07/profile-modern-2e.jpg"
        ToUserId = post.ToUserId
        NumberOfComments = post.NumberOfComments
        NumberOfSayBravo = post.NumberOfSayBravo
        TotalPoints = post.TotalPoints
        IsPinned = post.IsPinned
        
        hasImage = post.hasImage
        //        searchTerm = _searchTerm
    }
    
    init() {
        
        PostId = 0
        From = ""
        FromFullName = ""
        FromPic = ""
        FromUserId = ""
        ImagePost = ""
        IsAllowedForBravo = false
        ListOfComments = []
        ListOfTags = []
        AwardDescription = ""
        CreationDate = ""
        To = ""
        ToPic = ""
        ToUserId = ""
        NumberOfComments = 0
        NumberOfSayBravo = 0
        TotalPoints = 0
        IsPinned = false
        
        hasImage = false
        //        searchTerm = ""
    }
}
