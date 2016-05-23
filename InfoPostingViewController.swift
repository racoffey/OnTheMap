//
//  InfoPostingViewController.swift
//  OnTheMap
//
//  Created by Robert Coffey on 26/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
// 

import UIKit
import MapKit

class InfoPostingViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate  {
    
    //Set map view size for map display
    let regionRadius: CLLocationDistance = 10000
    
    //Initialize variables
    var locationString: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    
    //Outlets
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var firstStackView: UIStackView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var secondStackView: UIStackView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var URLTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up textfield delegates
        locationTextField.delegate = self
        URLTextField.delegate = self
        mapView.delegate = self

        // Set up initial view
        setFirstView()

    }
    
    // Show activity indicator until map has finnished loading
     func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool){
        activityIndicator.hidden = true
    }
    
    
    // Prepare initial view
    func setFirstView() {
        firstStackView.hidden = false
        secondStackView.hidden = true
        locationTextField.text = "Enter Location"
        URLTextField.text = "Enter URL"
        submitButton.hidden = true
        locationButton.hidden = false
        activityIndicator.hidden = true
    }
    
    // Prepare second view which appears after location entered
    func setSecondView() {
        firstStackView.hidden = true
        secondStackView.hidden = false
        activityIndicator.hidden = false
        submitButton.hidden = false
        locationButton.hidden = true
    }
    
    // Centre map display on initial coordinates
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        self.activityIndicator.hidden = true
    }
    
    //Present message to user
    func displayError(error: String) {
        
        // Show error to user using Alert Controller
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Clear text when editing textfields for the first time
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "Enter Location" {
            textField.text = ""
        }
        if textField.text == "Enter URL" {
            textField.text = "http://"
        }
        return
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    // Stop editing and hide keyboard when user taps the view
    @IBAction func userDidTapView(sender: AnyObject) {
        resignIfFirstResponder(locationTextField)
        resignIfFirstResponder(URLTextField)
    }
    

    // Send student location information to Udacity server
    @IBAction func submitButtonPressed(sender: AnyObject) {
        
        var studentParameters = [String: AnyObject]()
        
        // Check for basic URL format
        if let url = NSURL(string: URLTextField.text!) {
            if URLTextField.text == "http://" {
                self.displayError("Please enter a correct URL")
                return
            }
        }else {
            self.displayError("Please enter a correct URL")
            return
        }
        
        // Get name details regarding logged in user
        UdacityClient.sharedInstance().getUserInfo(UdacityClient.sharedInstance().userID!) { (success, let userInfo, errorString) in
            
            if success {
                studentParameters = userInfo
                
                //Populate dictionary with needed user details
                studentParameters[Constants.ParseRequestKeys.UniqueKey] = UdacityClient.sharedInstance().userID
                studentParameters[Constants.ParseRequestKeys.MapString] = self.locationString
                studentParameters[Constants.ParseRequestKeys.MediaURL] = self.URLTextField.text
                studentParameters[Constants.ParseRequestKeys.Latitude] = self.latitude
                studentParameters[Constants.ParseRequestKeys.Longitude] = self.longitude

                //Post student location
                ParseClient.sharedInstance().postStudentLocation(studentParameters, completionHandlerForPostSL: { (success, errorString) -> Void in
                    if success {
                        self.dismissViewControllerAnimated(true) { () -> Void in
                        }
                    }
                    else {
                        self.displayError("Failed to post student location: \(errorString)")
                        print("Failed to post student location: \(errorString)")
                        return 
                    }
                })
            }
            else {
                self.displayError("Problem getting user name: \(errorString!)")
                return
            }
        }
    }
    

    //Find location entered by user and display in a second stack view
    @IBAction func findLocationButtonPressed(sender: AnyObject) {
        
        let geocoder = CLGeocoder()
        locationString = locationTextField.text!
        
        // Check for basic input errors
        if locationString == "Enter Location" || locationString.characters.count < 2 {
            self.displayError("No location has been entered!")
            return
        }
        
        // Show activity indicator
        self.activityIndicator.hidden = false
        
        // Attempt to find geographic location based on text string
        geocoder.geocodeAddressString(locationString, completionHandler: {(placemarks, error) -> Void in
            
            // Report any error to user
            if((error) != nil){
                self.displayError("Could not identify location!")
                return 
            }
            
            // If successful centre map view on the location and present 2nd stack view
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                let location: CLLocation = CLLocation(latitude: coordinates.latitude , longitude: coordinates.longitude)
                self.centerMapOnLocation(location)
                self.setSecondView()
                self.latitude = coordinates.latitude
                self.longitude = coordinates.longitude
            }
        })
    }
    
    //Dismiss Info Posting View Controller if cancel button pressed
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true) { () -> Void in
        }
    }
}
