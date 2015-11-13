//
//  MyQuestionViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 11/2/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MyQuestionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var content = ""
    var id = ""
    
    var contentArray = [String]()
    var idArray = [String]()
    var creatorNameArray = [String]()
    var thankedArray = [Bool]()
    
    func loadAnswers(){
        let url = globalurl + "api/questions/" + id + "/answers/"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                let json = JSON(response.result.value!)
                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    let content = subJson["content"].string
                    let id = subJson["_id"].string
                    var creatorname = subJson["creatorname"].string
                    let anonymous = subJson["anonymous"].string
                    var thanked = subJson["thanked"].bool
                    
                    if creatorname == nil {
                        creatorname = "Anonymous"
                    } else if anonymous == "true" {
                        creatorname = "Anonymous"
                    }
                    
                    if thanked == nil {
                        thanked = false
                    }
                    
                    self.thankedArray.append(thanked!)
                    self.creatorNameArray.append(creatorname!)
                    self.contentArray.append(content!)
                    self.idArray.append(id!)
                    self.tableView.reloadData()
                }
                
        }
        
    }
    
    func loadQuestionContent(){
        let url = globalurl + "api/questions/" + id
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                let json = JSON(response.result.value!)
                print("JSON: \(json)")
                
                let questionContent = json["content"].string
                
                self.content = questionContent!
                self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.allowsSelection = false
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70
        
        self.contentArray.removeAll(keepCapacity: true)
        self.idArray.removeAll(keepCapacity: true)
        self.creatorNameArray.removeAll(keepCapacity: true)
        self.thankedArray.removeAll(keepCapacity: true)
        
        
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
        if section == 0 {
            return 1
        } else  {
            return contentArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: QuestionInfoTableViewCell = tableView.dequeueReusableCellWithIdentifier("QuestionTitleCell", forIndexPath: indexPath) as! QuestionInfoTableViewCell
            cell.headerTextView.text = self.content
            cell.headerTextView.userInteractionEnabled = false
            
            return cell
        } else {
            let cell: MyQuestionAnswerTableViewCell = tableView.dequeueReusableCellWithIdentifier("MyQuestionAnswerCell", forIndexPath: indexPath) as! MyQuestionAnswerTableViewCell
            
            cell.contentTextView.text = contentArray[indexPath.row]
            cell.nameTextView.text = creatorNameArray[indexPath.row]
            cell.contentTextView.userInteractionEnabled = false
            cell.nameTextView.userInteractionEnabled = false
            
            let thanked = thankedArray[indexPath.row]
            
            if thanked == true {
                cell.thankButton.selected = true
            } else {
                cell.thankButton.selected = false
            }
            
            cell.profileImageView.image = UIImage(named: "Placeholder")
            
            cell.thankButton.tag = indexPath.row
            cell.thankButton.addTarget(self, action: "thankAnswer:", forControlEvents: .TouchUpInside)
            cell.thankButton.setTitle("Thanked", forState: .Selected)
            cell.thankButton.setTitle("Thank", forState: .Normal)
            
            
            return cell
        }
    }
    
    func thankAnswer(sender: UIButton) {
        let answerId = idArray[sender.tag]
        
        if sender.selected == false {
            sender.selected = true
            
            let url = globalurl + "api/answers/" + answerId + "/thanked/"
            
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
            }
            
        } else {
            sender.selected = false
            
            let url = globalurl + "api/answers/" + answerId + "/unthanked/"
            
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
            }
        }
    }

}
