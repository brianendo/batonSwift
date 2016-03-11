//
//  AskQuestionViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 10/29/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import JWTDecode
import Crashlytics

extension Int
{
    static func random(range: Range<Int> ) -> Int
    {
        var offset = 0
        
        if range.startIndex < 0   // allow negative ranges
        {
            offset = abs(range.startIndex)
        }
        
        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}


class AskQuestionViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var charRemainingLabel: UILabel!
    @IBOutlet weak var bottomSpaceToLayoutGuide: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var channelButton: UIButton!
    @IBOutlet weak var topSpaceForTextView: NSLayoutConstraint!
    
    // MARK: - Variables
    let keychain = KeychainSwift()
    var placeholder = "What's on your mind?"
    var fromSpecificChannel = false
    var channelName = ""
    var channelId = ""
    var forEditPost = false
    var content = ""
    var questionId = ""
    
    // MARK: - Keyboard
    func registerForKeyboardNotifications ()-> Void   {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.bottomSpaceToLayoutGuide.constant = keyboardFrame.size.height
    }
    
    // MARK: - viewWill/viewDid
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if self.tabBarController != nil {
            self.tabBarController!.tabBar.hidden = true
        }
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let aRandomInt = Int.random(0...3)
        print(aRandomInt)
        
        contentTextView.delegate = self
        contentTextView.becomeFirstResponder()
        
        
        if forEditPost {
            contentTextView.text = self.content
            self.sendButton.hidden = true
            let count = 150 - self.content.characters.count
            self.charRemainingLabel.text = "\(count)"
            
            channelButton.frame = CGRectMake(0, 0, 0, 0)
            channelButton.hidden = true
            topSpaceForTextView.constant = 15
            self.contentTextView.setNeedsUpdateConstraints()
        } else {
            // Placeholder text
            if fromSpecificChannel {
                contentTextView.text = "What do you want to share with the " + self.channelName + " community?"
            } else {
                contentTextView.text = placeholder
            }
            
            contentTextView.textColor = UIColor.lightGrayColor()
            
            contentTextView.selectedTextRange = contentTextView.textRangeFromPosition(contentTextView.beginningOfDocument, toPosition: contentTextView.beginningOfDocument)
            
            self.sendButton.hidden = true
            
            if fromSpecificChannel {
                channelButton.setTitle(self.channelName, forState: .Normal)
                channelButton.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
                channelButton.layer.cornerRadius = 5
                channelButton.sizeToFit()
            } else {
                channelButton.frame = CGRectMake(0, 0, 0, 0)
                channelButton.hidden = true
                topSpaceForTextView.constant = 15
                self.contentTextView.setNeedsUpdateConstraints()
            }
        }
        
//        // Placeholder text
//        if fromSpecificChannel {
//            contentTextView.text = "What do you want to share with the " + self.channelName + " community?"
//        } else {
//           contentTextView.text = placeholder
//        }
//        
//        contentTextView.textColor = UIColor.lightGrayColor()
//        
//        contentTextView.selectedTextRange = contentTextView.textRangeFromPosition(contentTextView.beginningOfDocument, toPosition: contentTextView.beginningOfDocument)
//        
//        self.sendButton.hidden = true
//        
//        if fromSpecificChannel {
//            channelButton.setTitle(self.channelName, forState: .Normal)
//            channelButton.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
//            channelButton.layer.cornerRadius = 5
//            channelButton.sizeToFit()
//        } else {
//            channelButton.frame = CGRectMake(0, 0, 0, 0)
//            channelButton.hidden = true
//            topSpaceForTextView.constant = 15
//            self.contentTextView.setNeedsUpdateConstraints()
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - textView delegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = contentTextView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            if fromSpecificChannel {
                contentTextView.text = "What do you want to share with the " + self.channelName + " community?"
            } else {
                contentTextView.text = placeholder
            }
            contentTextView.textColor = UIColor.lightGrayColor()
            
            self.charRemainingLabel.text = "150"
            contentTextView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
            self.sendButton.hidden = true
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if contentTextView.textColor == UIColor.lightGrayColor() && !text.isEmpty {
            contentTextView.text = nil
            contentTextView.textColor = UIColor.blackColor()
        }
        
        // Limit character limit to 150
        let newLength: Int = (contentTextView.text as NSString).length + (text as NSString).length - range.length
        let remainingChar: Int = 150 - newLength
        
