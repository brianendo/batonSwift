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

class AskQuestionViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var charRemainingLabel: UILabel!
    
    @IBOutlet weak var bottomSpaceToLayoutGuide: NSLayoutConstraint!
    
    @IBOutlet weak var sendButton: UIButton!
    
    var anonymous = "false"
    
    var placeholder = "What are your thoughts on fantasy sports?"
    
    func checkLastQuestion() {
        let url = globalurl + "api/users/" + userid
        
        Alamofire.request(.GET, url, parameters: nil, encoding: .JSON).responseJSON { response in
            var value = response.result.value
            
            if value == nil {
                value = []
            } else {
                let json = JSON(value!)
                print("JSON: \(json)")
                var updated_at = json["updated_at"].string
                print(updated_at)
                
                if updated_at == nil {
                    updated_at = "2015-11-03T01:28:21.147Z"
                }
                
                var dateFor: NSDateFormatter = NSDateFormatter()
                dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                var yourDate: NSDate? = dateFor.dateFromString(updated_at!)
                
                let difference = NSDate().timeIntervalSinceDate(yourDate!)
                print(difference)
                
                if difference < 86400 {
                    let timeRemaining = Int(86400 - difference)
                    let timeLeft = self.returnSecondsToHoursMinutesSeconds(timeRemaining)
                    
                    print(timeLeft)
                    
                    let alert = UIAlertController(title: "You have to wait \(timeLeft) before your next question", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                    let libButton = UIAlertAction(title: "Invite Friends", style: UIAlertActionStyle.Default) { (alert) -> Void in
                    }
                    let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                        print("Cancel Pressed", terminator: "")
                    }
                    
                    alert.addAction(libButton)
                    alert.addAction(cancelButton)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    
                }
            }
                
            
            
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    
    func returnSecondsToHoursMinutesSeconds (seconds:Int) -> (String) {
        let (h, m, s) = secondsToHoursMinutesSeconds (seconds)
        if h == 0 && m == 0{
            return "\(s)s"
        } else if h == 0 {
            return "\(m)m \(s)s"
        } else {
            return "\(h)h \(m)m \(s)s"
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        print(keyboardFrame, terminator: "")
        self.bottomSpaceToLayoutGuide.constant = keyboardFrame.size.height - 50
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        // Do any additional setup after loading the view.
        
        self.checkLastQuestion()
        
        contentTextView.delegate = self
        
        // Make the keyboard pop up
        contentTextView.becomeFirstResponder()
        
        // Placeholder text
        contentTextView.text = placeholder
        contentTextView.textColor = UIColor.lightGrayColor()
        
        contentTextView.selectedTextRange = contentTextView.textRangeFromPosition(contentTextView.beginningOfDocument, toPosition: contentTextView.beginningOfDocument)
        
        self.sendButton.enabled = false
        self.sendButton.layer.masksToBounds = true
        self.sendButton.layer.borderColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0).CGColor
        self.sendButton.layer.borderWidth = 0.7
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = contentTextView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            contentTextView.text = placeholder
            contentTextView.textColor = UIColor.lightGrayColor()
            
            self.charRemainingLabel.text = "100"
            contentTextView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
            self.sendButton.enabled = false
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
        
        // Limit character limit to 200
        let newLength: Int = (contentTextView.text as NSString).length + (text as NSString).length - range.length
        let remainingChar: Int = 200 - newLength
        
        if contentTextView.text == placeholder {
            charRemainingLabel.text = "100"
        } else {
            // Make label show remaining characters
            charRemainingLabel.text = "\(remainingChar)"
        }
        // Once text > 100 chars, stop ability to change text
        return (newLength == 100) ? false : true
        
        
        
    }
    
    func textViewDidChange(textView: UITextView) {
        let trimmedString = contentTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if trimmedString.characters.count == 0 {
            self.sendButton.enabled = false
        } else {
            self.sendButton.enabled = true
        }
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if self.view.window != nil {
            if contentTextView.textColor == UIColor.lightGrayColor() {
                contentTextView.selectedTextRange = contentTextView.textRangeFromPosition(contentTextView.beginningOfDocument, toPosition: contentTextView.beginningOfDocument)
            }
        }
        
    }
    
    
    
    @IBAction func sendButtonPressed(sender: UIButton) {
        let text = self.contentTextView.text
        let url = globalurl + "api/questions"
        let parameters = [
            "content": text,
            "creatorname": name,
            "creator": userid,
            "anonymous": anonymous,
            "answercount": 0,
            "likes": 0
        ]
        Alamofire.request(.POST, url, parameters: parameters as? [String : AnyObject], encoding: .JSON)
        
        let newUrl = globalurl + "api/users/" + userid + "/updated-at/"
        Alamofire.request(.PUT, newUrl, parameters: nil, encoding: .JSON)
        
        NSNotificationCenter.defaultCenter().postNotificationName("askedQuestion", object: self)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    

}
