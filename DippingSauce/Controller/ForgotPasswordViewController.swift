//
//  ForgotPasswordViewController.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/03.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import ProgressHUD

class ForgotPasswordViewController: UIViewController {


    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        setupEmailTextField()
        setupResetButton()
    }
    @IBAction func dismissForgotPasswordViewController(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetButtonDidTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.validateField()
        self.forgotPassword(onSuccess: {
            ProgressHUD.showSuccess(SUCCESS_EMAIL_RESET)
            self.navigationController?.popViewController(animated: true)
        }) { (error) in
            ProgressHUD.showError(error)
        }
    }
    
}
