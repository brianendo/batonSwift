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
import Crashlytics

class TwitterSignupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

    // MARK: - Variables
    let keychain = KeychainSwift()
    var firstName = ""
    var lastName = ""
    var username = ""
    var twitterId = ""
    var profileImageUrl = ""
    var twitterUsername = ""
    var characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyz0123456789_")
    var namecharacterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_-' ")
    
    // MARK: - IBOutlet
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameStatusLabel: UILabel!
    
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
        // Add textField functions to textFields
        self.firstNameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.lastNameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.usernameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        // Add textField delegate to access delegate functions
        self.usernameTextField.delegate = self
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        
        
        // Fill text field with Twitter information
        self.firstNameTextField.text = firstName
        self.lastNameTextField.text = lastName
        self.usernameTextField.text = username.lowercaseString
        self.profileImageView.image = UIImage(named: "Placeholder")
        if profileImageUrl == "" {
            
        } else {
            let url = NSURL(string: profileImageUrl)
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            self.profileImageView.image = UIImage(data: data!)
        }
        
        self.profileImageView.layer.borderWidth = 0.5
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
        self.profileImageView.clipsToBounds = true
        
        // Check if the username is valid
        self.checkUsername()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - textField delegate
    
    // Checks if characters in textField change
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        
        // textField text cannot be longer than 20 characters
        return newLength <= 20
    }
    
    // MARK: textField functions
    func textFieldDidChange(textField: UITextField) {
        let lastName = self.lastNameTextField.text!
        let firstName = self.firstNameTextField.text!
        self.usernameTextField.text = self.usernameTextField.text?.lowercaseString
        
        // Checks if the firstName has characters not in the nameCharacterSet
        if ((firstName.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
            self.usernameStatusLabel.text = "First Name cannot contain special characters"
            self.signUpButton.hidden = true
        } else if ((lastName.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
            self.usernameStatusLabel.text = "Last Name cannot contain special characters"
            self.signUpButton.hidden = true
        } else {
            // Makes usernameText automatically lowercase
            
            if self.usernameTextField.text!.characters.count > 2  {
                
                let username = self.usernameTextField.text!.lowercaseString
                
                // Checks if the username has characters not in the characterSet
                if ((username.rangeOfCharacterFromSet(self.characterSet.invertedSet, options: [], range: nil)) != nil) {
                    self.usernameStatusLabel.text = "Username cannot contain special characters"
                    self.signUpButton.hidden = true
                } else {
                    
                    // Access the usernamecheck route
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
                                    self.signUpButton.hidden = false
                                } else if statuscode == 404 {
                                    self.usernameStatusLabel.text = "Username not available"
                                    self.signUpButton.hidden = true
                                } else {
                                    self.usernameStatusLabel.text = "Username not available"
                                    self.signUpButton.hidden = true
                                }
                            }  else {
                                self.usernameStatusLabel.text = "Username not available"
                                self.signUpButton.hidden = true
                            }
                            
                    }
                    
                }
                
                
            } else {
                self.usernameStatusLabel.text = "Username must be longer than 2 characters"
                self.signUpButton.hidden = true
            }
        }
        
        
