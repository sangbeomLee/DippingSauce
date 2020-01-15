//
//  SignInViewController.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/02.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import ProgressHUD
class SignInViewController: UIViewController {

    @IBOutlet weak var titleTextLabel: UILabel!
    
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    func setupUI(){
        setupTitleTextLabel()
        setupEmailTextField()
        setupPasswordTextField()
        setupSignUpButton()
        setupSignInButton()
        setupForgotButton()
    }

    @IBAction func dismissSignInViewController(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func signInButtonDidTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.validateField()
        self.signIn(onSuccess: {
            Api.User.isOnline(bool: true)
            // signIn에 성공하면 다음 화면을 보여주기위해 SceneDelegate에 있는 함수 불러온다.
            (UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).ConfigureInitialViewController()
        }) { (error) in
            ProgressHUD.showError(error)
        }
    }
}
