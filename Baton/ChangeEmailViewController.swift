//
//  ChangeEmailViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 2/1/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import JWTDecode

class ChangeEmailViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Variables
    let keychain = KeychainSwift()
    
    // MARK: - Keyboard
    func registerForKeyboardNotifications ()-> Void   {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.bottomLayoutConstraint.constant = keyboardFrame.size.height
    }
    
    // MARK: - viewDid/viewWill
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.registerForKeyboardNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.saveButton.enabled = false
        self.emailTextField.text = myemail
        self.emailTextField.becomeFirstResponder()
        
        self.emailTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    // MARK: - functions
    func textFieldDidChange(textField: UITextField) {
        if textField.text?.lowercaseString == myemail {
            self.saveButton.enabled = false
        } else {
            let email = self.emailTextField.text!.lowercaseString
            let check = isValidEmail(email)
            
            if check {
                self.saveButton.enabled = true
            } else {
                self.saveButton.enabled = false
            }
        }
        
    }

    // MARK: - IBActions
    @IBAction func exitButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        let email = emailTextField.text!.lowercaseString as String
        
        var token = keychain.get("JWT")
        do {
            
            let jwt = try decode(token!)
            if jwt.expired == true {
                var refresh_token = keychain.get("refresh_token")
                
                if refresh_token == nil {
                    refresh_token = ""
                }
                
                let url = globalurl + "api/changetoken/"
                
                let parameters = [
                    "refresh_token": refresh_token! as String
                ]
                
                Alamofire.request(.POST, url, parameters: parameters)
                    .responseJSON { response in
                        var value = response.result.value
                        
                        if value == nil {
                            value = []
                        } else {
                            let json = JSON(value!)
                            print("JSON: \(json)")
                            print(json["token"].string)
                            let newtoken = json["token"].string
                            self.keychain.set(newtoken!, forKey: "JWT")
                            token = newtoken
                            
                            let headers = [
                                "Authorization": "\(token!)"
                            ]
                            
                            let url = globalurl + "api/changeemail"
                            
                            let parameters = [
                                "id": userid,
                                "email": email
                            ]
                            
                            Alamofire.request(.POST, url, parameters: parameters, headers: headers)
                                .responseJSON { response in
                                    print(response.request)
                                    print(response.response)
                                    print(response.result)
                                    print(response.response?.statusCode)
                                    
                                    let statuscode = response.response?.statusCode
                                    
                                    if ( response.response != "FAILURE" ) {
                                        
                                        if (statuscode >= 200 && statuscode < 300)
                                        {
                                            print("Email changed")
                                            myemail = email
                                            let alert = UIAlertController(title: "Email Changed", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                                            let cancelButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                                                print("Cancel Pressed", terminator: "")
                                                self.dismissViewControllerAnimated(true, completion: nil)
                                            }
                                            alert.addAction(cancelButton)
                                            self.presentViewController(alert, animated: true, completion: nil)
                                        } else if statuscode == 404 {
                                            let alertView:UIAlertView = UIAlertView()
                                            alertView.title = "Failed!"
                                            alertView.message = "Current email taken"
                                            alertView.delegate = self
                                            alertView.addButtonWithTitle("OK")
                                            alertView.show()
                                        } else {
                                            let alertView:UIAlertView = UIAlertView()
                                            alertView.title = "Failed!"
                                            alertView.message = "Connection Failed"
                                            alertView.delegate = self
                                            alertView.addButtonWithTitle("OK")
                                            alertView.show()
                                        }
                                    }  else {
                                        let alertView:UIAlertView = UIAlertView()
                                        alertView.title = "Failed!"
                                        alertView.message = "Connection Failure"
                                        alertView.delegate = self
                                        alertView.addButtonWithTitle("OK")
                                        alertView.show()
                                    }
                                    
                            }

                        }
                        
                        
                }
            } else {
                let headers = [
                    "Authorization": "\(token!)"
                ]
                
                let url = globalurl + "api/changeemail"
                
                let parameters = [
                    "id": userid,
                    "email": email
                ]
                
                Alamofire.request(.POST, url, parameters: parameters, headers: headers)
                    .responseJSON { response in
                        print(response.request)
                        print(response.response)
                        print(response.result)
                        print(response.response?.statusCode)
                        
                        let statuscode = response.response?.statusCode
                        
                        if ( response.response != "FAILURE" ) {
                            
                            if (statuscode >= 200 && statuscode < 300)
                            {
                                print("Email changed")
                                myemail = email
                                let alert = UIAlertController(title: "Email Changed", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                                let cancelButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                                    print("Cancel Pressed", terminator: "")
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }
                                alert.addAction(cancelButton)
                                self.presentViewController(alert, animated: true, completion: nil)
                            } else if statuscode == 404 {
                                let alertView:UIAlertView = UIAlertView()
                                alertView.title = "Failed!"
                                alertView.message = "Current email taken"
                                alertView.delegate = self
                                alertView.addButtonWithTitle("OK")
                                alertView.show()
                            } else {
                                let alertView:UIAlertView = UIAlertView()
                                alertView.title = "Failed!"
                                alertView.message = "Connection Failed"
                                alertView.delegate = self
                                alertView.addButtonWithTitle("OK")
                                alertView.show()
                            }
                        }  else {
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Failed!"
                            alertView.message = "Connection Failure"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        }
                        
                }

            }
        } catch {
            print("Failed to decode JWT: \(error)")
        }
        
    }
    

}
