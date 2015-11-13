//
//  SubmitAnswerViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 10/29/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire

class SubmitAnswerViewController: UIViewController {

    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var anonymousButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var questionContentTextView: UITextView!
    @IBOutlet weak var bottomSpaceToLayoutGuide: NSLayoutConstraint!
    
    var id = ""
    var anonymous = "false"
    var content = ""
    var creatorname = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        self.profileImageView.frame = CGRectMake(0, 0, 30, 30)
        self.profileImageView.layer.borderWidth = 0.5
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
        self.profileImageView.clipsToBounds = true
        
        self.nameTextView.text = self.creatorname
        self.nameTextView.userInteractionEnabled = false
        
        self.questionContentTextView.text = self.content
        self.questionContentTextView.userInteractionEnabled = false
        
        self.profileImageView.image = UIImage(named: "Placeholder")
        // Do any additional setup after loading the view.
        self.nameButton.backgroundColor = UIColor.lightGrayColor()
        self.anonymousButton.backgroundColor = UIColor.clearColor()
        
        
        answerTextView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        print(keyboardFrame, terminator: "")
        self.bottomSpaceToLayoutGuide.constant = keyboardFrame.size.height - 50
    }
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        let content = self.answerTextView.text
        let url = globalurl + "api/answers"
        let parameters = [
            "content": content,
            "question_id": self.id,
            "creatorname": name,
            "creator": userid,
            "anonymous": anonymous
        ]
        
        Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON)
        
        NSNotificationCenter.defaultCenter().postNotificationName("submittedAnswer", object: self)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func nameButtonPressed(sender: UIButton) {
        self.nameButton.backgroundColor = UIColor.lightGrayColor()
        self.anonymousButton.backgroundColor = UIColor.clearColor()
        
        anonymous = "false"
    }
    
    
    @IBAction func anonymousButtonPressed(sender: UIButton) {
        self.nameButton.backgroundColor = UIColor.clearColor()
        self.anonymousButton.backgroundColor = UIColor.lightGrayColor()
        
        anonymous = "true"
    }
    
    
    

}
