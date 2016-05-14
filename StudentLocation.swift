//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Robert Coffey on 22/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import MapKit

// Student location class
class StudentLocation: NSObject, MKAnnotation {
 
    // Parameters
    
    let createdAt: String
    let firstName: String?
    let lastName: String?
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let mapString: String?
    let mediaURL: String?
    let objectId: String
    let uniqueKey: String
    let updatedAt: String
    var coordinate: CLLocationCoordinate2D
    
    // Init method to create class and populate variables
    init(createdAt: String,
        firstName: String?,
        lastName: String?,
        latitude: Double,
        longitude: Double,
        mapString: String?,
        mediaURL: String?,
        objectId: String,
        uniqueKey: String,
        updatedAt: String) {

        self.createdAt = createdAt
        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude as CLLocationDegrees
        self.longitude = longitude as CLLocationDegrees
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.updatedAt = updatedAt
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        
        super.init()
    }
    
    // Name and URL variables can be called
    var title: String? {
        return firstName! + " " + lastName!
    }
    
    var subtitle: String? {
        return mediaURL!
    }
}