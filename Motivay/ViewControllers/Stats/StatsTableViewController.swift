//
//  StatsTableViewController.swift
//  Motivay
//
//  Created by Yasser Osama on 3/12/18.
//  Copyright © 2018 Youxel. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout
import Alamofire

class StatsTableViewController: UITableViewController {

    //MARK: Outlets
    @IBOutlet weak var earnedPointsLabel: UILabel!
    @IBOutlet weak var sentPointsLabel: UILabel!
    @IBOutlet weak var totalPostsLabel: UILabel!
    @IBOutlet weak var saidBravoLabel: UILabel!
    @IBOutlet weak var starsCollectionView: UICollectionView!
    @IBOutlet weak var trendsCollectionView: UICollectionView!
    @IBOutlet weak var saidBravoNameLabel: AutomaticallyLocalizedLabel!
    
    //MARK: Properties
    var hashtags = [Hashtag]()
    var stars = [Star]()
    var myStats: MyStats!
    var allStars = [[Star]?]()
    
    //MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.tableView.contentInset = UIEdgeInsetsMake(16, 0, 0, 0)
        trendsCollectionView.register(UINib(nibName: "TopTrendsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "trendsCell")
        starsCollectionView.register(UINib(nibName: "StarsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "starsCell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        setTrendsViewLayout()
        saidBravoNameLabel.text = Fonts.saidBravo.y_localized
        trendsCollectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Constants.selectedVC = 5
        if Constants.languageChanged {
            Constants.languageChanged = false
            self.perform(#selector(pushSettings), with: nil, afterDelay: 0.1)
        }
        self.slideMenuController()?.addRightGestures()
        self.slideMenuController()?.addLeftGestures()
        
        if NetworkReachabilityManager()!.isReachable == false {
            AlertUtility.showConnectionError()
        } else {
            loadTrendsData()
            getStars()
            getMyStats()
        }
        
        self.tabBarController?.navigationItem.titleView = nil
        self.tabBarController?.navigationItem.title = "Stats".y_localized
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setLeftBarButton()
        self.navigationController?.y_showShadow()//y_addShadowWithColor()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        self.navigationController?.y_deleteShadowWithColor()
    }
    
    override func viewWillLayoutSubviews() {
        setStarsViewLayout()
    }
    
    func setLeftBarButton() {
        let leftButton: UIButton = UIButton(type: UIButtonType.custom)
        leftButton.frame = CGRect(x:0, y:0, width:34, height:34)
        leftButton.imageView?.contentMode = .scaleAspectFill
        if UserSettings.info == nil {
            leftButton.sd_setBackgroundImage(with: URL(string:""), for: .normal, placeholderImage: UIImage(named:"profileBig"), options:[])
        } else {
            leftButton.sd_setImage(with: URL(string:UserSettings.info!.ProfilePicture), for: .normal, placeholderImage: UIImage(named:"profileBig"), options:[])
        }
        leftButton.y_roundedCorners()
        leftButton.widthAnchor.constraint(equalToConstant: 34.0).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 34.0).isActive = true
        leftButton.addTarget(self, action: #selector(menu), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        
        tabBarController?.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc func menu() {
        if UserSettings.appLanguageIsArabic() {
            self.tabBarController?.openRight()
        } else {
            self.tabBarController?.openLeft()
        }
    }
    
    @objc func pushSettings() {
        let settings = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Settings") as! SettingsTableViewController
        self.navigationController?.pushViewController(settings, animated: false)
    }
    
    func setStarsViewLayout() {
//        let itemSize = UIScreen.main.bounds.width - 80
        let itemSize = starsCollectionView.frame
        let layout = UPCarouselFlowLayout()
        layout.itemSize = CGSize(width: itemSize.width - 10, height: itemSize.height - 10)
        layout.scrollDirection = .horizontal
        layout.spacingMode = .overlap(visibleOffset: 80)
        starsCollectionView.collectionViewLayout = layout
    }
    
    func setTrendsViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 160, height: 160)
        layout.scrollDirection = .horizontal
        trendsCollectionView.collectionViewLayout = layout
    }
    
    func loadTrendsData() {
        Backend.getTags(sorted: 1, completion: { (hashtags, backendError) in
            if hashtags == nil {
                if backendError == .connection {
                }
            } else {
                self.hashtags = hashtags!
                self.trendsCollectionView.reloadData()
                if UserSettings.appLanguageIsArabic() {
                    if self.trendsCollectionView.numberOfSections > 0 {
                        if self.trendsCollectionView.numberOfItems(inSection: 0) > 0 {
                            self.trendsCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
                        }
                    }
                }
            }
        })
    }
    
    func getStars() {
        Backend.getStars(completion: { (stars, backendError) in
            if stars == nil {
            } else {
                self.stars = stars!
                if self.stars.count > 0 {
                    self.allStars.removeAll()
                    let x = stars?.categorise { $0.Title }
                    if let y1 = x![StarTitle.performer] {
                        self.allStars.append(y1)
                    }
                    if let y2 = x![StarTitle.giver] {
                        self.allStars.append(y2)
                    }
                    if let y3 = x![StarTitle.posting] {
                        self.allStars.append(y3)
                    }
                    if let y4 = x![StarTitle.contributor] {
                        self.allStars.append(y4)
                    }
//                    let all = [y1, y2, y3, y4]
//                    self.allStars = all
                }
                self.starsCollectionView.reloadData()
                if UserSettings.appLanguageIsArabic() {
                    if self.trendsCollectionView.numberOfSections > 0 {
                        if self.trendsCollectionView.numberOfItems(inSection: 0) > 0 {
                    self.starsCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
                        }
                        
                    }
                }
            }
        })
    }
    
    func getMyStats() {
        Backend.getMyStats(completion: { (stats, backendError) in
            if stats == nil {
            } else {
                self.myStats = stats
                self.earnedPointsLabel.text = "\(stats!.EarnedPoints!)"
                self.sentPointsLabel.text = "\(stats!.SentPoints!)"
                self.totalPostsLabel.text = "\((stats!.TotalPosts)!)"
                self.saidBravoLabel.text = "\((stats!.SaidBravo)!)"
            }
        })
    }
    
    @objc func openProfile(_ sender: UIButton) {
        gotoProfile(withID: stars[sender.tag].UserId)
    }
    
    func gotoProfile(withID id: String) {
        Backend.getProfileDetails(withID: id, completion: { (employee, backendError) in
            if backendError != nil {
                
            } else {
                let profile = Utilities.storyboard(withName: "Main").instantiateViewController(withIdentifier: "Profile") as! MyProfileViewController
                profile.profileData = employee
                if id == UserSettings.info!.userID {
                    profile.myProfile = 1
                } else {
                    profile.myProfile = 0
                }
                self.navigationController?.pushViewController(profile, animated: true)
            }
        })
    }
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
//            headerView.backgroundView?.backgroundColor = .white
            headerView.contentView.backgroundColor = .white
            var text = ""
            if section == 0 {
                text = "My Stats".y_localized
            } else if section == 1 {
                text = /*"Stars"*/"Top Stars".y_localized
            } else if section == 2 {
                text = /*"Top Trends"*/"Trending Now".y_localized
            }
            headerView.textLabel?.text = text
            headerView.textLabel?.font = UIFont(name: Constants.boldFont(), size: 24)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let returnView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 16))
        returnView.backgroundColor = .clear
        return returnView
    }
    
