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
import Crashlytics
import AWSS3

class UsernameViewController: UIViewController, UITextFieldDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameStatusLabel: UILabel!
    
    // MARK: - Variables
    let keychain = KeychainSwift()
    var email = ""
    var password = ""
    var firstname = ""
    var lastname = ""
    var facebookId = ""
    var profileImageUrl = ""
    var fromFB = false
    var type = ""
    var schoolName = ""
    var schoolId = ""
    var characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyz0123456789_")
    
    // MARK: - Keyboard
    func registerForKeyboardNotifications ()-> Void   {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.bottomLayoutConstraint.constant = keyboardFrame.size.height
    }
    
    
    // MARK: - viewWill/viewDid
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.registerForKeyboardNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.doneButton.hidden = true
        self.usernameTextField.becomeFirstResponder()
        // Add function and delegate to textField
        self.usernameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.usernameTextField.delegate = self
    }
    
    // MARK: - textField delegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 20
    }
    
    // MARK: textField functions
    func textFieldDidChange(textField: UITextField) {
        // Makes textField automatically lowercase
        self.usernameTextField.text = textField.text?.lowercaseString
        if self.usernameTextField.text!.characters.count > 2  {
            
            let username = self.usernameTextField.text!.lowercaseString
            
            if ((username.rangeOfCharacterFromSet(self.characterSet.invertedSet, options: [], range: nil)) != nil) {
                self.usernameStatusLabel.text = "Username cannot contain special characters"
                self.doneButton.hidden = true
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
                                self.doneButton.hidden = false
                            } else if statuscode == 404 {
                                self.usernameStatusLabel.text = "Username not available"
                                self.doneButton.hidden = true
                            } else {
                                self.usernameStatusLabel.text = "Username not available"
                                self.doneButton.hidden = true
                            }
                        }  else {
                            self.usernameStatusLabel.text = "Username not available"
                            self.doneButton.hidden = true
                        }
                        
                }

            }
            
            
        } else {
            self.usernameStatusLabel.text = "Username must be longer than 2 characters"
            self.doneButton.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonTapped(sender: UIButton) {
        
        if fromFB {
            if type == "high school" {
                let parameters = [
                    "email": email,
                    "password": password,
                    "firstname": firstname,
                    "lastname": lastname,
                    "username": usernameTextField.text! as String,
                    "facebookId": facebookId,
                    "highSchoolId": schoolId,
                    "highSchoolName": schoolName,
                    "currentSchoolId": schoolId,
                    "currentSchoolName": schoolName
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
                            
                            // Username is available
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
                                
                                self.keychain.set(id!, forKey: "ID")
                                self.keychain.set("1", forKey: "ISLOGGEDIN")
                                self.keychain.set(token!, forKey: "JWT")
                                self.keychain.set(refresh_token!, forKey: "refresh_token")
                                userid = id!
                                
                                
                                // Get image from profileImageView and upload to S3
                                let url = NSURL(string: self.profileImageUrl)
                                let imageData = NSData(contentsOfURL: url!)
                                let image = UIImage(data: imageData!)
                                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                                let testFileURL1 = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp"))
                                let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
                                let data = UIImageJPEGRepresentation(image!, 0.1)
                                data!.writeToURL(testFileURL1, atomically: true)
                                
                                let key = "profilePics/" + id!
                                uploadRequest1.bucket = S3BucketName
                                uploadRequest1.key =  key
                                uploadRequest1.body = testFileURL1
                                let task = transferManager.upload(uploadRequest1)
                                task.continueWithBlock { (task) -> AnyObject! in
                                    if task.error != nil {
                                        print("Error: \(task.error)", terminator: "")
                                    } else {
                                        print("Upload successful", terminator: "")
                                    }
                                    return nil
                                }
                                
                                Answers.logSignUpWithMethod("Regular",
                                    success: true,
                                    customAttributes: [:])
                                
                                // Go to onboarding storyboard
                                let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
                                let mainVC = storyboard.instantiateInitialViewController()
                                self.presentViewController(mainVC!, animated: true, completion: nil)
                            } else if statuscode == 404 {
                                let alertView:UIAlertView = UIAlertView()
                                alertView.title = "Sign Up Failed!"
                                alertView.message = "Username taken"
                                alertView.delegate = self
                                alertView.addButtonWithTitle("OK")
                                alertView.show()
                            } else {
                                let alertView:UIAlertView = UIAlertView()
                                alertView.title = "Sign Up Failed!"
                                alertView.message = "Connection Failed"
                                alertView.delegate = self
                                alertView.addButtonWithTitle("OK")
                                alertView.show()
                            }
                        }  else {
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Sign up Failed!"
                            alertView.message = "Connection Failure"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        }
                        
                }
                
            } else {
                let parameters = [
                    "email": email,
                    "password": password,
                    "firstname": firstname,
                    "lastname": lastname,
                    "username": usernameTextField.text! as String,
                    "facebookId": facebookId,
                    "collegeId": schoolId,
                    "collegeName": schoolName,
                    "currentSchoolId": schoolId,
                    "currentSchoolName": schoolName
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
                            
                            // Username is available
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
                                
                                self.keychain.set(id!, forKey: "ID")
                                self.keychain.set("1", forKey: "ISLOGGEDIN")
                                self.keychain.set(token!, forKey: "JWT")
                                self.keychain.set(refresh_token!, forKey: "refresh_token")
                                userid = id!
                                
                                // Get image from profileImageView and upload to S3
                                let url = NSURL(string: self.profileImageUrl)
                                let imageData = NSData(contentsOfURL: url!)
                                let image = UIImage(data: imageData!)
                                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                                let testFileURL1 = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp"))
                                let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
                                let data = UIImageJPEGRepresentation(image!, 0.1)
                                data!.writeToURL(testFileURL1, atomically: true)
                                
                                let key = "profilePics/" + id!
                                uploadRequest1.bucket = S3BucketName
                                uploadRequest1.key =  key
                                uploadRequest1.body = testFileURL1
                                let task = transferManager.upload(uploadRequest1)
                                task.continueWithBlock { (task) -> AnyObject! in
                                    if task.error != nil {
                                        print("Error: \(task.error)", terminator: "")
                                    } else {
                                        print("Upload successful", terminator: "")
                                    }
                                    return nil
                                }
                                
                                Answers.logSignUpWithMethod("Regular",
                                    success: true,
                                    customAttributes: [:])
                                
                                // Go to onboarding storyboard
                                let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
                                let mainVC = storyboard.instantiateInitialViewController()
                                self.presentViewController(mainVC!, animated: true, completion: nil)
                            } else if statuscode == 404 {
                                let alertView:UIAlertView = UIAlertView()
                                alertView.title = "Sign Up Failed!"
                                alertView.message = "Username taken"
                                alertView.delegate = self
                                alertView.addButtonWithTitle("OK")
                                alertView.show()
                            } else {
                                let alertView:UIAlertView = UIAlertView()
                                alertView.title = "Sign Up Failed!"
                                alertView.message = "Connection Failed"
                                alertView.delegate = self
                                alertView.addButtonWithTitle("OK")
                                alertView.show()
                            }
                        }  else {
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Sign up Failed!"
                            alertView.message = "Connection Failure"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        }
                        
                }
            }
            
            
        } else {
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
                        
                        // Username is available
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
                            
                            self.keychain.set(id!, forKey: "ID")
                            self.keychain.set("1", forKey: "ISLOGGEDIN")
                            self.keychain.set(token!, forKey: "JWT")
                            self.keychain.set(refresh_token!, forKey: "refresh_token")
                            userid = id!
                            
                            Answers.logSignUpWithMethod("Regular",
                                success: true,
                                customAttributes: [:])
                            
                            // Go to onboarding storyboard
                            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
                            let mainVC = storyboard.instantiateInitialViewController()
                            self.presentViewController(mainVC!, animated: true, completion: nil)
                        } else if statuscode == 404 {
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Sign Up Failed!"
                            alertView.message = "Username taken"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        } else {
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Sign Up Failed!"
                            alertView.message = "Connection Failed"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        }
                    }  else {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign up Failed!"
                        alertView.message = "Connection Failure"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                    
            }
        }
        
        
    }
    
    

}
