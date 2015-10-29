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
    
    var id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            "creator": userid
        ]
        
        Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    

}