        if contentTextView.text == placeholder {
            charRemainingLabel.text = "150"
        } else {
            // Make label show remaining characters
            charRemainingLabel.text = "\(remainingChar)"
        }
        // Once text > 150 chars, stop ability to change text
        return (newLength == 150) ? false : true

    }
    
    // MARK: textView functions
    func textViewDidChange(textView: UITextView) {
        let trimmedString = contentTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if trimmedString.characters.count == 0 {
            self.sendButton.hidden = true
        } else {
            self.sendButton.hidden = false
        }
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if self.view.window != nil {
            if contentTextView.textColor == UIColor.lightGrayColor() {
                contentTextView.selectedTextRange = contentTextView.textRangeFromPosition(contentTextView.beginningOfDocument, toPosition: contentTextView.beginningOfDocument)
            }
        }
        
    }
    
    
    // MARK: - IBAction
    @IBAction func sendButtonPressed(sender: UIButton) {
        if forEditPost {
            print("Money everywhere")
            
            let url = globalurl + "api/editquestioncontent"
            let parameters = [
                "id": questionId,
                "newContent": contentTextView.text
            ]
            Alamofire.request(.PUT, url, parameters: parameters)
                .responseJSON { response in
                    print(response.response?.statusCode)
                    let value = response.result.value
                    print(value)
                    NSNotificationCenter.defaultCenter().postNotificationName("questionEdited", object: self)
//                    self.navigationController?.popViewControllerAnimated(true)
                    self.dismissViewControllerAnimated(true, completion: nil)
            }

            
        } else {
            if fromSpecificChannel {
                self.sendButton.enabled = false
                let text = self.contentTextView.text
                
                // Check if JWT is valid before posting question
                var token = keychain.get("JWT")
                
                do {
                    if token == nil {
                        var refresh_token = keychain.get("refresh_token")
                        
                        if refresh_token == nil {
                            refresh_token = ""
                        }
                        
                        let url = globalurl + "api/changetoken/"
                        let parameters = [
                            "refresh_token": refresh_token! as String
                        ]
                        Alamofire.request(.POST, url, parameters: parameters)
                            .responseJSON { response in
                                var value = response.result.value
                                
                                if value == nil {
                                    value = []
                                } else {
                                    let json = JSON(value!)
                                    let newtoken = json["token"].string
                                    self.keychain.set(newtoken!, forKey: "JWT")
                                    token = newtoken
                                    
                                    let headers = [
                                        "Authorization": "\(token!)"
                                    ]
                                    let url = globalurl + "api/questions"
                                    let parameters = [
                                        "content": text,
                                        "creatorname": myUsername,
                                        "creator": userid,
                                        "answercount": 0,
                                        "likes": 0,
                                        "channel_id": self.channelId,
                                        "channel_name": self.channelName
                                    ]
                                    Alamofire.request(.POST, url, parameters: parameters as? [String : AnyObject], headers: headers)
                                        .responseJSON { response in
                                            print(response.response?.statusCode)
                                            
                                            var value = response.result.value
                                            if value == nil {
                                                value = []
                                            }
                                            let json = JSON(value!)
                                            print("JSON: \(json)")
                                            let id = json["_id"].string
                                            print(id)
                                            self.questionId = id!
                                            
                                            
                                            Answers.logCustomEventWithName("Question submitted",
                                                customAttributes: ["channel": self.channelName, "username": myUsername])
                                            // Update feed with new question
                                            NSNotificationCenter.defaultCenter().postNotificationName("askedQuestion", object: self)
//                                            self.navigationController?.popViewControllerAnimated(true)
                                            self.performSegueWithIdentifier("segueFromAskQuestionToAddTake", sender: self)
                                    }
                                }
                                
                                
                        }
                    } else {
                        let jwt = try decode(token!)
                        if jwt.expired == true {
                            var refresh_token = keychain.get("refresh_token")
                            
                            if refresh_token == nil {
                                refresh_token = ""
                            }
                            
                            let url = globalurl + "api/changetoken/"
                            let parameters = [
                                "refresh_token": refresh_token! as String
                            ]
                            Alamofire.request(.POST, url, parameters: parameters)
                                .responseJSON { response in
                                    var value = response.result.value
                                    
                                    if value == nil {
                                        value = []
                                    } else {
                                        let json = JSON(value!)
                                        let newtoken = json["token"].string
                                        self.keychain.set(newtoken!, forKey: "JWT")
                                        token = newtoken
                                        
                                        let headers = [
                                            "Authorization": "\(token!)"
                                        ]
                                        let url = globalurl + "api/questions"
                                        let parameters = [
                                            "content": text,
                                            "creatorname": myUsername,
                                            "creator": userid,
                                            "answercount": 0,
                                            "likes": 0,
                                            "channel_id": self.channelId,
                                            "channel_name": self.channelName
                                        ]
                                        Alamofire.request(.POST, url, parameters: parameters as? [String : AnyObject], headers: headers)
                                            .responseJSON { response in
                                                print(response.response?.statusCode)
                                                
                                                var value = response.result.value
                                                if value == nil {
                                                    value = []
                                                }
                                                let json = JSON(value!)
                                                print("JSON: \(json)")
                                                let id = json["_id"].string
                                                print(id)
                                                self.questionId = id!
                                                
                                                Answers.logCustomEventWithName("Question submitted",
                                                    customAttributes: ["channel": self.channelName, "username": myUsername])
                                                // Update feed with new question
                                                NSNotificationCenter.defaultCenter().postNotificationName("askedQuestion", object: self)
//                                                self.navigationController?.popViewControllerAnimated(true)
                                                self.performSegueWithIdentifier("segueFromAskQuestionToAddTake", sender: self)
                                        }
                                    }
                                    
                                    
                            }
                        } else {
                            let headers = [
                                "Authorization": "\(token!)"
                            ]
                            
                            let url = globalurl + "api/questions"
                            let parameters = [
                                "content": text,
                                "creatorname": myUsername,
                                "creator": userid,
                                "answercount": 0,
                                "likes": 0,
                                "channel_id": self.channelId,
                                "channel_name": self.channelName
                            ]
                            Alamofire.request(.POST, url, parameters: parameters as? [String : AnyObject], headers: headers)
                                .responseJSON { response in
                                    print(response.request)
                                    print(response.response)
                                    print(response.result)
                                    print(response.response?.statusCode)
                                    
                                    var value = response.result.value
                                    if value == nil {
                                        value = []
                                    }
                                    let json = JSON(value!)
                                    print("JSON: \(json)")
                                    let id = json["_id"].string
                                    print(id)
                                    self.questionId = id!
                                    
                                    Answers.logCustomEventWithName("Question submitted",
                                        customAttributes: ["channel": self.channelName, "username": myUsername])
                                    NSNotificationCenter.defaultCenter().postNotificationName("askedQuestion", object: self)
//                                    self.navigationController?.popViewControllerAnimated(true)
                                    self.performSegueWithIdentifier("segueFromAskQuestionToAddTake", sender: self)
                                    
                            }
                        }
                        
                    }
                } catch {
                    print("Failed to decode JWT: \(error)")
                }
            } else {
                self.performSegueWithIdentifier("segueToPickChannel", sender: self)
            }
        }
        
        
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.contentTextView.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToPickChannel" {
            let pickChannelVC: PickChannelViewController = segue.destinationViewController as! PickChannelViewController
            pickChannelVC.questionText = self.contentTextView.text
        } else if segue.identifier == "segueFromAskQuestionToAddTake" {
            let addTakeVC: AddTakeViewController = segue.destinationViewController as! AddTakeViewController
            addTakeVC.questionContent = self.contentTextView.text
            addTakeVC.questionId = self.questionId
        }
    }
    
    // Uncomment for code to check what time question was asked last
