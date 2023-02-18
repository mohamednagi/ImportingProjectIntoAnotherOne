//
//  SZExampleMentionsTableViewDataManager.swift
//  SZMentionsExample
//
//  Created by Steven Zweier on 1/12/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit
//import SZMentionsSwift

class SZExampleMentionsTableViewDataManager: NSObject, UITableViewDataSource, UITableViewDelegate {

    private var listener: SZMentionsListener?
    var mentions = [SZExampleMention]()

    private var tableView: UITableView?
    private var filterString: String?

    init(mentionTableView: UITableView, mentionsListener: SZMentionsListener) {
        super.init()
        tableView = mentionTableView
        
        let nib = UINib(nibName: "MentionTableViewCell", bundle: nil)
        tableView!.register(
            nib,
            forCellReuseIdentifier: "MentionTableViewCell")
        listener = mentionsListener
    }

    func filter(_ string: String?) {
        filterString = string
        tableView?.reloadData()
    }

    private func mentionsList() -> [SZExampleMention] {
        var filteredMentions = mentions

        if (filterString?.count ?? 0 > 0) {
            filteredMentions = mentions.filter() {
                if let type = ($0 as SZExampleMention).mentionName as String! {
                    return type.lowercased().contains(filterString!.lowercased())
                } else {
                    return false
                }
            }
        }

        return filteredMentions
    }

    func firstMentionObject() -> SZExampleMention? {
        return mentionsList().first
    }
    @objc func addMentionWithIndex(_ sender: UIButton){
        let index = sender.tag
        addMention(mentionsList()[index])
    }
    func addMention(_ mention: SZExampleMention) {
        listener!.addMention(mention)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionsList().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MentionTableViewCell") as! MentionTableViewCell
        
        cell.title.text = mentionsList()[indexPath.row].fullName
        cell.subTitle.text = "@\(mentionsList()[indexPath.row].mentionName)"
        
        cell.profilePicImageView.y_circularRoundedCorner()
        cell.profilePicImageView.sd_setImage(with: URL(string: mentionsList()[indexPath.row].userImage), placeholderImage: UIImage(named: "profile"))

//        cell.profilePicImageView.image = UIImage(named: "profile")
        cell.hiddenButton.addTarget(self, action: #selector(self.addMentionWithIndex(_:)), for: .touchUpInside)
        cell.hiddenButton.tag = indexPath.row
        cell.y_fullWidthSeparator()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.addMention(mentionsList()[indexPath.row])
    }
}
