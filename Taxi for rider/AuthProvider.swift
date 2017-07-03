//
//  AuthProvider.swift
//  Taxi for rider
//
//  Created by Chingis on 10.06.17.
//  Copyright © 2017 Chingis. All rights reserved.
//

import Foundation
import FirebaseAuth

struct LoginErrorCode {
    static let INVALID_EMAIL = "Несуществующий email адрес"
    static let WRONG_PASSWORD = "Неверный пароль"
    static let PROBLEM_CONNECTING = "Проблемя при подсоединении к базе данных"
    static let USER_NOT_FOUND = "Пользователь не найден"
    static let EMAIL_ALREADY_IN_USE = "Данный email уже использован"
    static let WEAK_PASSWORD = "Пароль дольжен содержать больше 6 символов"
}

typealias LoginHandler = (_ msg: String?) -> Void

class AuthProvider  {
    private static let _instance = AuthProvider()
    
    static var Instance: AuthProvider {
        return _instance
    }
    
    func login(withEmail: String, password: String, loginHandler: LoginHandler?) {
        Auth.auth().signIn(withEmail: withEmail, password: password){ (user, error) in
        
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler)
            }
            else {
                loginHandler?(nil)
            }
            
        }
    }
    
    func signUp(withEmail: String, password: String, loginHandler: LoginHandler?) {
        
        Auth.auth().createUser(withEmail: withEmail, password: password){ (user, error) in
            
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler)
            }
            else {
                if user?.uid != nil {
                    //Сохраняем пользователя в базу данных
                    DBProvider.Instance.saveUser(withID: user!.uid, email: withEmail, password: password)
                    
                    //Логинимся
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler)
                    
                     
                }
            }
        }
    }
    
    
    func logOut() -> Bool {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                return true
            }
            catch {
                return false
            }
        }
        return true
    }
    
    private func handleErrors (err: NSError, loginHandler: LoginHandler?) {
        
        if let errCode = AuthErrorCode(rawValue: err.code) {
            switch errCode {
            case .wrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD)
                break
                
            case .invalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL)
                break
                
            case .userNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND)
                break
                
            case .emailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE)
                break
                
            case .weakPassword:
                loginHandler?(LoginErrorCode.WEAK_PASSWORD)
                break
                
            default:
                loginHandler?(LoginErrorCode.PROBLEM_CONNECTING)
                break
                
            }
        }
    }
    
}