//        // Makes usernameText automatically lowercase
//        self.usernameTextField.text = textField.text?.lowercaseString
//        if self.usernameTextField.text!.characters.count > 2  {
//            
//            let username = self.usernameTextField.text!.lowercaseString
//            
//            // Checks if the username has characters not in the characterSet
//            if ((username.rangeOfCharacterFromSet(self.characterSet.invertedSet, options: [], range: nil)) != nil) {
//                self.usernameStatusLabel.text = "Username cannot contain special characters"
//                self.signUpButton.hidden = true
//            } else {
//                
//                // Access the usernamecheck route
//                let url = globalurl + "api/usernamecheck/" + username
//                Alamofire.request(.GET, url, parameters: nil)
//                    .responseJSON { response in
//                        print(response.request)
//                        print(response.response)
//                        print(response.result)
//                        print(response.response?.statusCode)
//                        
//                        let statuscode = response.response?.statusCode
//                        
//                        if ( response.response != "FAILURE" ) {
//                            
//                            if (statuscode >= 200 && statuscode < 300)
//                            {
//                                print("Username available")
//                                self.usernameStatusLabel.text = "Username available"
//                                self.signUpButton.hidden = false
//                            } else if statuscode == 404 {
//                                self.usernameStatusLabel.text = "Username not available"
//                                self.signUpButton.hidden = true
//                            } else {
//                                self.usernameStatusLabel.text = "Username not available"
//                                self.signUpButton.hidden = true
//                            }
//                        }  else {
//                            self.usernameStatusLabel.text = "Username not available"
//                            self.signUpButton.hidden = true
//                        }
//                        
//                }
//                
//            }
//            
//            
//        } else {
//            self.usernameStatusLabel.text = "Username must be longer than 2 characters"
//            self.signUpButton.hidden = true
//        }
    }
    
    
    
    func firstNameTextFieldDidChange(textField: UITextField) {
        
        let firstName = self.firstNameTextField.text!
        
        // Checks if the firstName has characters not in the nameCharacterSet
        if ((firstName.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
            self.usernameStatusLabel.text = "Name cannot contain special characters"
            self.signUpButton.hidden = true
        } else {
            self.usernameStatusLabel.text = ""
            self.signUpButton.hidden = false
        }
        
    }
    
    func lastNameTextFieldDidChange(textField: UITextField) {
        
        let lastName = self.lastNameTextField.text!
        
        // Checks if the lastName has characters not in the nameCharacterSet
        if ((lastName.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
            self.usernameStatusLabel.text = "Name cannot contain special characters"
            self.signUpButton.hidden = true
        } else {
            self.usernameStatusLabel.text = ""
            self.signUpButton.hidden = false
        }
        
    }
    
    
    func checkUsername() {
        
        let firstName = self.firstNameTextField.text!
        let lastName = self.lastNameTextField.text!
        self.usernameTextField.text = self.usernameTextField.text?.lowercaseString
        let username = self.usernameTextField.text
        let usernameLowercase = username!.lowercaseString
        
        // Checks if the firstName has characters not in the nameCharacterSet
        if ((firstName.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
            self.usernameStatusLabel.text = "First Name cannot contain special characters"
            self.signUpButton.hidden = true
        } else if ((lastName.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
            self.usernameStatusLabel.text = "Last Name cannot contain special characters"
            self.signUpButton.hidden = true
        } else {
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
                            self.signUpButton.hidden = false
                        } else if statuscode == 404 {
                            self.usernameStatusLabel.text = "Username not available"
                            self.signUpButton.hidden = true
                        } else {
                            self.usernameStatusLabel.text = "Username not available"
                            self.signUpButton.hidden = true
                        }
                    }  else {
                        self.usernameStatusLabel.text = "Username not available"
                        self.signUpButton.hidden = true
                    }
                    
            }
        }
        
    }
    
    // MARK: - IBAction
    @IBAction func signUpButtonPressed(sender: UIButton) {
        let firstname = self.firstNameTextField.text! as String
        let lastname = self.lastNameTextField.text! as String
        let username = self.usernameTextField.text!.lowercaseString as String
        
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
                    
                    // Username is available
                    if (statuscode >= 200 && statuscode < 300)
                    {
                        print("Sign up successful")
                        let json = JSON(response.result.value!)
                        print("JSON: \(json)")
                        print(json["data"]["_id"].string)
                        print(json["token"].string)
                        let id = json["data"]["_id"].string
                        let token = json["token"].string
                        let refresh_token = json["data"]["token"].string
                        
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
                                        // Set refresh token in keychain
                                        self.keychain.set(token!, forKey: "refresh_token")
                                    }
                            }
                        } else {
                            // Set refresh token in keychain
                            self.keychain.set(refresh_token!, forKey: "refresh_token")
                        }
                        
                        self.keychain.set(id!, forKey: "ID")
                        self.keychain.set("1", forKey: "ISLOGGEDIN")
                        self.keychain.set(token!, forKey: "JWT")
                        
                        // Get image from profileImageView and upload to S3
                        let image = self.profileImageView.image
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
                        
                        Answers.logSignUpWithMethod("Twitter",
                            success: true,
                            customAttributes: [:])
                        
                        // Go to onboarding Storyboard
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
    
    // Change profilePicture by clicking clear button
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
    
    // MARK: - imagePickerController delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        // Grab the edited version of the image
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        let squareImage = RBSquareImage(editedImage)
        
        // Reduce the size of image
        let data = UIImageJPEGRepresentation(squareImage, 0.01)
        self.profileImageView.image = UIImage(data: data!)
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    

}
