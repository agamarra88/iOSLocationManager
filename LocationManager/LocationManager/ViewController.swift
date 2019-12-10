//
//  ViewController.swift
//  LocationManager
//
//  Created by Arturo Gamarra on 12/9/19.
//  Copyright © 2019 Abstract. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    let identifier = "Cell"
    
    @IBOutlet weak var tableView:UITableView!
    var locations:[LocationDate] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ABSLocationManager.shared.delegate = self
        ABSLocationManager.shared.alwaysRequestLocation = true
        ABSLocationManager.shared.startUpdatingLocation()
    }

    @IBAction func clearButtonTapped(_ sender: Any) {
        locations.removeAll()
        tableView.reloadData()
    }
}

extension ViewController: ABSLocationManagerDelegate {
    
    func locationManager(_ sender: ABSLocationManager, unavailableWithStatus status: CLAuthorizationStatus) {
        // If general location settings are disabled then open general location settings
        let urlString = ABSLocationManager.shared.isLocationServicesEnabled ?  UIApplication.openSettingsURLString : "App-Prefs:root=Privacy&path=LOCATION"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    func locationManager(_ sender: ABSLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ sender: ABSLocationManager, updatedLocation location: CLLocation) {
        let locationDate = LocationDate(location: location, date: Date())
        locations.insert(locationDate, at: 0)
        tableView.reloadData()
    }

}

extension ViewController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let item = locations[indexPath.item]
        cell.textLabel?.text = "Lat: \(item.location.coordinate.latitude)     Long:\(item.location.coordinate.longitude)"
        cell.detailTextLabel?.text = item.date.description
        return cell
    }
    
}
