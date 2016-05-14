//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Robert Coffey on 16/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation

// Parse API client

class ParseClient : NSObject {

    
    // Properties
    
    var studentLocations: [StudentLocation] = []
    var hasFetchedStudentLocations = false
    
    // Shared session
    var session = NSURLSession.sharedSession()
    
    
    // Initializers
    
    override init() {
        super.init()
    }
  
    // GET method
    func taskForGETMethod(method: String, var parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
    
    //Construct the URL request using input parameters
        let request = NSMutableURLRequest(URL: parseURLFromParameters(parameters, withPathExtension: method))
        request.addValue(Constants.ParseParameterValues.ApplicationID, forHTTPHeaderField: Constants.ParseParameterKeys.ApplicationID)
        request.addValue(Constants.ParseParameterValues.ApiKey, forHTTPHeaderField: Constants.ParseParameterKeys.ApiKey)
    
    //Prepare the request task
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
    
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
    
            //Was there an error?
            guard (error == nil) else {
                sendError("The parse GET request failed")
                return
            }
    
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                //self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandlerForGET)
                sendError("Your request returned a status code other than 2xx!")
                return
            }
    
            // GUARD: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
    
            // Parse the data and use the data and return the result
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
    
    // Execute the request
    task.resume()
    
    return task
    }
    
    
    // POST method
    func taskForPOSTMethod(method: String, var parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        
        // Build the URL based on header parameter and json body input
        let request = NSMutableURLRequest(URL: parseURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "POST"
        request.addValue(Constants.ParseParameterValues.ApplicationID, forHTTPHeaderField: Constants.ParseParameterKeys.ApplicationID)
        request.addValue(Constants.ParseParameterValues.ApiKey, forHTTPHeaderField: Constants.ParseParameterKeys.ApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Prepare request task
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                sendError("The POST method failed. \(error)")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your POST request returned a status code other than 2xx!")
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the POST request!")
                return
            }
            
            
            // Parse the data and return the resulting data
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        //Initiate the request
        task.resume()
        
        return task
    }
    

    // Get a number of the last student locations
    func getStudentLocations( completionHandlerForSession: (success: Bool, studentLocations: [StudentLocation], errorString: String?) -> Void) {
        
        //Establish parameters for GET request
        let method = "/StudentLocation"
        let parameters: [String: AnyObject] = [Constants.ParseParameterKeys.Limit : Constants.ParseParameterValues.Limit]
        
        //If student locations have already been fetched, no need to fetch again unless specific refresh requested
        if hasFetchedStudentLocations {
                completionHandlerForSession(success: true, studentLocations: self.studentLocations, errorString: nil)
                return
        }
        
        //Execute GET method
        taskForGETMethod(method, parameters: parameters) { (results, error) in

            // Handle error case
            if error != nil {
                completionHandlerForSession(success: false, studentLocations: self.studentLocations, errorString: "Failed to get student locations.")
            } else {
                //Put results into a data object and extract each student location into the Student Locations array and return array
                self.studentLocations.removeAll()
                var resultsDict = results as! [String: AnyObject]
                let resultsArray = resultsDict["results"] as! [AnyObject]
                for item in resultsArray {
                    let dict = item as! [String: AnyObject]
                    let studentLocation = StudentLocation(
                    createdAt: dict[Constants.ParseResponseKeys.CreatedAt] as! String,
                    firstName: dict[Constants.ParseResponseKeys.FirstName] as! String,
                    lastName: dict[Constants.ParseResponseKeys.LastName] as! String,
                    latitude: dict[Constants.ParseResponseKeys.Latitude] as! Double,
                    longitude: dict[Constants.ParseResponseKeys.Longitude] as! Double,
                    mapString: dict[Constants.ParseResponseKeys.MapString] as! String,
                    mediaURL: dict[Constants.ParseResponseKeys.MediaURL] as! String,
                    objectId: dict[Constants.ParseResponseKeys.ObjectId] as! String,
                    uniqueKey: dict[Constants.ParseResponseKeys.UniqueKey] as! String,
                    updatedAt: dict[Constants.ParseResponseKeys.UpdatedAt] as! String)
                        
                    self.studentLocations.append(studentLocation)
                }
                self.hasFetchedStudentLocations = true
                completionHandlerForSession(success: true, studentLocations: self.studentLocations, errorString: nil)
            }
        }
    }

    
    func postStudentLocation(bodyParameters: [String: AnyObject], completionHandlerForPostSL: (success: Bool, errorString: String?) -> Void) {
        
        //Prepare input parameters to POST request
        let parameters: [String: AnyObject] = [:]
        let method = "/StudentLocation"
        let jsonBody = covertToJson(bodyParameters)
        
        // Prepare request task using parameters
        taskForPOSTMethod(method, parameters: parameters, jsonBody: jsonBody) { (results, error) in

            //Handle error case
            if let error = error {
                print(error.localizedDescription)
                completionHandlerForPostSL(success: false, errorString: error.localizedDescription)
            } else {
                //If no error then report back that request successfully executed
                completionHandlerForPostSL(success: true, errorString: nil)
            }
        }
    }
    
    
    // Assisting functions
    
    // Create JSON string based on parameters dictionary
    func covertToJson (parameters: [String: AnyObject]) -> String {
        var jsonBody: String = "{"
        var newValue: String
        for (key, value) in parameters {
            print("Key = \(key)")
            print("Value = \(value)")
            if value is Double {
                newValue = String(value)
                let string: String = ("\"\(key)\": \(newValue), ")
                jsonBody.appendContentsOf(string)
            }
            else {
                newValue = value as! String
                let string: String = ("\"\(key)\": \"\(newValue)\", ")
                jsonBody.appendContentsOf(string)
            }
        }
        //Last comma and space removed and brace added
        jsonBody.removeAtIndex(jsonBody.endIndex.predecessor())
        jsonBody.removeAtIndex(jsonBody.endIndex.predecessor())
        jsonBody.appendContentsOf("}")
        return jsonBody
    }
    
    
    // Create a URL from parameters
    func parseURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.Parse.ApiScheme
        components.host = Constants.Parse.ApiHost
        components.path = Constants.Parse.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.URL!
    }
    
    
    // Parse raw JSON to NS object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject?
        
        //Attempt to parse data and report error if failure
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        // Return parsed result
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}
