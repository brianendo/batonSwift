//
//  ChangeEmailViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 2/1/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChangeEmailViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!
    
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
        self.saveButton.enabled = false
        self.emailTextField.text = myemail
        self.emailTextField.becomeFirstResponder()
        self.emailTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if textField.text == myemail {
            self.saveButton.enabled = false
        } else {
            self.saveButton.enabled = true
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exitButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        let email = emailTextField.text! as String
        
        let parameters = [
            "id": userid,
            "email": email
        ]
        
        let url = globalurl + "api/changeemail"
        
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
                        print("Password changed")
                        myemail = email
                        let alert = UIAlertController(title: "Email Changed", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                        let cancelButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                            print("Cancel Pressed", terminator: "")
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        alert.addAction(cancelButton)
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else if statuscode == 404 {
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Failed!"
                        alertView.message = "Current email taken"
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
