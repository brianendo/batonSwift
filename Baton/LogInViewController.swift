//
//  LogInViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 10/29/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import SwiftyJSON
import TwitterKit


class LogInViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    func registerForKeyboardNotifications ()-> Void   {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.bottomLayoutConstraint.constant = keyboardFrame.size.height
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.registerForKeyboardNotifications()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.emailTextField.becomeFirstResponder()
        
        let logInButton = TWTRLogInButton { (session, error) in
            if let unwrappedSession = session {
                let alert = UIAlertController(title: "Logged In",
                    message: "User \(unwrappedSession.userName) has logged in",
                    preferredStyle: UIAlertControllerStyle.Alert
                )
                print(unwrappedSession)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }
        
        // Log In Code
        Twitter.sharedInstance().logInWithCompletion { session, error in
            if (session != nil) {
                print("signed in as \(session!.userName)")
                print(session?.userID)
                let userID = (session?.userID)!
                let client = TWTRAPIClient()
                client.loadUserWithID(userID) { (user, error) -> Void in
                    // handle the response or error
                    print(user?.name)
                    print(user?.profileImageURL)
                    print(user?.profileImageLargeURL)
                    let url = "http://twitter.com/" + session!.userName
                    print(url)
                }
//                if let userID = Twitter.sharedInstance().sessionStore.session()!.userID {
//                    let client = TWTRAPIClient(userID: userID)
//                    print(userID)
//                    // make requests with client
//                }
            } else {
                print("error: \(error!.localizedDescription)")
            }
        }
        
        // TODO: Change where the log in button is positioned in your view
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logInButtonPressed(sender: UIButton) {
//        let username = self.usernameTextField.text!
//        let password = self.passwordTextField.text!
//        let url = "http://localhost:3000/api/login"
//        let parameters = [
//            "username": username,
//            "password": password
//        ]
//        
//        Alamofire.request(.POST, url, parameters: parameters)
//            .responseJSON { response in
//                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
//                
//                if let JSON = response.result.value {
//                    print("JSON: \(JSON)")
//                }
//        }
//        ref.authUser(emailTextField.text, password: passwordTextField.text,
//            withCompletionBlock: { error, authData in
//                if error != nil {
//                    // There was an error logging in to this account
//                } else {
//                    // We are now logged in
//                    print(authData.uid)
//                    
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let mainVC = storyboard.instantiateInitialViewController()
//                    self.presentViewController(mainVC!, animated: true, completion: nil)
//                }
//        })
        let email:String = emailTextField.text! as String
        let password:String = passwordTextField.text! as String
        
        if ( email == "" || password == "" ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign in Failed!"
            alertView.message = "Please enter Username and Password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            
            let parameters = [
                "email": email,
                "password": password
            ]
            
            let url = globalurl + "login"
            
            Alamofire.request(.POST, url, parameters: parameters)
                .responseJSON { response in
                    print(response.request)
                    print(response.response)
                    print(response.result)
                    print(response.response?.statusCode)
                    
                    let statuscode = response.response?.statusCode
                    if statuscode == 200 {
                        print("Log In successful")
                        let json = JSON(response.result.value!)
                        print("JSON: \(json)")
                        let id = json["_id"].string
                        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        prefs.setObject(id, forKey: "ID")
                        prefs.setInteger(1, forKey: "ISLOGGEDIN")
                        prefs.synchronize()
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainVC = storyboard.instantiateInitialViewController()
                        self.presentViewController(mainVC!, animated: true, completion: nil)
                    } else if statuscode == 400 {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign in Failed!"
                        alertView.message = "No user found"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    } else if statuscode == 404 {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign in Failed!"
                        alertView.message = "Password does not match"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    } else {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign in Failed!"
                        alertView.message = "Connection Failed"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
            }
        }
        
    }
    

}
