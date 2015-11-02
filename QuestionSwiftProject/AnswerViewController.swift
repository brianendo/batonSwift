//
//  AnswerViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 10/29/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AnswerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var content = ""
    var id = ""
    var creatorname = ""
    
    var contentArray = [String]()
    var idArray = [String]()
    var creatorNameArray = [String]()
    
    func loadAnswers(){
        let url = "http://localhost:3000/api/questionanswers"
        let parameters = [
            "question_id": id
        ]
        
        Alamofire.request(.POST, url, parameters: parameters)
            .responseJSON { response in
                let json = JSON(response.result.value!)
                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    let content = subJson["content"].string
                    let id = subJson["_id"].string
                    var creatorname = subJson["creatorname"].string
                    let anonymous = subJson["anonymous"].string
                    
                    if creatorname == nil {
                        creatorname = "Anonymous"
                    } else if anonymous == "true" {
                        creatorname = "Anonymous"
                    }
                    
                    self.creatorNameArray.append(creatorname!)
                    self.contentArray.append(content!)
                    self.idArray.append(id!)
                    self.tableView.reloadData()
                }
                
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.contentArray.removeAll(keepCapacity: true)
        self.idArray.removeAll(keepCapacity: true)
        self.creatorNameArray.removeAll(keepCapacity: true)
        
        self.loadAnswers()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else {
            return "Answers"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return contentArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: QuestionDetailTableViewCell = tableView.dequeueReusableCellWithIdentifier("TopCell", forIndexPath: indexPath) as! QuestionDetailTableViewCell
            
            cell.contentLabel.text = self.content
            cell.nameLabel.text = self.creatorname
            
            return cell
        } else {
            let cell: AnswerDetailTableViewCell = tableView.dequeueReusableCellWithIdentifier("AnswerCell", forIndexPath: indexPath) as! AnswerDetailTableViewCell
            
            cell.contentLabel.text = contentArray[indexPath.row]
            cell.nameLabel.text = creatorNameArray[indexPath.row]
            
            return cell
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSubmitAnswerVC" {
            let submitAnswerVC: SubmitAnswerViewController = segue.destinationViewController as! SubmitAnswerViewController
            submitAnswerVC.id = self.id
        }
    }
    
    @IBAction func answerBarButtonPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("showSubmitAnswerVC", sender: self)
    }
    

}
