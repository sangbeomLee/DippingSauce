//
//  UserTableViewCell.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/04.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import Firebase

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var onlineView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var controller: PeopleTableViewController!
    var user: User!
    var inboxChangedOnlineHandle: DatabaseHandle!
    var inboxChangedProfileHandle: DatabaseHandle!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let width = avatarImageView.frame.width
        avatarImageView.layer.cornerRadius = width/2
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        
        // onlineView
        let onlineViewWidth = onlineView.frame.size.width
        onlineView.layer.cornerRadius = onlineViewWidth/2
        onlineView.clipsToBounds = true
        onlineView.backgroundColor = .red
        onlineView.layer.borderWidth = 2
        onlineView.layer.borderColor = UIColor.systemBackground.cgColor
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
                self.onlineView.backgroundColor = online ? UIColor.green : UIColor.red
            }
        }
        if inboxChangedOnlineHandle != nil{
            refOnline.removeObserver(withHandle: inboxChangedOnlineHandle)
        }
        
        inboxChangedOnlineHandle = refOnline.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value{
                if snapshot.key == "online"{
                    self.onlineView.backgroundColor = (snap as! Bool) ? UIColor.green : UIColor.red
                }
            }
        })
        
        let refProfile = Ref().databaseSpecificUser(uid: user.uid)
        inboxChangedProfileHandle = refProfile.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value as? String{
                self.user.updateData(key: snapshot.key, value: snap)
                self.controller.tableView.reloadData()
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
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadData(_ user: User){
        self.usernameLabel.text = user.username
        self.statusLabel.text = user.status
        self.avatarImageView.loadImage(user.profileImageUrl)
        self.user = user
        observeActivity()
    }

}
