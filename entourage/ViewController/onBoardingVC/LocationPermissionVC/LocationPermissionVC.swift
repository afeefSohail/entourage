//
//  ViewController.swift
//  entourage
//
//  Created by Furqan Ahmad on 23/05/2019.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftLocation


class LocationPermissionVC: BaseVC {
    
    //MARK: - IBOutLets
    @IBOutlet weak var labelone: UILabel!
    @IBOutlet weak var labelTwo: UILabel!
    @IBOutlet weak var settingsBtn: UIButton!
    
    //MARK:- Class Properties
    let locationManager = CLLocationManager()
    var callback : getLocation!
    
    //MARK:- Constructor
    class func loadLocationPermissionVC(callback: @escaping getLocation) -> LocationPermissionVC{
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let location = storyboard.instantiateViewController(withIdentifier: "LocationPermissionVC") as! LocationPermissionVC
        
        location.callback = callback
        return location
    }
    
    
    override func setupGUI() {
        super.setupGUI()
        
        self.setUpNavigationBar()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!]
        
        //NavBar shadow
        self.addNavBarShadow()
        
        //NavBar Title
        self.title = "Location Permission"
        
        labelTwo.isHidden = true
        settingsBtn.isHidden = true
        
        checkLocationServices()
        
    }
    
    fileprivate func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    fileprivate func updateUserLocation(){
        self.startAnimation()
        WebServicesManager.shared.updateLocationBy { (reponse, error) in
            self.stopAnimation()
            
            if error == nil{
                self.dismiss(animated: true, completion: {
                    self.callback()
                })
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
    fileprivate func getCurrentLocation() {
        
        LocationManager.shared.locateFromIP(service: .ipApiCo) { result in
            switch result {
            case .failure(let error):
                debugPrint("An error has occurred while getting info about location: \(error)")
                
                self.showAlert(title: "Error", message: "An error has occurred while getting info about location: \(error)" )
            case .success(let place):
                
                EntourageManager.shared.user.latitude = String( place.coordinates!.latitude )
                EntourageManager.shared.user.longitude = String( place.coordinates!.longitude )
                
                self.updateUserLocation()
            }
        }
    }
    
    fileprivate  func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    
    fileprivate func checkLocationAuthorization() {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
            labelone.text = "Location is turned off"
            labelTwo.isHidden = false
            settingsBtn.isHidden = false
            
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            
            break
        case .authorizedAlways:
            
            break
        @unknown default:
            fatalError()
        }
    }
    
    @IBAction func pressSettingsBtn(_ sender: Any) {
        openBrowserWith(url: UIApplication.openSettingsURLString)
    }
    
}


// MARK: - CLLocationManagerDelegate
extension LocationPermissionVC : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        
        EntourageManager.shared.user.latitude = String( location.coordinate.latitude.description  )
        EntourageManager.shared.user.longitude = String( location.coordinate.longitude.description )
        
        self.updateUserLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
