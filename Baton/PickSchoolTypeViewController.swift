//
//  PickSchoolTypeViewController.swift
//  Baton
//
//  Created by Brian Endo on 3/30/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class PickSchoolTypeViewController: UIViewController {

    var firstName = ""
    var lastName = ""
    var profileImageUrl = ""
    var facebookId = ""
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func highSchoolButtonPressed(sender: UIButton) {
        self.performSegueWithIdentifier("segueToConfirmSchool", sender: self)
    }
    
    @IBAction func collegeButtonPressed(sender: UIButton) {
        self.performSegueWithIdentifier("segueToCollegeEmail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToConfirmSchool" {
            let confirmSchoolVC: ConfirmSchoolViewController = segue.destinationViewController as! ConfirmSchoolViewController
            confirmSchoolVC.firstName = firstName
            confirmSchoolVC.lastName = lastName
            confirmSchoolVC.profileImageUrl = profileImageUrl
            confirmSchoolVC.facebookId = facebookId
            confirmSchoolVC.email = email
        } else if segue.identifier == "segueToCollegeEmail" {
            let collegeEmailVC: CollegeEmailViewController = segue.destinationViewController as! CollegeEmailViewController
            collegeEmailVC.firstName = firstName
            collegeEmailVC.lastName = lastName
            collegeEmailVC.profileImageUrl = profileImageUrl
            collegeEmailVC.facebookId = facebookId
            collegeEmailVC.email = email
        }
    }
    
}
