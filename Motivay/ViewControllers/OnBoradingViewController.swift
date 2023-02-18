//
//  OnBoradingViewController.swift
//  Motivay
//
//  Created by Yasser Osama on 6/25/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit
import Lottie

class OnBoradingViewController: UIViewController, UIScrollViewDelegate /*, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout*/ {

    @IBOutlet weak var animationView: AnimationView!
    //MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    //IMAGE SLIDER
    
    @IBOutlet weak var pageControl: UIPageControl!
    /*
    @IBOutlet weak var collectionView: UICollectionView!
    */
    @IBOutlet weak var skipButton: UIBarButtonItem!
    @IBOutlet weak var signInButton: AutomaticallyLocalizedButton!
    
    //MARK: - Properties
    var images = ["intro-1", "intro-2", "intro-3"]
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        signInButton.backgroundColor = .primaryColor
        pageControl.currentPageIndicatorTintColor = .primaryColor
        
        if isAppAlreadyLaunchedOnce() {
            let introNavController = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "introNavController")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = introNavController
            appDelegate.window?.makeKeyAndVisible()
        } else {
    
            Constants.fromIntro = true
            setupScrollView()
            
            animationView.animation = Animation.named("give&receive")
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.play()
        
            pageControl.numberOfPages = images.count
            //IMAGE SLIDER
            /*
             
             
             for index in 0..<images.count {
             frame.origin.x = scrollView.frame.size.width * CGFloat(index)
             frame.size = scrollView.frame.size
             
             let imgView = UIImageView(frame: frame)
             imgView.image = UIImage(named: images[index])
             imgView.contentMode = .scaleAspectFit
             self.scrollView.addSubview(imgView)
             }
             scrollView.contentSize = CGSize(width: (scrollView.frame.size.width * CGFloat(images.count)), height: scrollView.frame.size.height)
             scrollView.delegate = self
             */
        }
    }
    
    @IBAction func sigInAction(_ sender: AutomaticallyLocalizedButton) {
        let signIn = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
        self.navigationController?.pushViewController(signIn, animated: true)
    }
    
    @IBAction func skipAction(_ sender: UIBarButtonItem) {
        let intro = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Intro") as! IntroViewController
        
        let nvc = UINavigationController(rootViewController: intro)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = nvc
        appDelegate.window?.makeKeyAndVisible()
    }
    
    func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: self.view.frame.size.width * 3, height: scrollView.frame.size.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / view.frame.size.width
        if pageNumber == 0 {
            animationView.animation = Animation.named("give&receive")
            animationView.loopMode = .loop
            animationView.play()
            skipButton.title = "Skip"
        } else if pageNumber == 1 {
            animationView.animation = Animation.named("redeem points")
            animationView.loopMode = .loop
            animationView.play()
            skipButton.title = "Skip"
        } else if pageNumber == 2 {
            animationView.animation = Animation.named("real motivation")
            animationView.loopMode = .loop
            animationView.play()
            skipButton.title = "Get Started"
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
    }
    
    //IMAGE SLIDER
    
    /*
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     return images.count
     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "introCell", for: indexPath) as! IntroCell
     cell.imageView.image = UIImage(named: images[indexPath.item])
     return cell
     }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     return collectionView.frame.size
     }
     */
    
    func isAppAlreadyLaunchedOnce() -> Bool {
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce") {
            print("App already launched")
            return true
        } else {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            return false
        }
    }
}

class IntroCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
}
