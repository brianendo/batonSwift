//
//  TwitterSignupViewController.swift
//  Baton
//
//  Created by Brian Endo on 2/3/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AWSS3
import MobileCoreServices
import KeychainSwift
import JWTDecode

class TwitterSignupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

    let keychain = KeychainSwift()
    
    var firstName = ""
    var lastName = ""
    var username = ""
    var twitterId = ""
    var profileImageUrl = ""
    var twitterUsername = ""
    
    var characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyz0123456789_")
    
    var namecharacterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_ ")
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameStatusLabel: UILabel!
    
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
    
    func checkUsername() {
        let username = self.usernameTextField.text
        
        let usernameLowercase = username!.lowercaseString
        
        let url = globalurl + "api/usernamecheck/" + usernameLowercase
        
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
                        self.signUpButton.enabled = true
                    } else if statuscode == 404 {
                        self.usernameStatusLabel.text = "Username not available"
                        self.signUpButton.enabled = false
                    } else {
                        self.usernameStatusLabel.text = "Username not available"
                        self.signUpButton.enabled = false
                    }
                }  else {
                    self.usernameStatusLabel.text = "Username not available"
                    self.signUpButton.enabled = false
                }
                
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstNameTextField.text = firstName
        self.lastNameTextField.text = lastName
        self.usernameTextField.text = username.lowercaseString
        self.checkUsername()
        self.usernameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.firstNameTextField.addTarget(self, action: "firstNameTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.lastNameTextField.addTarget(self, action: "lastNameTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        self.usernameTextField.delegate = self
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        
        
        self.profileImageView.image = UIImage(named: "Placeholder")
        let url = NSURL(string: profileImageUrl)
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        self.profileImageView.image = UIImage(data: data!)
        
        self.profileImageView.frame = CGRectMake(0, 0, 60, 60)
        self.profileImageView.layer.borderWidth = 0.5
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
        self.profileImageView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidChange(textField: UITextField) {
        self.usernameTextField.text = textField.text?.lowercaseString
        if self.usernameTextField.text!.characters.count > 2  {
            
            let username = self.usernameTextField.text!.lowercaseString
            
            if ((username.rangeOfCharacterFromSet(self.characterSet.invertedSet, options: [], range: nil)) != nil) {
                self.usernameStatusLabel.text = "Username cannot contain special characters"
                self.signUpButton.enabled = false
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
                                self.signUpButton.enabled = true
                            } else if statuscode == 404 {
                                self.usernameStatusLabel.text = "Username not available"
                                self.signUpButton.enabled = false
                            } else {
                                self.usernameStatusLabel.text = "Username not available"
                                self.signUpButton.enabled = false
                            }
                        }  else {
                            self.usernameStatusLabel.text = "Username not available"
                            self.signUpButton.enabled = false
                        }
                        
                }
                
            }
            
            
        } else {
            self.usernameStatusLabel.text = "Username must be longer than 2 characters"
            self.signUpButton.enabled = false
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 20
    }
    
    func firstNameTextFieldDidChange(textField: UITextField) {
        
        let firstName = self.firstNameTextField.text!
        
        if ((firstName.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
            self.usernameStatusLabel.text = "Name cannot contain special characters"
            self.signUpButton.enabled = false
        } else {
            self.usernameStatusLabel.text = ""
            self.signUpButton.enabled = true
        }
        
    }
    
    func lastNameTextFieldDidChange(textField: UITextField) {
        
        let lastName = self.lastNameTextField.text!
        
        if ((lastName.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
            self.usernameStatusLabel.text = "Name cannot contain special characters"
            self.signUpButton.enabled = false
        } else {
            self.usernameStatusLabel.text = ""
            self.signUpButton.enabled = true
        }
        
    }
    
    @IBAction func changePictureButtonPressed(sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let libButton = UIAlertAction(title: "Select photo from library", style: UIAlertActionStyle.Default) { (alert) -> Void in
            let photoLibraryController = UIImagePickerController()
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            let mediaTypes:[String] = [kUTTypeImage as String]
            photoLibraryController.mediaTypes = mediaTypes
            photoLibraryController.allowsEditing = true
            
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
        }
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            let cameraButton = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.Default) { (alert) -> Void in
                print("Take Photo", terminator: "")
                let cameraController = UIImagePickerController()
                //if it is then create an instance of UIImagePickerController
                cameraController.delegate = self
                cameraController.sourceType = UIImagePickerControllerSourceType.Camera
                
                let mediaTypes:[String] = [kUTTypeImage as String]
                //pass in the image as data
                
                cameraController.mediaTypes = mediaTypes
                cameraController.allowsEditing = true
                
                self.presentViewController(cameraController, animated: true, completion: nil)
                
            }
            alert.addAction(cameraButton)
        } else {
            print("Camera not available", terminator: "")
            
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            print("Cancel Pressed", terminator: "")
        }
        
        alert.addAction(libButton)
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        let squareImage = RBSquareImage(editedImage)
        let data = UIImageJPEGRepresentation(squareImage, 0.01)
        self.profileImageView.image = UIImage(data: data!)
        
        
        // Save image in S3 with the userID
//        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
//        let testFileURL1 = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp"))
//        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
//        
//        let data = UIImageJPEGRepresentation(squareImage, 0.01)
//        data!.writeToURL(testFileURL1, atomically: true)
//        uploadRequest1.bucket = S3BucketName
//        uploadRequest1.key =  userid
//        uploadRequest1.body = testFileURL1
//        
//        
//        let task = transferManager.upload(uploadRequest1)
//        task.continueWithBlock { (task) -> AnyObject! in
//            if task.error != nil {
//                print("Error: \(task.error)", terminator: "")
//            } else {
//                //                self.download()
//                print("Upload successful", terminator: "")
//            }
//            return nil
//        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    @IBAction func signUpButtonPressed(sender: UIButton) {
        let firstname = self.firstNameTextField.text! as String
        let lastname = self.lastNameTextField.text! as String
        let username = self.usernameTextField.text! as String
        
        let parameters = [
            "firstname": firstname,
            "lastname": lastname,
            "username": username,
            "twitter_id": self.twitterId,
            "twitter_username": self.twitterUsername
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
                        
//                        let id = json["_id"].string
//                        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//                        prefs.setObject(id, forKey: "ID")
//                        prefs.setInteger(1, forKey: "ISLOGGEDIN")
//                        prefs.synchronize()
                        
                        let image = self.profileImageView.image
                        
                        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                        let testFileURL1 = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp"))
                        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
                        
                        let data = UIImageJPEGRepresentation(image!, 0.1)
                        data!.writeToURL(testFileURL1, atomically: true)
                        uploadRequest1.bucket = S3BucketName
                        uploadRequest1.key =  id
                        uploadRequest1.body = testFileURL1
                        
                        
                        let task = transferManager.upload(uploadRequest1)
                        task.continueWithBlock { (task) -> AnyObject! in
                            if task.error != nil {
                                print("Error: \(task.error)", terminator: "")
                            } else {
                                //                self.download()
                                print("Upload successful", terminator: "")
                            }
                            return nil
                        }
                        
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                        let mainVC = storyboard.instantiateInitialViewController()
//                        self.presentViewController(mainVC!, animated: true, completion: nil)
                        
                        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
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
