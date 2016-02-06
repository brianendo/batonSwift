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
import KeychainSwift
import JWTDecode

class UsernameViewController: UIViewController, UITextFieldDelegate {

    let keychain = KeychainSwift()
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameStatusLabel: UILabel!
    
    
    var email = ""
    var password = ""
    var firstname = ""
    var lastname = ""
    
    var characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyz0123456789_")
    
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
        self.usernameTextField.delegate = self
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 20
    }
    
    func textFieldDidChange(textField: UITextField) {
        self.usernameTextField.text = textField.text?.lowercaseString
        if self.usernameTextField.text!.characters.count > 2  {
            
            let username = self.usernameTextField.text!.lowercaseString
            
            if ((username.rangeOfCharacterFromSet(self.characterSet.invertedSet, options: [], range: nil)) != nil) {
                self.usernameStatusLabel.text = "Username cannot contain special characters"
                self.doneButton.enabled = false
            } else {
                
                let url = globalurl + "api/usernamecheck/" + username
                
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
                                self.usernameStatusLabel.text = "Username not available"
                                self.doneButton.enabled = false
                            } else {
                                self.usernameStatusLabel.text = "Username not available"
                                self.doneButton.enabled = false
                            }
                        }  else {
                            self.usernameStatusLabel.text = "Username not available"
                            self.doneButton.enabled = false
                        }
                        
                }

            }
            
            
        } else {
            self.usernameStatusLabel.text = "Username must be longer than 2 characters"
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
                        print(json["data"]["_id"].string)
                        print(json["token"].string)
                        let id = json["data"]["_id"].string
                        let refresh_token = json["data"]["token"].string
                        let token = json["token"].string
                        do {
                            let jwt = try decode(token!)
                            print(jwt)
                            print(jwt.body)
                            print(jwt.expiresAt)
                        } catch {
                            print("Failed to decode JWT: \(error)")
                        }
                        self.keychain.set(id!, forKey: "ID")
                        self.keychain.set("1", forKey: "ISLOGGEDIN")
                        self.keychain.set(token!, forKey: "JWT")
                        self.keychain.set(refresh_token!, forKey: "refresh_token")
//                        let id = json["_id"].string
//                        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//                        prefs.setObject(id, forKey: "ID")
//                        prefs.setInteger(1, forKey: "ISLOGGEDIN")
//                        prefs.synchronize()
                        
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
