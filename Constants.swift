//
//  Constants.swift
//  OnTheMap
//
//  Created by Robert Coffey on 09/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation

import UIKit
import MapKit

// Constants

struct Constants {
    
    // Udacity URL API parameters
    struct Udacity {
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
    }
    
    // Udacity Parameter Keys
    struct UdacityParameterKeys {
        static let SessionID = "session_id"
        static let Username = "username"
        static let Password = "password"
    }
    
    
    // Udacity Response Keys
    struct UdacityResponseKeys {
        static let StatusCode = "status"
        static let ErrorMessage = "error"
        static let SessionID = "id"
        static let Session = "session"
        static let Success = "success"
        static let UserID = "key"
        static let Account = "account"
        static let Results = "results"
        static let User = "user"
        static let LastName = "last_name"
        static let FirstName = "first_name"
    }
    
    
    // Parse URL API parameters
    struct Parse {
        static let ApiScheme = "https"
        static let ApiHost = "api.parse.com"
        static let ApiPath = "/1/classes"
    }
    
    // Parse Parameter Keys
    struct ParseParameterKeys {
        static let ApplicationID = "X-Parse-Application-Id"
        static let ApiKey = "X-Parse-REST-API-Key"
        static let Limit = "limit"
        static let Order = "order"
    }
    
    // Parse Parameter Values
    struct ParseParameterValues {
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let Limit = "100"
        static let Order = "-updatedAt"
    }
    
    
    // Parse Response Keys
    struct ParseResponseKeys {
        static let StatusCode = "status"
        static let ErrorMessage = "error"
        static let Results = "results"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let ObjectId = "objectId"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
    }
    
    // Parse request keys
    struct ParseRequestKeys {
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Results = "results"
    }
    
    
    // UI attriutes
    struct UI {
    static let LoginColorTop = UIColor(red: 0.900, green: 0.300, blue: 0.100, alpha: 1.0).CGColor
    static let LoginColorBottom = UIColor(red: 0.8, green: 0.5, blue: 0.3, alpha: 1.0).CGColor
    static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
    static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    }
    
    // Selectors
    struct Selectors {
        static let KeyboardWillShow: Selector = "keyboardWillShow:"
        static let KeyboardWillHide: Selector = "keyboardWillHide:"
        static let KeyboardDidShow: Selector = "keyboardDidShow:"
        static let KeyboardDidHide: Selector = "keyboardDidHide:"
    }
    
    // Map attributes
    struct Map {
        static let RegionRadius: CLLocationDistance  = 1000000
    }
    
}