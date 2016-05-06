//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Robert Coffey on 09/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    let regionRadius: CLLocationDistance = 10000
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var studentLocations = [StudentLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Map view did load")
        mapView.delegate = self
        //let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        //centerMapOnLocation(initialLocation)
        //showAnnotation()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        updateStudentLocations()
      /*  let parameters: [String: AnyObject] = [Constants.ParseParameterKeys.Limit : Constants.ParseParameterValues.Limit]
        ParseClient.sharedInstance().getStudentLocations(parameters) { (success, studentLocations, errorString) in
            performUIUpdatesOnMain {
                if success {
                    print ("Success!")
                    print ("StudentLocations = \(studentLocations)")
                    self.studentLocations = studentLocations
                    self.showAnnotation()
                } else {
                    //self.displayError(errorString!)
                    print("Error = " + errorString!)
                }
            }
        }*/
    }

    

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showAnnotation() {
        let initialLocation = CLLocation(latitude: studentLocations[0].latitude, longitude: studentLocations[0].longitude)
        centerMapOnLocation(initialLocation)
        for studentLocation in studentLocations {
            mapView.addAnnotation(studentLocation)
        }
    }
    
    func refreshMapView() {
        ParseClient.sharedInstance().hasFetchedStudentLocations = false
        updateStudentLocations()
    }
    
    func updateStudentLocations() {
        let parameters: [String: AnyObject] = [Constants.ParseParameterKeys.Limit : Constants.ParseParameterValues.Limit]
        ParseClient.sharedInstance().getStudentLocations(parameters) { (success, studentLocations, errorString) in
            performUIUpdatesOnMain {
                if success {
                    print ("Success!")
                    print ("StudentLocations = \(studentLocations)")
                    self.studentLocations = studentLocations
                    self.showAnnotation()
                } else {
                    //self.displayError(errorString!)
                    print("Error = " + errorString!)
                }
            }
        }
    }
}

import MapKit

extension MapViewController: MKMapViewDelegate, UIGestureRecognizerDelegate {

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        print("Arrived in viewforannotation")
        if let annotation = annotation as? StudentLocation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
                    print("Dequeue a view")
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -10, y: 10)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                print("Created a new view")
            }
            
           /* let tap = UITapGestureRecognizer(target: self, action: "handleTap:")
            tap.delegate = self
            view.addGestureRecognizer(tap)
            print("Gesture recognizer added")
*/
            print("Returning view")
            return view
        }
        print("Returning nil")
        return nil
    }
    
    func handleTap() {
        print("Tap working")
    }
    
    
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
        calloutAccessoryControlTapped control: UIControl!) {
            let studentLocation = view.annotation as! StudentLocation
            UIApplication.sharedApplication().openURL(NSURL(string: studentLocation.mediaURL!)!)
    }
    
    
}



