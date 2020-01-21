//
//  SignUpViewController.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/02.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import ProgressHUD
import CoreLocation

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameView: UIView!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    var image: UIImage? = nil
    let manager = CLLocationManager()
    var userLat = ""
    var userLong = ""
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLocationManager()
        setupUI()
    }
    
    func setupUI(){
        setupTitleTextLabel()
        setupAvatarImageView()
        setupFullNameTextField()
        setupEmailTextField()
        setupPasswordTextField()
        setupSignUpButton()
        setupSignInButton()
    }
    
    @IBAction func dismissSignUpViewController(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signupButtonDidTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.validateField()
        if let userLat = UserDefaults.standard.value(forKey: CURRENT_LOCATION_LATITUDE) as? String{
            self.userLat = userLat
        }
        if let userLong = UserDefaults.standard.value(forKey: CURRENT_LOCATION_LONGITUDE) as? String{
            self.userLong = userLong
        }
        
        // 비어있는지 확인
        if !userLat.isEmpty && !userLong.isEmpty{
            // 로그인 표시
            self.location = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
        }
        
        self.signUpAddLocation(location: location, onSuccess: {
            Api.User.isOnline(bool: true)
            (UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).ConfigureInitialViewController()
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
}

