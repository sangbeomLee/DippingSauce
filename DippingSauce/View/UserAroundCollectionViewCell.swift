//
//  UserAroundCollectionViewCell.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/12.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase

class UserAroundCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var onlineImageView: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    var user: User!
    var inboxChangedOnlineHandle: DatabaseHandle!
    var inboxChangedProfileHandle: DatabaseHandle!
    var controller: UserAroundViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupOnlineImageView()
        setupAvatarImageView()
        setupAgeLabel()
        setupDistanceLabel()
    }
    
    func setupOnlineImageView(){
        onlineImageView.backgroundColor = UIColor.red
        let width = onlineImageView.frame.size.width
        onlineImageView.layer.cornerRadius = width/2
        onlineImageView.clipsToBounds = true
    }
    func setupAvatarImageView(){
        avatarImageView.contentMode = .scaleAspectFill
    }
    func setupAgeLabel(){
        
    }
    func setupDistanceLabel(){
        
    }
    
    func configureCell(){
        
    }
    func loadData(_ user: User, currentLocation: CLLocation?){
        self.user = user
        self.avatarImageView.loadImage(user.profileImageUrl)
        self.avatarImageView.loadImage(user.profileImageUrl) { (image) in
            self.user.profileImage = image
        }
        if let age = user.age{
            self.user.age = age
            self.ageLabel.text = "\(age)"
        }else{
            ageLabel.text = ""
        }
        observeActivity()
        guard let currentLocation = currentLocation else{
            distanceLabel.text = ""
            return
        }
        if !user.latitude.isEmpty && !user.longitude.isEmpty {
            let userLocation = CLLocation(latitude: Double(user.latitude)!, longitude: Double(user.longitude)!)
            // 미터로 나온다. 우리가 필요한건 km이기 때문에 /1000해준다.
            let distanceInKm: CLLocationDistance = userLocation.distance(from: currentLocation) / 1000
            distanceLabel.text = String(format: "%.2f km", distanceInKm)
        }else{
            distanceLabel.text = ""
        }
    }
    
    func observeActivity(){
        let refOnline = Ref().databaseIsOnline(uid: user.uid)
        // 한번만 본다,
        refOnline.observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? Dictionary<String, Any> else {
                //print("chatViewController/observeActivivity/error")
                return
            }
            if let online = value["online"] as? Bool{
                self.onlineImageView.backgroundColor = online ? UIColor.green : UIColor.red
            }
        }
        if inboxChangedOnlineHandle != nil{
            refOnline.removeObserver(withHandle: inboxChangedOnlineHandle)
        }
        
        inboxChangedOnlineHandle = refOnline.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value{
                if snapshot.key == "online"{
                    self.onlineImageView.backgroundColor = (snap as! Bool) ? UIColor.green : UIColor.red
                }
            }
        })
        
        let refProfile = Ref().databaseSpecificUser(uid: user.uid)
        inboxChangedProfileHandle = refProfile.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value as? String{
                self.user.updateData(key: snapshot.key, value: snap)
                self.controller.collectionView.reloadData()
            }
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let refOnline = Ref().databaseIsOnline(uid: self.user.uid)
        if inboxChangedOnlineHandle != nil{
            refOnline.removeObserver(withHandle: inboxChangedOnlineHandle)
        }
        
        let refUser = Ref().databaseSpecificUser(uid: user.uid)
        if inboxChangedProfileHandle != nil{
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
    }
}
