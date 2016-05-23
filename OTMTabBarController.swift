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
    
    // Outlets
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var mapPinButton: UIBarButtonItem!
 
    override func viewDidLoad() {
        mapPinButton.image = UIImage(named: "map pin")! as UIImage
        super.viewDidLoad()
    }

    // Logout of Facebook and cancel token
    func removeFbData() {
        //Remove FB Data
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }
    
    
    // If location button pressed instantiate a Info Posting View Controller and present VC
    @IBAction func locationButtonPressed(sender: AnyObject) {
        //prepareForSegue(<#T##segue: UIStoryboardSegue##UIStoryboardSegue#>, sender: <#T##AnyObject?#>)
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("InfoPostingViewController") as! InfoPostingViewController
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    //If refresh button pressed, establish which VC is currently selected and call the respective refresh function
    @IBAction func refreshButtonPressed(sender: AnyObject) {

        if self.selectedViewController!.isKindOfClass(MapViewController) {
            let controller = self.selectedViewController as! MapViewController
            controller.refreshMapView()
        }
        if self.selectedViewController!.isKindOfClass(TableViewController){
            let controller = self.selectedViewController as! TableViewController
            controller.refreshTableView()
        }
    }
    
    func displayError(errorString: String){
        if self.selectedViewController!.isKindOfClass(MapViewController) {
            let controller = self.selectedViewController as! MapViewController
            controller.displayError(errorString)
        }
        if self.selectedViewController!.isKindOfClass(TableViewController){
            let controller = self.selectedViewController as! TableViewController
            controller.displayError(errorString)
        }
    }
    
    
    // If logout button pressed, call logout function in Udacity client and dismiss view contoller, returning to login screen.
    // If there is an error present this on the current view controller window.
    @IBAction func logOutButtonPressed(sender: AnyObject) {
        
        UdacityClient.sharedInstance().logOutOfSession { (success, errorString) -> Void in
            if success {
                
                // If Facebook is being used for login then logout of Facebook and cancel access token
                if FBSDKAccessToken.currentAccessToken() != nil {
                    self.removeFbData()
                }
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                })
            } else {
                self.displayError(errorString!)
            }
        }
    }
    
    
}


