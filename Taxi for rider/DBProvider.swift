//
//  DBProvider.swift
//  Taxi for rider
//
//  Created by Chingis on 19.06.17.
//  Copyright © 2017 Chingis. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class DBProvider {
    private static let _instance = DBProvider()
    
    static var Instance: DBProvider {
        return _instance
    }
    
    var dbRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var ridersRef: DatabaseReference {
        return dbRef.child(Constants.RIDERS)
    }
    
    //request reference
    var requestRef: DatabaseReference {
        return dbRef.child(Constants.TAXI_REQUEST)
    }
    
    //request accepted
    var requestAcceptedRef: DatabaseReference {
        return dbRef.child(Constants.TAXI_ACCEPTED)
    }
    
    func saveUser (withID: String, email: String, password: String) {
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.isRider: true]
        
        ridersRef.child(withID).child(Constants.DATA).setValue(data)
    }
    
    func saveUserData (withID: String, firstName: String, email: String, phone: String) {
        let firstName: String = firstName
        ridersRef.child(withID).child("data").child(Constants.FIRST_NAME).setValue(firstName)
        ridersRef.child(withID).child("data").child(Constants.EMAIL).setValue(email)
        ridersRef.child(withID).child("data").child(Constants.PHONE_NUMBER).setValue(phone)
    }
    
}
