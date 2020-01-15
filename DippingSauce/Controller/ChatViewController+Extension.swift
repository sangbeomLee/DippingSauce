//
//  ChatViewController+Extension.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/06.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit

extension ChatViewController{
    func configureChatVC(partnerUserId: String, partnerUsername: String, partnerImage: UIImage){
        self.partnerUserId = partnerUserId
        self.partnerUsername = partnerUsername
        self.imagePartner = partnerImage
    }
    
    func observeMessages(){
        Api.Message.receiveMessage(from: Api.User.currentUserId, to: partnerUserId) { (message) in
            self.messages.append(message)
            self.sortMessages()
        }
//        Api.Message.receiveMessage(from: partnerUserId, to: Api.User.currentUserId) { (message) in
//            self.messages.append(message)
//            self.sortMessages()
//        }
    }
    func sortMessages(){
        // 꼭 알아둘 것
        messages = messages.sorted(by: { $0.date < $1.date })
        lastMessageKey = messages.first!.id
        // reload하는 이유는..?해야지 리로드해야 새로운 메시지 받을때마다 갱신하니까
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
    func scrollToBottom(){
        if messages.count > 0 {
            let index = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: index, at: .bottom, animated: true)
        }
    }
    func setupPicker(){
        picker.delegate = self
    }
    
