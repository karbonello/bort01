//
//  PAEditView.swift
//  Taxi for rider
//
//  Created by Chingis on 01.07.17.
//  Copyright © 2017 Chingis. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class PAEditView: UIViewController {
    
    let user = Auth.auth().currentUser

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.shadowColor = UIColor.black.cgColor
        avatarImageView.layer.shadowOpacity = 1
        avatarImageView.layer.shadowOffset = CGSize.zero
        avatarImageView.layer.shadowRadius = 10
        fillData()
    }
    
    func fillData() {
        DBProvider.Instance.ridersRef.child(user!.uid).observe(DataEventType.value, with: {(snapshot) in
            if let dataInData = snapshot.value as? NSDictionary {
                if let data = dataInData["data"] as? NSDictionary {
                    if let email = data[Constants.EMAIL] as? String {
                        self.emailField.text = email
                    } else {
                        self.emailField.text = ""
                    }
                    
                    if let firstName = data[Constants.FIRST_NAME] as? String {
                        self.nameField.text = firstName
                    } else {
                        self.nameField.text = ""
                    }
                    
                    if let phoneNumber = data[Constants.PHONE_NUMBER] as? String {
                        self.phoneField.text = phoneNumber
                    } else {
                        self.phoneField.text = ""
                    }
                }
            }
        })
        self.phoneField.text = ""
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        self.avatarTopConstraint.constant = -70
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.avatarTopConstraint.constant = 0
    }
    
    
    
    @IBAction func saveData(_ sender: Any) {
        if nameField.text != "" || phoneField.text != "" || emailField.text != "" {
            DBProvider.Instance.saveUserData(withID: user!.uid, firstName: nameField.text!, email: emailField.text!, phone: phoneField.text!)
            alertTheUser(title: "Успешно!", message: "Данные пользователя сохранены!")
        } else {
            alertTheUser(title: "Ошибка!", message: "Нужно ввести все поля!")
        }
    }
    
    private func alertTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}
