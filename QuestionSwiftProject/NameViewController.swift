//
//  NameViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 1/28/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class NameViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    var email = ""
    var password = ""
    
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
