//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Robert Coffey on 16/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation


class ParseClient : NSObject {

    
    // MARK: Properties
    
    var studentLocations: [StudentLocation] = []
    var hasFetchedStudentLocations = false
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // configuration object
    //   var config = TMDBConfig()
    
    // authentication stat
    var requestToken: String? = nil
    var sessionID : String? = nil
    var userID : Int? = nil
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // create a URL from parameters
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
        
        print(components.URL)
        
        return components.URL!
    }
    
    
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        print(data)
/*        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
        print ("Data is =")
        print(NSString(data: newData, encoding: NSUTF8StringEncoding))
*/
        var parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            print("Parse results = \(data)")
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    // MARK: GET
    
    func taskForGETMethod(method: String, var parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
    
    /* 1. Set the parameters */
        //parameters[Constants.ParseParameterKeys.ApiKey] = Constants.ParseParameterValues.ApiKey
        //parameters[Constants.ParseParameterKeys.ApplicationID] = Constants.ParseParameterValues.ApplicationID
    
    /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: parseURLFromParameters(parameters, withPathExtension: method))
        //request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        //request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue(Constants.ParseParameterValues.ApplicationID, forHTTPHeaderField: Constants.ParseParameterKeys.ApplicationID)
        request.addValue(Constants.ParseParameterValues.ApiKey, forHTTPHeaderField: Constants.ParseParameterKeys.ApiKey)
    
    /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            print("Error is  \(error)")
            print("Response is \(response)")
            print("Data is \(data)")
    
    func sendError(error: String) {
    print(error)
    let userInfo = [NSLocalizedDescriptionKey : error]
    completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
    }
    
    /* GUARD: Was there an error? */
    guard (error == nil) else {
    sendError("There was an error with your request: \(error)")
    return
    }
    
    /* GUARD: Did we get a successful 2XX response? */
    guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
    self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandlerForGET)
    sendError("Your request returned a status code other than 2xx!")
    return
    }
    
    /* GUARD: Was there any data returned? */
    guard let data = data else {
    sendError("No data was returned by the request!")
    return
    }
    
    /* 5/6. Parse the data and use the data (happens in completion handler) */
    self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
    }
    
    /* 7. Start the request */
    task.resume()
    
    return task
    }
    
    // MARK: POST
    
    func taskForPOSTMethod(method: String, var parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        //parameters[Constants.ParseParameterKeys.ApiKey] = Constants.ParseParameterValues.ApiKey
        //parameters[Constants.ParseParameterKeys.ApplicationID] = Constants.ParseParameterValues.ApplicationID
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: parseURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "POST"
        request.addValue(Constants.ParseParameterValues.ApplicationID, forHTTPHeaderField: Constants.ParseParameterKeys.ApplicationID)
        request.addValue(Constants.ParseParameterValues.ApiKey, forHTTPHeaderField: Constants.ParseParameterKeys.ApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        //request.HTTPBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}".dataUsingEncoding(NSUTF8StringEncoding)
        
        print("Request URL = \(request)")
        //print("Request header = \(request.)"
        print("HTTP body = \(jsonBody)")
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            print("Error is  \(error)")
            print("Response is \(response)")
            print("Data is \(data)")
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            
            
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    

    
    func getStudentLocations(parameters: [String: AnyObject], completionHandlerForSession: (success: Bool, studentLocations: [StudentLocation], errorString: String?) -> Void) {
        
        let method = "/StudentLocation"
        
        if hasFetchedStudentLocations {
                print("Has fetched student locations = \(hasFetchedStudentLocations)")
                completionHandlerForSession(success: true, studentLocations: self.studentLocations, errorString: nil)
                return
        }
        
        taskForGETMethod(method, parameters: parameters) { (results, error) in

            print("Reached after post method.")
            print("Results are = \(results)")
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForSession(success: false, studentLocations: self.studentLocations, errorString: "Login Failed (Session ID).")
            } else {
                //var item: AnyObject
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
        
        //func getSessionID(parameters: [String: AnyObject]) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        //        let parameters = [TMDBClient.ParameterKeys.RequestToken: requestToken!]
        let parameters: [String: AnyObject] = [:]
        let method = "/StudentLocation"
        /* 2. Make the request */
        //let jsonBody = "{\"udacity\": {\"username\": \"racoffey@gmail.com\", \"password\": \"Uranus2015\"}}"
        let jsonBody = covertToJson(bodyParameters)
        
        taskForPOSTMethod(method, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            print("Reached after post method.")
            print("Results are = \(results)")
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForPostSL(success: false, errorString: "Post Student Location Failed.")
            } else {
                print ("Data received by postSL = \(results)")
            /*    let resultsDict: [String: AnyObject] = (results as? Dictionary)!
                if let session = resultsDict[Constants.UdacityResponseKeys.Session] {
                    print ("Session = \(session)")
                    if let sessionID = session[Constants.UdacityResponseKeys.SessionID] as? String {
                        print("Session ID = " + sessionID)
                        completionHandlerForSession(success: true, sessionID: sessionID, errorString: "Login Failed (Session ID).")
                    }
                    else{
                        print("Could not find \(Constants.UdacityResponseKeys.SessionID) in \(results)")
                        completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                    }
                } else {
                    print("Could not find \(Constants.UdacityResponseKeys.SessionID) in \(results)")
                    completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                }*/
            }
        }
    }
    
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
        //print("JsonBody end index = \(jsonBody.characters.last)")
        //print(jsonBody)
        
        jsonBody.removeAtIndex(jsonBody.endIndex.predecessor())
        jsonBody.removeAtIndex(jsonBody.endIndex.predecessor())
        jsonBody.appendContentsOf("}")
        
        print(jsonBody)
        
        print(jsonBody)
        return jsonBody
    }
 /*
    func getSessionID(parameters: [String: AnyObject], completionHandlerForSession: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        //func getSessionID(parameters: [String: AnyObject]) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        //        let parameters = [TMDBClient.ParameterKeys.RequestToken: requestToken!]
        
        /* 2. Make the request */
        let jsonBody = "{\"udacity\": {\"username\": \"racoffey@gmail.com\", \"password\": \"Uranus2015\"}}"
        
        taskForPOSTMethod("/session", parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            print("Reached after post method.")
            print("Results are = \(results)")
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
            } else {
                print ("Data received by getSesssionID= \(results)")
                let resultsDict: [String: AnyObject] = (results as? Dictionary)!
                if let session = resultsDict[Constants.UdacityResponseKeys.Session] {
                    print ("Session = \(session)")
                    if let sessionID = session[Constants.UdacityResponseKeys.SessionID] as? String {
                        print("Session ID = " + sessionID)
                        completionHandlerForSession(success: true, sessionID: sessionID, errorString: "Login Failed (Session ID).")
                    }
                    else{
                        print("Could not find \(Constants.UdacityResponseKeys.SessionID) in \(results)")
                        completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                    }
                } else {
                    print("Could not find \(Constants.UdacityResponseKeys.SessionID) in \(results)")
                    completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                }
            }
        }
    }
    
    */
    
    // MARK: Helpers
    
    // substitute the key for the value that is contained within the method name
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    /*
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
    
    var parsedResult: AnyObject!
    do {
    parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
    } catch {
    let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
    completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
    }
    
    completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    */
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}
