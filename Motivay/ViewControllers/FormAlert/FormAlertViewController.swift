//
//  ResestViewController.swift
//
//  Created by Yehia Elbehery.
//

import UIKit
import Gradientable

class FormAlertViewController: UIViewController {
    
    @IBOutlet weak var indicatorButton: UIButton!
    @IBOutlet weak var messageLabel : UILabel!
    @IBOutlet weak var alertView : GradientableView!
    @IBOutlet weak var dismissButton : UIButton!
    
    
    var isSuccessAlert: Bool = true
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if isSuccessAlert {
            alertView.set(options: GradientableOptions(colors: [UIColor(r:156, g:204, b:101), UIColor(r:2, g:184, b:117)]))
            
            let options = GradientableOptions(direction: .topLeftToBottomRight)
            alertView.set(options: options)
            indicatorButton.setImage(UIImage(named:"validIco"), for: .normal)
        }else{
            
            alertView.set(options: GradientableOptions(colors: [UIColor(r:245, g:52, b:79), UIColor(r:255, g:96, b:48)]))
            
            let options = GradientableOptions(direction: .topLeftToBottomRight)
            alertView.set(options: options)
            indicatorButton.setImage(UIImage(named:"validIco-1"), for: .normal)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(){
        self.navigationController?.popViewController(animated: true)
    }
    
}

