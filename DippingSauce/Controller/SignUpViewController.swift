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
import GeoFire

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
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    
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
        
        self.signUp(onSuccess: {
            if !self.userLat.isEmpty && !self.userLong.isEmpty {
                let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(self.userLat)!), longitude: CLLocationDegrees(Double(self.userLong)!))
                // send location to firebase
                self.geoFireRef = Ref().databaseGeo
                self.geoFire = GeoFire(firebaseRef: self.geoFireRef)
                self.geoFire.setLocation(location, forKey: Api.User.currentUserId)
            }
            Api.User.isOnline(bool: true)
            (UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).ConfigureInitialViewController()
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
}

