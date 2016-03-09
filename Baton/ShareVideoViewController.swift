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
import Crashlytics

class ShareVideoViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    
    
    // MARK: - IBOutlets
    @IBOutlet weak var twitterShareButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var copyLinkButton: UIButton!
    
    // MARK: - Variables
    var answerId = ""
    var answerUrl = ""
    var questionContent = ""
    var editedQuestionContent = ""
    let composer = TWTRComposer()
    let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
    var fromAddTake = false
    
    // MARK: - viewDid/viewWill
    override func viewDidLoad() {
        super.viewDidLoad()
        print(answerId)
        answerUrl = batonUrl + "answers/\(answerId)"
        
        editedQuestionContent = questionContent
        if questionContent.characters.count > 80 {
            let ss1: String = (questionContent as NSString).substringToIndex(80)
            editedQuestionContent = ss1 + "..."
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - messageComposeVC
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
            Answers.logCustomEventWithName("Share Conversion",
                customAttributes: ["button":"message", "username": myUsername])
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
    
    func prepareSMSmessage(answerId:String) {
        if (MFMessageComposeViewController.canSendText()) {
            let messageVC = MFMessageComposeViewController()
            
            messageVC.body = "re: \"\(editedQuestionContent)\" \(answerUrl) via Baton"
            print(messageVC.body)
            
            messageVC.messageComposeDelegate = self
            
            self.presentViewController(messageVC, animated: true, completion:nil)
        } else {
            let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
    
    // MARK: - IBAction
    @IBAction func twitterShareButtonPressed(sender: UIButton) {
        Answers.logCustomEventWithName("Share Pressed",
            customAttributes: ["button":"Twitter", "username": myUsername])
        composer.setText("re: \"\(editedQuestionContent)\" \(answerUrl) via @WhatsOnBaton")
        
        // Called from a UIViewController
        composer.showFromViewController(self) { result in
            if (result == TWTRComposerResult.Cancelled) {
                print("Tweet composition cancelled")
            }
            else {
                print("Sending tweet!")
                Answers.logCustomEventWithName("Share Conversion",
                    customAttributes: ["button":"Twitter","username": myUsername])
            }
        }
    }
    
    @IBAction func facebookButtonPressed(sender: UIButton) {
        Answers.logCustomEventWithName("Share Pressed",
            customAttributes: ["button":"Facebook","username": myUsername])
        let thumbnailUrl = "https://s3-us-west-1.amazonaws.com/batonapp/BatonHighQuality.png"
        content.contentURL = NSURL(string: self.answerUrl)
        content.contentTitle = "re: \"\(editedQuestionContent)\""
        content.contentDescription = "A platfrom concise video discussions every day"
        content.imageURL = NSURL(string: thumbnailUrl )
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
    }
    
    
    
    @IBAction func sendMessageButtonPressed(sender: UIButton) {
        Answers.logCustomEventWithName("Share Pressed",
            customAttributes: ["button":"message", "username": myUsername])
        prepareSMSmessage(self.answerUrl)
    }
    
    
    @IBAction func copyLinkButtonPressed(sender: UIButton) {
        Answers.logCustomEventWithName("Share Pressed",
            customAttributes: ["button":"copy", "username": myUsername])
        // Copies link to pasteboard
        UIPasteboard.generalPasteboard().string = "\(answerUrl)"
    }
    
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        // Dismisses both the ShareVideoVC and TakeVideoVC
        if fromAddTake {
            self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    

}

