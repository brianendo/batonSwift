//
//  FeaturedVideoViewController.swift
//  Baton
//
//  Created by Brian Endo on 3/8/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import AVKit
import AVFoundation
import SwiftyJSON
import AWSS3
import TwitterKit
import MessageUI
import FBSDKShareKit
import Crashlytics

class FeaturedVideoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var answerArray = [Answer]()
    var questionIndex = 0
    var tag = 0
    
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Pause players when leaving vc
        for cell in tableView.visibleCells {
            if cell.isKindOfClass(FeaturedVideoTableViewCell) {
                let indexPath = tableView.indexPathForCell(cell)
                let cellRect = tableView.rectForRowAtIndexPath(indexPath!)
                let superView = tableView.superview
                let convertedRect = tableView.convertRect(cellRect, toView: superView)
                let intersect = CGRectIntersection(tableView.frame, convertedRect)
                let visibleHeight = CGRectGetHeight(intersect)
                let cellHeight = tableView.frame.height * 0.6
                let cell = cell as! FeaturedVideoTableViewCell
                
                if visibleHeight > cellHeight {
                    if (cell.player.rate > 0) {
                        cell.player.pause()
                        
                    } else {
                    }
                } else {
                    cell.player.pause()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Featured"
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.scrollsToTop = true
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.loadAnswers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadAnswers(){
        let url = globalurl + "api/featuredanswers"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                if value == nil {
                    value = []
                    
                } else {
                    let json = JSON(value!)
                    //                print("JSON: \(json)")
                    if json == [] {
                        print("No answers")
                    }
                    for (_,subJson):(String, JSON) in json {
                        //Do something you want
                        
                        let id = subJson["_id"].string
                        let creator = subJson["creator"].string
                        let creatorname = subJson["creatorname"].string
                        let video_url = subJson["video_url"].string
                        var likeCount = subJson["likes"].int
                        var frontCamera = subJson["frontCamera"].bool
                        var question_id = subJson["question_id"].string
                        var views = subJson["views"].number?.integerValue
                        if views == nil {
                            views = 0
                        }
                        var featuredQuestion = subJson["featuredQuestion"].bool
                        
                        if featuredQuestion == nil {
                            featuredQuestion = false
                        }
                        
                        var question_content = subJson["question_content"].string
                        if question_content == nil {
                            question_content = ""
                        }
                        
                        let createdAt = subJson["created_at"].string
                        let dateFor: NSDateFormatter = NSDateFormatter()
                        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
                        
                        if question_id == nil {
                            question_id = ""
                        }
                        
                        if frontCamera == nil {
                            frontCamera = false
                        }
                        
                        if likeCount == nil {
                            likeCount = 0
                        }
                        
                        if video_url != nil {
                            print(video_url)
                            
                            if question_content == "" {
                                let url = globalurl + "api/questions/" + question_id!
                                
                                Alamofire.request(.GET, url, parameters: nil)
                                    .responseJSON { response in
                                        let json = JSON(response.result.value!)
                                        print("JSON: \(json)")
                                        if json == [] {
                                            print("No answers")
                                        }
                                        var content = json["content"].string
                                        print(content)
                                        
                                        if content == nil {
                                            content = ""
                                        }
                                        
                                        let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: content, video_url: video_url, likeCount: likeCount, liked_by_user: "not checked", frontCamera: frontCamera, createdAt: yourDate, views: views, featuredQuestion: featuredQuestion, followingCreator: "not checked")
                                        self.answerArray.append(answer)
                                        self.answerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                }
                            } else {
                                let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: question_content, video_url: video_url, likeCount: likeCount, liked_by_user: "not checked", frontCamera: frontCamera, createdAt: yourDate, views: views, featuredQuestion: featuredQuestion, followingCreator: "not checked")
                                self.answerArray.append(answer)
                                self.answerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                
                                
                            }
                        }
                        
                        self.tableView.reloadData()
                    }
                }
                
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answerArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FeaturedVideoTableViewCell = tableView.dequeueReusableCellWithIdentifier("featuredVideoCell", forIndexPath: indexPath) as! FeaturedVideoTableViewCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        let question_content = answerArray[indexPath.row].question_content
        let question_id = answerArray[indexPath.row].question_id
        
        cell.questionContentTextView.text = question_content
        cell.questionContentTextView.editable = false
        cell.questionContentTextView.selectable = false
        
        let creatorname = answerArray[indexPath.row].creatorname
        
        // Add Attributes to specific part of a string
        let postedText = "\(creatorname)"
        let myFirstString = NSMutableAttributedString(string: postedText, attributes: [NSForegroundColorAttributeName:UIColor.blackColor(), NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 12.0)!])
        
        let creatornameText = " relayed:"
        let mySecondString = NSMutableAttributedString(string: creatornameText, attributes: [NSForegroundColorAttributeName:UIColor.blackColor(), NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 12.0)!])
        
        let result = NSMutableAttributedString()
        result.appendAttributedString(myFirstString)
        result.appendAttributedString(mySecondString)
        
        cell.extraButton.addTarget(self, action: "extraButtonTapped:", forControlEvents: .TouchUpInside)
        cell.extraButton.tag = indexPath.row
        
        cell.usernameButton.setAttributedTitle(result, forState: .Normal)
        cell.usernameButton.addTarget(self, action: "usernameTapped:", forControlEvents: .TouchUpInside)
        cell.usernameButton.tag = indexPath.row
        
        cell.questionContentButton.addTarget(self, action: "questionContentPressed:", forControlEvents: .TouchUpInside)
        cell.questionContentButton.tag = indexPath.row
        
        cell.videoView.addSubview(cell.playerController.view)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.playerController.view.userInteractionEnabled = true
        
        let view = UIView(frame: CGRectMake(cell.videoView.frame.origin.x, cell.videoView.frame.origin.y, cell.videoView.frame.size.width, cell.videoView.frame.size.height))
        cell.videoView.addSubview(view)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "singleTapped:")
        view.addGestureRecognizer(tapGesture)
        view.tag = indexPath.row
        
        cell.likeImageView.image = UIImage(named: "playImage")
        cell.likeImageView.hidden = true
        cell.likeImageView.alpha = 0.7
        cell.likeImageView.contentMode = UIViewContentMode.ScaleAspectFill
        cell.videoView.bringSubviewToFront(cell.likeImageView)
        
        let date = answerArray[indexPath.row].createdAt
        let timeAgo = timeAgoSinceDate(date, numericDates: true)
        
        cell.timeAgoLabel.text = timeAgo
        
        let views = answerArray[indexPath.row].views
        let abbrevViews = views.addCommas(views)
        cell.viewCountLabel.text = "\(abbrevViews) views"
        
        let doubleTapGesture = UITapGestureRecognizer()
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.addTarget(self, action: "doubleTapped:")
        view.addGestureRecognizer(doubleTapGesture)
        
        let likeCount = answerArray[indexPath.row].likeCount
        let abbrevLikeCount = likeCount.addCommas(likeCount)
        cell.likeCountTextView.text = "\(abbrevLikeCount) likes"
        cell.videoView.bringSubviewToFront(cell.likeCountTextView)
        cell.videoView.bringSubviewToFront(cell.heartImageView)
        
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: "toggleLike:", forControlEvents: .TouchUpInside)
        cell.videoView.bringSubviewToFront(cell.likeButton)
        
        
        return cell

    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! FeaturedVideoTableViewCell
        
        let videoUrl = answerArray[indexPath.row].video_url
        let newURL = NSURL(string: videoUrl)
        cell.player = AVPlayer(URL: newURL!)
        cell.playerController.player = cell.player
        
        cell.player.pause()
        
        let creator = answerArray[indexPath.row].creator
        
        if indexPath.row == 0 {
            cell.player.play()
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "videoEnd",
                name: AVPlayerItemDidPlayToEndTimeNotification,
                object: nil)
            let url = globalurl + "api/answers/" + answerArray[indexPath.row].id + "/viewed/"
            
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Not viewed")
                        
                    } else {
                        print("Viewed")
                    }
            }
        }
        
        
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
            
            let key = "profilePics/" + creator
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
                    imageCache[creator] = imageData
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
        
        let liked_by_user = self.answerArray[indexPath.row].liked_by_user
        
        if liked_by_user == "true" {
            cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
            cell.heartImageView.image = UIImage(named: "redHeartOutline")
        } else if liked_by_user == "not checked"{
            let url = globalurl + "api/answers/" + answerArray[indexPath.row].id + "/likecheck/" + userid
            
            Alamofire.request(.GET, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Gobi")
                        cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
                        cell.heartImageView.image = UIImage(named: "grayHeartOutline")
                        self.answerArray[indexPath.row].liked_by_user = "false"
                    } else {
                        print("Liked")
                        cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                        cell.heartImageView.image = UIImage(named: "redHeartOutline")
                        self.answerArray[indexPath.row].liked_by_user = "true"
                    }
            }
        } else if liked_by_user == "false" {
            cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
            cell.heartImageView.image = UIImage(named: "grayHeartOutline")
        }
    }
    
    // MARK: - tableView functions
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        switch (result.rawValue) {
        case MessageComposeResultCancelled.rawValue:
            print("Message was cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.rawValue:
            print("Message failed")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.rawValue:
            print("Message was sent")
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
    
    func extraButtonTapped(sender: UIButton) {
        let tag = sender.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 0)) as! FollowingAnswerTableViewCell
        if cell.player.rate > 0 {
            cell.player.pause()
            cell.likeImageView.alpha = 0.7
            cell.likeImageView.image = UIImage(named: "playImage")
            cell.likeImageView.hidden = false
        }
        let answerId = answerArray[tag].id
        let answerUrl = batonUrl + "answers/\(answerId)"
        
        var questionContent = answerArray[tag].question_content
        if questionContent.characters.count > 80 {
            let ss1: String = (questionContent as NSString).substringToIndex(80)
            questionContent = ss1 + "..."
            
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let copyLinkButton = UIAlertAction(title: "Copy Video URL", style: UIAlertActionStyle.Default) { (alert) -> Void in
            
            UIPasteboard.generalPasteboard().string = "\(answerUrl)"
        }
        let reportButton = UIAlertAction(title: "Report Video", style: UIAlertActionStyle.Default) { (alert) -> Void in
            print("Video reported")
            let parameters = [
                "type" : "reported video",
                "creator": userid,
                "relayId": answerId
            ]
            let url = globalurl + "api/alerts"
            
            Alamofire.request(.POST, url, parameters: parameters)
                .responseJSON { response in
                    print(response.request)
                    print(response.response)
                    print(response.result)
                    print(response.response?.statusCode)
            }
        }
        let facebookButton = UIAlertAction(title: "Share to Facebook", style: UIAlertActionStyle.Default) { (alert) -> Void in
            let thumbnailUrl = "https://s3-us-west-1.amazonaws.com/batonapp/BatonHighQuality.png"
            let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
            
            content.contentURL = NSURL(string: answerUrl)
            content.contentTitle = "re: \"\(questionContent)\""
            content.contentDescription = "A platfrom concise video discussions every day"
            content.imageURL = NSURL(string: thumbnailUrl )
            FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
            
        }
        let messageButton = UIAlertAction(title: "Share through Message", style: UIAlertActionStyle.Default) { (alert) -> Void in
            
            if (MFMessageComposeViewController.canSendText()) {
                let messageVC = MFMessageComposeViewController()
                
                messageVC.body = "re: \"\(questionContent)\" \(answerUrl) via Baton"
                print(messageVC.body)
                
                messageVC.messageComposeDelegate = self
                
                self.presentViewController(messageVC, animated: true, completion:nil)
            } else {
                let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
                errorAlert.show()
            }
        }
        let shareToTwitterButton = UIAlertAction(title: "Share to Twitter", style: UIAlertActionStyle.Default) { (alert) -> Void in
            let composer = TWTRComposer()
            composer.setText("re: \"\(questionContent)\" \(answerUrl) via @WhatsOnBaton")
            
            // Called from a UIViewController
            composer.showFromViewController(self) { result in
                if (result == TWTRComposerResult.Cancelled) {
                    print("Tweet composition cancelled")
                }
                else {
                    print("Sending tweet!")
                }
            }
            
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            print("Cancel Pressed", terminator: "")
        }
        
        alert.addAction(shareToTwitterButton)
        alert.addAction(facebookButton)
        alert.addAction(messageButton)
        alert.addAction(copyLinkButton)
        alert.addAction(reportButton)
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func usernameTapped(sender: UIButton) {
        let tag = sender.tag
        self.tag = tag
//        Answers.logCustomEventWithName("Username Tapped",
//            customAttributes: ["method": "nameOnAnswer", "where": "FollowingAnswers"])
        self.performSegueWithIdentifier("segueFromFeaturedToProfile", sender: self)
        
    }
    
    func questionContentPressed(sender: UIButton) {
        let tag = sender.tag
        self.questionIndex = tag
        self.performSegueWithIdentifier("segueFromFeaturedToAnswers", sender: self)
    }
    
    func toggleLike(sender: UIButton!) {
        print("button hit")
        let currentLiked = self.answerArray[sender.tag].liked_by_user
        let tag = sender.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 0)) as! FollowingAnswerTableViewCell
        let answerId = self.answerArray[sender.tag].id
        
        if currentLiked == "true" {
            print("unliked")
            self.answerArray[tag].likeCount -= 1
            self.answerArray[tag].liked_by_user = "false"
            let likeCount = self.answerArray[tag].likeCount
            cell.likeCountTextView.text = "\(likeCount) likes"
            cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
            cell.heartImageView.image = UIImage(named: "grayHeartOutline")
            
            let url = globalurl + "api/answers/" + answerId + "/unlikednotifs/" + userid
            
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        
                    } else {
                        print("unliked")
//                        Answers.logCustomEventWithName("Unlike",
//                            customAttributes: ["where": "Following"])
                        
                    }
            }
        } else {
            print("liked")
            self.answerArray[tag].likeCount += 1
            self.answerArray[tag].liked_by_user = "true"
            let likeCount = self.answerArray[tag].likeCount
            cell.likeCountTextView.text = "\(likeCount) likes"
            cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
            cell.heartImageView.image = UIImage(named: "redHeartOutline")
            
            let url = globalurl + "api/answers/" + answerId + "/likednotifs/" + userid
            
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Already liked")
                        
                    } else {
                        print("Liked")
//                        Answers.logCustomEventWithName("Like",
//                            customAttributes: ["method": "Button", "where": "Following"])
                        
                    }
            }
        }
    }
    
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        print("Double Tap")
        let tag = sender.view?.tag
        let currentLiked = self.answerArray[tag!].liked_by_user
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 0)) as! FollowingAnswerTableViewCell
        cell.likeImageView.image = UIImage(named: "Heart")
        cell.likeImageView.hidden = false
        cell.likeImageView.alpha = 1
        cell.player.play()
        
        if currentLiked == "true" {
            
        } else  {
            self.answerArray[tag!].likeCount += 1
            self.answerArray[tag!].liked_by_user = "true"
            let likeCount = self.answerArray[tag!].likeCount
            cell.likeCountTextView.text = "\(likeCount) likes"
            cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
            cell.heartImageView.image = UIImage(named: "redHeartOutline")
            
            let answerId = self.answerArray[tag!].id
            
            let url = globalurl + "api/answers/" + answerId + "/likednotifs/" + userid
            
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Already liked")
                        
                    } else {
                        print("Liked")
//                        Answers.logCustomEventWithName("Like",
//                            customAttributes: ["method": "Double Tap", "where": "Following"])
                        
                    }
            }
        }
        
        UIView.animateWithDuration(1.0, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            cell.likeImageView.alpha = 0
            }) { (success) -> Void in
                cell.likeImageView.alpha = 1
                cell.likeImageView.hidden = true
                
        }
        
        
    }
    
    func singleTapped(sender: UITapGestureRecognizer) {
        print("Tapped")
        let tag = sender.view?.tag
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 0)) as! FeaturedVideoTableViewCell
        if (cell.player.rate > 0) {
            cell.player.pause()
//            Answers.logCustomEventWithName("Pause Clicked",
//                customAttributes: ["where": "FollowingAnswers","row": tag!])
            cell.likeImageView.alpha = 0.7
            cell.likeImageView.image = UIImage(named: "playImage")
            cell.likeImageView.hidden = false
        } else {
            cell.player.play()
            let url = globalurl + "api/answers/" + answerArray[tag!].id + "/viewed/"
            
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Not viewed")
                        
                    } else {
                        print("Viewed")
                    }
            }
