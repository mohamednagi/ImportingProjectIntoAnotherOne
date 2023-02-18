//
//  FiltersTableViewCell.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import SDWebImage
import Gradientable

class FiltersTableViewCell: UITableViewCell {

    @IBOutlet weak var filterIconImageView: UIImageView!
    @IBOutlet weak var filterTitle: UILabel!
    
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var selectedContainerScrollView: UIScrollView!
    @IBOutlet weak var personsView: UIView!
    
    var accessoryButton: UIButton!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        accessoryType = .disclosureIndicator
        accessoryButton = subviews.flatMap { $0 as? UIButton }.first
        placeholderLabel.textColor = .primaryColor
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
            var accessoryButtonFrame = accessoryButton.frame
                if personsView.isHidden == true {
            accessoryButtonFrame.origin.y = self.frame.height - accessoryButtonFrame.size.height - 16
            accessoryButton?.frame = accessoryButtonFrame
        }
            if UserSettings.appLanguageIsArabic() {
                accessoryButton.setBackgroundImage(UIImage(named:"arrowPinkLeft"), for: .normal)
            }else{
                accessoryButton.setBackgroundImage(UIImage(named:"arrowPinkRight"), for: .normal)
            }
    }
    
    func createDepartmentBubbleView(_ deparmentName : String) -> UIView {
        let labelX = 16
        let labelY = 6
        let labelHeight = 20
        let fontSize = 14
        let radius = 16
        
        let name = deparmentName
        
        let label = UILabel(frame:CGRect(x:labelX, y:labelY, width:50, height:labelHeight))
        label.text = name
        label.font = label.font.withSize(CGFloat(fontSize))
        label.textColor = .greyishBrownTwo
        label.sizeToFit()
        
        var gradViewFrame : CGRect!
        
            gradViewFrame = CGRect(x:0, y:0, width:label.frame.origin.x + label.frame.size.width + 16, height:28)
        
        let gradView = UIView(frame:gradViewFrame)
        gradView.backgroundColor = UIColor(r:244, g:244, b:244)
        gradView.layer.cornerRadius = CGFloat(radius)
        gradView.clipsToBounds = true
        
        
        gradView.addSubview(label)
        
        return gradView
    }
    
    func createHashtagBubbleView(_ hashtag : Hashtag) -> GradientableView {
        let labelX = 16
        let labelY = 6
        let labelHeight = 20
        let fontSize = 14
        let radius = 16
        
        let name = hashtag.Name
        
        let label = UILabel(frame:CGRect(x:labelX, y:labelY, width:50, height:labelHeight))
        label.text = name
        label.font = label.font.withSize(CGFloat(fontSize))
        label.textColor = .white
        label.sizeToFit()
        
        var gradViewFrame : CGRect!
        
        gradViewFrame = CGRect(x:0, y:0, width:label.frame.origin.x + label.frame.size.width + 16, height:28)
        
        let gradView = GradientableView(frame:gradViewFrame)
        gradView.set(options: GradientableOptions(colors: [UIColor(hexString:hashtag.Color, alpha:1), UIColor(hexString:hashtag.Color, alpha:0.5)]))
        
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
//
//extension FiltersTableViewCell {
//    struct ViewModel {
//        let title : String
//        let imageName : String
//    }
//}
//
//extension FiltersTableViewCell.ViewModel {
//    init(_title: String, _imageName: String) {
//        title = _title
//        imageName = _imageName
//    }
//    
//    init() {
//        title = ""
//        imageName = ""
//    }
//}

