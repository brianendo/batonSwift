//
//  CollegeEmailViewController.swift
//  Baton
//
//  Created by Brian Endo on 3/31/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CollegeEmailViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    var firstName = ""
    var lastName = ""
    var profileImageUrl = ""
    var facebookId = ""
    var email = ""
    var schoolName = ""
    var schoolId = ""
    
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
        
        self.nextButton.hidden = true
        // Do any additional setup after loading the view.
        self.emailTextField.becomeFirstResponder()
        self.emailTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidChange(textField: UITextField) {
        
        let email = self.emailTextField.text!.lowercaseString
        let check = isValidEmail(email)
        
        if check {
            self.nextButton.hidden = false
        } else {
            self.nextButton.hidden = true
        }
        
    }
    
    
    @IBAction func nextButtonPressed(sender: UIButton) {
        let college = self.emailTextField.text!.lowercaseString
        if let collegeString = college.componentsSeparatedByString("@").last {
            print(collegeString)
            let parameters = [
                "emailFormat": collegeString
            ]
            let url = globalurl + "api/checkcollegeemail"
            
            Alamofire.request(.POST, url, parameters: parameters)
                .responseJSON { response in
                    print(response.request)
                    print(response.response)
                    print(response.result)
                    print(response.response?.statusCode)
                    let statuscode = response.response?.statusCode
                    if statuscode == 200 {
                        print("Channel is open")
                        let json = JSON(response.result.value!)
                        print("JSON: \(json)")
                        let id = json["_id"].string
                        let collegeName = json["name"].string
                        print(id)
                        print(collegeName)
                        
                        self.schoolId = id!
                        self.schoolName = collegeName!
                        
                        self.performSegueWithIdentifier("segueFromCollegeEmailToUsername", sender: self)
                    } else if statuscode == 400 {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "Channel is locked"
                        alertView.message = "Invite more of your friends"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    } else if statuscode == 404 {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "No channel exists"
                        alertView.message = "Start it yourself"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    } else {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign in Failed!"
                        alertView.message = "Connection Failed"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
            }

        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromCollegeEmailToUsername" {
            let usernameVC: UsernameViewController = segue.destinationViewController as! UsernameViewController
            usernameVC.firstname = firstName
            usernameVC.lastname = lastName
            usernameVC.profileImageUrl = profileImageUrl
            usernameVC.facebookId = facebookId
            usernameVC.email = email
            usernameVC.fromFB = true
            usernameVC.schoolName = schoolName
            usernameVC.schoolId = schoolId
            usernameVC.collegeEmail = emailTextField.text!.lowercaseString
            usernameVC.type = "college"
        }
    }
    
}
