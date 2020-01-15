//
//  MessageApi.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/05.
//  Copyright © 2020 이상범. All rights reserved.
//

import Foundation
import Firebase

class MessageApi{
    func sendMessage(from: String, to: String, value: Dictionary<String, Any>){
        let chnnelId = Message.hash(forMembers: [from, to])
//        let ref = Database.database().reference().child("feedMessages").child(chnnelId)
        let ref = Ref().databaseSendFeedMessages(chnnelId: chnnelId)
        //let ref = Ref().databaseSendTo(from: from, to: to)
        ref.childByAutoId().updateChildValues(value)
        
        // 불필요한 정보가 너무 많이 가니 (width ..etc) 없애는 작업한다.
        var dict = value
        if let text = dict["text"] as? String, text.isEmpty{
            dict[IMAGEURL] = nil
            dict[HEIGHT] = nil
            dict[WIDTH] = nil
        }
        let refFromInboxFrom =
            Database.database().reference().child(REF_INBOX).child(from).child(chnnelId)
        refFromInboxFrom.updateChildValues(dict)
        let refToInboxFrom = Database.database().reference().child(REF_INBOX).child(to).child(chnnelId)
        refToInboxFrom.updateChildValues(dict)
//        let refFrom = Ref().databaseInboxInfo(from: from, to: to)
//        refFrom.updateChildValues(dict)
//
//        let refTo = Ref().databaseInboxInfo(from: to, to: from)
//        refTo.updateChildValues(dict)
    }
    
    
    func receiveMessage(from: String, to: String, onSuccess: @escaping(Message) -> Void){
        let chnnelId = Message.hash(forMembers: [from, to])
//        let ref = Database.database().reference().child("feedMessages").child(chnnelId)
        let ref = Ref().databaseSendFeedMessages(chnnelId: chnnelId)
        //let ref = Ref().databaseSendTo(from: from, to: to)
        //기존에 것 보다 queryOrderedByKey().queryLimited()가 생김 밑에서 10개만 가져오는 것인가 보다.
        ref.queryOrderedByKey().queryLimited(toLast: 8).observe(.childAdded) { (dataSnapshot) in
            if let dict = dataSnapshot.value as? Dictionary<String, Any>{
                if let message = Message.transformMessage(dict: dict, keyId: dataSnapshot.key){
                    onSuccess(message)
                }
            }
        }
    }
    
    func loadMore(lastMessageKey: String?, from: String, to: String, onSuccess: @escaping([Message], String) -> Void){
        guard let lastMessageKey = lastMessageKey else{
            return
        }
        let chnnelId = Message.hash(forMembers: [from, to])
        let ref = Ref().databaseSendFeedMessages(chnnelId: chnnelId)
        ref.queryOrderedByKey().queryEnding(atValue: lastMessageKey).queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
            guard let first = snapshot.children.allObjects.first as? DataSnapshot else{
                return
            }
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else{
                return
            }
            var messages = [Message]()
            allObjects.forEach { (object) in
                if let dict = object.value as? Dictionary<String, Any>{
                    if let message = Message.transformMessage(dict: dict, keyId: object.key){
                        if object.key != lastMessageKey{
                            messages.append(message)
                        }
                    }
                }
            }
            onSuccess(messages, first.key)
        }
        
    }
}
