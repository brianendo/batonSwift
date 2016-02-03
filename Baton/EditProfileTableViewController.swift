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

class EditProfileTableViewController: UITableViewController {

    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var usernameStatusLabel: UILabel!
    
    var bio = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.allowsSelection = false
        self.usernameTextField.text = myUsername
        self.firstNameTextField.text = myfirstname
        self.lastNameTextField.text = mylastname
        self.bioTextView.text = mybio
        self.usernameStatusLabel.text = ""
        self.usernameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldDidChange(textField: UITextField) {
        if self.usernameTextField.text!.characters.count > 2  {
            
            let username = self.usernameTextField.text
            
            let usernameLowercase = username!.lowercaseString
            
            if usernameLowercase == myUsername {
                self.usernameStatusLabel.text = ""
                self.saveBarButton.enabled = true
            } else {
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
            
        } else {
            self.usernameStatusLabel.text = "Username not available"
            self.saveBarButton.enabled = false
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    @IBAction func exitBarButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        let username = usernameTextField.text! as String
        let firstname = firstNameTextField.text! as String
        let lastname = lastNameTextField.text! as String
        let bio = bioTextView.text! as String
        
        if (myUsername != username) || (mylastname != lastname) || (myfirstname != firstname) || (mybio != bio) {
            print("Changed")
            let url = globalurl + "api/edituser"
            let parameters = [
                "id": userid,
                "username": username,
                "firstname": firstname,
                "lastname": lastname,
                "bio": bio
            ]
            
            mybio = bio
            myUsername = username
            mylastname = lastname
            myfirstname = firstname
            
            Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON)
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    


}
