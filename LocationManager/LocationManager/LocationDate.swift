//
//  LocationDate.swift
//  LocationManager
//
//  Created by Arturo Gamarra on 12/9/19.
//  Copyright © 2019 Abstract. All rights reserved.
//

import CoreLocation

struct LocationDate {
    
    var location:CLLocation = CLLocation()
    var date:Date = Date()
    
    init() {
        
    }
    
    init(location:CLLocation, date:Date) {
        self.location = location
        self.date = date
    }
    
}
