//
//  User.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/04.
//  Copyright © 2020 이상범. All rights reserved.
//

import Foundation
import UIKit

class User{
    var uid: String
    var username: String
    var email: String
    var status: String
    var profileImageUrl: String
    var profileImage = UIImage()
    var isMale: Bool?
    var age: Int?
    var latitude = ""
    var longitude = ""
    
    init(uid: String, username: String, email: String, status: String, profileImageUrl: String){
        self.uid = uid
        self.username = username
        self.email = email
        self.status = status
        self.profileImageUrl = profileImageUrl
    }
    
    static func transformUser(dict: [String:Any]) -> User?{
        guard let uid = dict[UID] as? String,
            let username = dict[USERNAME] as? String,
            let email = dict[EMAIL] as? String,
            let status = dict[STATUS] as? String,
            let profileImageUrl = dict[PROFILE_IMAGE_URL] as? String else{
                return nil
        }
        let user = User(uid: uid, username: username, email: email, status: status, profileImageUrl: profileImageUrl)
        
        if let isMale = dict[ISMALE] as? Bool{
            user.isMale = isMale
        }
        if let age = dict[AGE] as? Int{
            user.age = age
        }
        if let latitude = dict[CURRENT_LOCATION_LATITUDE] as? String{
            user.latitude = latitude
        }
        if let longitude = dict[CURRENT_LOCATION_LONGITUDE] as? String{
            user.longitude = longitude
        }
        
        return user
    }
    
    func updateData(key: String, value: String){
        switch key{
        case USERNAME: self.username = value
        case EMAIL: self.email = value
        case PROFILE_IMAGE_URL: self.profileImageUrl = value
        case STATUS: self.status = value
            
        default: break
        }
    }
}
