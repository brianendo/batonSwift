//
//  NameViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 1/28/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class NameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameStatusLabel: UILabel!
    
    var email = ""
    var password = ""
    
    var namecharacterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_ ")
    
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
        self.nextButton.enabled = true
        // Do any additional setup after loading the view.
        self.firstNameTextField.addTarget(self, action: "firstNameTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.lastNameTextField.addTarget(self, action: "lastNameTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
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
            self.nameStatusLabel.text = "Name cannot contain special characters"
            self.nextButton.enabled = false
        } else {
            self.nameStatusLabel.text = ""
            self.nextButton.enabled = true
        }
        
    }
    
    func lastNameTextFieldDidChange(textField: UITextField) {
        
        let lastName = self.lastNameTextField.text!
        
        if ((lastName.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
            self.nameStatusLabel.text = "Name cannot contain special characters"
            self.nextButton.enabled = false
        } else {
            self.nameStatusLabel.text = ""
            self.nextButton.enabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromNameToUsername" {
            let usernameVC: UsernameViewController = segue.destinationViewController as! UsernameViewController
            usernameVC.email = self.email
            usernameVC.password = self.password
            usernameVC.firstname = firstNameTextField.text! as String
            usernameVC.lastname = lastNameTextField.text! as String
        }
    }
    
    @IBAction func nextButtonTapped(sender: UIButton) {
        self.performSegueWithIdentifier("segueFromNameToUsername", sender: self)
    }

}
