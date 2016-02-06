//
//  SignUpViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 10/29/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
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
        self.signUpButton.enabled = false
        // Do any additional setup after loading the view.
        self.emailTextField.addTarget(self, action: "emailTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.passwordTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func emailTextFieldDidChange(textField: UITextField) {
        
        let email = self.emailTextField.text!
        let check = isValidEmail(email)
        
        if check {
            self.signUpButton.enabled = true
        } else {
            self.signUpButton.enabled = false
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        
        if self.passwordTextField.text!.characters.count > 5  {
            self.statusLabel.text = ""
            self.signUpButton.enabled = true
        } else {
            self.statusLabel.text = "Password must be at least 6 characters"
            self.signUpButton.enabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromSignUpToName" {
            let nameVC: NameViewController = segue.destinationViewController as! NameViewController
            nameVC.email = emailTextField.text! as String
            nameVC.password = passwordTextField.text! as String
        }
    }
    
    @IBAction func signUpButtonPressed(sender: UIButton) {
        let email = emailTextField.text! as String
        let password = passwordTextField.text! as String
        
        if ( email == "" || password == "" ) {
            
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "Please enter Username and Password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
//        } else if ( !password.isEqual(confirm_password) ) {
//            
//            var alertView:UIAlertView = UIAlertView()
//            alertView.title = "Sign Up Failed!"
//            alertView.message = "Passwords doesn't Match"
//            alertView.delegate = self
//            alertView.addButtonWithTitle("OK")
//            alertView.show()
//        } else {
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
                            var alertView:UIAlertView = UIAlertView()
                            alertView.title = "Sign Up Failed!"
                            alertView.message = "Email taken"
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

        
        
//        ref.createUser(emailTextField.text, password: passwordTextField.text,
//            withValueCompletionBlock: { error, result in
//                if error != nil {
//                    // There was an error creating the account
//                } else {
//                    let uid = result["uid"] as? String
//                    print("Successfully created user account with uid: \(uid)")
//                    
//                    ref.authUser(self.emailTextField.text, password: self.passwordTextField.text,
//                        withCompletionBlock: { error, authData in
//                            if error != nil {
//                                // There was an error logging in to this account
//                            } else {
//                                // We are now logged in
//                                
//                                let newUser = [
//                                    "firstname": self.firstNameTextField.text!,
//                                    "lastname": self.lastNameTextField.text!
//                                ]
//                                
//                                ref.childByAppendingPath("users").childByAppendingPath(authData.uid).setValue(newUser)
//                                
//                                let url = globalurl + "api/users"
//                                
//                                let parameters = [
//                                    "firstname": self.firstNameTextField.text!,
//                                    "lastname": self.lastNameTextField.text!,
//                                    "firebase_id": authData.uid,
//                                    "email": self.emailTextField.text!,
//                                    "username": self.firstNameTextField.text! + self.lastNameTextField.text!
//                                ]
//                                
//                                Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON)
//                                
//                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                                let mainVC = storyboard.instantiateInitialViewController()
//                                self.presentViewController(mainVC!, animated: true, completion: nil)
//                            }
//                    })
//                    
//                }
//        })

}

func isValidEmail(testStr:String) -> Bool {
    // println("validate calendar: \(testStr)")
    let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluateWithObject(testStr)
}
