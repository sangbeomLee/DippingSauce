//
//  InboxTableViewCell.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/07.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import Firebase

class InboxTableViewCell: UITableViewCell {

    @IBOutlet weak var onlineView: UIView!
    @IBOutlet weak var avartaImageView: UIImageView!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var dateTextLabel: UILabel!
    
    // 상대방 유저 정보.
    var user: User!
    var inbox: Inbox!
    var inboxChangedOnlineHandle: DatabaseHandle!
    var inboxChangedProfileHandel: DatabaseHandle!
    var inboxChangedMessageHandel: DatabaseHandle!
    var controller: MessagesTableViewController!
     
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    func setupUI(){
        setupAvatarImageView()
        setupMessageTextLabel()
        setupDateTextLabel()
        setupUsernameTextLabel()
    }
    func setupAvatarImageView(){
        let width = avartaImageView.frame.size.width
        avartaImageView.layer.cornerRadius = width/2
        avartaImageView.clipsToBounds = true
        avartaImageView.contentMode = .scaleAspectFill
        
        // onlineView
        let onlineViewWidth = onlineView.frame.size.width
        onlineView.layer.cornerRadius = onlineViewWidth/2
        onlineView.clipsToBounds = true
        onlineView.backgroundColor = .red
        onlineView.layer.borderWidth = 2
        onlineView.layer.borderColor = UIColor.systemBackground.cgColor
        
    }
    func setupUsernameTextLabel(){
        
    }
    func setupMessageTextLabel(){
        
    }
    func setupDateTextLabel(){
        
    }
    func configureCell(uid: String, inbox: Inbox){
        self.user = inbox.user
        self.inbox = inbox
        avartaImageView.loadImage(inbox.user.profileImageUrl)
        usernameTextLabel.text = inbox.user.username
        dateTextLabel.text = inbox.date.doubleToDateTimeString()
        messageTextLabel.text = inbox.text
        observeActivity()
        
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
        
        let refUser = Ref().databaseSpecificUser(uid: user.uid)
        if inboxChangedProfileHandel != nil{
            refUser.removeObserver(withHandle: inboxChangedProfileHandel)
        }
        
        inboxChangedProfileHandel = refUser.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value as? String{
                self.user.updateData(key: snapshot.key, value: snap)
                self.controller.sortedInbox()
            }
        })
        
        //let refMessage = Ref().databaseInboxInfo(from: Api.User.currentUserId, to: user.uid)
        let channelId = Message.hash(forMembers: [Api.User.currentUserId, user.uid])
        let refMessage = Ref().databaseInboxForUser(uid: Api.User.currentUserId).child(channelId)
        
        if inboxChangedMessageHandel != nil{
            refMessage.removeObserver(withHandle: inboxChangedMessageHandel)
        }
        inboxChangedMessageHandel = refMessage.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value{
                self.inbox.updateData(key: snapshot.key, value: snap)
                self.controller.sortedInbox()
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
        if inboxChangedProfileHandel != nil{
            refUser.removeObserver(withHandle: inboxChangedProfileHandel)
        }
        
        let channelId = Message.hash(forMembers: [Api.User.currentUserId, user.uid])
        let refMessage = Ref().databaseInboxForUser(uid: Api.User.currentUserId).child(channelId)
        //let refMessage = Ref().databaseInboxInfo(from: Api.User.currentUserId, to: user.uid)
        if inboxChangedMessageHandel != nil{
            refMessage.removeObserver(withHandle: inboxChangedMessageHandel)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
