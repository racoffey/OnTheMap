//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Robert Coffey on 09/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    var userID: String = ""
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        configureUI()
        
        subscribeToNotification(UIKeyboardWillShowNotification, selector: Constants.Selectors.KeyboardWillShow)
        subscribeToNotification(UIKeyboardWillHideNotification, selector: Constants.Selectors.KeyboardWillHide)
        subscribeToNotification(UIKeyboardDidShowNotification, selector: Constants.Selectors.KeyboardDidShow)
        subscribeToNotification(UIKeyboardDidHideNotification, selector: Constants.Selectors.KeyboardDidHide)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    func completeLogin() {
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            self.setUIEnabled(true)
        /*
            if let nc = self.storyboard!.instantiateInitialViewController() as? NavigationController {
                nc.userID = self.userID
                self.presentViewController(nc, animated: true, completion: nil)
            }
          */
            
            
          
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController") as! NavigationController
            //controller.userID = self.userID
            self.presentViewController(controller, animated: true, completion: nil)
            let topController: OTMTabBarController = controller.topViewController as! OTMTabBarController
            topController.userID = self.userID
        }
    }
    
    func displayError(error: String, debugLabelText: String? = nil) {
        print(error)
        performUIUpdatesOnMain {
            self.setUIEnabled(true)
            self.debugTextLabel.text = error
        }
    }
    
    // MARK: Login
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        userDidTapView(self)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            
            
            //    Steps for Authentication...
            //    https://www.themoviedb.org/documentation/api/sessions
            
            //    Step 1: Create a request token
            //Step 2: Ask the user for permission via the API ("login")
            //   Step 3: Create a session ID
            
            //    Extra Steps...
            //    Step 4: Get the user id ;)
            //    Step 5: Go to the next view!
            
          //  getRequestToken()
            let parameters: [String: AnyObject] =
                [Constants.UdacityParameterKeys.Username: usernameTextField.text!,
                Constants.UdacityParameterKeys.Password: passwordTextField.text!]
            print(parameters)
            UdacityClient.sharedInstance().getSessionID(parameters) { (success, sessionID, userID, errorString) in
                if success { self.userID = userID! }
                performUIUpdatesOnMain {
                    if success {
                        self.completeLogin()
                    } else {
                        self.displayError(errorString!)
                    }
                }
            }
        }
    }
    
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://www.udacity.com/account/auth#!/signup")!)
    }

 /*
    // MARK: TheMovieDB
    
    private func getRequestToken() {
        
        /* TASK: Get a request token, then store it (appDelegate.requestToken) and login with the token */
        
        /* 1. Set the parameters */
        let methodParameters = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey
        ]
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSURLRequest(URL: appDelegate.tmdbURLFromParameters(methodParameters, withPathExtension: "/authentication/token/new"))
        
        /* 4. Make the request */
        let task = appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* Parse the data! */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                print(parsedResult)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* 6. Use the data! */
            if let token: String = parsedResult[Constants.TMDBResponseKeys.RequestToken] as? String {
                print(token)
                self.setUIEnabled(true)
                self.debugTextLabel.text = token
                self.appDelegate.requestToken = token
                self.loginWithToken(token)
            } else {
                print("Could not parse token.")
            }
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    private func loginWithToken(requestToken: String) {
        
        /* TASK: Login, then get a session id */
        
        /* 1. Set the parameters */
        let methodParameters: [String: AnyObject] = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey,
            Constants.TMDBParameterKeys.RequestToken: requestToken,
            Constants.TMDBParameterKeys.Username: usernameTextField.text!,
            Constants.TMDBParameterKeys.Password: passwordTextField.text!
        ]
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSURLRequest(URL: appDelegate.tmdbURLFromParameters(methodParameters, withPathExtension: "/authentication/token/validate_with_login"))
        print(request)
        /* 4. Make the request */
        let task = appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                print(parsedResult)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* 6. Use the data! */
            if let success: Bool = parsedResult[Constants.TMDBResponseKeys.Success] as? Bool {
                if success { print("Login successful!")}
                self.getSessionID(self.appDelegate.requestToken!)
                //self.setUIEnabled(true)
                //self.debugTextLabel.text = token as! String
            } else {
                print("Login not successful")
            }
            
            /* 7. Start the request */
        }
        task.resume()
    }
    
    private func getSessionID(requestToken: String) {
        
        /* TASK: Get a session ID, then store it (appDelegate.sessionID) and get the user's id */
        
        /* 1. Set the parameters */
        /* 2/3. Build the URL, Configure the request */
        /* 4. Make the request */
        /* 5. Parse the data */
        /* 6. Use the data! */
        /* 7. Start the request */
        
        
        /* 1. Set the parameters */
        let methodParameters: [String: AnyObject] = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey,
            Constants.TMDBParameterKeys.RequestToken: requestToken
        ]
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSURLRequest(URL: appDelegate.tmdbURLFromParameters(methodParameters, withPathExtension: "/authentication/session/new"))
        print(request)
        
        /* 4. Make the request */
        let task = appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            
            func displayError(error: String, debugLabelText: String? = nil) {
                print(error)
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = "Login Failed (Session ID)."
                }
            }
            
            
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx! Error code = ")
                print((response as? NSHTTPURLResponse)?.statusCode)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                print(parsedResult)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* 6. Use the data! */
            if let sessionid: String = parsedResult[Constants.TMDBResponseKeys.SessionID] as? String {
                print("Session id ")
                print(sessionid)
                self.appDelegate.sessionID = sessionid
                self.getUserID(sessionid)
            } else {
                print("Could not retrieve User ID")
            }
            
            /* 7. Start the request */
        }
        task.resume()
        completeLogin()
    }
    
    private func getUserID(sessionID: String) {
        
        /* TASK: Get the user's ID, then store it (appDelegate.userID) for future use and go to next view! */
        
        /* 1. Set the parameters */
        /* 2/3. Build the URL, Configure the request */
        /* 4. Make the request */
        /* 5. Parse the data */
        /* 6. Use the data! */
        /* 7. Start the request */
        
        
        /* 1. Set the parameters */
        let methodParameters: [String: AnyObject] = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey,
            Constants.TMDBParameterKeys.SessionID: sessionID
        ]
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSURLRequest(URL: appDelegate.tmdbURLFromParameters(methodParameters, withPathExtension: "/account"))
        print(request)
        
        /* 4. Make the request */
        let task = appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            
            func displayError(error: String, debugLabelText: String? = nil) {
                print(error)
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = "Login Failed (User ID)."
                }
            }
            
            
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx! Error code = ")
                print((response as? NSHTTPURLResponse)?.statusCode)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                print(parsedResult)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* 6. Use the data! */
            if let userid: Int = parsedResult[Constants.TMDBResponseKeys.UserID] as? Int {
                self.appDelegate.userID = userid
                print("User Id = ")
                print(userid)
            } else {
                print("Could not retrieve User ID")
            }
            
            /* 7. Start the request */
        }
        task.resume()

        
    }*/
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            movieImageView.hidden = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
            movieImageView.hidden = false
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
}

// MARK: - LoginViewController (Configure UI)

extension LoginViewController {
    
    private func setUIEnabled(enabled: Bool) {
        usernameTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButton.enabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.enabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    private func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [Constants.UI.LoginColorTop, Constants.UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        configureTextField(usernameTextField)
        configureTextField(passwordTextField)
    }
    
    private func configureTextField(textField: UITextField) {
        let textFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .Always
        textField.backgroundColor = Constants.UI.GreyColor
        textField.textColor = Constants.UI.BlueColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        textField.tintColor = Constants.UI.BlueColor
        textField.delegate = self
    }
}

// MARK: - LoginViewController (Notifications)

extension LoginViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}