    @objc func performerUserImageTapped(_ sender: UIButton) {
        gotoProfile(withID: allStars[0]![sender.tag].UserId)
    }
    
    @objc func giverUserImageTapped(_ sender: UIButton) {
        gotoProfile(withID: allStars[1]![sender.tag].UserId)
    }
    
    @objc func postingUserImageTapped(_ sender: UIButton) {
        gotoProfile(withID: allStars[2]![sender.tag].UserId)
    }
    
    @objc func contributorUserImageTapped(_ sender: UIButton) {
        gotoProfile(withID: allStars[3]![sender.tag].UserId)
    }
}

extension StatsTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == starsCollectionView {
            return allStars.count
        } else if collectionView == trendsCollectionView {
            return hashtags.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == starsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "starsCell", for: indexPath) as! StarsCollectionViewCell
            for i in 0..<3 {
                cell.starsDetails[i].isHidden = true
                cell.userImageButtons[i].removeTarget(self, action: nil, for: .allEvents)
            }
            if let starType = allStars[indexPath.row] {
                for (i, star) in starType.enumerated() {
                    switch star.Title {
                    case .performer?:
                        cell.bgImageView.image = #imageLiteral(resourceName: "performer")
                        cell.userTitleLabel.text = "Top Performer".y_localized
                        cell.valueNameLabel.text = "Points".y_localized
                        cell.userImageButtons[i].addTarget(self, action: #selector(performerUserImageTapped(_:)), for: .touchUpInside)
                        cell.userImageButtons[i].tag = i
//                        cell.userNameLabels[i].addShadow(withColor: UIColor.scarlet30)
                    case .giver?:
                        cell.bgImageView.image = #imageLiteral(resourceName: "giver")
                        cell.userTitleLabel.text = "Top Giver".y_localized
                        cell.valueNameLabel.text = "Points".y_localized
                        cell.userImageButtons[i].addTarget(self, action: #selector(giverUserImageTapped(_:)), for: .touchUpInside)
                        cell.userImageButtons[i].tag = i
//                        cell.userNameLabels[i].addShadow(withColor: UIColor.darkGrassGreen30)
                    case .posting?:
                        cell.bgImageView.image = #imageLiteral(resourceName: "posting")
                        cell.userTitleLabel.text = "Top Posting".y_localized
                        cell.valueNameLabel.text = "Posts".y_localized
                        cell.userImageButtons[i].addTarget(self, action: #selector(postingUserImageTapped(_:)), for: .touchUpInside)
                        cell.userImageButtons[i].tag = i
//                        cell.userNameLabels[i].addShadow(withColor: UIColor.darkSkyBlue30)
                    case .contributor?:
                        cell.bgImageView.image = #imageLiteral(resourceName: "contributor")
                        cell.userTitleLabel.text = "Top Contributor".y_localized
                        cell.valueNameLabel.text = "Reactions".y_localized
                        cell.userImageButtons[i].addTarget(self, action: #selector(contributorUserImageTapped(_:)), for: .touchUpInside)
                        cell.userImageButtons[i].tag = i
//                        cell.userNameLabels[i].addShadow(withColor: UIColor.scarlet30)
                    default:
                        print("none")
                    }
                    cell.userImageViews[i].sd_setImage(with: URL(string: star.UserImage), placeholderImage: #imageLiteral(resourceName: "profile"))
                    cell.userImageViews[i].y_circularRoundedCorner()
                    cell.valueLabels[i].text = "\((star.Value)!)"
                    if UserSettings.appLanguageIsArabic() {
                        cell.valueLabels[i].textAlignment = .left
                    }
                    if UserSettings.appLanguageIsArabic() {
                        cell.rankLabels[i].text = "\(star.Rank!)".toArabic() + "#"
                    } else {
                        cell.rankLabels[i].text = "#" + "\(star.Rank!)"
                    }
                    cell.userNameLabels[i].text = star.UserFullName
                    cell.starsDetails[i].isHidden = false
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendsCell", for: indexPath) as! TopTrendsCollectionViewCell
            cell.trendNameLabel.text = hashtags[indexPath.item].Name
            cell.numberOfPostsLabel.text = "\((hashtags[indexPath.item].NumberOfPosts)!)".toArabic() + " " + "posts".y_localized
            cell.trendImageView.y_roundCorners(withRadius: 2)
            cell.trendImageView.contentMode = .scaleAspectFill
            if let url = hashtags[indexPath.item].Image {
                cell.trendImageView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "total"))
            } else {
                cell.trendImageView.image = #imageLiteral(resourceName: "total")
            }
            return cell
        }
    }
}

public extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var categories: [U: [Iterator.Element]] = [:]
        for element in self {
            let key = key(element)
            if case nil = categories[key]?.append(element) {
                categories[key] = [element]
            }
        }
        return categories
    }
    
    func categorise<U : Hashable>(_ key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var dict: [U:[Iterator.Element]] = [:]
        for el in self {
            let key = key(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}
