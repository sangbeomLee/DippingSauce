//
//  InboxApi.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/07.
//  Copyright © 2020 이상범. All rights reserved.
//

import Foundation
import Firebase

typealias InboxCompletion = (Inbox) -> Void

class InboxApi{
    func lastMessage(uid: String, onSuccess: @escaping(InboxCompletion)){
        let ref = Ref().databaseInboxForUser(uid: uid)
        
        // DATE순으로 가져온다.
        ref.queryOrdered(byChild: DATE).queryLimited(toLast: 8).observe(.childAdded) { (dataSnapshot) in
            if let dict = dataSnapshot.value as? Dictionary<String, Any>{
                guard let partnerId = dict["to"] as? String else{
                    return
                }
                
                let uid = (partnerId == Api.User.currentUserId) ? (dict["from"] as! String) : partnerId
                let channelId = Message.hash(forMembers: [uid, partnerId])
                Api.User.getUserInfo(uid: uid) { (user) in
                    if let inbox = Inbox.transformInbox(dict: dict, channelId: channelId, user: user){
                        onSuccess(inbox)
                    }
                }
            }
        }
    }
    
    func loadMore(start timestemp: Double?, controller: MessagesTableViewController, from: String, onSuccess: @escaping(InboxCompletion)){
        guard let timestemp = timestemp else{
            return
        }
        
        // queryOrdered(byChild) child를 기준으로 정렬한다.
        let ref = Ref().databaseInboxForUser(uid: from).queryOrdered(byChild: DATE).queryEnding(atValue: timestemp - 1).queryLimited(toLast: 3)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else{
                return
            }
            if allObjects.isEmpty{
                controller.tableView.tableFooterView = UIView()
                
            }
            
            allObjects.forEach { (object) in
                if let dict = object.value as? Dictionary<String, Any> {
                    let partnerId = dict["to"] as! String
                    let channelId = Message.hash(forMembers: [from, partnerId])
                    Api.User.getUserInfo(uid: partnerId) { (user) in
                        if let inbox = Inbox.transformInbox(dict: dict, channelId: channelId, user: user){
                            onSuccess(inbox)
                        }
                    }
                }
            }
        }
        
    }
    
}
