//
//  ConfirmationVC.swift
//  Taxi for rider
//
//  Created by Chingis on 02.07.17.
//  Copyright © 2017 Chingis. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

class ConfirmationVC: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate, UISearchBarDelegate {
    
    private var locationManager = CLLocationManager()

    @IBOutlet weak var confirmationBtn: UIButton!
    @IBOutlet weak var gMap: GMSMapView!
    @IBOutlet weak var carCategoryImageView: UIImageView!
    @IBOutlet weak var carCategoryCarModelLabel: UILabel!
    @IBOutlet weak var carCategoryPriceLabel: UILabel!
    
    @IBOutlet weak var startLocationBtn: UIButton!
    @IBOutlet weak var endLocationBtn: UIButton!
    @IBOutlet weak var timeBtn: UIButton!
    
    @IBOutlet weak var cursor: UIImageView!
    
    
    var startLocation: CLLocationCoordinate2D!
    var endLocation: CLLocationCoordinate2D!
    
    var carModel: String?
    var price: String?
    var carImage: UIImage?
    
    var isWaitingStartPoint: Bool = false
    var isWaitingEndPoint: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmationBtn.layer.cornerRadius = 10
        confirmationBtn.titleLabel?.textAlignment = NSTextAlignment.left
        print("\(startLocation)")
        gMap.camera = GMSCameraPosition.camera(withLatitude: startLocation.latitude, longitude: startLocation.longitude, zoom: 17.0)
        setViewStyles()
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(CLLocationCoordinate2DMake(startLocation.latitude, startLocation.longitude)) { response, error in
            if let address = response?.firstResult() {
                let lines = address.lines
                let cursorsAddress = lines![0]
                self.startLocationBtn.setTitle(cursorsAddress, for: UIControlState.normal)
            }
        }
        
        carCategoryPriceLabel.text = price
        carCategoryCarModelLabel.text = carModel
        carCategoryImageView.image = carImage
    
    }
    
    func setViewStyles() {
        self.startLocationBtn.contentHorizontalAlignment = .left
        self.endLocationBtn.contentHorizontalAlignment = .left
        self.timeBtn.contentHorizontalAlignment = .left
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print(startLocation)
        
        initialazeLocationManager()
    }
    
    
    private func initialazeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        self.gMap.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
    }
    
    
    
    //********************************************* поиск мест ******************************************
    
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
        
        var camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
        self.gMap.camera = camera
        self.dismiss(animated: true, completion: nil) // dismiss after select place
        
        if isWaitingEndPoint {
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)) { response, error in
                if let address = response?.firstResult() {
                    let lines = address.lines
                    let cursorsAddress = lines![0]
                    self.endLocationBtn.setTitle(cursorsAddress, for: UIControlState.normal)
                }
            }
            endLocation = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            isWaitingEndPoint = false
        }
        
        if isWaitingStartPoint {
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)) { response, error in
                if let address = response?.firstResult() {
                    let lines = address.lines
                    let cursorsAddress = lines![0]
                    self.startLocationBtn.setTitle(cursorsAddress, for: UIControlState.normal)
                }
            }
            startLocation = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            isWaitingStartPoint = false
        }
        
        if startLocation != nil && endLocation != nil {
            print("Рисуем маршрут")
            
            gMap.clear()
            
            let startMarker = GMSMarker(position: startLocation)
            startMarker.map = gMap
            
            let endMarker = GMSMarker(position: endLocation)
            endMarker.map = gMap
            
            drawPath(startLocation: CLLocation(latitude: startLocation.latitude, longitude: startLocation.longitude), endLocation: CLLocation(latitude: endLocation.latitude, longitude: endLocation.longitude))
            
            
            self.cursor.isHidden = true
        }
    }
    
    func averagePoint(firstPoint: CLLocationCoordinate2D, secondPoint: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: firstPoint.latitude + ((secondPoint.latitude - firstPoint.latitude) / 2), longitude: firstPoint.longitude + ((secondPoint.longitude - firstPoint.longitude) / 2))
    }
    
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            // print route using Polyline
            
            var bounds = GMSCoordinateBounds()
            
            var totalPath: GMSPath!
            
            bounds = bounds.includingCoordinate(self.startLocation)
            bounds = bounds.includingCoordinate(self.endLocation)
            
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.red
                polyline.map = self.gMap
                
            }
            
            self.gMap.animate(with: GMSCameraUpdate.fit(bounds))
            
            
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print("ERROR AUTO COMPLETE \(error)")
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }
    
    
    
    @IBAction func openStartPointSearchAddress(_ sender: UIButton) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        isWaitingStartPoint = true
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    @IBAction func openEndPointSearchAddress(_ sender: UIButton) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        isWaitingEndPoint = true
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    @IBAction func callTaxi(_ sender: Any) {
        if startLocation != nil {
            print("Делаем заказ")
            TaxiHandler.Instance.requestTaxi(latitude: Double(startLocation.latitude), longitude: Double(startLocation.longitude))
        }
    }
    
    
    
}
