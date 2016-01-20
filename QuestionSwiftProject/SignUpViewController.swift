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
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpButtonPressed(sender: UIButton) {
        ref.createUser(emailTextField.text, password: passwordTextField.text,
            withValueCompletionBlock: { error, result in
                if error != nil {
                    // There was an error creating the account
                } else {
                    let uid = result["uid"] as? String
                    print("Successfully created user account with uid: \(uid)")
                    
                    ref.authUser(self.emailTextField.text, password: self.passwordTextField.text,
                        withCompletionBlock: { error, authData in
                            if error != nil {
                                // There was an error logging in to this account
                            } else {
                                // We are now logged in
                                
                                let newUser = [
                                    "firstname": self.firstNameTextField.text!,
                                    "lastname": self.lastNameTextField.text!
                                ]
                                
                                ref.childByAppendingPath("users").childByAppendingPath(authData.uid).setValue(newUser)
                                
                                let url = globalurl + "api/users"
                                
                                let parameters = [
                                    "firstname": self.firstNameTextField.text!,
                                    "lastname": self.lastNameTextField.text!,
                                    "firebase_id": authData.uid,
                                    "email": self.emailTextField.text!,
                                    "username": self.firstNameTextField.text! + self.lastNameTextField.text!
                                ]
                                
                                Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON)
                                
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let mainVC = storyboard.instantiateInitialViewController()
                                self.presentViewController(mainVC!, animated: true, completion: nil)
                            }
                    })
                    
                }
        })

    }
    
    

}
