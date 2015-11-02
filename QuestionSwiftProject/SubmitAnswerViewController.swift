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
    
    
    
    var id = ""
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
    
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        let content = self.answerTextView.text
        let url = "http://localhost:3000/api/answers"
        let parameters = [
            "content": content,
            "question_id": self.id,
            "creatorname": name,
            "creator": userid,
            "anonymous": anonymous
        ]
        
        Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func nameButtonPressed(sender: UIButton) {
        self.nameButton.selected = true
        self.anonymousButton.selected = false
        anonymous = "false"
    }
    
    
    @IBAction func anonymousButtonPressed(sender: UIButton) {
        self.nameButton.selected = false
        self.anonymousButton.selected = true
        anonymous = "true"
    }
    
    
    

}
