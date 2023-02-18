//
//  ViewController.swift
//  ImporterProject
//
//  Created by Mohamed Nagi on 16/02/2023.
//

import UIKit


class ViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    
    @IBAction func GoToMotivayPressed (_ sender: UIButton) {
        let signIn = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
        navigationController?.pushViewController(signIn, animated: true)
    }
}

