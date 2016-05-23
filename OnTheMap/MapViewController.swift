//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Robert Coffey on 09/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
// 

import UIKit
import MapKit


class MapViewController: UIViewController{

    // Set the size of then intial map view
    let regionRadius: CLLocationDistance = Constants.Map.RegionRadius
    
    
    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tabBarButton: UITabBarItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        //Establish map view delegate and intial settings
        mapView.delegate = self
        activityIndicator.hidden = false
        
        //Set image for tab bar button
        tabBarButton.image = UIImage(named: "map")! as UIImage
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        // Load the locations of a number of students and present them on the map
        loadStudentLocations()
    }
    

    //Set map view region
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    //Add annotations for each student location
    func showAnnotation() {
        let initialLocation = CLLocation(latitude: AppData.sharedInstance().studentLocations[0].latitude, longitude: AppData.sharedInstance().studentLocations[0].longitude)
        centerMapOnLocation(initialLocation)
        for studentLocation in AppData.sharedInstance().studentLocations {
            let annotation = AnnotationObject(studentLocation: studentLocation)
            mapView.addAnnotation(annotation as! MKAnnotation)
        }
    }
    
    
    //Reload the data and present it again
    func refreshMapView() {
        AppData.sharedInstance().hasFetchedStudentLocations = false
        loadStudentLocations()
    }
    
    
    // Load the student locations and present them
    func loadStudentLocations() {
        
        //Get the locations using a shared instance of the Parse Client
        ParseClient.sharedInstance().getStudentLocations() { (success, studentLocations, errorString) in
            performUIUpdatesOnMain {
                if success {
                    self.showAnnotation()
                }
                else {
                    self.displayError(errorString!)
                }
            }
        }
    }
}


extension MapViewController: MKMapViewDelegate, UIGestureRecognizerDelegate {

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        //Use Student Location as annotation object, create annotation view and assign queued annotations if possible
   //     if let annotation = annotation as? StudentLocation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                //If queued annotations not availabel then create new with call out and accessory
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -10, y: 10)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            //Return the annotation view
            return view
    //    }
    //    return nil
    }
    
    //If call out it tapped then open URL link in Student Location
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
        calloutAccessoryControlTapped control: UIControl!) {
            //let annotation = view.annotation
            print("Call out was pressed")
            print("URL =  \(view.annotation?.subtitle)")
            //Check URL is properly formatted and if not present error on map
            if let url = NSURL(string: ((view.annotation?.subtitle)!)!) {
                print("Url being opened = \(url)")
                UIApplication.sharedApplication().openURL(url)
            }
            else {
                displayError("Cannot present web page")
            }
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool){
        activityIndicator.hidden = true
    }
    
    
    //Present messages to user
    func displayError(error: String) {
        // Show error to user using Alert Controller
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}



