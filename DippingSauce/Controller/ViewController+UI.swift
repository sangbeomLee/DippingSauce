//
//  ViewController+UI.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/02.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import ProgressHUD
import Firebase

extension ViewController{
    func setupHeaderTitle(){
        // -open- customize header label ----
        // title, subtitle에 사용할 문장을 정의한다.
        let title = "Create a new account"
        let subtitle = "\n\nThis is subtitle we shold change this for DippingSauceApp"
        
        // attributedText
        // title에 NSAtrributedString 하기 위해 NSMutableAttributedString 을 사용하여 string 부분에 원하는 문장이 들어가고 attributes에 [key : value] 형식으로 attribute들을 정의할 수 있다.
        let attributedTitle = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.init(name: "Didot", size: 28)!, NSAttributedString.Key.foregroundColor : UIColor.black])
        
        let attributedSubtitle = NSMutableAttributedString(string: subtitle, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.init(white: 0, alpha: 0.45) ])
        
        // subtitle의 attribute를 append 해준다.
        attributedTitle.append(attributedSubtitle)
        
        // paragraphStyle 지정. lineSpacing = 5 로 지정 해 주었다.
        let paragraphSytle = NSMutableParagraphStyle()
        paragraphSytle.lineSpacing = 5
        
        // attributedTitle에 addAttribute를 하여 적용시킴.
        attributedTitle.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphSytle, range: NSMakeRange(0, attributedTitle.length))
        
        // titleLabel의 numberOfLines = 0 << 여러 줄 나오면 다 표시하겠다는 표시.
        titleLabel.numberOfLines = 0
        // 여러개가 적용되면 attributedText 로 set 해준다.
        titleLabel.attributedText = attributedTitle
        // ----- customize header label -close-
    }
    func setupTermsLabel(){
        let termsTitle = "By clicking 'Create a new account' you agree to our"
        let termsSubtitle = "\nTerms of Service"
        
        let attributedTermsTitle = NSMutableAttributedString(string: termsTitle, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor(white: 0, alpha: 0.65)])
        let attributedTermsSubtitle = NSMutableAttributedString(string: termsSubtitle, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor(white: 0, alpha: 0.65)])
        attributedTermsTitle.append(attributedTermsSubtitle)
        
        termsOfServiceLabel.attributedText = attributedTermsTitle
        termsOfServiceLabel.numberOfLines = 0
        
    }
    func setupFacebookButton(){
        // button
        signInWithFacebookButton.setTitle("Sign in with Facebook", for: .normal)
        signInWithFacebookButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        signInWithFacebookButton.backgroundColor = UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1)
        signInWithFacebookButton.layer.cornerRadius = 5
        signInWithFacebookButton.clipsToBounds = true
        signInWithFacebookButton.setImage(UIImage(named: IMAGE_ICON_FACEBOOK), for: .normal)
        signInWithFacebookButton.tintColor = .white
        signInWithFacebookButton.imageView?.contentMode = .scaleAspectFit
        signInWithFacebookButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: -50, bottom:  8, right: 0)
        
        signInWithFacebookButton.addTarget(self, action: #selector(facebookButtonDidTapped), for: .touchUpInside)
    }
    @objc func facebookButtonDidTapped(){
        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error{
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            
            guard let accessToken = AccessToken.current else{
                ProgressHUD.showError("Failed to get accessToken")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Auth.auth().signIn(with: credential) { (result, error) in
                if let error = error{
                    ProgressHUD.showError(error.localizedDescription)
                    return
                }
            
                if let authData = result {
                    let dict: Dictionary<String, Any> = [
                        UID : authData.user.uid,
                        EMAIL : authData.user.email!,
                        USERNAME : authData.user.displayName,
                        PROFILE_IMAGE_URL : authData.user.photoURL?.absoluteString,
                        STATUS : "Wellcome to DippingSauce"
                    ]
                    Ref().databaseSpecificUser(uid: authData.user.uid).updateChildValues(dict) { (error, ref) in
                        if error == nil{
                            Api.User.isOnline(bool: true)
                            (UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).ConfigureInitialViewController()
                        }else{
                            ProgressHUD.showError(error!.localizedDescription)
                        }
                    }
                }
            }
        }
        
    }
    
    func setupGoogleButton(){
        signInWithGoogleButton.setTitle("Sign in with Google    ", for: .normal)
        signInWithGoogleButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        signInWithGoogleButton.backgroundColor = UIColor(red: 234/255, green: 67/255, blue: 53/255, alpha: 1)
        signInWithGoogleButton.layer.cornerRadius = 5
        signInWithGoogleButton.clipsToBounds = true
        signInWithGoogleButton.setImage(UIImage(named: IMAGE_ICON_GOOGLE), for: .normal)
        signInWithGoogleButton.imageView?.contentMode = .scaleAspectFit
        signInWithGoogleButton.tintColor = .white
        signInWithGoogleButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: -50, bottom: 8, right: 0)
    }
    func setupNewAccountButton(){
        createANewAccountButton.setTitle("Create a new account", for: .normal)
        createANewAccountButton.backgroundColor = .black
        createANewAccountButton.layer.cornerRadius = 5
        createANewAccountButton.clipsToBounds = true
        createANewAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        
    }
    func setupOrLabel(){
        orLabel.text = "Or"
        orLabel.textColor = UIColor(white: 0, alpha: 0.45)
        orLabel.font = UIFont.boldSystemFont(ofSize: 14)
        orLabel.textAlignment = .center
    }
}
