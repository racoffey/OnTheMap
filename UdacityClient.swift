//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Robert Coffey on 09/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import FBSDKCoreKit

// Udacity AP Client: NSObject

class UdacityClient : NSObject {
    
    // Shared session
    var session = NSURLSession.sharedSession()
    
    // Session info
    var sessionID : String? = nil
    var userID : String? = nil
    
    // Initializers
    
    override init() {
        super.init()
    }
    
    
    
    // GET method
   func taskForGETMethod(method: String, var parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
    
        
        //Build the URL based on input parameters
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(parameters, withPathExtension: method))
        
        //Construct the task
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            //GUARD: Was there an error?
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Parse the data and return the parsed result
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        // Execute the request
        task.resume()
        
        return task
    }
    
    
    // POST Method
    
    func taskForPOSTMethod(method: String, var parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        
        // Build the URL with header parameters and JSON body
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Prepare the request task
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil,  error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }

            // GUARD: Was there an error?
            guard (error == nil) else {
                sendError((error?.localizedDescription)!)
                return
            }

            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if ((response as? NSHTTPURLResponse)?.statusCode)! as Int == 403 {
                    sendError("Incorrect username and/or password")
                    return
                } else {
                    sendError("Post request failed.")
                    return
                }
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Parse the data and return parsed result
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        //Execute the request task
        task.resume()
        
        return task
    }
    
    
    // DELETE Method
    
    func taskForDELETEMethod(method: String, var parameters: [String:AnyObject], completionHandlerForDELETE: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Build the URL with header parameters and JSON body
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        //Prepare the request task
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDELETE(result: nil,  error: NSError(domain: "taskForDELETEMethod", code: 1, userInfo: userInfo))
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                sendError((error?.localizedDescription)!)
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Delete request failed.")
                return
            }
            
            // Parse the data and return parsed result
            self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandlerForDELETE)
        }
        
        //Execute the request task
        task.resume()
        
        return task
    }
    
    func logOutOfSession(completionHandlerForLogOut: (success: Bool, errorString: String?) -> Void) {
        
        //Prepare request parameters for DELETE method
        let method: String = "/session"
        let parameters: [String: AnyObject] = [:]
        
        //Call DELETE method
        taskForDELETEMethod(method ,parameters: parameters) {(results, error) in
            
            //Handle error case
            if error != nil {
                completionHandlerForLogOut(success: false, errorString: "Could not retrieve user details.")
            }
            else {
                // Return success result to requesting VC
                 completionHandlerForLogOut(success: true, errorString: nil)
            }
        }
    }
    
    
    func getUserInfo(userID: String, completionHandlerForUserInfo: (success: Bool, userInfo: [String: AnyObject], errorString: String?) -> Void) {
        
        //Prepare request parameters for GET method
        let method: String = "/users/\(userID)"
        let parameters: [String: AnyObject] = [:]
        
        //Initialise dictionary for results
        var userInfo = [String: AnyObject]()
        
        //Call GET method
        taskForGETMethod(method ,parameters: parameters) {(results, error) in
                
            //Handle error case
            if error != nil {
                completionHandlerForUserInfo(success: false, userInfo: userInfo, errorString: "Could not retrieve user details.")
            }
            else {
                // Read parsed results into dictionary object
                let resultsDict: [String: AnyObject] = (results as? Dictionary)!
                    
                //Retrieve first and last names from results and return them through completion handler
                if let userDict = resultsDict[Constants.UdacityResponseKeys.User] {
                    userInfo[Constants.ParseRequestKeys.FirstName] = userDict[Constants.UdacityResponseKeys.FirstName]
                    userInfo[Constants.ParseRequestKeys.LastName] = userDict[Constants.UdacityResponseKeys.LastName]
                    completionHandlerForUserInfo(success: true, userInfo: userInfo, errorString: nil)
                }
                else{
                    //Handle case where user cannot be found
                    completionHandlerForUserInfo(success: false, userInfo: userInfo, errorString: "Could not retrieve user details.")
                }
            }
        }
    }
    
    
    func getSessionID(var parameters: [String: AnyObject], completionHandlerForSession: (success: Bool, sessionID: String?, userID: String?, errorString: String?) -> Void) {
    
        
        //Prepare input to POST method
        let jsonBody = "{\"udacity\": {\"username\": \"\(parameters[Constants.UdacityParameterKeys.Username]!)\", \"password\": \"\(parameters[Constants.UdacityParameterKeys.Password]!)\"}}" 
        parameters = [:]
        
        // Execute POST method
        taskForPOSTMethod("/session", parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            // Handle error case
            if error != nil  {
                completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: error?.localizedDescription)
                    return
            }
            else {
                
                //Read results into dictionary object
                let resultsDict: [String: AnyObject] = (results as? Dictionary)!
                
                //Extract User ID from the Account item in the results dictionary and save it for future interactions
                if let account = resultsDict[Constants.UdacityResponseKeys.Account]{
                    if let userID = account[Constants.UdacityResponseKeys.UserID] as? String {
                        self.userID = userID
                    }
                    else{
                        completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Could not find User ID.")
                        return
                    }
                }
                
                //Extract the Session ID from the Session item in the results dictionary
                if let session = resultsDict[Constants.UdacityResponseKeys.Session] {
                    if let sessionID = session[Constants.UdacityResponseKeys.SessionID] as? String {
                        completionHandlerForSession(success: true, sessionID: sessionID, userID: self.userID, errorString: nil)
                    }
                    else{
                        completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Could not find Session ID")
                        return
                    }
                } else {
                completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Could not find Session in response.")
                }
            }
        }
    }
    
    // Create udacity session using Facebook access token
    func getSessionIDWithFB(var parameters: [String: AnyObject], completionHandlerForSessionWithFB: (success: Bool, sessionID: String?, userID: String?, errorString: String?) -> Void) {
        
        // Get current access token
        let token = FBSDKAccessToken.currentAccessToken().tokenString! as String
    
        //Prepare input to POST method
        let jsonBody = "{\"facebook_mobile\": {\"access_token\":\"\(token);\"}}"
        parameters = [:]
        
        // Execute POST method
        taskForPOSTMethod("/session", parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            // Handle error case
            if error != nil  {
                completionHandlerForSessionWithFB(success: false, sessionID: nil, userID: nil, errorString: error?.localizedDescription)
                return
            }
            else {
                
                //Read results into dictionary object
                let resultsDict: [String: AnyObject] = (results as? Dictionary)!
                
                //Extract User ID from the Account item in the results dictionary and save it for future interactions
                if let account = resultsDict[Constants.UdacityResponseKeys.Account]{
                    if let userID = account[Constants.UdacityResponseKeys.UserID] as? String {
                        self.userID = userID
                    }
                    else{
                        completionHandlerForSessionWithFB(success: false, sessionID: nil, userID: nil, errorString: "Could not find User ID.")
                        return
                    }
                }
                
                //Extract the Session ID from the Session item in the results dictionary
                if let session = resultsDict[Constants.UdacityResponseKeys.Session] {
                    if let sessionID = session[Constants.UdacityResponseKeys.SessionID] as? String {
                        completionHandlerForSessionWithFB(success: true, sessionID: sessionID, userID: self.userID, errorString: nil)
                    }
                    else{
                        completionHandlerForSessionWithFB(success: false, sessionID: nil, userID: nil, errorString: "Could not find Session ID")
                        return
                    }
                } else {
                    completionHandlerForSessionWithFB(success: false, sessionID: nil, userID: nil, errorString: "Could not find Session in response.")
                }
            }
        }
    }
    
    
    // Assisting functions
    
    // Create a URL from parameters
    func udacityURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {

        let components = NSURLComponents()
        components.scheme = Constants.Udacity.ApiScheme
        components.host = Constants.Udacity.ApiHost
        components.path = Constants.Udacity.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.URL!
    }
    
    // Parse raw JSON data to NS Object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        // Remove first 5 characters from raw data as required in Udacity API specification
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        
        // Populate result with parsed data and return result
        var parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(newData)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    
    // Shared Instance

    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
