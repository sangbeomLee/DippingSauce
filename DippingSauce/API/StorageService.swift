//
//  StorageService.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/03.
//  Copyright © 2020 이상범. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
import ProgressHUD
import AVFoundation

class StorageService{
    static func saveVideoMessage(url: URL, uid: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        let ref = Ref().storageSpecificVideoMessage(uid: uid)
        //let metadata = StorageMetadata()
        //metadata.contentType = "video/quicktime"
        guard let videoData = NSData(contentsOf: url) as Data? else{
            return
        }
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        ref.putData(videoData, metadata: metadata) { (metadata, error) in
            if error != nil{
                onError(error!.localizedDescription)
            }
            ref.downloadURL { (videoUrl, error) in
                // 1. thumbnail
                if let thumbnailImage = self.thumbnailImageForFileUrl(url){
                    // 2. video, thumbnail
                    savePhotoMessage(image: thumbnailImage, uid: uid, onSuccess: { (value) in
                        if let dict = value as? Dictionary<String,Any>{
                            var dictValue = dict
                            if let videoUrlString = videoUrl?.absoluteString{
                                dictValue["videoUrl"] = videoUrlString
                            }
                            onSuccess(dictValue)
                        }
                    }) { (errorMessage) in
                        onError(errorMessage)
                    }
                }
                if error != nil{
                    onError(error!.localizedDescription)
                }
            }
        }
    }
    
    static func thumbnailImageForFileUrl(_ url: URL) -> UIImage?{
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value, 6)
        do{
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }catch let error as NSError{
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func savePhotoMessage(image: UIImage?, uid: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void ){
        if let imagePhoto = image{
            let ref = Ref().storageSpecificImageMessage(uid: uid)
            if let data = imagePhoto.jpegData(compressionQuality: 0.5){
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpg"
                ref.putData(data, metadata: metaData) { (metaData, error) in
                    if error != nil{
                        onError(error!.localizedDescription)
                    }
                    ref.downloadURL { (url, error) in
                        if error != nil{
                            onError(error!.localizedDescription)
                            return
                        }
                        guard let metaImageUrl = url?.absoluteString else{
                            print("no MetaImageUrl")
                            return
                        }
                        let dict: Dictionary<String, Any> = [
                            "imageUrl" : metaImageUrl as Any,
                            "width" : imagePhoto.size.width as Any,
                            "height" : imagePhoto.size.height as Any,
                            "text" : "" as Any
                        ]
                        onSuccess(dict)
                    }
                }
            }
        }
    }
    
    static func saveProfileImage(image: UIImage, uid: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        guard let imageData = image.jpegData(compressionQuality: 0.4) else{
            print("saveProfileImage : no ImageData")
            return
        }
        let storageProfileRef = Ref().storageSpecificProfile(uid: uid)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageProfileRef.putData(imageData, metadata: metaData) { (storageMetaData, error) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            
            // url가져오기
            storageProfileRef.downloadURL { (url, error) in
                if error != nil{
                    onError(error!.localizedDescription)
                    return
                }
                guard let metaImageUrl = url?.absoluteString else{
                    print("no MetaImageUrl")
                    return
                }
                
                // changeRequest
                if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest(){
                    changeRequest.photoURL = url
                    changeRequest.commitChanges { (error) in
                        if let error = error{
                            onError(error.localizedDescription)
                        } else{
                            NotificationCenter.default.post(name: NSNotification.Name(IDENTIFIER_UPDATE_PROFILE_IMAGE), object: nil)
                        }
                        
                    }
                }
                var dict = Dictionary<String, Any>()
                dict[PROFILE_IMAGE_URL] = metaImageUrl
                
                // 여기서 database imageUrl바꿔준다.
                Ref().databaseSpecificUser(uid: uid).updateChildValues(dict) {
                    (error, databaseReference) in
                    if error != nil{
                        onError(error!.localizedDescription)
                    }else{
                        onSuccess()
                    }
                }
            }
        }
    }

    
    static func savePhoto(username: String, uid: String, data: Data, metaData: StorageMetadata,
                          storageProfileRef: StorageReference, dictionary: Dictionary<String, Any>,
                          onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void ){
        
        
        storageProfileRef.putData(data, metadata: metaData) { (storageMetaData, error) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            
            // url가져오기
            storageProfileRef.downloadURL { (url, error) in
                if error != nil{
                    onError(error!.localizedDescription)
                    return
                }
                guard let metaImageUrl = url?.absoluteString else{
                    print("no MetaImageUrl")
                    return
                }
                if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest(){
                    changeRequest.photoURL = url
                    changeRequest.displayName = username
                    changeRequest.commitChanges { (error) in
                        if let error = error{
                            onError(error.localizedDescription)
                        }
                    }
                }
                var tempDictionary = dictionary
                tempDictionary[PROFILE_IMAGE_URL] = metaImageUrl
                Ref().databaseSpecificUser(uid: uid).updateChildValues(tempDictionary) {
                    (error, databaseReference) in
                    if error != nil{
                        onError(error!.localizedDescription)
                    }else{
                        onSuccess()
                    }
                }
            }
        }
    }
}
