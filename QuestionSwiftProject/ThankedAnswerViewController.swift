//
//  ThankedAnswerViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 11/3/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ThankedAnswerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var id = ""
    var answerContent = ""
    var answerContentArray = [String]()
    var answerCreatorNameArray = [String]()
    
    var questionAskedContent = ""
    var questionCreatorName = ""
    
    func loadQuestionContent(){
        let url = globalurl + "api/questions/" + id
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                let json = JSON(response.result.value!)
                print("JSON: \(json)")
                
                let questionContent = json["content"].string
                var creatorname = json["creatorname"].string
                let anonymous = json["anonymous"].string
                
                if creatorname == nil {
                    creatorname = "Anonymous"
                } else if anonymous == "true" {
                    creatorname = "Anonymous"
                }
                
                self.questionAskedContent = questionContent!
                self.questionCreatorName = creatorname!
                self.tableView.reloadData()
        }
    }
    
    func loadMyAnswer(){
        let url = globalurl + "api/questions/" + id + "/answers-by-user/" + userid
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                let json = JSON(response.result.value!)
                print("JSON: \(json)")
                
                let content = json["content"].string
                
                self.answerContent = content!
                self.tableView.reloadData()
        }
        
    }
    
    func loadAnswers(){
        let url = globalurl + "api/questions/" + id + "/answers/"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                
                let json = JSON(response.result.value!)
                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    
                    let content = subJson["content"].string
                    let creatorname = subJson["creatorname"].string
                    
                    self.answerContentArray.append(content!)
                    self.answerCreatorNameArray.append(creatorname!)
                    self.tableView.reloadData()
                }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.allowsSelection = false
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        
        self.loadQuestionContent()
        self.loadAnswers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        } else {
            return answerContentArray.count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else {
            return "Answers"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: QuestionThankedTableViewCell = tableView.dequeueReusableCellWithIdentifier("questionThankedCell", forIndexPath: indexPath) as! QuestionThankedTableViewCell
            
            cell.profileImageView.image = UIImage(named: "Placeholder")
            cell.nameTextView.text = self.questionCreatorName
            cell.questionTextView.text = self.questionAskedContent
            cell.nameTextView.userInteractionEnabled = false
            cell.questionTextView.userInteractionEnabled = false
            
            return cell
        } else {
            let cell: QuestionThankedTableViewCell = tableView.dequeueReusableCellWithIdentifier("questionThankedCell", forIndexPath: indexPath) as! QuestionThankedTableViewCell
            
            cell.profileImageView.image = UIImage(named: "Placeholder")
            cell.nameTextView.text = self.answerCreatorNameArray[indexPath.row]
            cell.questionTextView.text = self.answerContentArray[indexPath.row]
            
            cell.nameTextView.userInteractionEnabled = false
            cell.questionTextView.userInteractionEnabled = false
            
            return cell
        }
        
    }
    

}
