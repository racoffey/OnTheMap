//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Robert Coffey on 09/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
    
    var studentLocations = [StudentLocation]()

    @IBOutlet weak var locationsTableView: UITableView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        loadStudentLocations()
    }
    
    func loadStudentLocations() {
        let parameters: [String: AnyObject] = [Constants.ParseParameterKeys.Limit : Constants.ParseParameterValues.Limit]
        ParseClient.sharedInstance().getStudentLocations(parameters) { (success, studentLocations, errorString) in
            print ("Success from Table View!")
            print ("StudentLocations = \(studentLocations)")
            self.studentLocations = studentLocations
            performUIUpdatesOnMain {
                if success {
                    self.locationsTableView.reloadData()
                    print("Table reloaded")
                } else {
                    //self.displayError(errorString!)
                    print("Error = " + errorString!)
                }
            }
        }
    }
    
    func refreshTableView() {
        ParseClient.sharedInstance().hasFetchedStudentLocations = false
        loadStudentLocations()
    }
    
}


extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("Arrived in table view")
        let CellReuseId = "StudentLocationCell"
        let image = UIImage(named: "map pin")
        let studentLocation = studentLocations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseId) as UITableViewCell!
        cell.textLabel!.text = studentLocation.title!
        print("Student Location title =  \(studentLocation.title!)")
        cell.imageView?.image = image
        cell.detailTextLabel?.text = studentLocation.subtitle!
        //cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit

        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of student locations = \(studentLocations.count)")
        return studentLocations.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentLocation = studentLocations[indexPath.row]
        if studentLocation.mediaURL != nil {
            UIApplication.sharedApplication().openURL(NSURL(string: studentLocation.mediaURL!)!)
        }
    }
}
