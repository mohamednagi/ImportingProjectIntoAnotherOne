//
//  NotificationTableViewCell.swift
//  Motivay
//
//  Created by Yasser Osama on 3/19/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var notificationActionerImageView: UIImageView!
    @IBOutlet weak var notificationTypeImageView: UIImageView!
    @IBOutlet weak var notificationTitle: AutomaticallyLocalizedLabel!
    @IBOutlet weak var notificationDateLabel: UILabel!
    @IBOutlet weak var notificationTimeLabel: UILabel!
    
    var viewModel: ViewModel = ViewModel() {
        didSet {
            notificationActionerImageView.y_circularRoundedCorner()
            switch viewModel.notificationType {
            case .like?:
                notificationTypeImageView.image = #imageLiteral(resourceName: "notifLike")
            case .comment?:
                notificationTypeImageView.image = #imageLiteral(resourceName: "notifComment")
            case .thanks?:
                notificationTypeImageView.image = #imageLiteral(resourceName: "notifPost")
            default:
                notificationTypeImageView.image = UIImage()
                notificationActionerImageView.image = #imageLiteral(resourceName: "systemNotification")
            }
            
            let date = viewModel.date.y_getDateFromString()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy, h:mm a"
            if UserSettings.appLanguageIsArabic() {
                formatter.locale = Locale(identifier: "ar")
            } else {
                formatter.locale = Locale(identifier: "en")
            }
//            let current = formatter.string(from: date!).y_getDateFromString()
//            let currentDate = current.UTCToLocal().getDateFromString()
            formatter.dateFormat = "dd MMM YYYY"
            let dateStr = formatter.string(from: date!)
            notificationDateLabel.text = dateStr
            notificationDateLabel.font = UIFont(name: Constants.regularFont(), size: 14)!
            formatter.dateFormat = "hh:mm a"
            let timeStr = formatter.string(from: date!)
            notificationTimeLabel.text = timeStr
            notificationTimeLabel.font = UIFont(name: Constants.regularFont(), size: 14)!
            
            switch viewModel.notificationType {
                case .thanks?:
                
//                    print(" ", viewModel.notificationType, " > \(viewModel.senderImage)")
                    let url = URL(string: viewModel.senderImage ?? "")
                    notificationActionerImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "profile")) { (image, error, cacheType, imageUrl) in
                        if image == nil {
                            self.notificationActionerImageView.image = #imageLiteral(resourceName: "profile")
                        } else {
                            
                        }
                    }
                break
            case .like?, .comment?:
                
                let url = URL(string: viewModel.actionerImage ?? "")
                notificationActionerImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "profile")) { (image, error, cacheType, imageUrl) in
                    if image == nil {
                        self.notificationActionerImageView.image = #imageLiteral(resourceName: "profile")
                    } else {
                        
                    }
                }
            default:
                notificationActionerImageView.image = #imageLiteral(resourceName: "systemNotification")
            }
            if viewModel.notificationType == .comment {
                notificationTitle.attributedText = commentText(viewModel: viewModel)
            } else if viewModel.notificationType == .like {
                notificationTitle.attributedText = bravoText(viewModel: viewModel)
            } else if viewModel.notificationType == .thanks {
                notificationTitle.attributedText = thankYouText(viewModel: viewModel)
            } else if viewModel.notificationType == .approved {
                notificationTitle.attributedText = pinnedApprovedPostText(viewModel: viewModel)
            } else if viewModel.notificationType == .pinned {
                notificationTitle.attributedText = pinnedApprovedPostText(viewModel: viewModel)
            } else if viewModel.notificationType == .star {
                notificationTitle.attributedText = starText()
            } else if viewModel.notificationType == .sendThreshold {
                notificationTitle.attributedText = sendTresholdText()
            } else if viewModel.notificationType == .receiveThreshold {
                notificationTitle.attributedText = receiveThresholdText()
            } else if viewModel.notificationType == .rejected {
                notificationTitle.attributedText = pinnedApprovedPostText(viewModel: viewModel)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func thankYouText(viewModel: ViewModel) -> NSMutableAttributedString {
        let sender = viewModel.senderName!
        let points = viewModel.points!
        var attributedString: NSMutableAttributedString!
        if viewModel.tags != nil {
            var str = ""
            let gaveYou = "gave you".y_localized
            let firstPart = "\(sender) \(gaveYou) "
            var pointsStr = "\(points) points"
            if UserSettings.appLanguageIsArabic() {
                if points <= 10 {
                    pointsStr = "\(points) " + "point".y_localized
                } else {
                    pointsStr = "\(points) " + "points".y_localized
                }
            }
            let forYour = "for your".y_localized
            let and = "and".y_localized
            let tags = viewModel.tags!
            if tags.count > 1 {
                var tagsNameArr = [String]()
                for i in tags {
                    tagsNameArr.append(i)
                }
                var tagsArrExceptLast = tagsNameArr
                tagsArrExceptLast.removeLast()
                let tagsString = tagsArrExceptLast.joined(separator: ", ")
                str = firstPart + "\(pointsStr) \(forYour) \(tagsString) \(and) \(tagsNameArr.last!)."
            } else if tags.count == 1 {
                str = firstPart + "\(pointsStr) \(forYour) \(tags.first!)."
            } else if tags.count == 0 {
                str = firstPart + pointsStr + "."
            }
            attributedString = NSMutableAttributedString(string: str, attributes: [
                .font: UIFont(name: Constants.regularFont(), size: 16.0)!,
                .foregroundColor: UIColor(white: 3.0 / 255.0, alpha: 1.0)
                ])
            attributedString.addAttribute(.font, value: UIFont(name: Constants.boldFont(), size: 16.0)!, range: NSRange(location: 0, length: sender.count))
            attributedString.addAttributes([
                .font: UIFont(name: Constants.boldFont(), size: 16.0)!,
                .foregroundColor: UIColor.primaryColor
                ], range: NSRange(location: firstPart.count, length: pointsStr.count))
        }
        return attributedString
    }
    
    func bravoText(viewModel: ViewModel) -> NSMutableAttributedString {
        let receiver = viewModel.receiverName ?? "Unknow Profile"
        let actioner = viewModel.actionerName ?? "Unknow Profile"
        let sender = viewModel.senderName!
        let count = viewModel.actionerCount!
        var str = ""
        var firstPart = ""
        var secondPart = ""
        let bravo = Fonts.bravo.y_localized
        var other = "other".y_localized
        var said = "said".y_localized
        
        if count > 2 {
        } else {
            if UserSettings.appLanguageIsArabic() {
                other = "others".y_localized
                said = "said1".y_localized
            }
        }
        
        let and = "and".y_localized
        let on = "on".y_localized
        let yourMotive = "your motive post to ".y_localized
        if count > 1 {
            firstPart = "\(actioner) \(and) \(count - 1) \(other) \(said) \(bravo) \(on) "
            if UserSettings.info?.userID == viewModel.senderId {
                secondPart = firstPart + yourMotive
                str = secondPart + receiver
            } else {
                str = firstPart + "\(sender)'s motive post."
                if UserSettings.appLanguageIsArabic() {
                    secondPart = firstPart + "post ".y_localized
                    str = secondPart + receiver + "motive ".y_localized
                }
            }
        } else {
            firstPart = "\(actioner) " + "\(said) \(bravo) \(on) "
            if UserSettings.info?.userID == viewModel.senderId {
                secondPart = firstPart + yourMotive
                str = secondPart + receiver
            } else {
                str = firstPart + "\(sender)'s motive post."
                if UserSettings.appLanguageIsArabic() {
                    secondPart = firstPart + "post ".y_localized
                    str = secondPart + receiver + "motive ".y_localized
                }
            }
        }
        let attributedString = NSMutableAttributedString(string: str, attributes: [
            .font: UIFont(name: Constants.regularFont(), size: 16.0)!,
            .foregroundColor: UIColor(white: 3.0 / 255.0, alpha: 1.0)
            ])
        attributedString.addAttribute(.font, value: UIFont(name: Constants.boldFont(), size: 16.0)!, range: NSRange(location: 0, length: actioner.count))
        
        if count > 1 {
            attributedString.addAttributes([
                .font: UIFont(name: Constants.boldFont(), size: 16.0)!,
                .foregroundColor: UIColor.primaryColor
                ], range: NSRange(location: "\(actioner) \(and) \(count - 1) \(other) \(said) ".count, length: bravo.count))
        } else {
            attributedString.addAttributes([
                .font: UIFont(name: Constants.boldFont(), size: 16.0)!,
                .foregroundColor: UIColor.primaryColor
                ], range: NSRange(location: "\(actioner) \(said) ".count, length: bravo.count))
        }
        
        if secondPart.isEmpty {
            attributedString.addAttribute(.font, value: UIFont(name: Constants.boldFont(), size: 16.0)!, range: NSRange(location: firstPart.count, length: sender.count))
        } else {
            attributedString.addAttribute(.font, value: UIFont(name: Constants.boldFont(), size: 16.0)!, range: NSRange(location: secondPart.count, length: receiver.count))
        }
        return attributedString
    }
    
    func commentText(viewModel: ViewModel) -> NSMutableAttributedString {
        let receiver = viewModel.receiverName ?? "Unknow Profile"
        let actioner = viewModel.actionerName ?? "Unknow Profile"
        let sender = viewModel.senderName!
        let count = viewModel.actionerCount!
        var str = ""
        var firstPart = ""
        var secondPart = ""
        var action = ""
        var other = "other".y_localized
        
        if count > 2 {
            action = "replied".y_localized
        } else {
            if UserSettings.appLanguageIsArabic() {
                other = "others".y_localized
                action = "replied1".y_localized
            } else {
                action = "replied"
            }
        }
        
        let and = "and".y_localized
        let on = "on".y_localized
        let yourMotive = "your motive post to ".y_localized
        if count > 1 {
            firstPart = "\(actioner) \(and) \(count - 1) \(other) \(action) \(on) "
            if UserSettings.info?.userID == viewModel.senderId {
                secondPart = firstPart + yourMotive
                str = secondPart + receiver
            } else {
                str = firstPart + "\(sender)'s motive post."
                if UserSettings.appLanguageIsArabic() {
                    secondPart = firstPart + "post ".y_localized
                    str = secondPart + receiver + "motive ".y_localized
                }
            }
        } else {
            firstPart = "\(actioner) " + "\(action) \(on) "
            if UserSettings.info?.userID == viewModel.senderId {
                secondPart = firstPart + yourMotive
                str = secondPart + receiver
            } else {
                str = firstPart + "\(sender)'s motive post."
                if UserSettings.appLanguageIsArabic() {
                    secondPart = firstPart + "post ".y_localized
                    str = secondPart + receiver + "motive ".y_localized
                }
            }
        }
        let attributedString = NSMutableAttributedString(string: str, attributes: [
            .font: UIFont(name: Constants.regularFont(), size: 16.0)!,
            .foregroundColor: UIColor(white: 3.0 / 255.0, alpha: 1.0)
            ])
        attributedString.addAttribute(.font, value: UIFont(name: Constants.boldFont(), size: 16.0)!, range: NSRange(location: 0, length: actioner.count))
        if secondPart.isEmpty {
            attributedString.addAttribute(.font, value: UIFont(name: Constants.boldFont(), size: 16.0)!, range: NSRange(location: firstPart.count, length: sender.count))
        } else {
            attributedString.addAttribute(.font, value: UIFont(name: Constants.boldFont(), size: 16.0)!, range: NSRange(location: secondPart.count, length: receiver.count))
        }
        
        return attributedString
    }
    
    func pinnedApprovedPostText(viewModel: ViewModel) -> NSMutableAttributedString {
        let receiver = viewModel.receiverName ?? "Unknow Profile"
        let pinned = "has been pinned.".y_localized
        let approved = "has been approved.".y_localized
        let rejected = "has been rejected.".y_localized
        let firstPart = "Your motive post to "
        var action = ""
        if viewModel.notificationType == .pinned {
            action = pinned
        } else if viewModel.notificationType == .approved {
            action = approved
        } else if viewModel.notificationType == .rejected {
            action = rejected
        }
        var str = firstPart + "\(receiver) " + action
        var attributedString = NSMutableAttributedString(string: str, attributes: [
            .font: UIFont(name: Constants.regularFont(), size: 16.0)!,
            .foregroundColor: UIColor(white: 3.0 / 255.0, alpha: 1.0)
            ])
        if UserSettings.appLanguageIsArabic() {
            str = action + receiver + "."
            attributedString = NSMutableAttributedString(string: str, attributes: [
                .font: UIFont(name: Constants.regularFont(), size: 16.0)!,
                .foregroundColor: UIColor(white: 3.0 / 255.0, alpha: 1.0)
                ])
            attributedString.addAttribute(.font, value: UIFont(name: Constants.boldFont(), size: 16.0)!, range: NSRange(location: action.count, length: receiver.count))
        } else {
            attributedString.addAttribute(.font, value: UIFont(name: Constants.boldFont(), size: 16.0)!, range: NSRange(location: firstPart.count, length: receiver.count))
        }
        
        return attributedString
    }
    
    func starText() -> NSMutableAttributedString {
        let str = "Congratulations! You are one of the stars, Keep it up.".y_localized
        let attributedString = NSMutableAttributedString(string: str, attributes: [
            .font: UIFont(name: Constants.regularFont(), size: 16.0)!,
            .foregroundColor: UIColor(white: 3.0 / 255.0, alpha: 1.0)
            ])
        return attributedString
    }
    
    func receiveThresholdText() -> NSMutableAttributedString {
        let str = "Unfortunately, you didn't receive enough points this month. We believe that you can do better.".y_localized
        let attributedString = NSMutableAttributedString(string: str, attributes: [
            .font: UIFont(name: Constants.regularFont(), size: 16.0)!,
            .foregroundColor: UIColor(white: 3.0 / 255.0, alpha: 1.0)
            ])
        return attributedString
    }
    
    func sendTresholdText() -> NSMutableAttributedString {
        let stillHave = "You still have ".y_localized
        let inBalance = "in your balance, ".y_localized
        let motivate = "try to motivate your colleagues.".y_localized
        let pointsStr = "\(UserSettings.info?.Balance ?? 0) " + "points".y_localized
        let str = stillHave + "\(pointsStr) " + inBalance + motivate
        let attributedString = NSMutableAttributedString(string: str, attributes: [
            .font: UIFont(name: Constants.regularFont(), size: 16.0)!,
            .foregroundColor: UIColor(white: 3.0 / 255.0, alpha: 1.0)
            ])
        attributedString.addAttribute(.font, value: UIFont(name: Constants.boldFont(), size: 16.0)!, range: NSRange(location: stillHave.count, length: pointsStr.count))
        return attributedString
    }
}

extension NotificationTableViewCell {
    struct ViewModel {
        var notificationType: NotificationType!
        var actionerImageUrl: String!
        var points: Int!
        var receiverName: String!
        var senderName: String!
        var senderImage: String!
        var senderId: String!
        var actionerName: String!
        var actionerImage: String!
        var actionerCount: Int!
        var tags: [String]?
        var date: String!
    }
}

extension NotificationTableViewCell.ViewModel {
    init(notification: NotificationModel) {
        notificationType = notification.type
        actionerImageUrl = ""
        points = notification.points
        receiverName = notification.receiverName
        senderName = notification.senderName
        senderImage = notification.senderImage
        senderId = notification.senderId
        actionerName = notification.actionerName
        actionerImage = notification.actionerImage
        actionerCount = notification.actionerCount
        tags = notification.tags
        date = notification.date
    }
}
