//
//  AddTakeViewController.swift
//  Baton
//
//  Created by Brian Endo on 3/8/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class AddTakeViewController: UIViewController {

    var questionId = ""
    var questionContent = ""
    
    @IBOutlet weak var questionContentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        questionContentLabel.text = questionContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTakeButtonPressed(sender: UIButton) {
        self.performSegueWithIdentifier("segueFromAddTakeToTakeVideo", sender: self)
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
//        self.navigationController?.popToRootViewControllerAnimated(true)
        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromAddTakeToTakeVideo" {
            let takeVideoVC: TakeVideoViewController = segue.destinationViewController as! TakeVideoViewController
            takeVideoVC.content = questionContent
            takeVideoVC.id = questionId
            takeVideoVC.fromAddTake = true
        }
    }
    

}
