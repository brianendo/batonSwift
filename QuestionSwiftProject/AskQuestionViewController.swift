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
    
    var anonymous = "false"
    
    func checkLastQuestion() {
        let url = globalurl + "api/users/" + userid
        
        Alamofire.request(.GET, url, parameters: nil, encoding: .JSON).responseJSON { response in
            
            let json = JSON(response.result.value!)
            print("JSON: \(json)")
            let currentuserid = json["_id"].string
            let firstname = json["firstname"].string
            let lastname = json["lastname"].string
            let updated_at = json["updated_at"].string
            print(updated_at)
            
            var dateFor: NSDateFormatter = NSDateFormatter()
            dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            var yourDate: NSDate? = dateFor.dateFromString(updated_at!)
            let time = yourDate?.timeIntervalSince1970
            
            print(time)
            print(yourDate)
            
            name = firstname! + " " + lastname!
            userid = currentuserid!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.nameButton.selected = true
        self.checkLastQuestion()
        
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
