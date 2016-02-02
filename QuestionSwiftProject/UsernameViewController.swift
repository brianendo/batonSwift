//
//  UsernameViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 1/28/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UsernameViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameStatusLabel: UILabel!
    
    
    var email = ""
    var password = ""
    var firstname = ""
    var lastname = ""
    
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
        self.doneButton.enabled = false
        self.usernameTextField.becomeFirstResponder()
        self.usernameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if self.usernameTextField.text!.characters.count > 2  {
            
            let username = self.usernameTextField.text
            
            let usernameLowercase = username!.lowercaseString
            
            let url = globalurl + "api/usernamecheck/" + username!
            
            Alamofire.request(.GET, url, parameters: nil)
                .responseJSON { response in
                    print(response.request)
                    print(response.response)
                    print(response.result)
                    print(response.response?.statusCode)
                    
                    let statuscode = response.response?.statusCode
                    
                    if ( response.response != "FAILURE" ) {
                        
                        if (statuscode >= 200 && statuscode < 300)
                        {
                            print("Username available")
                            self.usernameStatusLabel.text = "Username available"
                            self.doneButton.enabled = true
                        } else if statuscode == 404 {
//                            var alertView:UIAlertView = UIAlertView()
//                            alertView.title = "Sign Up Failed!"
//                            alertView.message = "Username taken"
//                            alertView.delegate = self
//                            alertView.addButtonWithTitle("OK")
//                            alertView.show()
                            self.usernameStatusLabel.text = "Username not available"
                            self.doneButton.enabled = false
                        } else {
//                            var alertView:UIAlertView = UIAlertView()
//                            alertView.title = "Sign Up Failed!"
//                            alertView.message = "Connection Failed"
//                            alertView.delegate = self
//                            alertView.addButtonWithTitle("OK")
//                            alertView.show()
                            self.usernameStatusLabel.text = "Username not available"
                            self.doneButton.enabled = false
                        }
                    }  else {
//                        var alertView:UIAlertView = UIAlertView()
//                        alertView.title = "Sign up Failed!"
//                        alertView.message = "Connection Failure"
//                        alertView.delegate = self
//                        alertView.addButtonWithTitle("OK")
//                        alertView.show()
                        self.usernameStatusLabel.text = "Username not available"
                        self.doneButton.enabled = false
                    }
                    
            }
        } else {
            self.usernameStatusLabel.text = "Username not available"
            self.doneButton.enabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonTapped(sender: UIButton) {
        
        let parameters = [
            "email": email,
            "password": password,
            "firstname": firstname,
            "lastname": lastname,
            "username": usernameTextField.text! as String
        ]
        
        let url = globalurl + "api/signup"
        
        Alamofire.request(.POST, url, parameters: parameters)
            .responseJSON { response in
                print(response.request)
                print(response.response)
                print(response.result)
                print(response.response?.statusCode)
                
                let statuscode = response.response?.statusCode
                
                if ( response.response != "FAILURE" ) {
                    
                    if (statuscode >= 200 && statuscode < 300)
                    {
                        print("Sign up successful")
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
                    } else if statuscode == 404 {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign Up Failed!"
                        alertView.message = "Username taken"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    } else {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign Up Failed!"
                        alertView.message = "Connection Failed"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                }  else {
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign up Failed!"
                    alertView.message = "Connection Failure"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
                
        }
    }
    
    

}
