//
//  TrendDetailsHeaderViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit

class TrendDetailsHeaderViewController: UIViewController {
    
    @IBOutlet weak var hashtagTitleLabel: UILabel!
    @IBOutlet weak var taggedTimesLabel: UILabel!
    @IBOutlet weak var totalPointsLabel: UILabel!
    @IBOutlet weak var thisMonthLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        hashtagTitleLabel.textColor = .primaryColor
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

