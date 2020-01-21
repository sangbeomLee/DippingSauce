//
//  SignUpViewController+UI.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/02.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import ProgressHUD
import CoreLocation

extension SignUpViewController{
    func setupTitleTextLabel(){
        titleTextLabel.text = "Sign Up"
        titleTextLabel.font = UIFont.init(name: "Didot", size: 28)
        titleTextLabel.textColor = .black
    }
    func setupAvatarImageView(){
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width*0.5
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = UIColor(red: 235/255, green: 230/255, blue: 204/255, alpha: 1)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
        avatarImageView.contentMode = .scaleAspectFill
    }
    
    @objc func presentPicker(){
        let picker = UIImagePickerController()
        // 이 부분은 사진을 클릭하고 사진을 edit할 수 있게 한다.
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func setupFullNameTextField(){
        fullNameView.layer.borderWidth = 1
        fullNameView.layer.borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1).cgColor
        fullNameView.layer.cornerRadius = 3
        fullNameView.clipsToBounds = true
        fullNameTextField.borderStyle = .none
        let placeholderAttribute = NSAttributedString(string: "Full Name", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        fullNameTextField.attributedPlaceholder = placeholderAttribute
        fullNameTextField.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
    }
    func setupEmailTextField(){
        emailView.layer.borderWidth = 1
        emailView.layer.borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1).cgColor
        emailView.layer.cornerRadius = 3
        emailView.clipsToBounds = true
        emailTextField.borderStyle = .none
        let placeholderAttribute = NSAttributedString(string: "Email Adderss", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        emailTextField.attributedPlaceholder = placeholderAttribute
        emailTextField.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
    }
    func setupPasswordTextField(){
        passwordView.layer.borderWidth = 1
        passwordView.layer.borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1).cgColor
        passwordView.layer.cornerRadius = 3
        passwordView.clipsToBounds = true
        passwordTextField.borderStyle = .none
        let placeholderAttribute = NSAttributedString(string: "Password (8+ Catracters)", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        passwordTextField.attributedPlaceholder = placeholderAttribute
        passwordTextField.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
    }
    func setupSignUpButton(){
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        signUpButton.layer.cornerRadius = 3
        signUpButton.clipsToBounds = true
        signUpButton.backgroundColor = .black
        signUpButton.setTitleColor(.white, for: .normal)
    }
    func setupSignInButton(){
        let signinTitle = "Already have an account? "
        let signinSubTitle = "Sign In"
        
        let signinTitleAttribute = NSMutableAttributedString(string: signinTitle, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 0.65)])
        let signinSubTitleAttribute = NSMutableAttributedString(string: signinSubTitle, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.black])
        signinTitleAttribute.append(signinSubTitleAttribute)
        signInButton.setAttributedTitle(signinTitleAttribute, for: .normal)
    }
    func validateField(){
        guard let userName = fullNameTextField.text, !userName.isEmpty else{
            ProgressHUD.showError(ERROR_EMPTY_USERNAME)
            return
        }
        guard let email = emailTextField.text, !email.isEmpty else{
            ProgressHUD.showError(ERROR_EMPTY_EMAIL)
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else{
            ProgressHUD.showError(ERROR_EMPTY_PASSWORD)
            return
        }
    }
    
    func configureLocationManager(){
        // location에 대한 정보
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = true
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            manager.startUpdatingLocation()
        }
    }
    func signUp(onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        // send to firebase
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let userName = fullNameTextField.text!
        let image = avatarImageView.image
        ProgressHUD.show("Loading..")
        Api.User.signUp(withUsername: userName, email: email, password: password, image: image, onSuccess: {
            ProgressHUD.dismiss()
            onSuccess()
        }) { (errorMessage) in
            onError(errorMessage)
        }
    }
    
    func signUpAddLocation(location: CLLocation?, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        // send to firebase
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let userName = fullNameTextField.text!
        let image = avatarImageView.image
        
        guard let location = location else{
            ProgressHUD.show("Loading..")
            Api.User.signUp(withUsername: userName, email: email, password: password, image: image, onSuccess: {
                ProgressHUD.dismiss()
                onSuccess()
            }) { (errorMessage) in
                onError(errorMessage)
            }
            return
        }
        
        ProgressHUD.show("Loading..")
        Api.User.signUpAddLocation(withUsername: userName, email: email, password: password, image: image, location: location, onSuccess: {
            ProgressHUD.dismiss()
            onSuccess()
        }) { (errorMessage) in
            onError(errorMessage)
        }
    }
    
    // 키보드등의 이벤트를 종료할때 키보드 내리는 오버라이드
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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

extension SignUpViewController: CLLocationManagerDelegate{
    // ChangeAuthorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse){
            manager.startUpdatingLocation()
        }
    }
    // error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        ProgressHUD.showError(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let updatedLocation: CLLocation = locations.first!
        let newCoordinate: CLLocationCoordinate2D = updatedLocation.coordinate
        // update Location
        let userDefaults: UserDefaults = UserDefaults.standard
        userDefaults.set("\(newCoordinate.latitude)", forKey: CURRENT_LOCATION_LATITUDE)
        userDefaults.set("\(newCoordinate.longitude)", forKey: CURRENT_LOCATION_LONGITUDE)
        userDefaults.synchronize()
        
    }
}
