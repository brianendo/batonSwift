//
//  NameViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 1/28/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class NameViewController: UIViewController, UITextFieldDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameStatusLabel: UILabel!
    
    // MARK: - Variables
    var email = ""
    var password = ""
    var namecharacterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_- '")
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nextButton.hidden = false
        
        // Add functions and delegate to textField
        self.firstNameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.lastNameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
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
    func textFieldDidChange(textField: UITextField) {
        let firstName = self.firstNameTextField.text!
        let lastName = self.lastNameTextField.text!
        
        if ((firstName.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
            self.nameStatusLabel.text = "First Name cannot contain special characters"
            self.nextButton.hidden = true
        } else  if ((lastName.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
            self.nameStatusLabel.text = "Last Name cannot contain special characters"
            self.nextButton.hidden = true
        } else {
            self.nameStatusLabel.text = ""
            self.nextButton.hidden = false
        }
        
    }
    
    
    func firstNameTextFieldDidChange(textField: UITextField) {
        
        let firstName = self.firstNameTextField.text!
        
        if ((firstName.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
            self.nameStatusLabel.text = "Name cannot contain special characters"
            self.nextButton.hidden = true
        } else {
            self.nameStatusLabel.text = ""
            self.nextButton.hidden = false
        }
        
    }
    
    func lastNameTextFieldDidChange(textField: UITextField) {
        
        let lastName = self.lastNameTextField.text!
        
        if ((lastName.rangeOfCharacterFromSet(self.namecharacterSet.invertedSet, options: [], range: nil)) != nil) {
            self.nameStatusLabel.text = "Name cannot contain special characters"
            self.nextButton.hidden = true
        } else {
            self.nameStatusLabel.text = ""
            self.nextButton.hidden = false
        }
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromNameToUsername" {
            let usernameVC: UsernameViewController = segue.destinationViewController as! UsernameViewController
            usernameVC.email = self.email
            usernameVC.password = self.password
            usernameVC.firstname = firstNameTextField.text! as String
            usernameVC.lastname = lastNameTextField.text! as String
        }
    }
    
    // MARK: - IBAction
    @IBAction func nextButtonTapped(sender: UIButton) {
        self.performSegueWithIdentifier("segueFromNameToUsername", sender: self)
    }

}
