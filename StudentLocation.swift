//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Robert Coffey on 22/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import MapKit

// Student location struct
struct StudentLocation {

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
    
    //Init method takes dictionary and reads out parameter settings
    init(parameters: [String : AnyObject]) {

        self.createdAt = parameters[Constants.ParseResponseKeys.CreatedAt] as! String
        self.firstName = parameters[Constants.ParseResponseKeys.FirstName] as! String
        self.lastName = parameters[Constants.ParseResponseKeys.LastName] as! String
        self.latitude = parameters[Constants.ParseResponseKeys.Latitude] as! CLLocationDegrees
        self.longitude = parameters[Constants.ParseResponseKeys.Longitude] as! CLLocationDegrees
        self.mapString = parameters[Constants.ParseResponseKeys.MapString] as! String
        self.mediaURL = parameters[Constants.ParseResponseKeys.MediaURL] as! String
        self.objectId = parameters[Constants.ParseResponseKeys.ObjectId] as! String
        self.uniqueKey = parameters[Constants.ParseResponseKeys.UniqueKey] as! String
        self.updatedAt = parameters[Constants.ParseResponseKeys.UpdatedAt] as! String
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)

    }
}

