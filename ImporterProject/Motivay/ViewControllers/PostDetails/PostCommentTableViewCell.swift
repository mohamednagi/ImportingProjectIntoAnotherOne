//
//  PostTableViewCell.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import SDWebImage
import Gradientable

class PostCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userImageButton: UIButton!
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var userFullNameButton: UIButton!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var postCommentContentLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    var parentAdapter: PostDetailsTableViewAdapter!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func gotoProfile(_ sender: Any) {
        
    }
    
    var viewModel: ViewModel = ViewModel() {
        didSet {
            
            if viewModel.UserImage == nil {
                self.userImageView.image = UIImage(named:"profileBig")
            }else{
                self.userImageView.sd_setImage(with: URL(string:viewModel.UserImage!), placeholderImage: UIImage(named:"profileBig"))
            }
            
            let content = NSMutableAttributedString(string:viewModel.Message.trimmed, attributes: [
                NSAttributedStringKey.font: UIFont(name: Constants.regularFont(), size: 14)!
                ] as [NSAttributedStringKey : Any])
            
            
            let to = NSAttributedString(string: "Replying to ".y_localized, attributes: [NSAttributedStringKey.font: UIFont(name: Constants.regularFont(), size: 14)!, NSAttributedStringKey.foregroundColor: UIColor.battleshipGrey])
            
            
            
            let toUserString = NSAttributedString(string: "@\(viewModel.post.From!)", attributes: [NSAttributedStringKey.font: UIFont(name: Constants.regularFont(), size: 14)!, NSAttributedStringKey.foregroundColor: UIColor.primaryColor])
            
            let final = NSMutableAttributedString()
            final.append(to)
            final.append(toUserString)
            self.toLabel.attributedText = final
//            if UserSettings.appLanguageIsArabic() == false {
//                final.append(NSAttributedString(string:" "))
//                final.append(to)
//            }
//            final.append(NSAttributedString(string:" "))
//            final.append(image1String)
//            final.append(NSAttributedString(string:" "))
//            final.append(toUserString)
            
//            if UserSettings.appLanguageIsArabic() {
//                final.append(NSAttributedString(string:" "))
//                final.append(to)
//            }
//            if viewModel.searchTerm != nil {
//                final.addAttributes(attributes, range:NSRange(final.range(of: viewModel.searchTerm)!, in: button.titleLabel!.text!))
//            }
            
            self.postCommentContentLabel.attributedText = content
            
            if let postComment = parentAdapter.data[self.tag] as? PostComment {
            let showMore = postComment.showMore
            if showMore {
                self.postCommentContentLabel.numberOfLines = 0
            }else{
                self.postCommentContentLabel.numberOfLines = 2
            }
            if viewModel.Message.y_getLinesArrayOfString(in: self.postCommentContentLabel).count > 1 {
                var str = ""
                if showMore {
                    str = "Show less".y_localized
                    let showMoreLess = NSAttributedString(string: str, attributes: [NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 12)!, NSAttributedStringKey.foregroundColor: UIColor.primaryColor])
                    content.append(NSAttributedString(string:"\n"))
                    content.append(showMoreLess)
                    self.postCommentContentLabel.adjustsFontSizeToFitWidth = false
                    self.postCommentContentLabel.lineBreakMode = .byWordWrapping
                    self.postCommentContentLabel.attributedText = content
                    
                }else{
                    str = "Show more".y_localized
                    let showMoreLess = NSAttributedString(string: str, attributes: [NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 12)!, NSAttributedStringKey.foregroundColor: UIColor.primaryColor])
                    let textLines = viewModel.Message.y_getLinesArrayOfString(in: self.postCommentContentLabel)
                    let twoLinesAndShowMore = NSMutableAttributedString(string:"\(textLines[0].trimmed)" , attributes: [
                        NSAttributedStringKey.font: UIFont(name: Constants.regularFont(), size: 14)!
                        ] as [NSAttributedStringKey : Any])
                    twoLinesAndShowMore.append(NSAttributedString(string:"\n"))
                    twoLinesAndShowMore.append(showMoreLess)
                    self.postCommentContentLabel.adjustsFontSizeToFitWidth = true
                    self.postCommentContentLabel.minimumScaleFactor = 0.5
                    self.postCommentContentLabel.attributedText = twoLinesAndShowMore
                    self.postCommentContentLabel.lineBreakMode = .byTruncatingTail
                }
                self.postCommentContentLabel.sizeToFit()
            }
            }
            
            let attributes = [
                NSAttributedStringKey.foregroundColor : UIColor.battleshipGrey, NSAttributedStringKey.font: UIFont(name: Constants.regularFont(), size: 14)!
                ] as [NSAttributedStringKey : Any]
            
            let string = NSMutableAttributedString(string: "\(viewModel.FullName!) @\(viewModel.UserName!)", attributes: [NSAttributedStringKey.font: UIFont(name: Constants.boldFont(), size: 14)!])
            self.userFullNameLabel.attributedText = string
            string.addAttributes(attributes, range:NSRange(self.userFullNameLabel.text!.range(of: "@\(viewModel.UserName!)")!, in: self.userFullNameLabel.text!))
            self.userFullNameLabel.attributedText = string
            
            
            if UserSettings.appLanguageIsArabic() {
                self.timeLabel.text = viewModel.CreationDate.y_getDateFromString()!.y_timeAgoTodayOnlySinceDateInArabic()
                self.timeLabel.textAlignment = .left
            }else{
                self.timeLabel.text = viewModel.CreationDate.y_getDateFromString()!.y_timeAgoTodayOnlySinceDate(numericDates: true)
                self.timeLabel.textAlignment = .right
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension PostCommentTableViewCell {
    struct ViewModel {
        var Id: Int!
        var From : String!
        var UserImage : String!
        var UserName : String?
        var FullName : String?
        var Message: String!
        var CreationDate : String!
        
        var post: Post
        var isMyComment : Bool
    }
}

extension PostCommentTableViewCell.ViewModel {
    init(postComment: PostComment, _post:Post) {
        Id = postComment.Id
        From = postComment.From
        UserName = postComment.UserName
        if postComment.FullName == nil {
            FullName = ""
        }else{
            FullName = postComment.FullName
        }
        UserImage = postComment.UserImage
//        FromUserId = postComment.FromUserId
        Message = postComment.Message
        CreationDate = postComment.CreationDate
//        To = postComment.To
//        ToPic = postComment.ToPic
//        ToUserId = postComment.ToUserId
        
        post = _post
        isMyComment = postComment.isMyComment
    }
    
    init() {
        
        Id = 0
        From = ""
        UserImage = ""
        UserName = ""
        FullName = ""
        Message = ""
        CreationDate = ""
        
        post = Post(JSON:JSON())!
        isMyComment = false
    }
}
