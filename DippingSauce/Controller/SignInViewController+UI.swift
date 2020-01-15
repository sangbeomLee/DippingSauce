//
//  SignInViewController+UI.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/02.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import ProgressHUD
extension SignInViewController{
    func setupTitleTextLabel(){
        titleTextLabel.text = "Sign In"
        titleTextLabel.font = UIFont.init(name: "Didot", size: 28)
        titleTextLabel.textColor = .black
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
    
    func setupSignInButton(){
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        signInButton.layer.cornerRadius = 3
        signInButton.clipsToBounds = true
        signInButton.backgroundColor = .black
        signInButton.setTitleColor(.white, for: .normal)
    }
    func setupSignUpButton(){
        let signupTitle = "Don't have an account? "
        let signupSubTitle = "Sign Up"
        
        let signupTitleAttribute = NSMutableAttributedString(string: signupTitle, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.init(white: 0, alpha: 0.65)])
        let signupSubTitleAttribute = NSMutableAttributedString(string: signupSubTitle, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.black])
        signupTitleAttribute.append(signupSubTitleAttribute)
        signUpButton.setAttributedTitle(signupTitleAttribute, for: .normal)
    }
    func validateField(){
        guard let email = emailTextField.text, !email.isEmpty else{
            ProgressHUD.showError(ERROR_EMPTY_EMAIL)
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else{
            ProgressHUD.showError(ERROR_EMPTY_PASSWORD)
            return
        }
    }
    
    func signIn(onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        let email = emailTextField.text!
        let password = passwordTextField.text!
        ProgressHUD.show("Loading..")
        Api.User.signIn(email: email, password: password, onSuccess: {
            ProgressHUD.dismiss()
            onSuccess()
        }) { (errorMessage) in
            onError(errorMessage)
        }
    }
    
    func setupForgotButton(){
        
    }
}
