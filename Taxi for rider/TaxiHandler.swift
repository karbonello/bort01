//
//  TaxiHandler.swift
//  Taxi for rider
//
//  Created by Chingis on 20.06.17.
//  Copyright © 2017 Chingis. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol TaxiController: class {
    func canCallTaxi(delegateCalled: Bool)
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String)
    func updateDriversLocation (lat: Double, long: Double)
    
}

class TaxiHandler {
    private static let _instance = TaxiHandler()
    
    weak var delegate: TaxiController?
    
    var rider =  ""
    var driver = ""
    var rider_id = ""
    
    static var Instance: TaxiHandler {
        return _instance
    }
    
    func observeMessagesForRider() {
        // Пассажир вызвал такси
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.rider_id = snapshot.key
                        self.delegate?.canCallTaxi(delegateCalled: true)
                    }
                }
            }
        }
        // Пассажир отменил вызов
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        //self.delegate?.canCallTaxi(delegateCalled: false)
                    }
                }
                
                if let name = data[Constants.NAME] as? String {
                    self.rider = name
                }
            }
        }
        //Водитель принял вызов
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded)  {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                print("1")
                if let name = data[Constants.NAME] as? String {
                    print("2")
                    if self.driver == "" {
                        print("3")
                        self.driver = name
                        print("ну принял или нет?")
                        self.delegate?.driverAcceptedRequest(requestAccepted: true, driverName: self.driver)
                    }
                }
            }
        }
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.driver = ""
                        self.delegate?.driverAcceptedRequest(requestAccepted: false, driverName: name)
                        self.delegate?.canCallTaxi(delegateCalled: false)
                    }
                }
            } 
        }
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childChanged) {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                print(data)
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        if let lat = data[Constants.LATITUDE] as? Double {
                            if let long = data[Constants.LONGITUDE] as? Double {
                                self.delegate?.updateDriversLocation(lat: lat, long: long)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func requestTaxi(latitude: Double, longitude: Double) {
        let data: Dictionary<String, Any> = [Constants.NAME: rider, Constants.LATITUDE: latitude, Constants.LONGITUDE: longitude]
        DBProvider.Instance.requestRef.childByAutoId().setValue(data)
    }
    
    func cancelTaxi() {
        DBProvider.Instance.requestRef.child(rider_id).removeValue()
        DBProvider.Instance.requestAcceptedRef.child(rider_id).removeValue()
    }
    
    func acceptTaxi() {
        DBProvider.Instance.requestRef.child(rider_id).removeValue()
    }
}
