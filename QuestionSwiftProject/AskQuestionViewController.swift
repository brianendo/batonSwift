//
//  AskQuestionViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 10/29/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire

class AskQuestionViewController: UIViewController {
    
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var anonymousButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    
    var anonymous = "false"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.nameButton.selected = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func sendButtonPressed(sender: UIButton) {
        let text = self.contentTextView.text
        let url = "http://localhost:3000/api/questions"
        let parameters = [
            "content": text,
            "creatorname": name,
            "creator": userid,
            "anonymous": anonymous,
            "answercount": 0
        ]
        
        Alamofire.request(.POST, url, parameters: parameters as? [String : AnyObject], encoding: .JSON)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func nameButtonPressed(sender: UIButton) {
        self.anonymousButton.selected = false
        self.nameButton.selected = true
        self.anonymous = "false"
    }
    
    @IBAction func anonymousButtonPressed(sender: UIButton) {
        self.anonymousButton.selected = true
        self.nameButton.selected = false
        self.anonymous = "true"
    }
    
    
    

}
