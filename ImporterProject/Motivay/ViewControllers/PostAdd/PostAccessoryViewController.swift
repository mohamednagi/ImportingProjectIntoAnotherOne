//
//  PostAccessoryViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit

class PostAccessoryViewController: UIViewController {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var galleryButton : UIButton!
    @IBOutlet weak var sendButton : UIButton!
    
    @IBOutlet weak var charCountLabel: ArabicNumbersLabel!
    
    var isSuccessAlert: Bool = true
   
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.backgroundColor = .primaryColor
        charCountLabel.textColor = .primaryColor
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

