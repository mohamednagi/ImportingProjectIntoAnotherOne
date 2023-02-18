//
//  SZExampleMention.swift
//  SZMentionsExample
//
//  Created by Steven Zweier on 1/12/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import UIKit
//import SZMentionsSwift

class SZExampleMention: CreateMention {
    var userId: String = ""
    var mentionName: String = ""
    var fullName: String = ""
    var mentionRange: NSRange = NSMakeRange(0, 0)
    var userImage: String = ""
    
    init(_userId: String, _userName: String, _fullName: String, _userImage: String){
        userId = _userId
        mentionName = _userName
        fullName = _fullName
        userImage = _userImage
    }
}
