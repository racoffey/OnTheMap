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
            print("Refresh button pressed")
            print("Presented view controller = \(self.selectedViewController)")
            self.selectedViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
            //self.storyboard?.instantiateInitialViewController()
        
        
            //self.presentedViewController?.dismissViewControllerAnimated(true, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
        
        
        /*print("Selected VC = \(selectedViewController)")
        if ((selectedViewController? = "OnTheMap.MapViewContr
        oller") != nil) {
            print("Map View selected")
        }*/

    }
    

}