//
//  MessagesViewController.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/04.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit

class MessagesTableViewController: UITableViewController {

    var inboxArray = [Inbox]()
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    var lastInboxDate: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        observeInbox()
    }
    
    func setupNavigationBar(){
        navigationItem.title = "Messages"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        let width = containView.frame.size.width
        containView.layer.cornerRadius = width/2
        containView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill

        containView.addSubview(avatarImageView)
        let leftBarButtonItem = UIBarButtonItem(customView: containView)
        self.navigationItem.leftBarButtonItem  = leftBarButtonItem
        
        Api.User.getUserInfo(uid: Api.User.currentUserId, onSuccess: { (user) in
            self.avatarImageView.loadImage(user.profileImageUrl)
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile), name: NSNotification.Name(IDENTIFIER_UPDATE_PROFILE_IMAGE), object: nil)
        
    }
    @objc func updateProfile(){
        Api.User.getUserInfo(uid: Api.User.currentUserId, onSuccess: { (user) in
            self.avatarImageView.loadImage(user.profileImageUrl)
        })
    }
    
    func observeInbox(){
        // 이 부분 다시보자.
        Api.Inbox.lastMessage(uid: Api.User.currentUserId) { (inbox) in
            if !self.inboxArray.contains(where: {$0.user.uid == inbox.user.uid}){
                self.inboxArray.append(inbox)
                self.sortedInbox()
            }
        }
    }
    func sortedInbox(){
        // 시간 최근것이 위에와야하니까 이렇게 한다.
        inboxArray.sort(by: {$0.date > $1.date})
        // inbox의 마지막 array
        lastInboxDate = inboxArray.last!.date
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // 위에서 아래로 드래그 할 때 불러오는 함수
    func loadMore(){
        Api.Inbox.loadMore(start: lastInboxDate, controller: self, from: Api.User.currentUserId) { (inbox) in
            self.tableView.tableFooterView = UIView()
            if self.inboxArray.contains(where: { $0.channelId == inbox.channelId }){
                return
            }
            self.inboxArray.append(inbox)
            self.tableView.reloadData()
            self.lastInboxDate = self.inboxArray.last!.date
        }
    }
    
    func setupTableView(){
        tableView.tableFooterView = UIView()
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return inboxArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_CELL_INBOX, for: indexPath) as! InboxTableViewCell

        cell.controller = self
        cell.configureCell(uid: Api.User.currentUserId, inbox: inboxArray[indexPath.row])
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? InboxTableViewCell else{
            print("MessagesTableViewController/didSelectRowAt/error")
            return
        }
        
        let storyboard = UIStoryboard(name: "Message", bundle: nil)
        let chatVC = storyboard.instantiateViewController(identifier: IDENTIFIER_CHAT) as! ChatViewController
        chatVC.imagePartner = cell.avartaImageView.image
        chatVC.partnerUsername = cell.usernameTextLabel.text
        chatVC.partnerUserId = cell.user.uid
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
   
    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if let lastIndex = self.tableView.indexPathsForVisibleRows?.last{
            if lastIndex.row > self.inboxArray.count-2 {
                let spinner = UIActivityIndicatorView(style: .medium)
                spinner.startAnimating()
                spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
                
                self.tableView.tableFooterView = spinner
                self.tableView.tableFooterView?.isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self.loadMore()
                }
            }
        }
    }

}
