//
//  MyTrendsHeaderTableViewCell.swift
//
//  Created by Yehia Elbehery.
//

import UIKit

class MyTrendsHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var hashtagTitleLabel: UILabel!
    @IBOutlet weak var taggedTimesLabel: UILabel!
    @IBOutlet weak var totalPointsLabel: UILabel!
    @IBOutlet weak var thisMonthLabel : UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        hashtagTitleLabel.textColor = .primaryColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
