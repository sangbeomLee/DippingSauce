//
//  MessageTableViewCell.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/06.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import AVFoundation

class MessageTableViewCell: UITableViewCell {
    @IBOutlet weak var bubbleRightConstrant: NSLayoutConstraint!
    @IBOutlet weak var bubbleLeftConstrant: NSLayoutConstraint!
    @IBOutlet weak var bubbleViewWidth: NSLayoutConstraint!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var photoMessageImageView: UIImageView!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var headerTimeLabel: UILabel!
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var message: Message!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    func setupUI(){
        setBubbleView()
        setPhotoView()
    }
    
    func configureCell(uid: String, message: Message, image: UIImage ){
        self.message = message
        let text = message.text
        if !text.isEmpty {
            messageTextLabel.text = message.text
            messageTextLabel.isHidden = false
            // 이쪽 widthValue를 40 더해주었더니 ... 나오던것이 사라짐. width가 너무 작게 되었었나보다.
            let widthValue = text.estimateFrameText(text).width + 35
            
            if widthValue < 75{
                bubbleViewWidth.constant = 75
            }else{
                bubbleViewWidth.constant = widthValue
            }
            dateLabel.textColor = .lightGray
        }
        let imageUrl = message.imageUrl
        if !imageUrl.isEmpty{
            photoMessageImageView.loadImage(imageUrl)
            photoMessageImageView.layer.borderColor = UIColor.clear.cgColor
            bubbleViewWidth.constant = 250
            photoMessageImageView.isHidden = false
            dateLabel.textColor = .white
        }
        
        let videoUrl = message.videoUrl
        if !videoUrl.isEmpty{
            playButton.isHidden = false
            dateLabel.textColor = .white
        }
        
        // 보내는 사람
        if uid == message.from{
            bubbleView.backgroundColor = UIColor.systemGroupedBackground
            bubbleView.layer.borderColor = UIColor.clear.cgColor
            bubbleRightConstrant.constant = 8
            bubbleLeftConstrant.constant = UIScreen.main.bounds.width - bubbleViewWidth.constant - bubbleRightConstrant.constant
            
        }else{
            profileImageView.isHidden = false
            profileImageView.image = image
            bubbleView.backgroundColor = UIColor.white
            bubbleView.layer.borderColor = UIColor.lightGray.cgColor
            bubbleLeftConstrant.constant = 55
            bubbleRightConstrant.constant = UIScreen.main.bounds.width - bubbleViewWidth.constant - bubbleLeftConstrant.constant
        }
        
        // dateTime
        let date = Date(timeIntervalSince1970: message.date)
        let dateToString = message.date.doubleToDateTimeString()
        dateLabel.text = dateToString
        
        self.formatHeaderTimeLable(time: date) { (text) in
            self.headerTimeLabel.text = text
        }
        
    }
    func formatHeaderTimeLable(time: Date, complition: @escaping(String) -> Void){
        var text = ""
        let currentDate = Date()
        let format = "yyyyMMdd"
        let currentDateString = currentDate.toString(dateFormat: format)
        let pastDataString = time.toString(dateFormat: format)
        
        // 같은날
        if pastDataString.elementsEqual(currentDateString){
            text = time.toString(dateFormat: "HH:mm a") + ", Today"
        }else{
            // 다른날
            text = time.toString(dateFormat: "yyyy/MM/dd")
        }
        complition(text)
    }
    
    func setBubbleView(){
        bubbleView.layer.cornerRadius = 15
        bubbleView.clipsToBounds = true
        bubbleView.layer.borderWidth = 0.4
        messageTextLabel.numberOfLines = 0
        
        messageTextLabel.isHidden = true
        playButton.isHidden = true
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }
    func setPhotoView(){
        let profileWidth = profileImageView.frame.size.width
        profileImageView.layer.cornerRadius = profileWidth/2
        profileImageView.clipsToBounds = true
        photoMessageImageView.layer.cornerRadius = 15
        photoMessageImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        photoMessageImageView.isHidden = true
        profileImageView.isHidden = true
    }
    // dequeueReusableCell을 사용하여 셀을 구성하면 셀을 재사용하는데 그때 불러오는 함수이다.
    // 셀을 재사용할 때 문제점은 안의 값이 초기화가 되지않아 중복이 될 수 있다. 때문에 이 prepare에서 초기화를 시켜준다.
    override func prepareForReuse() {
        super.prepareForReuse()
        messageTextLabel.isHidden = true
        photoMessageImageView.isHidden = true
        profileImageView.isHidden = true
        playButton.isHidden = true
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
        // remove observer
        if observation != nil { stopObservers() }
        playerLayer?.removeFromSuperlayer()
        player?.pause()
  
        messageTextLabel.text = nil
        photoMessageImageView.image = nil
        dateLabel.text = nil
    }

    func stopObservers(){
        player?.removeObserver(self, forKeyPath: "status")
        observation = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func playButtonDidTapped(_ sender: Any) {
        handlePlayer()
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let status: AVPlayer.Status = player!.status
        switch (status){
        case AVPlayer.Status.readyToPlay:
            activityIndicatorView.isHidden = true
            activityIndicatorView.stopAnimating()
            break
        case AVPlayer.Status.unknown, AVPlayer.Status.failed:
            break
        @unknown default:
            fatalError()
        }
    }
    
    var observation: Any? = nil
    func handlePlayer(){
        let videoUrl = message.videoUrl
        if videoUrl.isEmpty {
            return
        }
        if let url = URL(string: videoUrl){
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
            activityIndicatorView.style = .large
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            // gravity 확인
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            playerLayer?.frame = photoMessageImageView.frame
            // 이부분 확인
            observation = player?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            player?.volume = 0
            playButton.isHidden = true
        }
    }
    
}

