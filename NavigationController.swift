//
//  NavigationController.swift
//  OnTheMap
//
//  Created by Robert Coffey on 01/05/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {
    
    //var studentLocations: [StudentLocation] = []
 //   var userID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
 //       print("Controller UserID = " + userID)
 //       let topController: OTMTabBarController = self.topViewController as! OTMTabBarController
 //       topController.userID = userID

    }
    
    
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        print("Refresh button pressed")
        /*print("Selected VC = \(selectedViewController)")
        if ((selectedViewController? = "OnTheMap.MapViewContr
        oller") != nil) {
        print("Map View selected")
        }*/
    }
}

