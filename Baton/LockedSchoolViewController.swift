//
//  LockedSchoolViewController.swift
//  Baton
//
//  Created by Brian Endo on 4/5/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import MessageUI
import Alamofire
import SwiftyJSON

class LockedSchoolViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    
    var schoolName = ""
    var fromSuggest = false
    var channelId = ""
    var userEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if schoolName == "" {
            messageLabel.text = "We need a few more students from your school before we can start a channel."
        } else {
            messageLabel.text = "We need a few more students from \(schoolName) before we can start a channel."
        }
        
        if fromSuggest {
            
        } else {
            self.addInterestedUser()
        }
    }
    
    func addInterestedUser() {
        let url = globalurl + "api/interestedChannel"
        let parameters = [
            "id": self.channelId,
            "email": self.userEmail
        ]
        Alamofire.request(.PUT, url, parameters: parameters, headers: nil)
            .responseJSON { response in
                print(response.response?.statusCode)
                
                var value = response.result.value
                if value == nil {
                    value = []
                }
                let json = JSON(value!)
                print("JSON: \(json)")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        switch (result.rawValue) {
        case MessageComposeResultCancelled.rawValue:
            print("Message was cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.rawValue:
            print("Message failed")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.rawValue:
            print("Message was sent")
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
    
    @IBAction func inviteFriendsButtonPressed(sender: UIButton) {
        if (MFMessageComposeViewController.canSendText()) {
            let messageVC = MFMessageComposeViewController()
            
            messageVC.body = "Get Baton to see what is going on at our school. Download it here: http://batonapp.io/"
            print(messageVC.body)
            
            messageVC.messageComposeDelegate = self
            
            self.presentViewController(messageVC, animated: true, completion:nil)
        } else {
            let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
    

}
