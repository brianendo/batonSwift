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
import JWTDecode
import KeychainSwift

class LogInViewController: UIViewController {
    
    let keychain = KeychainSwift()
    
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
        let email:String = emailTextField.text!.lowercaseString as String
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
            
            let url = globalurl + "api/login"
            
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
                        print(json["data"]["_id"].string)
                        print(json["token"].string)
                        let id = json["data"]["_id"].string
                        let token = json["token"].string
                        var refresh_token = json["data"]["token"].string
                        do {
                            let jwt = try decode(token!)
                            print(jwt)
                            print(jwt.body)
                            print(jwt.expiresAt)
                        } catch {
                            print("Failed to decode JWT: \(error)")
                        }
                        
                        if refresh_token == nil {
                            // Generate refresh token if user does not have one
                            let url = globalurl + "api/users/" + id! + "/addtoken/"
                            
                            Alamofire.request(.PUT, url, parameters: nil)
                                .responseJSON { response in
                                    let result = response.result.value
                                    print(result)
                                    if result == nil {
                                        
                                    } else {
                                        let json = JSON(response.result.value!)
                                        print("JSON: \(json)")
                                        let token = json["token"].string
                                        self.keychain.set(token!, forKey: "refresh_token")
                                    }
                            }
                        } else {
                            self.keychain.set(refresh_token!, forKey: "refresh_token")
                        }
                        self.keychain.set(id!, forKey: "ID")
                        self.keychain.set("1", forKey: "ISLOGGEDIN")
                        self.keychain.set(token!, forKey: "JWT")
//                        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//                        prefs.setObject(id, forKey: "ID")
//                        prefs.setInteger(1, forKey: "ISLOGGEDIN")
//                        prefs.synchronize()
                        
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
    
    @IBAction func forgotPasswordButtonPressed(sender: UIButton) {
        let forgotUrl = globalurl + "forgot"
        UIApplication.sharedApplication().openURL(NSURL(string: forgotUrl)!)
    }
    
    

}
