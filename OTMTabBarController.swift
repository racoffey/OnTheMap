//
//  OTMTabBarController.swift
//  OnTheMap
//
//  Created by Robert Coffey on 16/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import UIKit



class OTMTabBarController: UITabBarController {
    
    var studentLocations: [StudentLocation] = []
    var userID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(" Tab bar userID = \(userID)")
    }
    

    @IBAction func locationButtonPressed(sender: AnyObject) {
        //prepareForSegue(<#T##segue: UIStoryboardSegue##UIStoryboardSegue#>, sender: <#T##AnyObject?#>)
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("InfoPostingViewController") as! InfoPostingViewController
        viewController.userID = userID
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    

    @IBAction func refreshButtonPressed(sender: AnyObject) {

        if self.selectedViewController!.isKindOfClass(MapViewController) {
            let controller = self.selectedViewController as! MapViewController
            controller.refreshMapView()
        } else if self.selectedViewController!.isKindOfClass(TableViewController){
            let controller = self.selectedViewController as! TableViewController
            controller.refreshTableView()
        } else {
            print("trying to refresh an unknown view")
        }
    }
}


