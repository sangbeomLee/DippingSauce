//
//  DetailViewController.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/14.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI(){
        setupAgeLabel()
        setupSendButton()
        setupUsernameLabel()
        setupStatusLabel()
        setupAvatarImageView()
        setupGenderImageView()
    }
    func setupSendButton(){
        sendButton.layer.cornerRadius = 5
        sendButton.clipsToBounds = true
    }
    func setupAvatarImageView(){
        avatarImageView.image = user.profileImage
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        
        // gradient주기 잘 써먹자.
        let frameGradient = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: avatarImageView.frame.size.height)
        avatarImageView.addBlackGradientLayer(frame: frameGradient, colors: [.clear, .black])
    }
    func setupAgeLabel(){
        ageLabel.text = user.age == nil ? "Optional" : "Age: \(user.age!)"
    }
    func setupGenderImageView(){
        guard let isMale = user.isMale else{
            return
        }
        genderImageView.image = isMale ? UIImage(named: IMAGE_ICON_MALE) : UIImage(named: IMAGE_ICON_FEMALE)
        
        genderImageView.contentMode = .scaleAspectFill
    }
    func setupUsernameLabel(){
        usernameLabel.text = user.username
    }
    func setupStatusLabel(){
        statusLabel.text = user.status
        statusLabel.font = UIFont.systemFont(ofSize: 17)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    @IBAction func backButtonDidTapped(_ sender: Any) {
    }
    
    @IBAction func sendButtonDidTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: STORYBOARD_NAME_MESSAGE, bundle: nil)
        let chatVC = storyboard.instantiateViewController(identifier: IDENTIFIER_CHAT) as! ChatViewController
        chatVC.configureChatVC(partnerUserId: user.uid, partnerUsername: user.username, partnerImage: user.profileImage)
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
}
