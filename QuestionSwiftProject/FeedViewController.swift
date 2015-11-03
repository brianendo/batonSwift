//
//  FeedViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 10/29/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var questionArray = [Question]()
    var myQuestionArray = [Question]()
    
    
    var refreshControl:UIRefreshControl!
    
    func loadData() {
        let url = globalurl + "api/questions-ordered/" + userid
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                }
                
                let json = JSON(value!)
                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    let content = subJson["content"].string
                    let id = subJson["_id"].string
                    let anonymous = subJson["anonymous"].string
                    var answercount = subJson["answercount"].number?.stringValue
                    var creatorname = subJson["creatorname"].string
                    
                    if answercount == nil {
                        answercount = "0"
                    }
                    
                    if creatorname == nil {
                        creatorname = "Anonymous"
                    } else if anonymous == "true" {
                        creatorname = "Anonymous"
                    }
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount)
                    self.questionArray.append(question)
                    
                    self.tableView.reloadData()
                }
        }
    }
    
    func loadMyQuestions() {
        let url = globalurl + "api/myquestions/" + userid
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                }
                
                let json = JSON(value!)
                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    let content = subJson["content"].string
                    let id = subJson["_id"].string
                    let anonymous = subJson["anonymous"].string
                    var answercount = subJson["answercount"].number?.stringValue
                    var creatorname = subJson["creatorname"].string
                    
                    if answercount == nil {
                        answercount = "0"
                    }
                    
                    if creatorname == nil {
                        creatorname = "Anonymous"
                    } else if anonymous == "true" {
                        creatorname = "Anonymous"
                    }
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount)
                    self.myQuestionArray.append(question)

                    self.tableView.reloadData()
                }
        }
    }
    
    func loadUserInfo() {
        let url = globalurl + "api/currentuser"
        let parameters = [
            "firebase_id": currentUser
        ]
        
        Alamofire.request(.POST, url, parameters: parameters)
            .responseJSON { response in
                let json = JSON(response.result.value!)
                print("JSON: \(json)")
                let currentuserid = json["_id"].string
                let firstname = json["firstname"].string
                let lastname = json["lastname"].string
                
                name = firstname! + " " + lastname!
                userid = currentuserid!
                self.tableView.reloadData()
                self.loadData()
                self.loadMyQuestions()
                
        }
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated
                print(authData.uid)
                currentUser = authData.uid
                
                self.tableView.dataSource = self
                self.tableView.delegate = self
                
                self.questionArray.removeAll(keepCapacity: true)
                self.myQuestionArray.removeAll(keepCapacity: true)
                
                self.loadUserInfo()
                
            } else {
                // No user is signed in
                let login = UIStoryboard(name: "LogIn", bundle: nil)
                let loginVC = login.instantiateInitialViewController()
                self.presentViewController(loginVC!, animated: true, completion: nil)
            }
        })

        // Do any additional setup after loading the view.
        self.refreshControl = UIRefreshControl()
//        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func refresh(sender:AnyObject)
    {
        // Code to refresh table view
        self.questionArray.removeAll(keepCapacity: true)
        self.myQuestionArray.removeAll(keepCapacity: true)
        
        self.loadUserInfo()
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
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
            return "My Questions"
        } else {
            return "Open Questions"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return myQuestionArray.count
        } else {
            return questionArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: MyQuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("MyQuestionCell", forIndexPath: indexPath) as! MyQuestionTableViewCell
            
            cell.contentLabel.text = myQuestionArray[indexPath.row].content
            cell.answercountLabel.text = myQuestionArray[indexPath.row].answercount
            
            return cell
        } else {
            let cell: QuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionTableViewCell
            
            cell.contentLabel.text = questionArray[indexPath.row].content
            cell.nameLabel.text = questionArray[indexPath.row].creatorname
            cell.answercountLabel.text = questionArray[indexPath.row].answercount
            
            return cell
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showQuestionDetailVC" {
            let answerVC: AnswerViewController = segue.destinationViewController as! AnswerViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let content = self.questionArray[indexPath!.row].content
            let id = self.questionArray[indexPath!.row].id
            let creatorname = self.questionArray[indexPath!.row].creatorname
            answerVC.content = content
            answerVC.id = id
            answerVC.creatorname = creatorname
        } else if segue.identifier == "showMyQuestionVC" {
            let myQuestionVC: MyQuestionViewController = segue.destinationViewController as! MyQuestionViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let content = self.myQuestionArray[indexPath!.row].content
            let id = self.myQuestionArray[indexPath!.row].id
            myQuestionVC.content = content
            myQuestionVC.id = id
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.performSegueWithIdentifier("showMyQuestionVC", sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            self.performSegueWithIdentifier("showQuestionDetailVC", sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    @IBAction func askQuestionBarButtonPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("showAskQuestionVC", sender: self)
    }
    
    
    @IBAction func logOutButtonPressed(sender: UIBarButtonItem) {
        ref.unauth()
        
        let login = UIStoryboard(name: "LogIn", bundle: nil)
        let loginVC = login.instantiateInitialViewController()
        self.presentViewController(loginVC!, animated: true, completion: nil)
        
    }
    
    

}
