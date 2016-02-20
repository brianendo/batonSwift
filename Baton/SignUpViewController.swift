//
//  SignUpViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 10/29/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire

class SignUpViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
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
        
        self.signUpButton.hidden = true
        
        // Add functions to textFields
        self.emailTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.passwordTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - textField functions
//    func emailTextFieldDidChange(textField: UITextField) {
//        let email = self.emailTextField.text!.lowercaseString
//        let check = isValidEmail(email)
//        
//        if check {
//            self.signUpButton.hidden = false
//        } else {
//            self.signUpButton.hidden = true
//        }
//    }
    
    func textFieldDidChange(textField: UITextField) {
        
        let email = self.emailTextField.text!.lowercaseString
        let check = isValidEmail(email)
        
        if check {
            if self.passwordTextField.text!.characters.count > 5  {
                self.statusLabel.text = ""
                self.signUpButton.hidden = false
            } else {
                self.statusLabel.text = "Password must be at least 6 characters"
                self.signUpButton.hidden = true
            }
        } else {
            self.signUpButton.hidden = true
        }
        
    }
    
    // Should add checks to make sure password does not contain bad characters
//    func passwordTextFieldDidChange(textField: UITextField) {
//        
//        if self.passwordTextField.text!.characters.count > 5  {
//            self.statusLabel.text = ""
//            self.signUpButton.hidden = false
//        } else {
//            self.statusLabel.text = "Password must be at least 6 characters"
//            self.signUpButton.hidden = true
//        }
//    }

    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromSignUpToName" {
            let nameVC: NameViewController = segue.destinationViewController as! NameViewController
            nameVC.email = emailTextField.text! as String
            nameVC.password = passwordTextField.text! as String
        }
    }
    
    // MARK: - IBAction
    @IBAction func signUpButtonPressed(sender: UIButton) {
        let email = emailTextField.text!.lowercaseString as String
        let password = passwordTextField.text! as String
        
        if ( email == "" || password == "" ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "Please enter Username and Password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
            let parameters = [
                "email": email,
                "password": password
            ]
            let url = globalurl + "api/checkemail"
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
                            print("Email available")
                            self.performSegueWithIdentifier("segueFromSignUpToName", sender: self)
                        } else if statuscode == 404 {
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Sign Up Failed!"
                            alertView.message = "Email taken"
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

// Check if the email has valid formatting, not 100% accurate
func isValidEmail(testStr:String) -> Bool {
    // println("validate calendar: \(testStr)")
    let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluateWithObject(testStr)
}
