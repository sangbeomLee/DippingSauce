//
//  User.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/04.
//  Copyright © 2020 이상범. All rights reserved.
//

import Foundation

class Message{
    var id: String
    var from: String
    var to: String
    var text: String
    var date: Double
    var imageUrl: String
    var videoUrl: String
    var read: Bool
    var height: Double
    var width: Double
    
    init(id: String, from: String, to: String, text: String, date: Double, imageUrl: String, videoUrl: String, read: Bool, height: Double, width: Double){
        self.id = id
        self.from = from
        self.to = to
        self.text = text
        self.date = date
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
        self.read = read
        self.height = height
        self.width = width
    }
    
    static func transformMessage(dict: [String:Any], keyId: String) -> Message?{
        guard let from = dict["from"] as? String,
            let to = dict["to"] as? String,
            let date = dict["date"] as? Double,
            let read = dict["read"] as? Bool
        else{
            return nil
        }
        let text = (dict["text"] as? String) == nil ? "" : (dict["text"]! as! String)
        let imageUrl = (dict["imageUrl"] as? String) == nil ? "" : (dict["imageUrl"]! as! String)
        let videoUrl = (dict["videoUrl"] as? String) == nil ? "" : (dict["videoUrl"]! as! String)
        let height = (dict["height"] as? Double) == nil ? 0 : (dict["height"]! as! Double)
        let width = (dict["width"] as? Double) == nil ? 0 : (dict["width"]! as! Double)
        
        let message = Message(id: keyId, from: from, to: to, text: text, date: date, imageUrl: imageUrl, videoUrl: videoUrl, read: read, height: height, width: width)
        
        return message
    }
    
    static func hash(forMembers members: [String]) -> String{
        let hash = members[0].hashString ^ members[1].hashString
        let memberHash = String(hash)
        
        return memberHash
    }
}
