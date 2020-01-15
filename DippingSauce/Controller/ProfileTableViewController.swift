//
//  ProfileTableViewController.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/07.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import ProgressHUD

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var segmentedContoller: UISegmentedControl!
    @IBOutlet weak var statusTextField: UITextField!
    @IBOutlet weak var emailtextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeData()
        setupUI()
    }
    func observeData(){
        Api.User.getUserSingleInfo(uid: Api.User.currentUserId) { (user) in
            self.usernameTextField.text = user.username
            self.emailtextField.text = user.email
            self.statusTextField.text = user.status
            self.avatarImageView.loadImage(user.profileImageUrl)
            if let age = user.age {
                self.ageTextField.text = "\(age)"
            }else{
                self.ageTextField.placeholder = "Optional"
            }
            if let isMale = user.isMale {
                self.segmentedContoller.selectedSegmentIndex = isMale ? 0 : 1
            }
        }
//        // 이미지가 바뀌고 두번실행된다. 때문에 시작할때 한번만 되게 한다.
//        Api.User.getUserInfo(uid: Api.User.currentUserId) { (user) in
//            self.usernameTextField.text = user.username
//            self.emailtextField.text = user.email
//            self.statusTextField.text = user.status
//            self.avatarImageView.loadImage(user.profileImageUrl)
//        }
    }
    func setupUI(){
        setupAvatarImageView()
    }
    func setupAvatarImageView(){
        self.view.endEditing(true)
        // setup avartaImageView
        let width = avatarImageView.frame.size.width
        avatarImageView.layer.cornerRadius = width/2
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        avatarImageView.addGestureRecognizer(tapGesture)
        avatarImageView.isUserInteractionEnabled = true
    }
    @objc func presentPicker(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonDidTapped(_ sender: Any) {
        Api.User.logOut()
    }
    @IBAction func saveButtonDidTapped(_ sender: Any) {
        self.view.endEditing(true)
        ProgressHUD.show("Loading...")
        
        var dict = Dictionary<String, Any>()
        if let username = usernameTextField.text, !username.isEmpty{
            dict[USERNAME] = username
        }
        if let email = emailtextField.text, !email.isEmpty{
            dict[EMAIL] = email
        }
        if let status = statusTextField.text, !status.isEmpty{
            dict[STATUS] = status
        }
        if segmentedContoller.selectedSegmentIndex == 0{
            dict[ISMALE] = true
        }else{
            dict[ISMALE] = false
        }
        if let age = ageTextField.text , !age.isEmpty {
            dict[AGE] = Int(age)
        }
        
        Api.User.saveUserProfile(dict: dict, onSuccess: {
            if let image = self.image{
                StorageService.saveProfileImage(image: image, uid: Api.User.currentUserId, onSuccess: {
                }) { (error) in
                    ProgressHUD.showError(error)
                }
            }
            ProgressHUD.showSuccess()
        }) { (error) in
            ProgressHUD.showError(error)
        }
    }
}

extension ProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageSelected = info[.editedImage] as? UIImage{
            avatarImageView.image = imageSelected
        }
        if let imageOriginal = info[.originalImage] as? UIImage{
            avatarImageView.image = imageOriginal
        }
        image = avatarImageView.image
        picker.dismiss(animated: true, completion: nil)
    }
    
}
