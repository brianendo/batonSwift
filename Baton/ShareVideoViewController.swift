//
//  ShareVideoViewController.swift
//  Baton
//
//  Created by Brian Endo on 2/8/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import MessageUI
import TwitterKit
import FBSDKShareKit

class ShareVideoViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var twitterShareButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var copyLinkButton: UIButton!
    
    var answerId = ""
    var answerUrl = ""
    let composer = TWTRComposer()
    let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(answerId)
        answerUrl = globalurl + "answers/\(answerId)"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
//        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 20)!]
//        
//        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
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
    
    func prepareSMSmessage(answerId:String)
    {
        
        if (MFMessageComposeViewController.canSendText()) {
            
            let messageVC = MFMessageComposeViewController()
            
            messageVC.body = "Check out my Baton video here: \(answerUrl)"
            print(messageVC.body)
            
            messageVC.messageComposeDelegate = self
            
            self.presentViewController(messageVC, animated: true, completion:nil)
        } else {
            let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
    
    
    @IBAction func twitterShareButtonPressed(sender: UIButton) {
        
        composer.setText("Check out my Baton video here: \(answerUrl)")
        
        // Called from a UIViewController
        composer.showFromViewController(self) { result in
            if (result == TWTRComposerResult.Cancelled) {
                print("Tweet composition cancelled")
            }
            else {
                print("Sending tweet!")
            }
        }
    }
    
    @IBAction func facebookButtonPressed(sender: UIButton) {
        content.contentURL = NSURL(string: self.answerUrl)
        content.contentTitle = "Baton Video"
        content.contentDescription = "Quick video discussion"
//        content.imageURL = NSURL(string: self.contentURLImage)
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
    }
    
    
    
    @IBAction func sendMessageButtonPressed(sender: UIButton) {
        prepareSMSmessage(self.answerUrl)
    }
    
    
    @IBAction func copyLinkButtonPressed(sender: UIButton) {
        UIPasteboard.generalPasteboard().string = "\(answerUrl)"
    }
    
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

}