    func setupTableView(){
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        if #available(iOS 10.0, *){
            tableView.refreshControl = refreshControl
        }else{
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(loadMore), for: .valueChanged)
        
    }
    @objc func loadMore(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Api.Message.loadMore(lastMessageKey: self.lastMessageKey, from: Api.User.currentUserId, to: self.partnerUserId) { (messagesArray, lastMessageKey) in
                if messagesArray.isEmpty{
                    self.refreshControl.endRefreshing()
                    return
                }
                self.lastMessageKey = lastMessageKey
                self.messages.append(contentsOf: messagesArray)
                self.messages = self.messages.sorted(by: {$0.date < $1.date})
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func setupInputContainer(){
        // withRenderingMode(alwaysTemplate) << 안의 색상정보를 지우고 새로 입힐 수 있게해준다.
        let mediaImage = UIImage(named: IMAGE_ICON_ATTACH)?.withRenderingMode(.alwaysTemplate)
        mediaButton.setImage(mediaImage, for: .normal)
        mediaButton.tintColor = .lightGray
        let audioImage = UIImage(named: IMAGE_ICON_MIC)?.withRenderingMode(.alwaysTemplate)
        audioButton.setImage(audioImage, for: .normal)
        audioButton.tintColor = .lightGray
        
        setupInputTextView()
        
        // keyboard
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification){
        let userInfo = notification.userInfo
        let keyboardScreenEndFrame = (userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        let bottomSafeArea = view.safeAreaInsets.bottom
        let inputViewBottomConstrant = bottomSafeArea - keyboardViewEndFrame.height
        
        if notification.name == UIResponder.keyboardWillHideNotification{
            bottomConstrant.constant = 0
        }else if notification.name == UIResponder.keyboardWillChangeFrameNotification{
            bottomConstrant.constant = inputViewBottomConstrant
        }else{
            return;
        }
        
        // animated
        view.layoutIfNeeded()
    }
    
    func setupInputTextView(){
        inputTextView.delegate = self
        placeholderLabel.isHidden = false

        let placeholderX: CGFloat = self.view.frame.size.width / 75
        let placeholderY: CGFloat = 0
        let placeholderWidth: CGFloat = inputTextView.bounds.width - placeholderX
        let placeholderHeight: CGFloat = inputTextView.bounds.height
        let placeholderFontSize: CGFloat = self.view.frame.size.width / 25
        placeholderLabel.frame = CGRect(x: placeholderX, y: placeholderY, width: placeholderWidth, height: placeholderHeight)
        placeholderLabel.text = "Write a message"
        placeholderLabel.font = UIFont.init(name: "HelveticaNeue", size: placeholderFontSize)
        placeholderLabel.textColor = .lightGray
        placeholderLabel.textAlignment = .left
        
        inputTextView.addSubview(placeholderLabel)
    }
    
    func setupNavigationBar(){
        // 기존 네이게이션바에서 largeDisplay를 썻기때문에 취소해준다.
        navigationItem.largeTitleDisplayMode = .never
        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        avatarImageView.image = imagePartner
        avatarImageView.contentMode = .scaleAspectFill
        let avatarImageViewWidth = avatarImageView.frame.width
        avatarImageView.layer.cornerRadius = avatarImageViewWidth/2
        avatarImageView.clipsToBounds = true
        containView.addSubview(avatarImageView)
        let rightBarButton = UIBarButtonItem(customView: containView)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        updateTopLabel(bool: false)
        observeActivity()
        self.navigationItem.titleView = topLabel
    }
    
    func updateTopLabel(bool: Bool){
        var status = ""
        var color = UIColor()
        
        if bool {
            if isTyping {
                status = "Typing..."
                color = .gray
            }else{
                status = "Active"
                color = .green
            }
        }else{
            status = "Last Active " + self.lastTimeOnline
            color = .red
        }
        topLabel.textAlignment = .center
        topLabel.numberOfLines = 0
        // topLabel
        let attributed = NSMutableAttributedString(string: partnerUsername + "\n", attributes: [.font : UIFont.systemFont(ofSize: 17), .foregroundColor : UIColor.black])
        let subTitleAttribute = NSAttributedString(string: status, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor : color])
        attributed.append(subTitleAttribute)
        topLabel.attributedText = attributed
    }
    
    func observeActivity(){
        let ref = Ref().databaseIsOnline(uid: partnerUserId)
        // 한번만 본다,
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? Dictionary<String, Any> else {
                //print("chatViewController/observeActivivity/error2")
                return
            }
            if let online = value["online"] as? Bool{
                self.isActive = online
            }
            if let latest = value["latest"] as? Double{
                self.lastTimeOnline = latest.doubleToDateTimeString()
            }
            if let typing = value["typing"] as? String {
                self.isTyping = typing == Api.User.currentUserId ? true : false
            }
            self.updateTopLabel(bool: self.isActive)
        }
        
        ref.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value{
                if snapshot.key == "online"{
                    self.isActive = snap as! Bool
                }
                if snapshot.key == "latest"{
                    let latest = snap as! Double
                    self.lastTimeOnline = latest.doubleToDateTimeString()
                }
                if snapshot.key == "typing"{
                    self.isTyping = snap as! String == Api.User.currentUserId ? true : false
                }
            }
            self.updateTopLabel(bool: self.isActive)
        })
    }
    
    func sendToFirebase(dictionary: Dictionary<String,Any>){
           let date: Double = Date().timeIntervalSince1970
           var value = dictionary
           value["from"] = Api.User.currentUserId
           value["to"] = partnerUserId
           value["date"] = date
           value["read"] = false
           Api.Message.sendMessage(from: Api.User.currentUserId, to: partnerUserId, value: value)
       }
}
extension ChatViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        let spacing = CharacterSet.whitespacesAndNewlines
        if !textView.text.trimmingCharacters(in: spacing).isEmpty{
            let text = textView.text.trimmingCharacters(in: spacing)
            sendButton.isEnabled = true
            sendButton.setTitleColor(.black, for: .normal)
            placeholderLabel.isHidden = true
        }else{
            sendButton.isEnabled = false
            sendButton.setTitleColor( .lightGray, for: .normal)
            placeholderLabel.isHidden = false
        }
        if !isTyping{
            Api.User.typing(from: Api.User.currentUserId, to: partnerUserId)
            isTyping = true
        }else{
            timer.invalidate()
        }
        timerTyping()
    }
    
    func timerTyping(){
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer) in
            Api.User.typing(from: Api.User.currentUserId, to: "")
            self.isTyping = false
        })
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoUrl = info[.mediaURL] as? URL{
            handleVideoSelectedUrl(videoUrl)
        }else{
            handleImageSelectedForInfo(info)
        }
        
    }
    
    func handleVideoSelectedUrl(_ url: URL){
        // save video data
        let videoname = NSUUID().uuidString
        StorageService.saveVideoMessage(url: url, uid: videoname, onSuccess: { (anyValue) in
            if let dict = anyValue as? [String:Any]{
                self.sendToFirebase(dictionary: dict)
            }
        }) { (errorMessage) in
            print(errorMessage)
        }
        self.picker.dismiss(animated: true, completion: nil)
    }
    
    func handleImageSelectedForInfo(_ info: [UIImagePickerController.InfoKey : Any]){
        var selectedImageFromPicker: UIImage?
        if let seletedImage = info[.editedImage] as? UIImage{
            selectedImageFromPicker = seletedImage
        }
        if let imageOriginal = info[.originalImage] as? UIImage{
            selectedImageFromPicker = imageOriginal
        }
        // save photo data
        // 같은이름(uid)으로 파일이 계속 저장되니까 NSUUID()를 통하여 유니크한 아이디를 넣어준다.
        let imageName = NSUUID().uuidString
        StorageService.savePhotoMessage(image: selectedImageFromPicker, uid: imageName, onSuccess: { (anyValue) in
            if let dict = anyValue as? [String:Any]{
                self.sendToFirebase(dictionary: dict)
            }
        }) { (errorMessage) in
            print(errorMessage)
        }
        
        self.picker.dismiss(animated: true, completion: nil )
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_CELL_MESSAGE, for: indexPath) as! MessageTableViewCell
        
        cell.configureCell(uid: Api.User.currentUserId, message: messages[indexPath.row], image: imagePartner)
        cell.headerTimeLabel.isHidden = (indexPath.row % 3 == 0) ? false : true
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = 0
        let message = messages[indexPath.row]
        let text = message.text
        if !text.isEmpty {
            height = text.estimateFrameText(text).height + 60
        }
        let heightMessage = message.height
        let widthMessage = message.width
        // 가로 세로 비율 해서 곱해주기.
        if heightMessage != 0 , widthMessage != 0 {
            height = CGFloat(heightMessage/widthMessage * 250)
        }
        return height
    }
    
}

