//
//  SuggestSchoolViewController.swift
//  Baton
//
//  Created by Brian Endo on 4/5/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SuggestSchoolViewController: UIViewController{

    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    var firstname = ""
    var lastname = ""
    var email = ""
    var type = ""
    
    
    func registerForKeyboardNotifications ()-> Void   {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SuggestSchoolViewController.keyboardWillShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SuggestSchoolViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications () -> Void {
        let center:  NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.bottomLayoutConstraint.constant = keyboardFrame.size.height
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.bottomLayoutConstraint.constant = 0
    }
    
    override func viewWillAppear(animated: Bool) {
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.deregisterFromKeyboardNotifications()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.hidden = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"Back", style:.Plain, target:nil, action:nil)
        
        self.title = "Suggest School"
        // Do any additional setup after loading the view.
        self.nameTextField.addTarget(self, action: #selector(SuggestSchoolViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.locationTextField.addTarget(self, action: #selector(SuggestSchoolViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        self.nameTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidChange(textField: UITextField) {
        let name = nameTextField.text
        let location = locationTextField.text
        
        if name == "" || location == "" {
            doneButton.hidden = true
        } else {
            doneButton.hidden = false
        }
        
    }
    
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        let url = globalurl + "api/alerts"
        let parameters = [
            "type": self.type,
            "firstname": self.firstname,
            "lastname": self.lastname,
            "email": self.email,
            "schoolName": self.nameTextField.text!,
            "schoolLocation": self.locationTextField.text!
        ]
        Alamofire.request(.POST, url, parameters: parameters, headers: nil)
            .responseJSON { response in
                print(response.response?.statusCode)
                
                var value = response.result.value
                if value == nil {
                    value = []
                }
                let json = JSON(value!)
                print("JSON: \(json)")
        }
        
        
        self.performSegueWithIdentifier("segueFromSuggestToLocked", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromSuggestToLocked" {
            let lockedSchoolVC: LockedSchoolViewController = segue.destinationViewController as! LockedSchoolViewController
            lockedSchoolVC.schoolName = nameTextField.text!
            lockedSchoolVC.fromSuggest = true
        }
    }

}