//            Answers.logCustomEventWithName("Play Clicked",
//                customAttributes: ["where": "FollowingAnswers","row": tag!])
//            Answers.logCustomEventWithName("Video Viewed",
//                customAttributes: ["where":"FollowingAnswers", "row": tag!])
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "videoEnd",
                name: AVPlayerItemDidPlayToEndTimeNotification,
                object: nil)
            cell.likeImageView.hidden = true
        }
        
    }
    
    func videoEnd() {
        for cell in tableView.visibleCells {
            if cell.isKindOfClass(FeaturedVideoTableViewCell) {
                let indexPath = tableView.indexPathForCell(cell)
                let cellRect = tableView.rectForRowAtIndexPath(indexPath!)
                let superView = tableView.superview
                let convertedRect = tableView.convertRect(cellRect, toView: superView)
                let intersect = CGRectIntersection(tableView.frame, convertedRect)
                let visibleHeight = CGRectGetHeight(intersect)
                let cellHeight = tableView.frame.height * 0.6
                let cell = cell as! FeaturedVideoTableViewCell
                
                if visibleHeight > cellHeight {
                    cell.likeImageView.image = UIImage(named: "replayImage")
                    cell.likeImageView.hidden = false
                    cell.likeImageView.alpha = 0.7
                    
                    if (cell.player.rate > 0) {
                        
                        
                    } else {
                        print("Reached")
//                        Answers.logCustomEventWithName("Full View",
//                            customAttributes: ["where":"FollowingVC"])
                        let seconds : Int64 = 0
                        let preferredTimeScale : Int32 = 1
                        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
                        
                        cell.player.seekToTime(seekTime)
                        //                        cell.player.play()
                    }
                } else {
                    cell.player.pause()
                }
            }
        }
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromFeaturedToAnswers" {
            let answerVC: AnswersViewController = segue.destinationViewController as! AnswersViewController
            let indexPath = self.questionIndex
            let content = self.answerArray[indexPath].question_content
            let id = self.answerArray[indexPath].question_id
            let featuredQuestion = self.answerArray[indexPath].featuredQuestion
            if featuredQuestion {
                answerVC.fromFeatured = true
            }
            answerVC.content = content
            answerVC.id = id
            answerVC.fromFollowing = true
            self.navigationController?.hidesBarsOnSwipe = false
            self.navigationController?.navigationBarHidden = false
        } else if segue.identifier == "segueFromFeaturedToProfile" {
            let profileVC: ProfileViewController = segue.destinationViewController as! ProfileViewController
            for cell in tableView.visibleCells {
                if cell.isKindOfClass(FollowingAnswerTableViewCell) {
                    let cell = cell as! FollowingAnswerTableViewCell
                    cell.player.pause()
                }
            }
            let creatorId = answerArray[tag].creator
            let creatorname = answerArray[tag].creatorname
            profileVC.fromOtherVC = true
            profileVC.creatorId = creatorId
            profileVC.creatorname = creatorname
            self.navigationController?.hidesBarsOnSwipe = false
            self.navigationController?.navigationBarHidden = false
            
        }
    }
    
    // MARK: - scrollView
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("Did end dragging")
        self.scrollingfinished()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        print("Did end decelerating")
        self.scrollingfinished()
    }
    
    func scrollingfinished() {
        for cell in tableView.visibleCells {
            if cell.isKindOfClass(FeaturedVideoTableViewCell) {
                let indexPath = tableView.indexPathForCell(cell)
                let cellRect = tableView.rectForRowAtIndexPath(indexPath!)
                let superView = tableView.superview
                let convertedRect = tableView.convertRect(cellRect, toView: superView)
                let intersect = CGRectIntersection(tableView.frame, convertedRect)
                let visibleHeight = CGRectGetHeight(intersect)
                let cellHeight = tableView.frame.height * 0.6
                let cell = cell as! FeaturedVideoTableViewCell
                
                if visibleHeight > cellHeight {
                    cell.likeImageView.hidden = true
                    
                    let cmTime = cell.player.currentItem?.currentTime()
                    let currentTime = CMTimeGetSeconds(cmTime!)
                    
                    if (cell.player.rate > 0) {
                        print("Playing")
                        
                    } else if currentTime > 0 {
                        cell.player.pause()
                        cell.likeImageView.image = UIImage(named: "playImage")
                        cell.likeImageView.hidden = false
                        cell.likeImageView.alpha = 0.7
                    }
                    else {
                        print("Reached")
                        print(currentTime)
//                        Answers.logCustomEventWithName("Video Viewed",
//                            customAttributes: ["where":"AnswersVC", "row": (indexPath?.row)!])
                        let url = globalurl + "api/answers/" + answerArray[(indexPath?.row)!].id + "/viewed/"
                        
                        Alamofire.request(.PUT, url, parameters: nil)
                            .responseJSON { response in
                                let result = response.result.value
                                print(result)
                                if result == nil {
                                    print("Not viewed")
                                    
                                } else {
                                    print("Viewed")
                                }
                        }
                        
                        let seconds : Int64 = 0
                        let preferredTimeScale : Int32 = 1
                        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
                        
                        cell.player.seekToTime(seekTime)
                        cell.player.play()
                    }
                } else {
                    cell.player.pause()
                    cell.likeImageView.image = UIImage(named: "playImage")
                    cell.likeImageView.hidden = false
                    cell.likeImageView.alpha = 0.7
                }
            }
        }
    }
    
}
