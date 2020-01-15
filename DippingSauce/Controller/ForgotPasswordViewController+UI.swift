//
//  ForgotPasswordViewController+UI.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/03.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import ProgressHUD

extension ForgotPasswordViewController{
    func setupEmailTextField(){
        emailView.layer.cornerRadius = 3
        emailView.clipsToBounds = true
        emailView.layer.borderWidth = 1
        emailView.layer.borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1).cgColor
        emailTextField.borderStyle = .none
        let attributedPlaceholder = NSAttributedString(string: "Email address", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        emailTextField.attributedPlaceholder = attributedPlaceholder
        emailTextField.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
    }
    
    func setupResetButton(){
        resetButton.backgroundColor = .black
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.setTitle("Reset My Password", for: .normal)
        resetButton.layer.cornerRadius = 5
        resetButton.clipsToBounds = true
        resetButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
    }
    func validateField(){
        guard let email = emailTextField.text, !email.isEmpty else{
            ProgressHUD.showError(ERROR_EMPTY_EMAIL)
            return
        }
    }
    
    func forgotPassword(onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String)->Void){
        let email = emailTextField.text!
        Api.User.forgotPassword(email: email, onSuccess: {
            onSuccess()
        }) { (errorMessage) in
            onError(errorMessage)
        }
    }
}