//    func checkLastQuestion() {
//        let url = globalurl + "api/users/" + userid
//        
//        Alamofire.request(.GET, url, parameters: nil, encoding: .JSON).responseJSON { response in
//            var value = response.result.value
//            
//            if value == nil {
//                value = []
//            } else {
//                let json = JSON(value!)
//                print("JSON: \(json)")
//                var updated_at = json["updated_at"].string
//                print(updated_at)
//                
//                if updated_at == nil {
//                    updated_at = "2015-11-03T01:28:21.147Z"
//                }
//                
//                var dateFor: NSDateFormatter = NSDateFormatter()
//                dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//                var yourDate: NSDate? = dateFor.dateFromString(updated_at!)
//                
//                let difference = NSDate().timeIntervalSinceDate(yourDate!)
//                print(difference)
//                
//                if difference < 86400 {
//                    let timeRemaining = Int(86400 - difference)
//                    let timeLeft = self.returnSecondsToHoursMinutesSeconds(timeRemaining)
//                    
//                    print(timeLeft)
//                    
//                    let alert = UIAlertController(title: "You have to wait \(timeLeft) before your next question", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
//                    let libButton = UIAlertAction(title: "Invite Friends", style: UIAlertActionStyle.Default) { (alert) -> Void in
//                    }
//                    let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
//                        print("Cancel Pressed", terminator: "")
//                    }
//                    
//                    alert.addAction(libButton)
//                    alert.addAction(cancelButton)
//                    self.presentViewController(alert, animated: true, completion: nil)
//                } else {
//                    
//                }
//            }
//            
//            
//            
//        }
//    }
//    
//    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
//        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
//    }
//    
//    
//    func returnSecondsToHoursMinutesSeconds (seconds:Int) -> (String) {
//        let (h, m, s) = secondsToHoursMinutesSeconds (seconds)
//        if h == 0 && m == 0{
//            return "\(s)s"
//        } else if h == 0 {
//            return "\(m)m \(s)s"
//        } else {
//            return "\(h)h \(m)m \(s)s"
//        }
//    }

}
