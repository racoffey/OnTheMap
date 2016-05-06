//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Robert Coffey on 16/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import MapKit

class StudentLocations: NSObject, MKAnnotation {
 
   /*
    let createdAt = "2016-04-16T19:51:12.304Z";
    let firstName = jonathan;
    let lastName = eustace;
    let latitude = "49.2635385";
    let longitude = "-123.1385709";
    let mapString = Vancouver;
    let mediaURL = "Http://Google.com";
    let objectId = 16Q1Imnw2d;
    let uniqueKey = 12344;
    let updatedAt = "2016-04-16T19:51:12.304Z";
*/
    
    
    var title: String?
    let locationName: String
    let discipline: String
    var coordinate: CLLocationCoordinate2D
    
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}
