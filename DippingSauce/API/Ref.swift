//
//  Ref.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/03.
//  Copyright © 2020 이상범. All rights reserved.
//

import Foundation
import Firebase

let REF_USER = "users"
let REF_MESSAGE = "messages"
let REF_INBOX = "inbox"
let REF_GEO = "Geolocation"

let STORAGE_PROFILE = "profile"
let STORAGE_PHOTO = "photo"
let STORAGE_VIDEO = "video"
let PROFILE_IMAGE_URL = "profileImageUrl"
let UID = "uid"
let EMAIL = "email"
let USERNAME = "usermame"
let STATUS = "status"
let TEXT = "text"
let DATE = "date"
let READ = "read"
let IMAGEURL = "imageUrl"
let VIDEOURL = "videoUrl"
let WIDTH = "width"
let HEIGHT = "height"
let IS_ONLINE = "isOnline"
let FEED_MESSAGES = "feedMessages"
let ISMALE = "isMale"
let AGE = "age"
let INITIAL_DISTANCE = Double(20)
let CURRENT_LOCATION_LATITUDE = "current_location_latitude"
let CURRENT_LOCATION_LONGITUDE = "current_location_longitude"

let ERROR_EMPTY_USERNAME = "Please enter an username"
let ERROR_EMPTY_EMAIL = "Please enter an email address"
let ERROR_EMPTY_PASSWORD = "Please enter a password"
let ERROR_EMPTY_PHOTO = "Please choose your profile image"

let SUCCESS_EMAIL_RESET = "We have just sent you a password reset email. Please check your inbox and follow the instructions to reset your password"

let IDENTIFIER_TAPBAR = "MessageTapbarVC"
let IDENTIFIER_MAIN = "MainVC"
let IDENTIFIER_CELL_USERS = "UsersTableViewCell"
let IDENTIFIER_CHAT = "ChatVC"
let IDENTIFIER_CELL_MESSAGE = "MessageTableViewCell"
let IDENTIFIER_CELL_INBOX = "InboxTableViewCell"
let IDENTIFIER_UPDATE_PROFILE_IMAGE = "updateProfileImage"
let IDENTIFIER_USER_AROUND = "UserAroundViewController"
let IDENTIFIER_USER_AROUND_CELL = "UserAroundCollectionViewCell"
let IDENTIFIER_MAP = "MapViewController"
let IDENTIFIER_DETATIL = "DetailViewController"

let STORYBOARD_NAME_MAIN = "Main"
let STORYBOARD_NAME_MESSAGE = "Message"
let STORYBOARD_NAME_AROUND = "Around"

let IMAGE_ICON_ATTACH = "icon-attach"
let IMAGE_ICON_MIC = "icon-mic"
let IMAGE_ICON_LOCATION = "icon-location"
let IMAGE_ICON_MAP = "icon-map"
let IMAGE_ICON_REFRESH = "icon-refresh"
let IMAGE_ICON_DUMMY = "icon-dummy"
let IMAGE_ICON_BACK = "icon-back"
let IMAGE_ICON_PERSON = "icon-person"
let IMAGE_ICON_DIRECTION = "icon-direction"
let IMAGE_ICON_MALE = "icon-male"
let IMAGE_ICON_FEMALE = "icon-female"
let IMAGE_ICON_FACEBOOK = "icon-facebook"
let IMAGE_ICON_GOOGLE = "icon-google"


class Ref{
    let databaseRoot: DatabaseReference = Database.database().reference()
    var databaseUsers: DatabaseReference{
        return databaseRoot.child(REF_USER)
    }
    func databaseSpecificUser(uid: String) -> DatabaseReference{
        return databaseUsers.child(uid)
    }
    
    func databaseIsOnline(uid: String) -> DatabaseReference{
        return databaseUsers.child(uid).child(IS_ONLINE)
    }
    
    var databaseMessage: DatabaseReference{
        return databaseRoot.child(REF_MESSAGE)
    }
    func databaseSendTo(from: String, to: String) -> DatabaseReference{
        return databaseMessage.child(from).child(to)
    }
    
    var databaseInbox: DatabaseReference{
        return databaseRoot.child(REF_INBOX)
    }
    func databaseInboxInfo(from: String, to: String) -> DatabaseReference{
        return databaseInbox.child(from).child(to)
    }
    func databaseInboxForUser(uid: String) -> DatabaseReference{
        return databaseInbox.child(uid)
    }
    
    var databaseFeedMessage: DatabaseReference{
        return databaseRoot.child(FEED_MESSAGES)
    }
    func databaseSendFeedMessages(chnnelId: String) -> DatabaseReference{
        return databaseFeedMessage.child(chnnelId)
    }
    
    var databaseGeo: DatabaseReference{
        return databaseRoot.child(REF_GEO)
    }
    
    let storageRoot = Storage.storage().reference()
    var storageProfile: StorageReference{
        return storageRoot.child(STORAGE_PROFILE)
    }
    
    func storageSpecificProfile(uid: String) -> StorageReference{
        return storageProfile.child(uid)
    }
    
    var storageMessage: StorageReference{
        return storageRoot.child(REF_MESSAGE)
    }
    
    func storageSpecificImageMessage(uid: String) -> StorageReference{
        return storageMessage.child(STORAGE_PHOTO).child(uid)
    }
    func storageSpecificVideoMessage(uid: String) -> StorageReference{
        return storageMessage.child(STORAGE_VIDEO).child(uid)
    }
    
 
}
