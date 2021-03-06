//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Robert Coffey on 09/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
// 

import UIKit

class TableViewController: UIViewController {
    
    
    //Outlets
    @IBOutlet weak var locationsTableView: UITableView!
    @IBOutlet weak var tabBarButton: UITabBarItem!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set list image for tab bar button
        tabBarButton.image = UIImage(named: "list")! as UIImage
    }
    
    
    override func viewWillAppear(animated: Bool) {
        //Load student locations and present them
        if AppData.sharedInstance().studentLocations.count == 0 {
            loadStudentLocations()
        }
    }
    
    //Load student locations if they have not been loaded earlier or when refresh is requested
    func loadStudentLocations() {
        
        //Get student locations
        ParseClient.sharedInstance().getStudentLocations() { (success, studentLocations, errorString) in
            //self.studentLocations = studentLocations

            if success {
                self.locationsTableView.reloadData()
            } else {
                self.displayError(errorString!)
            }
        }
    }
    
    //Reload student locations and present them again
    func refreshTableView() {
        AppData.sharedInstance().hasFetchedStudentLocations = false
        loadStudentLocations()
    }
    
    //Present messages to user
    func displayError(error: String) {
        
        // Show error to user using Alert Controller
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}


extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    
    //Populate table with Student Locations
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellReuseId = "StudentLocationCell"
        let image = UIImage(named: "map pin")
        let studentLocation = AppData.sharedInstance().studentLocations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseId) as UITableViewCell!
        
        //Present student name and URL in call out box
        cell.textLabel!.text = studentLocation.firstName! + " " + studentLocation.lastName!
        cell.imageView?.image = image
        cell.detailTextLabel?.text = studentLocation.mediaURL
        
        return cell
    }
    
    //Provide number of rows in table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppData.sharedInstance().studentLocations.count
    }
    
    //Take action if user has selected a row
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentLocation = AppData.sharedInstance().studentLocations[indexPath.row]
        
        //Check URL is properly formatted and if so attempt to open it
        if let url = NSURL(string: studentLocation.mediaURL!) {
            UIApplication.sharedApplication().openURL(NSURL(string: studentLocation.mediaURL!)!)
        }
        else {
            displayError("Could not present web page")
        }
    }
}
