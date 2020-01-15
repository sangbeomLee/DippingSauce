//
//  User.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/04.
//  Copyright © 2020 이상범. All rights reserved.
//

import Foundation

class Inbox{
    var user: User
    var text: String
    var date: Double
    var read: Bool
    var channelId: String
    
    init(user: User, text: String, date: Double, read: Bool, channelId: String){
        self.user = user
        self.text = text
        self.date = date
        self.read = read
        self.channelId = channelId
    }
    
    static func transformInbox(dict: [String:Any], channelId: String, user: User) -> Inbox?{
        guard let text = dict[TEXT] as? String,
            let date = dict[DATE] as? Double,
            let read = dict[READ] as? Bool
        else{
            return nil
        }
        let hasText = text.isEmpty ? "[MEDIA]" : text

        let inbox = Inbox(user: user, text: hasText, date: date, read: read, channelId: channelId)
        return inbox
    }
    
    func updateData(key: String, value: Any){
        switch key{
        case TEXT: self.text = (value as! String)
        case DATE: self.date = (value as! Double)
            
        default: break
        }
    }
}
