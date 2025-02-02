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
import AWSS3
import Crashlytics

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    var notificationArray = [Notification]()
    var refreshControl:UIRefreshControl!
    var counter = 0
    var notificationIndex = 0
    let interactor = Interactor()
    
    // MARK: - viewWill/viewDid
    override func viewWillAppear(animated: Bool) {
        
        self.tabBarController!.tabBar.hidden = false
        let tabItem = self.tabBarController?.viewControllers![2]
//        tabItem?.tabBarItem.image = UIImage(named: "thickerBell")
        tabItem?.tabBarItem.badgeValue = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Makes sure that readAll is not called if there are no new notifications
        if counter > 0 {
            self.counter = 0
            self.readAll()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Notifications"
        self.definesPresentationContext = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.scrollsToTop = true
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70
        self.tableView.tableFooterView = UIView()
        
//        self.notificationArray.removeAll(keepCapacity: true)
        self.loadNotifications()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFeed", name: "newNotification", object: nil)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    // MARK: - functions
    func loadNotifications(){
        let url = globalurl + "api/users/" + userid + "/notifications/"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                    print("No notifications")
                    self.tableView.hidden = true
                    let label = UILabel(frame: CGRectMake(0, 0, 400, 400))
                    label.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, 100)
                    label.textAlignment = NSTextAlignment.Center
                    label.text = "No Notifications"
                    label.font = UIFont(name: "HelveticaNeue-Light", size: 35)
                    label.numberOfLines = 0
                    self.view.addSubview(label)
                    
                } else {
                    self.notificationArray.removeAll(keepCapacity: true)
                    self.tableView.hidden = false
                    let json = JSON(response.result.value!)
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    let type = subJson["type"].string
                    
                    let id = subJson["_id"].string
                    let sender = subJson["sender"].string
                    
                    var sendername = subJson["sendername"].string
                    let anonymous = subJson["anonymous"].string
                    var question_id = subJson["question_id"].string
                    if question_id == nil {
                        question_id = ""
                    }
                    var read = subJson["read"].bool
                    var answer_id = subJson["answer_id"].string
                    if answer_id == nil {
                        answer_id = ""
                    }
                    let createdAt = subJson["created_at"].string
                    
                    let dateFor: NSDateFormatter = NSDateFormatter()
                    dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
                    
                    
                    if sendername == nil {
                        sendername = "Anonymous"
                    } else if anonymous == "true" {
                        sendername = "Anonymous"
                    }
                    
                    if read == false {
                        self.counter++
                    }
                    
                    if read == nil {
                        read = false
                    }
                    
                    var question_content = subJson["question_content"].string
                    if question_content == nil {
                        question_content = ""
                    }
                    
                    var featuredQuestion = subJson["featuredQuestion"].bool
                    if featuredQuestion == nil {
                        featuredQuestion = false
                    }
                    
                    var thumbnail_url = subJson["thumbnail_url"].string
                    
                    if thumbnail_url == nil {
                        thumbnail_url = ""
                    }
                    
                    let notification = Notification(id: id, type: type, sender: sender, sendername: sendername, question_id: question_id, read: read, content: question_content, createdAt: yourDate, answer_id: answer_id, thumbnail_url: thumbnail_url, featuredQuestion: featuredQuestion)
                    self.notificationArray.append(notification)
                    self.notificationArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                    self.tableView.reloadData()
                    
                }

                }
                                
        }
        
    }
    
    
    
    
    func readAll() {
        let url = globalurl + "api/notifications/" + userid + "/readall"
        
        Alamofire.request(.PUT, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                }
                self.counter = 0
                self.loadNotifications()
        }
    }
    
    
    func refreshFeed(){
        self.loadNotifications()
    }
    
    func refresh(sender:AnyObject)
    {
        // Code to refresh table view
        self.readAll()
        let delayInSeconds = 1.0;
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            self.refreshControl!.endRefreshing()
        }
    }
    
    // MARK: - tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let type = notificationArray[indexPath.row].type
        let sendername = notificationArray[indexPath.row].sendername
        let read = notificationArray[indexPath.row].read
        let sender = notificationArray[indexPath.row].sender
        
        if type == "answer" {
            let cell: NotificationAnswerTableViewCell = tableView.dequeueReusableCellWithIdentifier("notificationAnswerCell", forIndexPath: indexPath) as! NotificationAnswerTableViewCell
            if read == false {
                cell.backgroundColor = UIColor(white:0.91, alpha:1.0)
            } else if read == true {
                cell.backgroundColor = UIColor.whiteColor()
            }
            let postedText = "\(sendername) "
            let myFirstString = NSMutableAttributedString(string: postedText, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Medium", size: 16.0)!])
            
            let creatornameText = "answered your question"
            let mySecondString = NSMutableAttributedString(string: creatornameText, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 16.0)!])
            
            let result = NSMutableAttributedString()
            result.appendAttributedString(myFirstString)
            result.appendAttributedString(mySecondString)
            
            cell.headerTextView.attributedText = result
            let answerContent = notificationArray[indexPath.row].content
            
            cell.contentTextView.text = "\"\(answerContent)\""
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            cell.headerTextView.userInteractionEnabled = false
            cell.contentTextView.userInteractionEnabled = false
            
            cell.profileImageView.image = UIImage(named: "Placeholder")
            if let cachedImageResult = imageCache[sender] {
                print("pull from cache")
                cell.profileImageView.image = UIImage(data: cachedImageResult!)
            } else {
                cell.profileImageView.image = UIImage(named: "Placeholder")
                let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp-download")
                let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                
                let key = "profilePics/" + sender
                let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
                readRequest1.bucket = S3BucketName
                readRequest1.key =  key
                readRequest1.downloadingFileURL = downloadingFileURL1
                
                let task = transferManager.download(readRequest1)
                task.continueWithBlock { (task) -> AnyObject! in
                    if task.error != nil {
                        print("No Profile Pic")
                    } else {
                        let image = UIImage(contentsOfFile: downloadingFilePath1)
                        let imageData = UIImageJPEGRepresentation(image!, 1.0)
                        imageCache[sender] = imageData
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
            
            return cell
        } else if type == "like"{
            let cell: NotificationLikedTableViewCell = tableView.dequeueReusableCellWithIdentifier("notificationLikedCell", forIndexPath: indexPath) as! NotificationLikedTableViewCell
            if read == false {
                cell.backgroundColor = UIColor(white:0.91, alpha:1.0)
            } else if read == true {
                cell.backgroundColor = UIColor.whiteColor()
            }
            
            let notificationId = notificationArray[indexPath.row].id
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            let postedText = "\(sendername) "
            let myFirstString = NSMutableAttributedString(string: postedText, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Medium", size: 16.0)!])
            
            let creatornameText = "liked your answer"
            let mySecondString = NSMutableAttributedString(string: creatornameText, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 16.0)!])
            
            let result = NSMutableAttributedString()
            result.appendAttributedString(myFirstString)
            result.appendAttributedString(mySecondString)
            
            cell.contentTextView.attributedText = result
            
            cell.contentTextView.userInteractionEnabled = false
            
            cell.profileImageView.image = UIImage(named: "Placeholder")
            if let cachedImageResult = imageCache[sender] {
                print("pull from cache")
                cell.profileImageView.image = UIImage(data: cachedImageResult!)
            } else {
                cell.profileImageView.image = UIImage(named: "Placeholder")
                
                let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp-download")
                let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                
                let key = "profilePics/" + sender
                let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
                readRequest1.bucket = S3BucketName
                readRequest1.key =  key
                readRequest1.downloadingFileURL = downloadingFileURL1
                
                let task = transferManager.download(readRequest1)
                task.continueWithBlock { (task) -> AnyObject! in
                    if task.error != nil {
                        print("No Profile Pic")
                    } else {
                        let image = UIImage(contentsOfFile: downloadingFilePath1)
                        let imageData = UIImageJPEGRepresentation(image!, 1.0)
                        imageCache[sender] = imageData
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
            
            let thumbnail = notificationArray[indexPath.row].thumbnail_url
            cell.thumbnailImageView.clipsToBounds = true
            cell.thumbnailImageView.image = UIImage(named: "Placeholder")
            
            if thumbnail == "" {
                
            } else {
                if let cachedImageResult = imageCache[notificationId] {
                    print("pull from cache")
                    cell.thumbnailImageView.image = UIImage(data: cachedImageResult!)
                } else {
                    // 3
                    cell.thumbnailImageView.image = UIImage(named: "Placeholder")
                    let url = NSURL(string: thumbnail)
                    let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                    imageCache[notificationId] = data
                    cell.thumbnailImageView.image = UIImage(data: data!)
                }
                
            }
            
            cell.thumbnailButton.addTarget(self, action: "thumbnailTapped:", forControlEvents: .TouchUpInside)
            cell.thumbnailButton.tag = indexPath.row
            
            return cell
        }
        // Following notifications
        else {
            let cell: NotificationFollowTableViewCell = tableView.dequeueReusableCellWithIdentifier("notificationFollowCell", forIndexPath: indexPath) as! NotificationFollowTableViewCell
            if read == false {
                cell.backgroundColor = UIColor(white:0.91, alpha:1.0)
            } else if read == true {
                cell.backgroundColor = UIColor.whiteColor()
            }
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            let postedText = "\(sendername) "
            let myFirstString = NSMutableAttributedString(string: postedText, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Medium", size: 16.0)!])
            
            let creatornameText = "followed you"
            let mySecondString = NSMutableAttributedString(string: creatornameText, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 16.0)!])
            
            let result = NSMutableAttributedString()
            result.appendAttributedString(myFirstString)
            result.appendAttributedString(mySecondString)
            
            cell.contentTextView.attributedText = result
            
            cell.contentTextView.userInteractionEnabled = false
            
            cell.followButton.tag = indexPath.row
            cell.followButton.addTarget(self, action: "toggleFollow:", forControlEvents: .TouchUpInside)
            cell.followButton.setImage(UIImage(named: "addperson"), forState: .Normal)
            cell.followButton.setImage(UIImage(named: "addedperson"), forState: .Selected)
            cell.followButton.selected = false
            
            cell.profileImageView.image = UIImage(named: "Placeholder")
            if let cachedImageResult = imageCache[sender] {
                print("pull from cache")
                cell.profileImageView.image = UIImage(data: cachedImageResult!)
            } else {
                cell.profileImageView.image = UIImage(named: "Placeholder")
                
                let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp-download")
                let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                
                let key = "profilePics/" + sender
                let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
                readRequest1.bucket = S3BucketName
                readRequest1.key =  key
                readRequest1.downloadingFileURL = downloadingFileURL1
                
                let task = transferManager.download(readRequest1)
                task.continueWithBlock { (task) -> AnyObject! in
                    if task.error != nil {
                        print("No Profile Pic")
                    } else {
                        let image = UIImage(contentsOfFile: downloadingFilePath1)
                        let imageData = UIImageJPEGRepresentation(image!, 1.0)
                        imageCache[sender] = imageData
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
            
            let url = globalurl + "api/user/" + userid + "/follows/" + notificationArray[indexPath.row].sender
            
            Alamofire.request(.GET, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Not Following")
                        cell.followButton.selected = false
                    } else {
                        print("Already Following")
                        cell.followButton.selected = true
                    }
            }
            
            return cell
        }
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let type = notificationArray[indexPath.row].type
        let id = notificationArray[indexPath.row].id
        let read = notificationArray[indexPath.row].read
        
        
        if read == false  {
            
            let url = globalurl + "api/notifications/" + id + "/read/"
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
            }
            
            if type == "answer"  {
                Answers.logCustomEventWithName("Notification Clicked",
                    customAttributes: ["read": false, "type": type])
                notificationIndex = indexPath.row
                self.performSegueWithIdentifier("segueFromNotificationToVideoView", sender: self)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            } else {
                Answers.logCustomEventWithName("Notification Clicked",
                    customAttributes: ["read": false, "type": type])
                notificationIndex = indexPath.row
                self.performSegueWithIdentifier("segueFromNotificationsToProfile", sender: self)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
            
        } else {
            if type == "answer" {
                Answers.logCustomEventWithName("Notification Clicked",
                    customAttributes: ["read": true, "type": type])
                notificationIndex = indexPath.row
                self.performSegueWithIdentifier("segueFromNotificationToVideoView", sender: self)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            } else {
                Answers.logCustomEventWithName("Notification Clicked",
                    customAttributes: ["read": true, "type": type])
                notificationIndex = indexPath.row
                self.performSegueWithIdentifier("segueFromNotificationsToProfile", sender: self)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    // MARK: - tableView functions
    func thumbnailTapped(sender:UIButton) {
        self.notificationIndex = sender.tag
        self.performSegueWithIdentifier("segueFromNotificationToVideoView", sender: self)
    }
    
    func toggleFollow(sender:UIButton!) {
        let tag = sender.tag
        let creatorId = self.notificationArray[tag].sender
        
        if sender.selected == false {
            sender.selected = true
            let url = globalurl + "api/user/" + userid + "/follows/" + creatorId
            
            Alamofire.request(.POST, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Already Followed")
                    } else {
                        print("Following")
                    }
            }
        } else {
            sender.selected = false
            let url = globalurl + "api/user/" + userid + "/unfollows/" + creatorId
            
            Alamofire.request(.DELETE, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Could not remove")
                    } else {
                        print("Removed")
                    }
            }
        }
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToAnsweredQuestionVC" {
            let answeredQuestionVC: AnsweredQuestionViewController = segue.destinationViewController as! AnsweredQuestionViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            print(self.notificationArray[indexPath!.row])
            let questionId = self.notificationArray[indexPath!.row].question_id
            let answerId = self.notificationArray[indexPath!.row].answer_id
            let featuredQuestion = self.notificationArray[indexPath!.row].featuredQuestion
            if featuredQuestion {
                answeredQuestionVC.fromFeatured = true
            }
            answeredQuestionVC.questionId = questionId
            answeredQuestionVC.answerId = answerId
            notificationArray[indexPath!.row].read = true
            self.tableView.reloadData()
        } else if segue.identifier == "segueFromNotificationsToProfile" {
            let profileVC: ProfileViewController = segue.destinationViewController as! ProfileViewController
            let creatorId = notificationArray[notificationIndex].sender
            let creatorname = notificationArray[notificationIndex].sendername
            profileVC.fromOtherVC = true
            profileVC.creatorId = creatorId
            profileVC.creatorname = creatorname
            notificationArray[notificationIndex].read = true
            self.tableView.reloadData()

        } else if segue.identifier == "segueFromNotificationToVideoView" {
            let videoVC: VideoViewController = segue.destinationViewController as! VideoViewController
            let answerId = notificationArray[notificationIndex].answer_id
            videoVC.answerId = answerId
            videoVC.fromNotification = true
            videoVC.transitioningDelegate = self
            videoVC.interactor = interactor
            notificationArray[notificationIndex].read = true
            self.tableView.reloadData()
        }
    }
    

}

extension NotificationViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
