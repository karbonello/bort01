//
//  SignInVC.swift
//  Taxi for rider
//
//  Created by Chingis on 09.06.17.
//  Copyright © 2017 Chingis. All rights reserved.
//

import UIKit
import Firebase

class SignInVC: UIViewController {
    
    private let RIDER_SEGUE = "RiderVC"
    private let DATA_INPUT = "DataInputVC"

    
    private let AFTER_REGISTRATION_SEGUE = "AfterRegistrationSegue"

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailRegisterField: UITextField!
    @IBOutlet weak var passwordRegisterField: UITextField!
    @IBOutlet weak var passwordConfirmationField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        //emailTextField.layer.cornerRadius = 0
        //passwordTextField.layer.cornerRadius = 0
    }
    
    @IBAction func logIn(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            AuthProvider.Instance.login(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertTheUser(title: "Проблема со входом", message: message!)
                }
                else {
                    TaxiHandler.Instance.rider = self.emailTextField.text!
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil)
                }
            })
        }
        else {
            alertTheUser(title: "Требуется ввести email и пароль ", message: "Пожалуйста введите email и пароль в текстовые поля")
        }
    }
    @IBAction func signUp(_ sender: Any) {
        
        if emailRegisterField.text != "" && passwordRegisterField.text != "" && passwordRegisterField.text == passwordConfirmationField.text {
            
            AuthProvider.Instance.signUp(withEmail: emailRegisterField.text!, password: passwordRegisterField.text!,  loginHandler: { (message) in
                
                if message != nil {
                    self.alertTheUser(title: "Проблема с регистрацией нового пользователя", message: message!)
                }
                else {
                    self.alertTheUser(title: "Регистрация прошла успешно!", message: "Пользователь создан!")
                    self.performSegue(withIdentifier: self.DATA_INPUT, sender: nil)
                }
            })
        }
        else {
            if passwordRegisterField.text != passwordConfirmationField.text {
                
                alertTheUser(title: "Ошибка регистрации! ", message: "Пароли не совпадают!")
            }
            else {
                alertTheUser(title: "Требуется ввести email и пароль ", message: "Пожалуйста введите email и пароль в текстовые поля")
            }
        }
        
    }
    
    private func alertTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
}
