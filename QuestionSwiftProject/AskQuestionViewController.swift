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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func sendButtonPressed(sender: UIButton) {
        let text = self.contentTextView.text
        let url = "http://localhost:3000/api/questions"
        let parameters = [
            "content": text
        ]
        
        Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    

}
