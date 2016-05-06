//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Robert Coffey on 09/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation

// MARK: - TMDBClient: NSObject

class UdacityClient : NSObject {
    

    // MARK: Properties
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // configuration object
 //   var config = TMDBConfig()
    
    // authentication stat
    //var requestToken: String? = nil
    var sessionID : String? = nil
    var userID : String? = nil
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // create a URL from parameters
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
        
        print(components.URL)
        
        return components.URL!
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        print(data)
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
        print ("Data is =")
        print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        
        var parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(newData)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    // MARK: GET
    
   func taskForGETMethod(method: String, var parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
 //       parameters[ParameterKeys.ApiKey] = Constants.ApiKey
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(parameters, withPathExtension: method))
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
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
     //   parameters[ParameterKeys.ApiKey] = Constants.ApiKey
        //let newParameters: [String: AnyObject] = ["udacity": parameters]
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        print(jsonBody)
        print(request.HTTPBody)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            print("Error is  \(error)")
            print("Error description = \(error?.localizedDescription)")
            print("Response is \(response)")
            print("Data is \(data)")
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil,  error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError((error?.localizedDescription)!)
                return
            }
            
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Check your username and password.")
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
    
    // MARK: GET Image
    
/*    func taskForGETImage(size: String, filePath: String, completionHandlerForImage: (imageData: NSData?, error: NSError?) -> Void) -> NSURLSessionTask {
        
        /* 1. Set the parameters */
        // There are none...
        
        /* 2/3. Build the URL and configure the request */
        let baseURL = NSURL(string: config.baseImageURLString)!
        let url = baseURL.URLByAppendingPathComponent(size).URLByAppendingPathComponent(filePath)
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForImage(imageData: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
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
            completionHandlerForImage(imageData: data, error: nil)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    */
   /*
    
    */
    
    func getUserInfo(userID: String, completionHandlerForUserInfo: (success: Bool, userInfo: [String: AnyObject], errorString: String?) -> Void) {
        
        
            let method: String = "/users/\(userID)"
            let parameters: [String: AnyObject] = [:]
        
            var userInfo = [String: AnyObject]()
        
        
        
            taskForGETMethod(method ,parameters: parameters) {(results, error) in
                
                if let error = error {
                    print(error)
                    completionHandlerForUserInfo(success: false, userInfo: userInfo, errorString: "Get user info request failed (User Info).")
                } else {
                    print ("Data received by getUserInfo \(results)")
                    let resultsDict: [String: AnyObject] = (results as? Dictionary)!
                    if let userDict = resultsDict[Constants.UdacityResponseKeys.User] {
                        print("UserDict = \(userDict)")
                        userInfo[Constants.ParseRequestKeys.FirstName] = userDict[Constants.UdacityResponseKeys.FirstName]
                        userInfo[Constants.ParseRequestKeys.LastName] = userDict[Constants.UdacityResponseKeys.LastName]
                        print("UserInfo = \(userInfo)")
                        completionHandlerForUserInfo(success: true, userInfo: userInfo, errorString: nil)
                    }
                    else{
                        print("Could not find \(Constants.UdacityResponseKeys.User) in \(results)")
                        completionHandlerForUserInfo(success: false, userInfo: userInfo, errorString: "Get user info request failed (User Info).")
                        }
                    }
             /*       if let session = resultsDict[Constants.UdacityResponseKeys.Session] {
                        print ("Session = \(session)")
                        //print ("Account = \(account)")
                        if let sessionID = session[Constants.UdacityResponseKeys.SessionID] as? String {
                            print("Session ID = " + sessionID)
                            print("User ID = " + self.userID!)
                            completionHandlerForSession(success: true, sessionID: sessionID, userID: self.userID, errorString: "Login Failed (Session ID).")
                        }
                        else{
                            print("Could not find \(Constants.UdacityResponseKeys.SessionID) in \(results)")
                            completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Session ID).")
                        }
                    } else {
                        print("Could not find \(Constants.UdacityResponseKeys.SessionID) in \(results)")
                        completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Session ID).")
                    }
                }*/
            }
    }
    
    
    func getSessionID(var parameters: [String: AnyObject], completionHandlerForSession: (success: Bool, sessionID: String?, userID: String?, errorString: String?) -> Void) {
    
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        //        let parameters = [TMDBClient.ParameterKeys.RequestToken: requestToken!]
        
        /* 2. Make the request */
        let jsonBody = "{\"udacity\": {\"username\": \"\(parameters[Constants.UdacityParameterKeys.Username]!)\", \"password\": \"\(parameters[Constants.UdacityParameterKeys.Password]!)\"}}"
        parameters = [:]
        
        taskForPOSTMethod("/session", parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            //print("Reached after post method.")
            //print("Results are = \(results)")
            /* 3. Send the desired value(s) to completion handler */
            if error != nil  {
                print("Localized description in get session ID = \(error?.localizedDescription)")
                
                completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: error?.localizedDescription)
                    return
            } else {
                print ("Data received by getSesssionID= \(results)")
                let resultsDict: [String: AnyObject] = (results as? Dictionary)!
                //if let session = resultsDict[Constants.UdacityResponseKeys.Session] && let account = resultsDict[Constants.UdacityResponseKeys.Account] {
                if let account = resultsDict[Constants.UdacityResponseKeys.Account]{
                    if let userID = account[Constants.UdacityResponseKeys.UserID] as? String {
                        self.userID = userID
                    }
                    else{
                        print("Could not find \(Constants.UdacityResponseKeys.UserID) in \(results)")
                        completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Session ID).")
                    }
                }
            if let session = resultsDict[Constants.UdacityResponseKeys.Session] {
                    print ("Session = \(session)")
                    //print ("Account = \(account)")
                    if let sessionID = session[Constants.UdacityResponseKeys.SessionID] as? String {
                        print("Session ID = " + sessionID)
                        print("User ID = " + self.userID!)
                        completionHandlerForSession(success: true, sessionID: sessionID, userID: self.userID, errorString: "Login Failed (Session ID).")
                    }
                    else{
                        print("Could not find \(Constants.UdacityResponseKeys.SessionID) in \(results)")
                        completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Session ID).")
                    }
                } else {
                    print("Could not find \(Constants.UdacityResponseKeys.SessionID) in \(results)")
                completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Session ID).")
                }
            }
        }
    }
    
    
    
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

    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
