//
//  NotificationViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 11/3/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var notificationArray = [Notification]()
    
    var refreshControl:UIRefreshControl!
    
    func loadNotifications(){
        let url = globalurl + "api/users/" + userid + "/notifications/"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                } else {
                    let json = JSON(response.result.value!)
                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    let type = subJson["type"].string
                    let id = subJson["_id"].string
                    let sender = subJson["sender"].string
                    
                    var sendername = subJson["sendername"].string
                    let anonymous = subJson["anonymous"].string
                    let question_id = subJson["question_id"].string
                    var read = subJson["read"].bool
                    let answer_id = subJson["answer_id"].string
                    let createdAt = subJson["created_at"].string
                    
                    let dateFor: NSDateFormatter = NSDateFormatter()
                    dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
                    
                    
                    if sendername == nil {
                        sendername = "Anonymous"
                    } else if anonymous == "true" {
                        sendername = "Anonymous"
                    }
                    
                    if read == nil {
                        read = false
                    }
                    
                    if type == "answer" {
                        
                        let newUrl = globalurl + "api/questions/" + question_id!
                        
                        Alamofire.request(.GET, newUrl, parameters: nil)
                            .responseJSON { response in
                                var value = response.result.value
                                
                                if value == nil {
                                    value = []
                                }
                                
                                let json = JSON(value!)
                                print("JSON: \(json)")
                                
                                let content = json["content"].string
                                let notification = Notification(id: id, type: type, sender: sender, sendername: sendername, question_id: question_id, read: read, content: content, createdAt: yourDate)
                                self.notificationArray.append(notification)
                                self.notificationArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                
                                self.tableView.reloadData()
                        }
                    } else if type == "thank"{
                        let newUrl = globalurl + "api/answers/" + answer_id!
                        
                        Alamofire.request(.GET, newUrl, parameters: nil)
                            .responseJSON { response in
                                var value = response.result.value
                                
                                if value == nil {
                                    value = []
                                }
                                
                                let json = JSON(value!)
                                print("JSON: \(json)")
                                
                                let content = json["content"].string
                                let notification = Notification(id: id, type: type, sender: sender, sendername: sendername, question_id: question_id, read: read, content: content, createdAt: yourDate)
                                self.notificationArray.append(notification)
                                self.notificationArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                
                                self.tableView.reloadData()
                        }
                    }
                }

                }
                                
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70
        
        self.notificationArray.removeAll(keepCapacity: true)
        self.loadNotifications()
        
        self.refreshControl = UIRefreshControl()
        //        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func refresh(sender:AnyObject)
    {
        // Code to refresh table view
        self.notificationArray.removeAll(keepCapacity: true)
        
        self.loadNotifications()
        let delayInSeconds = 1.5;
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            self.refreshControl!.endRefreshing()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: NotificationAnswerTableViewCell = tableView.dequeueReusableCellWithIdentifier("notificationAnswerCell", forIndexPath: indexPath) as! NotificationAnswerTableViewCell
        
        let type = notificationArray[indexPath.row].type
        let sendername = notificationArray[indexPath.row].sendername
        let read = notificationArray[indexPath.row].read
        
        if read == false {
            cell.backgroundColor = UIColor.grayColor()
        } else if read == true {
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        if type == "answer" {
            cell.headerTextView.text = "\(sendername) answered your question:"
        } else if type == "thank" {
            cell.headerTextView.text = "\(sendername) thanked your answer:"
        }
        
        let answerContent = notificationArray[indexPath.row].content
        
        cell.contentTextView.text = "\"\(answerContent)\""
        cell.headerTextView.userInteractionEnabled = false
        cell.contentTextView.userInteractionEnabled = false
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let type = notificationArray[indexPath.row].type
        let id = notificationArray[indexPath.row].id
        
        if type == "answer" {
            let url = globalurl + "api/notifications/" + id + "/read/"
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
            }
            
            self.performSegueWithIdentifier("notificationToMyQuestion", sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            let url = globalurl + "api/notifications/" + id + "/read/"
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
            }
            
            self.performSegueWithIdentifier("notificationToThankedAnswer", sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "notificationToMyQuestion" {
            let myQuestionVC: MyQuestionViewController = segue.destinationViewController as! MyQuestionViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let id = self.notificationArray[indexPath!.row].question_id
            myQuestionVC.id = id
            notificationArray[indexPath!.row].read = true
            self.tableView.reloadData()
        } else if segue.identifier == "notificationToThankedAnswer" {
            let thankedAnswerVC: ThankedAnswerViewController = segue.destinationViewController as! ThankedAnswerViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let id = self.notificationArray[indexPath!.row].question_id
            thankedAnswerVC.id = id
            notificationArray[indexPath!.row].read = true
            self.tableView.reloadData()
        }
    }
    

}
