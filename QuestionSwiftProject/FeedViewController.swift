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
import AWSS3

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var questionArray = [Question]()
    var myQuestionArray = [Question]()
    var selectedIndexPath = 0
    
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
                    var answercount = subJson["answercount"].number?.integerValue
                    var creatorname = subJson["creatorname"].string
                    let answeredBy = subJson["answered_by"]
                    let creator = subJson["creator"].string
                    var answered = false
                    var user = false
                    let createdAt = subJson["created_at"].string
                    
                    let dateFor: NSDateFormatter = NSDateFormatter()
                    dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
                    
                    if creator == userid {
                        user = true
                    }
                    
                    for (_,subJson):(String, JSON) in answeredBy {
                        let answerer = subJson.string
                        if answerer == userid {
                            answered = true
                        }
                    }
                    
                    if answercount == nil {
                        answercount = 0
                    }
                    
                    if creatorname == nil {
                        creatorname = "Anonymous"
                    } else if anonymous == "true" {
                        creatorname = "Anonymous"
                    }
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: answered, currentuser: user, createdAt: yourDate, creator: creator)
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
                    var answercount = subJson["answercount"].number?.integerValue
                    var creatorname = subJson["creatorname"].string
                    let answeredBy = subJson["answered_by"]
                    let creator = subJson["creator"].string
                    var answered = false
                    var user = false
                    let createdAt = subJson["created_at"].string
                    
                    let dateFor: NSDateFormatter = NSDateFormatter()
                    dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
                    
                    if creator == userid{
                        user = true
                    }
                    
                    for (_,subJson):(String, JSON) in answeredBy {
                        let answerer = subJson.string
                        if answerer == userid {
                            answered = true
                        }
                    }
                    
                    if answercount == nil {
                        answercount = 0
                    }
                    
                    if creatorname == nil {
                        creatorname = "Anonymous"
                    } else if anonymous == "true" {
                        creatorname = "Anonymous"
                    }
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: answered, currentuser: user, createdAt: yourDate, creator: creator)
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
                var value = response.result.value
                
                if value == nil {
                    value = []
                } else {
                    let json = JSON(value!)
                    print("JSON: \(json)")
                    let currentuserid = json["_id"].string
                    let firstname = json["firstname"].string
                    let lastname = json["lastname"].string
                    
                    name = firstname! + " " + lastname!
                    userid = currentuserid!
                    self.tableView.reloadData()
                    self.loadData()
                }
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
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                self.tableView.rowHeight = UITableViewAutomaticDimension
                self.tableView.estimatedRowHeight = 80
                
                self.questionArray.removeAll(keepCapacity: true)
                self.myQuestionArray.removeAll(keepCapacity: true)
                
                self.loadUserInfo()
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeFeed", name: "submittedAnswer", object: nil)
                 NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFeed", name: "askedQuestion", object: nil)
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
    
    func changeFeed(){
        let count = questionArray[selectedIndexPath].answercount
        questionArray[selectedIndexPath].answercount = count + 1
        questionArray[selectedIndexPath].answered = true
        self.tableView.reloadData()
    }
    
    func refreshFeed(){
        self.questionArray.removeAll(keepCapacity: true)
        self.myQuestionArray.removeAll(keepCapacity: true)
        self.loadData()
        self.tableView.reloadData()
    }
    
    func refresh(sender:AnyObject){
        // Code to refresh table view
        self.questionArray.removeAll(keepCapacity: true)
        self.myQuestionArray.removeAll(keepCapacity: true)
        
        self.loadUserInfo()
        self.tableView.reloadData()
        
        let delayInSeconds = 1.5;
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            self.refreshControl!.endRefreshing()
        }
    }

    func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [NSCalendarUnit.Minute, NSCalendarUnit.Hour, NSCalendarUnit.Day, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.Second]
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:NSDateComponents = calendar.components(unitFlags, fromDate: earliest, toDate: latest, options: [])
        
        
        if (components.year >= 2) {
            return "\(components.year) years ago"
        } else if (components.year >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month >= 2) {
            return "\(components.month) months ago"
        } else if (components.month >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear >= 2) {
            return "\(components.weekOfYear) weeks ago"
        } else if (components.weekOfYear >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day >= 2) {
            return "\(components.day)d"
        } else if (components.day >= 1){
            if (numericDates){
                return "1d"
            } else {
                return "Yesterday"
            }
        } else if (components.hour >= 2) {
            return "\(components.hour)h"
        } else if (components.hour >= 1){
            if (numericDates){
                return "1h"
            } else {
                return "An hour ago"
            }
        } else if (components.minute >= 2) {
            return "\(components.minute)m"
        } else if (components.minute >= 1){
            if (numericDates){
                return "1m"
            } else {
                return "A minute ago"
            }
        } else if (components.second >= 3) {
            return "\(components.second)s"
        } else {
            return "1s"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return "My Questions"
//        } else {
//            return "Open Questions"
//        }
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return myQuestionArray.count
//        } else {
//            return questionArray.count
//        }
        return questionArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            let cell: MyQuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("MyQuestionCell", forIndexPath: indexPath) as! MyQuestionTableViewCell
//            
//            cell.contentLabel.text = myQuestionArray[indexPath.row].content
//            cell.answercountLabel.text = myQuestionArray[indexPath.row].answercount
//            
//            return cell
//        } else {
//            let cell: QuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionTableViewCell
//            
//            cell.contentLabel.text = questionArray[indexPath.row].content
//            cell.nameLabel.text = questionArray[indexPath.row].creatorname
//            cell.answercountLabel.text = questionArray[indexPath.row].answercount
//            
//            return cell
//        }
        let cell: QuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.questionTextView.text = questionArray[indexPath.row].content
        cell.questionTextView.userInteractionEnabled = false
        
        let creatorname = questionArray[indexPath.row].creatorname
        cell.nameTextView.text = creatorname
        cell.nameTextView.userInteractionEnabled = false
        let answercount = questionArray[indexPath.row].answercount
        
        let answered = questionArray[indexPath.row].answered
        let userStatus = questionArray[indexPath.row].currentuser
        
        if answered == true {
            cell.backgroundColor = UIColor.grayColor()
        } else if userStatus == true {
            cell.backgroundColor = UIColor.lightGrayColor()
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        cell.answercountLabel.text =  "\(answercount)/2"
        
        let date = questionArray[indexPath.row].createdAt
        let timeAgo = timeAgoSinceDate(date, numericDates: true)
        
        cell.timeAgoLabel.text = timeAgo
        
        let creator = questionArray[indexPath.row].creator
        
        cell.profileImageView.image = UIImage(named: "Placeholder")
        if creatorname == "Anonymous" {
            cell.profileImageView.image = UIImage(named: "Placeholder")
        } else {
            cell.profileImageView.image = UIImage(named: "Placeholder")
            if let cachedImageResult = imageCache[creator] {
                print("pull from cache")
                cell.profileImageView.image = UIImage(data: cachedImageResult!)
            } else {
                // 3
                cell.profileImageView.image = UIImage(named: "Placeholder")
                
                // 4
                let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp-download")
                let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                
                
                let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
                readRequest1.bucket = S3BucketName
                readRequest1.key = creator
                readRequest1.downloadingFileURL = downloadingFileURL1
                
                let task = transferManager.download(readRequest1)
                task.continueWithBlock { (task) -> AnyObject! in
                    if task.error != nil {
                        print("No Profile Pic")
                    } else {
                        let image = UIImage(contentsOfFile: downloadingFilePath1)
                        let imageData = UIImageJPEGRepresentation(image!, 1.0)
                        imageCache[currentUser] = imageData
                        dispatch_async(dispatch_get_main_queue()
                            , { () -> Void in
                                cell.profileImageView.image = UIImage(contentsOfFile: downloadingFilePath1)
                                cell.setNeedsLayout()
                                
                        })
                        print("Fetched image")
                    }
                    return nil
                }
            }
        }
        return cell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMyQuestionVC" {
            let myQuestionVC: MyQuestionViewController = segue.destinationViewController as! MyQuestionViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let content = self.questionArray[indexPath!.row].content
            let id = self.questionArray[indexPath!.row].id
            myQuestionVC.content = content
            myQuestionVC.id = id
        } else if segue.identifier == "showSubmitAnswerVC" {
            let answerVC: SubmitAnswerViewController = segue.destinationViewController as! SubmitAnswerViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let content = self.questionArray[indexPath!.row].content
            let id = self.questionArray[indexPath!.row].id
            let creatorname = self.questionArray[indexPath!.row].creatorname
            self.selectedIndexPath = indexPath!.row
            answerVC.content = content
            answerVC.id = id
            answerVC.creatorname = creatorname
        } else if segue.identifier == "feedToThankedAnswerVC" {
            let thankedAnswerVC: ThankedAnswerViewController = segue.destinationViewController as! ThankedAnswerViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let id = self.questionArray[indexPath!.row].id
            thankedAnswerVC.id = id
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.section == 0 {
//            self.performSegueWithIdentifier("showMyQuestionVC", sender: self)
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        } else {
//            self.performSegueWithIdentifier("showQuestionDetailVC", sender: self)
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        }
        
//        self.performSegueWithIdentifier("showQuestionDetailVC", sender: self)
        if questionArray[indexPath.row].currentuser == true {
            self.performSegueWithIdentifier("showMyQuestionVC", sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else if questionArray[indexPath.row].answered == true {
            self.performSegueWithIdentifier("feedToThankedAnswerVC", sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            self.performSegueWithIdentifier("showSubmitAnswerVC", sender: self)
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
