//
//  RiderVC.swift
//  Taxi for rider
//
//  Created by Chingis on 19.06.17.
//  Copyright © 2017 Chingis. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
//c google maps

class RiderVC: UIViewController, CLLocationManagerDelegate, TaxiController, GMSMapViewDelegate, UISearchBarDelegate,GMSAutocompleteViewControllerDelegate  {
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var driverLocation: CLLocationCoordinate2D?
    
    private var canCallTaxi = true
    private var riderCanceledRequest = false
    private var firstLocation = true
    private var timer = Timer()
    private var isSidebarOpened = false
    
    var carClasses = CarCategory.createCarCategory()   
    
    //private var 👱🏻🚕 = ""
    
    //private var placeOnCursor = GMSPlace()
    
    var carClassButtons: Dictionary<UIButton, String> = [:]

    @IBOutlet weak var carPickerCollection: UICollectionView!
    @IBOutlet weak var TableMenu: UITableView!
    @IBOutlet weak var callTaxiBtn: UIButton!
    //@IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var gMap: GMSMapView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var sidebarLeadinConstraint: NSLayoutConstraint!
    @IBOutlet weak var showMenuBtn: UIButton!
    @IBOutlet weak var locationCursor: UIImageView!
    @IBOutlet weak var currentPlace: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        initialazeLocationManager()
        
        //функционал для гамбургера
        showMenuBtn.addTarget(self.revealViewController, action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer()) 
        
        TaxiHandler.Instance.observeMessagesForRider()
        TaxiHandler.Instance.delegate = self
        gMap.isMyLocationEnabled = true
        customizeNavBar()
    }
    
    func customizeNavBar() {
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        callTaxiBtn.layer.cornerRadius = 10
    }
    
    private func initialazeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //если у нас есть координаты из менеджера
        if let location = locationManager.location?.coordinate {
            
            let locationCLLoc = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            //центрицует на вид на пользователя, если он двинулся за раз больше чем на 30 единиц
            if userLocation != nil {
                let userCLLoc = CLLocation(latitude: userLocation!.latitude, longitude: userLocation!.longitude)
                if locationCLLoc.distance(from: userCLLoc) > 25 {
                    gMap.animate(toLocation: location)
                }
            }
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            gMap.clear()
            
            if driverLocation != nil {
                if !canCallTaxi {
                    print("где маркер? \(Double(driverLocation!.latitude)) \(Double(driverLocation!.longitude))")
                    let driverMarker = GMSMarker()
                    driverMarker.position = driverLocation!
                    driverMarker.title = "Местоположение водителя"
                    driverMarker.snippet = TaxiHandler.Instance.driver
                    driverMarker.map = gMap
                }
            }
            
            if firstLocation {
                gMap.camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 17.0)
                firstLocation = false
            }
            
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(CLLocationCoordinate2DMake(gMap.camera.target.latitude, gMap.camera.target.longitude)) { response, error in
                if let address = response?.firstResult() {
                    let lines = address.lines
                    let cursorsAddress = lines![0]
                    self.currentPlace.text = cursorsAddress
                }
            }
        }
        
        //----------------------
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 16.0)
        
        self.gMap.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
        //----------------------
        
    }
    
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String) {
        print("Ну че? \(riderCanceledRequest)")
        if !riderCanceledRequest {
            if requestAccepted {
                TaxiHandler.Instance.acceptTaxi()
                alertTheUser(title: "Ваш заказ принят", message: "\(driverName) ответил на ваш заказ")
            } else {
                TaxiHandler.Instance.cancelTaxi()
                alertTheUser(title: "Заказ отменен", message: "\(driverName) отклонил ваш заказ")
                locationCursor.isHidden = false
            }
        }
        riderCanceledRequest = false
    }
    
    func updateDriversLocation(lat: Double, long: Double) {
        driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    func canCallTaxi(delegateCalled: Bool) {
        if delegateCalled {
            callTaxiBtn.setTitle("ОТМЕНИТЬ ЗАКАЗ", for: UIControlState.normal)
            canCallTaxi = false
        } else {
            callTaxiBtn.setTitle("ЗАКАЗАТЬ ТАКСИ", for: UIControlState.normal)
            canCallTaxi = true
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        if AuthProvider.Instance.logOut() {
             dismiss(animated: true, completion: nil)
        }
        else {
            alertTheUser(title: "Ошибка выхода", message: "В данный момент не получается выйти, попробуйте позже")
        }
    }
    
    private func alertTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    /*@IBAction func callTaxi(_ sender: Any) {
        if userLocation != nil {
            if canCallTaxi {
                TaxiHandler.Instance.requestTaxi(latitude: Double(gMap.camera.target.latitude), longitude: Double(gMap.camera.target.longitude))
                locationCursor.isHidden = true
                canCallTaxi(delegateCalled: false)
            } else {
                //riderCanceledRequest = true
                TaxiHandler.Instance.cancelTaxi()
                canCallTaxi(delegateCalled: true)
            }
        }
    }*/
    
    @IBAction func showMyLocation(_ sender: Any) {
        if let location = locationManager.location?.coordinate {
            gMap.animate(toLocation: location)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmationSegue" {
            if let confirmationVC = segue.destination as? ConfirmationVC {
                confirmationVC.startLocation = gMap.camera.target
                confirmationVC.price = "1234руб"
                confirmationVC.carModel = "Мерин"
                confirmationVC.carImage = UIImage(named: "carIcon1")!
            }
        }
    }
    
    //**************************************** Отработка кнопки поиска *************************************
    // MARK: CLLocation Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get location \(error)")
    }

    
    // MARK: GMSMapview Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.gMap.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        self.gMap.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    
    // MARK: GOOGLE AUTO COMPLETE DELEGATE
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
        self.gMap.camera = camera
        self.dismiss(animated: true, completion: nil) // dismiss after select place
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print("ERROR AUTO COMPLETE \(error)")
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }
    
    
    
    @IBAction func openSearchAddress(_ sender: UIButton) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    
}



