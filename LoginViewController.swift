//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Robert Coffey on 09/04/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
// 

import Foundation
import UIKit

//  LoginViewController: UIViewController

class LoginViewController: UIViewController {
    
    // Properties
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    
    // Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookLoginButton: BorderedButton!

    
    // Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        configureUI()
        
        subscribeToNotification(UIKeyboardWillShowNotification, selector: Constants.Selectors.KeyboardWillShow)
        subscribeToNotification(UIKeyboardWillHideNotification, selector: Constants.Selectors.KeyboardWillHide)
        subscribeToNotification(UIKeyboardDidShowNotification, selector: Constants.Selectors.KeyboardDidShow)
        subscribeToNotification(UIKeyboardDidHideNotification, selector: Constants.Selectors.KeyboardDidHide)
        
        // If there is an active Facebook access token login without further user input
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            getSessionWithFB()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        setUIEnabled(true)
    }
    
    
    // Use FBSDK Login Manager to initiate Facebook login
    func fbLoginInitiate() {
        let loginManager = FBSDKLoginManager()
        loginManager.logInWithReadPermissions(["public_profile", "email"], handler: {(result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if (error != nil) {
                self.displayError("Facebook login failed")
                self.removeFbData()
            } else if result.isCancelled {
                // User Cancellation
                self.removeFbData()
            } else {
                // If successful get Udacity session
                self.getSessionWithFB()
            }
        })
    }
    
    
    // Log out of Facebook and cancel access token
    func removeFbData() {
        //Remove FB Data
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }

    
    // Get a Udacity session using Facebook access token
    func getSessionWithFB() {
        
        let parameters = [String: AnyObject]()
    
        //Perform login request and if successful complete login
        UdacityClient.sharedInstance().getSessionIDWithFB(parameters) { (success, sessionID, userID, errorString) in
            performUIUpdatesOnMain {
                if success {
                    self.completeLogin()
                } else {
                    self.displayError(errorString!)
                }
            }
        }
    }
    
    
    // Cancel notifications when view disappears
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    
    // Complete login by instantiating and presenting navigation view controller
    func completeLogin() {
        performUIUpdatesOnMain {
            //Present navigtation view controller when login is successful
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
            
        }
    }
    
    //Present message to user
    func displayError(error: String, debugLabelText: String? = nil) {
        print(error)
        
        // Show error to user using Alert Controller
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil)
        
        // Ensure UI is fully enabled again
        setUIEnabled(true)
    }
    
    // Login
    @IBAction func loginPressed(sender: AnyObject) {
        
        userDidTapView(self)
        
        //Check that username and password field have contents
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            displayError("Username or Password empty")
        } else {
            
            //Prepare parameters for login request
            setUIEnabled(false)
            let parameters: [String: AnyObject] =
                [Constants.UdacityParameterKeys.Username: usernameTextField.text!,
                Constants.UdacityParameterKeys.Password: passwordTextField.text!]

            //Perform login request and if successful complete login
            UdacityClient.sharedInstance().getSessionID(parameters) { (success, sessionID, userID, errorString) in
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
    
    //If signup button present then open appropriate Udacity page
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://www.udacity.com/account/auth#!/signup")!)
    }
    
    // If Facebook login button pressed then initiate Facebook login sequence
    @IBAction func FBSDKLoginButtonPressed(sender: AnyObject) {
        fbLoginInitiate()
    }
}

// LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Show/Hide Keyboard
    
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

// LoginViewController - configure Login User Interface

extension LoginViewController {
    
    // Prepare UI
    private func setUIEnabled(enabled: Bool) {
        usernameTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButton.enabled = enabled
        
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