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

class AskQuestionViewController: UIViewController {
    
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var anonymousButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var bottomSpaceToLayoutGuide: NSLayoutConstraint!
    
    
    
    
    var anonymous = "false"
    
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
        self.nameButton.backgroundColor = UIColor.lightGrayColor()
        self.anonymousButton.backgroundColor = UIColor.clearColor()
        
        self.checkLastQuestion()
        
        contentTextView.becomeFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func sendButtonPressed(sender: UIButton) {
        let text = self.contentTextView.text
        let url = globalurl + "api/questions"
        let parameters = [
            "content": text,
            "creatorname": name,
            "creator": userid,
            "anonymous": anonymous,
            "answercount": 0
        ]
        Alamofire.request(.POST, url, parameters: parameters as? [String : AnyObject], encoding: .JSON)
        
        let newUrl = globalurl + "api/users/" + userid + "/updated-at/"
        Alamofire.request(.PUT, newUrl, parameters: nil, encoding: .JSON)
        
        NSNotificationCenter.defaultCenter().postNotificationName("askedQuestion", object: self)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func nameButtonPressed(sender: UIButton) {
        self.nameButton.backgroundColor = UIColor.lightGrayColor()
        self.anonymousButton.backgroundColor = UIColor.clearColor()
        self.anonymous = "false"
    }
    
    @IBAction func anonymousButtonPressed(sender: UIButton) {
        self.anonymousButton.backgroundColor = UIColor.lightGrayColor()
        self.nameButton.backgroundColor = UIColor.clearColor()
        self.anonymous = "true"
    }
    
    
    

}
