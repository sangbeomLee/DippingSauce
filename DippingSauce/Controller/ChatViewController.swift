//
//  ChatViewController.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/05.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var mediaButton: UIButton!
    @IBOutlet weak var bottomConstrant: NSLayoutConstraint!
    
    var imagePartner: UIImage!
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    var topLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    var partnerUsername: String!
    var partnerUserId: String!
    var placeholderLabel = UILabel()
    var picker = UIImagePickerController()
    var messages = [Message]()
    var isActive = false
    var isTyping = false
    var timer = Timer()
    var lastTimeOnline = ""
    var refreshControl = UIRefreshControl()
    var lastMessageKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPicker()
        setupNavigationBar()
        setupInputContainer()
        setupTableView()
        observeMessages()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // tabBar를 가려준다.
        self.tabBarController?.tabBar.isHidden = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    @IBAction func mediaButtonDidTapped(_ sender: Any) {
        let alert = UIAlertController(title: "DippingSauce", message: "Select", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Take a picture", style: .default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.picker.sourceType = .camera
                self.present(self.picker, animated: true, completion: nil)
            }else{ print("unavailable") }
        }
        let videoCamera = UIAlertAction(title: "Take a video", style: .default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                self.picker.sourceType = .camera
                // import했으며 video를 찍게해준다..?-------- d알아볼것
                self.picker.mediaTypes = [String(kUTTypeMovie)]
                self.picker.videoExportPreset = AVAssetExportPresetPassthrough
                self.picker.videoMaximumDuration = 30
                //---------------------
                self.present(self.picker, animated: true, completion: nil)
            }else{ print("unavailable") }
        }
        let library = UIAlertAction(title: "Choose an Image or a Video", style: .default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                self.picker.sourceType = .photoLibrary
                // 이미지와 비디오 둘 다 나오게한다.
                self.picker.mediaTypes = [String(kUTTypeImage),String(kUTTypeMovie)]
                self.present(self.picker, animated: true, completion: nil)
            }else{ print("unavailable") }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(videoCamera)
        alert.addAction(cancel)
        //picker.modalPresentationStyle = .fullScreen
        present(alert, animated: true, completion: nil)
    }
    @IBAction func audioButtonDidTappted(_ sender: Any) {
    }
    @IBAction func sendButtonDidTapped(_ sender: Any) {
        if let text = inputTextView.text, text != ""{
            inputTextView.text = ""
            // 갱신
            self.textViewDidChange(inputTextView)
            sendToFirebase(dictionary: ["text" : text as Any])
        }
    }
    
}

