//
//  EditProfileTableViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 1/29/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import JWTDecode

class EditProfileTableViewController: UITableViewController, UITextFieldDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var usernameStatusLabel: UILabel!
    @IBOutlet weak var twitterTextField: UITextField!
    
    // MARK: - Variables
    let keychain = KeychainSwift()
    var characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyz0123456789_")
    var namecharacterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_ ")
    var bio = ""
    var twitterUsername = ""
    
    // MARK: - viewWill/viewDid
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveBarButton.enabled = false
        self.tableView.allowsSelection = false
        
        // Prefill contents from global variables
        self.usernameTextField.text = myUsername
        self.firstNameTextField.text = myfirstname
        self.lastNameTextField.text = mylastname
        self.bioTextView.text = mybio
        self.twitterTextField.text = twitterUsername
        self.usernameStatusLabel.text = ""
        
        self.usernameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.firstNameTextField.addTarget(self, action: "firstNameTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.lastNameTextField.addTarget(self, action: "lastNameTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.twitterTextField.addTarget(self, action: "twitterTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        self.usernameTextField.delegate = self
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    func firstNameTextFieldDidChange(textField: UITextField) {
        
        let firstName = self.firstNameTextField.text!
        
        if firstName == myfirstname {
            self.usernameStatusLabel.text = ""
            self.saveBarButton.enabled = false
        } else {
            if ((firstName.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
                self.usernameStatusLabel.text = "Name cannot contain special characters"
                self.saveBarButton.enabled = false
            } else {
                self.usernameStatusLabel.text = ""
                self.saveBarButton.enabled = true
            }
        }
    }
    
    func twitterTextFieldDidChange(textField: UITextField) {
        
        let twitter = self.firstNameTextField.text!
        
        if twitter == twitterUsername {
            self.usernameStatusLabel.text = ""
            self.saveBarButton.enabled = false
        } else {
            if ((twitter.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
                self.usernameStatusLabel.text = "Name cannot contain special characters"
                self.saveBarButton.enabled = false
            } else {
                self.usernameStatusLabel.text = ""
                self.saveBarButton.enabled = true
            }
        }
    }
    
    func lastNameTextFieldDidChange(textField: UITextField) {
        
        let lastName = self.lastNameTextField.text!
        
        if lastName == mylastname {
            self.usernameStatusLabel.text = ""
            self.saveBarButton.enabled = false
        } else {
            if ((lastName.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
                self.usernameStatusLabel.text = "Name cannot contain special characters"
                self.saveBarButton.enabled = false
            } else {
                self.usernameStatusLabel.text = ""
                self.saveBarButton.enabled = true
            }
        }
    }

    func textFieldDidChange(textField: UITextField) {
        self.usernameTextField.text = textField.text?.lowercaseString
        
        if self.usernameTextField.text!.characters.count > 2  {
            
            let username = self.usernameTextField.text!.lowercaseString
            
            if username == myUsername {
                self.usernameStatusLabel.text = ""
                self.saveBarButton.enabled = false
            } else {
                if ((username.rangeOfCharacterFromSet(self.characterSet.invertedSet, options: [], range: nil)) != nil) {
                    self.usernameStatusLabel.text = "Username cannot contain special characters"
                    self.saveBarButton.enabled = false
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
                                    self.saveBarButton.enabled = true
                                } else if statuscode == 404 {
                                    self.usernameStatusLabel.text = "Username not available"
                                    self.saveBarButton.enabled = false
                                } else {
                                    self.usernameStatusLabel.text = "Username not available"
                                    self.saveBarButton.enabled = false
                                }
                            }  else {
                                self.usernameStatusLabel.text = "Username not available"
                                self.saveBarButton.enabled = false
                            }
                            
                    }
                }
                
                

            }
            
        } else {
            self.usernameStatusLabel.text = "Username must be longer than 2 characters"
            self.saveBarButton.enabled = false
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func exitBarButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        let username = usernameTextField.text! as String
        let firstname = firstNameTextField.text! as String
        let lastname = lastNameTextField.text! as String
        let bio = bioTextView.text! as String
        let twitter = twitterTextField.text! as String
        
        // Check if any of the textField have changed
        if (myUsername != username) || (mylastname != lastname) || (myfirstname != firstname) || (mybio != bio) || (twitterUsername != twitter) {
            print("Changed")
            
            mybio = bio
            myUsername = username
            mylastname = lastname
            myfirstname = firstname
            
            var token = self.keychain.get("JWT")
            do {
                
                let jwt = try decode(token!)
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
                                
                                let parameters = [
                                    "id": userid,
                                    "username": username,
                                    "firstname": firstname,
                                    "lastname": lastname,
                                    "bio": bio,
                                    "twitter_username": twitter
                                ]
                                
                                let url = globalurl + "api/edituser"
                                Alamofire.request(.POST, url, parameters: parameters, headers: headers)
                                    .responseJSON { response in
                                        print(response.request)
                                        print(response.response)
                                        print(response.result)
                                        print(response.response?.statusCode)
                                }
                            }
                            
                            
                    }
                } else {
                    let headers = [
                        "Authorization": "\(token!)"
                    ]
                    
                    let parameters = [
                        "id": userid,
                        "username": username,
                        "firstname": firstname,
                        "lastname": lastname,
                        "bio": bio,
                        "twitter_username": twitter
                    ]
                    
                    let url = globalurl + "api/edituser"
                    Alamofire.request(.POST, url, parameters: parameters, headers: headers)
                        .responseJSON { response in
                            print(response.request)
                            print(response.response)
                            print(response.result)
                            print(response.response?.statusCode)
                    }
                }
            } catch {
                print("Failed to decode JWT: \(error)")
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    


}
