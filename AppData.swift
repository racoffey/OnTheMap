//
//  AppData.swift
//  OnTheMap
//
//  Created by Robert Coffey on 15/05/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation

// Class for data that shall be available across the app
class AppData {
    
    // Properties
    var studentLocations: [StudentLocation] = []
    var hasFetchedStudentLocations = false
    

    class func sharedInstance() -> AppData {
        struct Singleton {
            static var sharedInstance = AppData()
        }
        return Singleton.sharedInstance
    }
}