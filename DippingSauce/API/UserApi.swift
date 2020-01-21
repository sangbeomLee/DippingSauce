//
//  UserApi.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/03.
//  Copyright © 2020 이상범. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import ProgressHUD
import CoreLocation
import GeoFire

class UserApi {
    
    var currentUserId: String{
        return Auth.auth().currentUser != nil ? Auth.auth().currentUser!.uid : ""
    }
    func signUpAddLocation(withUsername username: String, email: String, password: String, image: UIImage?,
                           location: CLLocation, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        
        guard let imageSelected = image else{
            ProgressHUD.showError(ERROR_EMPTY_PHOTO)
            return
        }
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else{
            print("signupButtonDidTapped : no ImageData")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            if error != nil{
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            if let authData = authDataResult{
                let dictionary: Dictionary<String, Any> = [
                    UID : authData.user.uid,
                    EMAIL : authData.user.email!,
                    USERNAME : username,
                    PROFILE_IMAGE_URL : "",
                    STATUS : "Wellcome to DippingSauce"
                ]
                let geoFireRef = Ref().databaseGeo
                let geoFire = GeoFire(firebaseRef: geoFireRef)
                geoFire.setLocation(location, forKey: Api.User.currentUserId)
                
                let storageProfile = Ref().storageSpecificProfile(uid: authData.user.uid)
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpg"
                StorageService.savePhoto(username: username, uid: authData.user.uid, data: imageData, metaData: metaData, storageProfileRef: storageProfile, dictionary: dictionary, onSuccess: {
                    onSuccess()
                }) { (onErrorMessage) in
                     onError(onErrorMessage)
                }
            }
        }
    }
    
    
    func signUp(withUsername username: String, email: String, password: String, image: UIImage?,
                onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        
        guard let imageSelected = image else{
            ProgressHUD.showError(ERROR_EMPTY_PHOTO)
            return
        }
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else{
            print("signupButtonDidTapped : no ImageData")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            if error != nil{
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            if let authData = authDataResult{
                let dictionary: Dictionary<String, Any> = [
                    UID : authData.user.uid,
                    EMAIL : authData.user.email!,
                    USERNAME : username,
                    PROFILE_IMAGE_URL : "",
                    STATUS : "Wellcome to DippingSauce"
                ]
                
                let storageProfile = Ref().storageSpecificProfile(uid: authData.user.uid)
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpg"
                StorageService.savePhoto(username: username, uid: authData.user.uid, data: imageData, metaData: metaData, storageProfileRef: storageProfile, dictionary: dictionary, onSuccess: {
                    onSuccess()
                }) { (onErrorMessage) in
                     onError(onErrorMessage)
                }  
            }
        }
    }
    
    func signIn(email: String, password: String,
                onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
        
    }
    func forgotPassword(email: String, onSuccess: @escaping() -> Void,onError: @escaping(_ errorMessage: String) -> Void){
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil{
                onError(error!.localizedDescription)
            }else{
                onSuccess()
            }
            
        }
    }
    
    func logOut(){
        do{
            Api.User.isOnline(bool: false)
            try Auth.auth().signOut()
        }catch{
            ProgressHUD.showError(error.localizedDescription)
        }
        // SceneDelegate에 있는 ConfigureInitialViewController를 불러온다.
        (UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).ConfigureInitialViewController()
    }
    
    func observeUsers(onSuccess: @escaping(UserCompletion)) {
        Ref().databaseUsers.observe(.childAdded) { (dataSnapshot) in
            if let userInfo = dataSnapshot.value as? Dictionary<String, Any>{
                if let user = User.transformUser(dict: userInfo){
                    onSuccess(user)
                }
            }
        }
    }
    func getUserSingleInfo(uid: String, onSuccess: @escaping(UserCompletion)){
        let ref = Ref().databaseSpecificUser(uid: uid)
        ref.observeSingleEvent(of: .value) { (snapShot) in
            guard let dict = snapShot.value as? Dictionary<String,Any> else{
                print("getUserInfo : Error")
                return
            }
            if let user = User.transformUser(dict: dict){
                onSuccess(user)
            }
        }
    }
    func getUserInfo(uid: String, onSuccess: @escaping(UserCompletion)){
        let ref = Ref().databaseSpecificUser(uid: uid)
        ref.observe(.value) { (snapShot) in
            guard let dict = snapShot.value as? Dictionary<String,Any> else{
                print("getUserInfo : Error")
                return
            }
            if let user = User.transformUser(dict: dict){
                onSuccess(user)
            }
        }
    }
    
    func saveUserProfile(dict: Dictionary<String, Any>, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        let ref = Ref().databaseSpecificUser(uid: Api.User.currentUserId)
        ref.updateChildValues(dict) { (error, databaseReference) in
            if error != nil{
                onError(error!.localizedDescription)
            }else{ 
                onSuccess()
            }
        }
    }
    
    func isOnline(bool: Bool){
        if !Api.User.currentUserId.isEmpty {
            let ref = Ref().databaseIsOnline(uid: Api.User.currentUserId)
            let dict: Dictionary<String, Any> = [
                "online": bool as Any,
                "latest": Date().timeIntervalSince1970 as Any
            ]
            ref.updateChildValues(dict)
        }
    }
    
    func typing(from: String, to: String){
        let ref = Ref().databaseIsOnline(uid: from)
        let dict: Dictionary<String, Any> = [
            "typing": to
        ]
        ref.updateChildValues(dict)
    }
}

typealias UserCompletion = (User) -> Void
