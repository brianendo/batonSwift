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
    
    var contentArray = [String]()
    var idArray = [String]()
    var creatorNameArray = [String]()
    
    func loadData() {
        let url = "http://localhost:3000/api/questionsordered"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                let json = JSON(response.result.value!)
                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    let content = subJson["content"].string
                    let id = subJson["_id"].string
                    let anonymous = subJson["anonymous"].string
                    
                    var creatorname = subJson["creatorname"].string
                    
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
    
    func loadUserInfo() {
        let url = "http://localhost:3000/api/currentuser"
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
                
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated
                print(authData.uid)
                currentUser = authData.uid
                
                self.loadUserInfo()
                
                self.tableView.dataSource = self
                self.tableView.delegate = self
                
                self.contentArray.removeAll(keepCapacity: true)
                self.idArray.removeAll(keepCapacity: true)
                self.creatorNameArray.removeAll(keepCapacity: true)
                self.loadData()
                
            } else {
                // No user is signed in
                let login = UIStoryboard(name: "LogIn", bundle: nil)
                let loginVC = login.instantiateInitialViewController()
                self.presentViewController(loginVC!, animated: true, completion: nil)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: QuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionTableViewCell
        
        cell.contentLabel.text = contentArray[indexPath.row]
        cell.nameLabel.text = creatorNameArray[indexPath.row]
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showQuestionDetailVC" {
            let answerVC: AnswerViewController = segue.destinationViewController as! AnswerViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let content = self.contentArray[indexPath!.row]
            let id = self.idArray[indexPath!.row]
            let creatorname = self.creatorNameArray[indexPath!.row]
            answerVC.content = content
            answerVC.id = id
            answerVC.creatorname = creatorname
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showQuestionDetailVC", sender: self)
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
