//
//  InfoPostingViewController.swift
//  OnTheMap
//
//  Created by Robert Coffey on 26/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import UIKit
import MapKit

class InfoPostingViewController: UIViewController, UITextFieldDelegate  {
    
    let regionRadius: CLLocationDistance = 10000
    
    var studentLocations = [StudentLocation]()
    var userID: String = ""
    var locationString: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    
    //var studentLocation: StudentLocation
    

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var firstStackView: UIStackView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var secondStackView: UIStackView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var URLTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        //locationTextField.delegate = self
        //mapView.delegate = self
        
        locationTextField.delegate = self
        URLTextField.delegate = self
        print("Info Posting User ID = \(userID)")

        setFirstView()
        //view.backgroundColor = UIColor.darkGrayColor()

    }
    
    func setFirstView() {
        firstStackView.hidden = false
        secondStackView.hidden = true
        locationTextField.text = "Enter Location"
        URLTextField.text = "Enter URL"
    }
    
    func setSecondView() {
        firstStackView.hidden = true
        secondStackView.hidden = false
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //Only clear text when editing for the first time
        print("Text field started editing")
        print("Text field text = " + textField.text!)
        if textField.text == "Enter Location" {
            textField.text = ""
        }
        if textField.text == "Enter URL" {
            textField.text = "http://"
        }
        print("Returning from text field did begin editing")
        return
    }
    
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        
        UdacityClient.sharedInstance().getUserInfo(userID) { (success, var userInfo, errorString) in
            print("User info is = \(userInfo)")
            userInfo[Constants.ParseRequestKeys.UniqueKey] = self.userID
            userInfo[Constants.ParseRequestKeys.MapString] = self.locationString
            userInfo[Constants.ParseRequestKeys.MediaURL] = self.URLTextField.text
            userInfo[Constants.ParseRequestKeys.Latitude] = self.latitude
            userInfo[Constants.ParseRequestKeys.Longitude] = self.longitude

            
        ParseClient.sharedInstance().postStudentLocation(userInfo, completionHandlerForPostSL: { (success, errorString) -> Void in
            if success {
                print("Student Location updated successfully!")
            }
            else {
                print(errorString)
            }
        })
            
        }
    }


    @IBAction func findLocationButtonPressed(sender: AnyObject) {

        let geocoder = CLGeocoder()
        
        locationString = locationTextField.text!
        
        geocoder.geocodeAddressString(locationString, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                print("Location = \(coordinates).self")
                let location: CLLocation = CLLocation(latitude: coordinates.latitude , longitude: coordinates.longitude)
                self.centerMapOnLocation(location)
                self.setSecondView()
                self.latitude = coordinates.latitude
                self.longitude = coordinates.longitude
                
            }
        })

        
    }
    
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true) { () -> Void in
        }
    }
}