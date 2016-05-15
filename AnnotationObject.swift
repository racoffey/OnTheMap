//
//  AnnotationObject.swift
//  OnTheMap
//
//  Created by Robert Coffey on 15/05/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import MapKit

// Class to meet MKAnnotation protocol requirements for map annotation
class AnnotationObject: NSObject, MKAnnotation {
    
    //Parameters
    var coordinate: CLLocationCoordinate2D
    var firstName: String
    var lastName: String
    var mediaURL: String
    
    init(studentLocation: StudentLocation) {
        self.coordinate = studentLocation.coordinate
        self.firstName = studentLocation.firstName!
        self.lastName = studentLocation.lastName!
        self.mediaURL = studentLocation.mediaURL!
        
        super.init()
    }
    
    // Name and URL variables can be called according to the MKAnnotation protocol
    var title: String? {
        return firstName + " " + lastName
    }
    
    var subtitle: String? {
        return mediaURL
    }
}
