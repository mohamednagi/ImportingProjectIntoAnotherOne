//
//  RewardsSubcategoryTableViewCell.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import SDWebImage
import PDFKit

class RewardsSubcategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rewardImageView: UIImageView!
    @IBOutlet weak var pointsLabel: ArabicNumbersLabel!
    
    @IBOutlet weak var titleLabel: AutomaticallyLocalizedLabel!
    @IBOutlet weak var descriptionLabel: AutomaticallyLocalizedLabel!
    
    @IBOutlet weak var redeemContainerView: UIView!
    @IBOutlet weak var redeemButton: UIButton!
    @IBOutlet weak var redeemImageView: UIImageView!
    @IBOutlet weak var redeemTitle: AutomaticallyLocalizedLabel!
    
    @IBOutlet weak var bookmarkContainterView: UIView!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var bookmarkImageView: UIImageView!
    @IBOutlet weak var bookmarkTitle: AutomaticallyLocalizedLabel!
    
    var isRedeemedVC = false
    
    
    @IBOutlet weak var redeemedLabel: AutomaticallyLocalizedLabel!
    
    var reward: Reward! {
        didSet {
            self.titleLabel.text = reward.RewardName
            self.descriptionLabel.text = reward.VendorName
            self.pointsLabel.text = Utilities.suffixNumber(number: NSNumber(integerLiteral: reward.RewardsPoints))
//            self.pointsLabel.text = "\(reward.RewardsPoints!)"
            
            
            if reward.RewardImage == nil {
                self.rewardImageView.sd_setImage(with: URL(string:"group-1"))
            }else{
                self.rewardImageView.sd_setImage(with: URL(string:reward.RewardImage), placeholderImage:UIImage(named:"group-1"))
                
                //unrelated pdf exporting code
                /*
 let pdfDocument = PDFDocument()
                
                // Load or create your UIImage
                let image = self.rewardImageView.image
                
                 Create a PDF page instance from your image
                let pdfPage = PDFPage(image: image!)
                
                // Insert the PDF page into your document
                pdfDocument.insert(pdfPage!, at: 0)
                
                // Get the raw data of your PDF document
                let data = pdfDocument.dataRepresentation()
                
//                 The url to save the data to
                do {
                let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
                let url = documentDirectory.appendingPathComponent("gdfToThe.pdf")
                
                // Save the data to the url
                try! data!.write(to: url)
                    print("savvved")
                    
                    
                        let filePath = url.path
                        let fileManager = FileManager.default
                        if fileManager.fileExists(atPath: filePath) {
                            print("FILE AVAILABLE")
                        } else {
                            print("FILE NOT AVAILABLE")
                        }
                    print(filePath)
                    
                } catch {
                    print(error)
                }
//                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//                let url = NSURL(fileURLWithPath: path)
                */

            }
            rewardImageView.layer.cornerRadius = 4
            rewardImageView.clipsToBounds = true
            if reward.IsBookmarked {
                if UserSettings.appLanguageIsArabic() {
                    bookmarkTitle.text = "مفضل"
                }else{
                    bookmarkTitle.text = "Bookmarked"
                }
                bookmarkImageView.image = UIImage(named:"bookmark")
            }else{
                bookmarkTitle.text = "Bookmark".y_localized
                bookmarkImageView.image = UIImage(named:"stroke2")
            }
            bookmarkTitle.sizeToFit()
            if isRedeemedVC == false {
                redeemedLabel.isHidden = true
            }else{
                redeemedLabel.isHidden = false
                redeemedLabel.text = ""
                let dateFormatterPrint = DateFormatter()
                if UserSettings.appLanguageIsArabic() {
                    dateFormatterPrint.locale = Locale(identifier: "ar_AR")
                } else {
                    dateFormatterPrint.locale = Locale(identifier: "en_US")
                }
                dateFormatterPrint.dateFormat = "dd/MM/yyyy"//"dd MMM yyyy"
                if reward.RedeemDate.y_getDateFromString() != nil {
                if UserSettings.appLanguageIsArabic() {
                    dateFormatterPrint.dateFormat = "yyyy/MM/dd"
//                    redeemedLabel.text = "تم إسترداده \(dateFormatterPrint.string(from:reward.RedeemDate.y_getDateFromString()!)) من \(reward.VendorName!)"
                    redeemedLabel.text = "تم الإسترداد بتاريخ \(dateFormatterPrint.string(from:reward.RedeemDate.y_getDateFromString()!)) من \(reward.VendorName!)"
                }else{
                    redeemedLabel.text = "Redeemed on \(dateFormatterPrint.string(from:reward.RedeemDate.y_getDateFromString()!)) from \(reward.VendorName!)"//"Redeemed \(dateFormatterPrint.string(from:reward.RedeemDate.y_getDateFromString()!)) from \(reward.VendorName!)"
                }
                }
            }
        }
    }
    func takeScreenshot(_ shouldSave: Bool = true) -> UIImage? {
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = screenshotImage, shouldSave {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        return screenshotImage
    }
//    var homeVC : HomeViewController?
//    var postDetailsVC: PostDetailsViewController?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        
        self.pointsLabel.textColor = .primaryColor
        self.bookmarkTitle.textColor = .primaryColor
        self.redeemTitle.textColor = .primaryColor
    }
    
    override func layoutSubviews() {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension RewardsSubcategoryTableViewCell : CollectionViewAdapterDelegate, CollectionViewAdapterDataSource {
    
}
