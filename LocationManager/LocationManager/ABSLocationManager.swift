//
//  ABSLocationManager.swift
//  LocationManager
//
//  Created by Arturo Gamarra on 12/7/16.
//  Copyright © 2016 Abstract. All rights reserved.
//

import UIKit
import CoreLocation

protocol ABSLocationManagerDelegate: class {
    
    func locationManager(_ sender:ABSLocationManager, unavailableWithStatus status:CLAuthorizationStatus)
    func locationManager(_ sender:ABSLocationManager, didFailWithError error:Error)
    func locationManager(_ sender:ABSLocationManager, updatedLocation location:CLLocation)
    
}

class ABSLocationManager: NSObject {
    
    // MARK: - Constants
    static let updateLocationNotification = NSNotification.Name("LocationManagerUpdateLocationNotification")
    
    // MARK: - Singleton
    static let shared = ABSLocationManager()
    
    // MARK: - Configuration Properties
    var distanceAccurancy: CLLocationAccuracy = kCLLocationAccuracyBest {
        didSet {
            self.locationManager.desiredAccuracy = distanceAccurancy
        }
    }
    var distanceFilter: CLLocationDistance = kCLDistanceFilterNone {
        didSet {
            self.locationManager.distanceFilter = distanceFilter
        }
    }
    var alwaysRequestLocation:Bool = false {
        didSet {
            if oldValue != alwaysRequestLocation && isRequestingLocation {
                stopUpdatingLocation()
                startUpdatingLocation()
            }
        }
    }
    
    // MARK: - Calculated Properties
    var isLocationServicesEnabled:Bool  {
        return CLLocationManager.locationServicesEnabled()
    }
    
    // MARK: - Properties
    fileprivate var isRequestingLocation:Bool = false
    fileprivate var locationManager:CLLocationManager
    
    weak var delegate:ABSLocationManagerDelegate?
    var currentLocation:CLLocation?
    
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        
        locationManager.desiredAccuracy = distanceAccurancy
        locationManager.distanceFilter = distanceFilter
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.delegate = self
    }
    
    // MARK: - Public
    @discardableResult func startUpdatingLocation() -> Bool {
        if !CLLocationManager.locationServicesEnabled() {
            delegate?.locationManager(self, unavailableWithStatus: .restricted)
            return false
        }
        
        let status = CLLocationManager.authorizationStatus()
        if (status == .denied || status == .restricted) {
            delegate?.locationManager(self, unavailableWithStatus: status)
            return false
        }
        
        if !alwaysRequestLocation {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.showsBackgroundLocationIndicator = true
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        return true
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.showsBackgroundLocationIndicator = false
    }
    
}

// MARK: - CLLocationManagerDelegate
extension ABSLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location service failed with error \(error)")
        delegate?.locationManager(self, didFailWithError: error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        self.currentLocation = location
        self.delegate?.locationManager(self, updatedLocation: location)
        NotificationCenter.default.post(name: ABSLocationManager.updateLocationNotification, object: location)
        print("Latitude \(location.coordinate.latitude), Longitude \(location.coordinate.longitude)\n")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            startUpdatingLocation()
        } else {
            stopUpdatingLocation()
            delegate?.locationManager(self, unavailableWithStatus: status)
        }
    }
    
}
