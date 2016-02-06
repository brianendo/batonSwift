//
//  ChangePasswordViewController.swift
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

class ChangePasswordViewController: UIViewController {

    let keychain = KeychainSwift()
    
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusLabel: UILabel!
    
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
        self.newPasswordTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        
        if self.newPasswordTextField.text!.characters.count > 5  {
            self.statusLabel.text = ""
            self.submitButton.enabled = true
        } else {
            self.statusLabel.text = "Password must be at least 6 characters"
            self.submitButton.enabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.submitButton.enabled = false
        // Do any additional setup after loading the view.
        self.currentPasswordTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exitButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        let password = currentPasswordTextField.text! as String
        let newpassword = newPasswordTextField.text! as String
        
        
        
        var token = self.keychain.get("JWT")
        print(token)
        
        do {
            
            let jwt = try decode(token!)
            print(jwt)
            print(jwt.body)
            print(jwt.expiresAt)
            print(jwt.expired)
            if jwt.expired == true {
                var refresh_token = self.keychain.get("refresh_token")
                
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
                            
                            let url = globalurl + "api/changepassword"
                            
                            let parameters = [
                                "id": userid,
                                "password": password,
                                "newpassword": newpassword
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
                                            print("Password changed")
                                            let alert = UIAlertController(title: "Password Changed", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                                            let cancelButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                                                print("Cancel Pressed", terminator: "")
                                                self.dismissViewControllerAnimated(true, completion: nil)
                                            }
                                            alert.addAction(cancelButton)
                                            self.presentViewController(alert, animated: true, completion: nil)
                                        } else if statuscode == 404 {
                                            var alertView:UIAlertView = UIAlertView()
                                            alertView.title = "Failed!"
                                            alertView.message = "Current password incorrect"
                                            alertView.delegate = self
                                            alertView.addButtonWithTitle("OK")
                                            alertView.show()
                                        } else {
                                            var alertView:UIAlertView = UIAlertView()
                                            alertView.title = "Failed!"
                                            alertView.message = "Connection Failed"
                                            alertView.delegate = self
                                            alertView.addButtonWithTitle("OK")
                                            alertView.show()
                                        }
                                    }  else {
                                        var alertView:UIAlertView = UIAlertView()
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
                
                let url = globalurl + "api/changepassword"
                
                let parameters = [
                    "id": userid,
                    "password": password,
                    "newpassword": newpassword
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
                                print("Password changed")
                                let alert = UIAlertController(title: "Password Changed", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                                let cancelButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                                    print("Cancel Pressed", terminator: "")
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }
                                alert.addAction(cancelButton)
                                self.presentViewController(alert, animated: true, completion: nil)
                            } else if statuscode == 404 {
                                var alertView:UIAlertView = UIAlertView()
                                alertView.title = "Failed!"
                                alertView.message = "Current password incorrect"
                                alertView.delegate = self
                                alertView.addButtonWithTitle("OK")
                                alertView.show()
                            } else {
                                var alertView:UIAlertView = UIAlertView()
                                alertView.title = "Failed!"
                                alertView.message = "Connection Failed"
                                alertView.delegate = self
                                alertView.addButtonWithTitle("OK")
                                alertView.show()
                            }
                        }  else {
                            var alertView:UIAlertView = UIAlertView()
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

        
//        let url = globalurl + "api/changepassword"
//        
//        Alamofire.request(.POST, url, parameters: parameters)
//            .responseJSON { response in
//                print(response.request)
//                print(response.response)
//                print(response.result)
//                print(response.response?.statusCode)
//                
//                let statuscode = response.response?.statusCode
//                
//                if ( response.response != "FAILURE" ) {
//                    
//                    if (statuscode >= 200 && statuscode < 300)
//                    {
//                        print("Password changed")
//                        let alert = UIAlertController(title: "Password Changed", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
//                        let cancelButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
//                            print("Cancel Pressed", terminator: "")
//                            self.dismissViewControllerAnimated(true, completion: nil)
//                        }
//                        alert.addAction(cancelButton)
//                        self.presentViewController(alert, animated: true, completion: nil)
//                    } else if statuscode == 404 {
//                        var alertView:UIAlertView = UIAlertView()
//                        alertView.title = "Failed!"
//                        alertView.message = "Current password incorrect"
//                        alertView.delegate = self
//                        alertView.addButtonWithTitle("OK")
//                        alertView.show()
//                    } else {
//                        var alertView:UIAlertView = UIAlertView()
//                        alertView.title = "Failed!"
//                        alertView.message = "Connection Failed"
//                        alertView.delegate = self
//                        alertView.addButtonWithTitle("OK")
//                        alertView.show()
//                    }
//                }  else {
//                    var alertView:UIAlertView = UIAlertView()
//                    alertView.title = "Failed!"
//                    alertView.message = "Connection Failure"
//                    alertView.delegate = self
//                    alertView.addButtonWithTitle("OK")
//                    alertView.show()
//                }
//                
//        }
    }
    
    

}
