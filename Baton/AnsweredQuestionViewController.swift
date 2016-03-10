//
//  AnsweredQuestionViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 12/7/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
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

class AnsweredQuestionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    var questionId = ""
    var answerId = ""
    var videoUrl = ""
    var contentText = ""
    var liked_by_user = false
    var question: Question?
    var answer: Answer?
    var postedBy = false
    var fromFeatured = false
    
    // MARK: - viewWill/viewDid
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "videoEnd",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: nil)
    }
    
    func videoEnd() {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as! AnsweredQuestionTableViewCell
        cell.likeImageView.image = UIImage(named: "replayImage")
        cell.likeImageView.alpha = 0.7
        cell.likeImageView.hidden = false
        
        Answers.logCustomEventWithName("Full View",
            customAttributes: ["where":"AnsweredQuestionVC"])
//        let url = globalurl + "api/answers/" + answerId + "/viewed/"
//        Alamofire.request(.PUT, url, parameters: nil)
//            .responseJSON { response in
//                let result = response.result.value
//                print(result)
//                if result == nil {
//                    print("Not viewed")
//                    
//                } else {
//                    print("Viewed")
//                }
//        }
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        
        cell.player.seekToTime(seekTime)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: nil)
        for cell in tableView.visibleCells {
            if cell.isKindOfClass(AnsweredQuestionTableViewCell) {
                let indexPath = tableView.indexPathForCell(cell)
                let cellRect = tableView.rectForRowAtIndexPath(indexPath!)
                let superView = tableView.superview
                let convertedRect = tableView.convertRect(cellRect, toView: superView)
                let intersect = CGRectIntersection(tableView.frame, convertedRect)
                let visibleHeight = CGRectGetHeight(intersect)
                let cellHeight = tableView.frame.height * 0.6
                let cell = cell as! AnsweredQuestionTableViewCell
                
                if visibleHeight > cellHeight {
                    // Check is playing is already playing
                    cell.likeImageView.hidden = true
                    if (cell.player.rate > 0) {
                        cell.player.pause()
                        cell.likeImageView.image = UIImage(named: "playImage")
                        cell.likeImageView.hidden = false
                        cell.likeImageView.alpha = 0.7
                    } else {
                        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.scrollsToTop = true
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 300
        self.tabBarController?.tabBar.hidden = true
        
        
        self.loadQuestion()
        self.loadAnswer()
    }
    
    // MARK: - loadData functions
    func loadAnswer() {
        let url = globalurl + "api/answers/" + answerId
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                if value == nil {
                    value = []
                }
                
                let subJson = JSON(value!)
                print("JSON: \(subJson)")
                let id = subJson["_id"].string
                let creator = subJson["creator"].string
                let creatorname = subJson["creatorname"].string
                let video_url = subJson["video_url"].string
                var likeCount = subJson["likes"].int
                var frontCamera = subJson["frontCamera"].bool
                var views = subJson["views"].number?.integerValue
                if views == nil {
                    views = 0
                }
                var featuredQuestion = subJson["featuredQuestion"].bool
                
                if featuredQuestion == nil {
                    featuredQuestion = false
                }
                
                
                if frontCamera == nil {
                    frontCamera = false
                }
                
                
                let createdAt = subJson["created_at"].string
                let dateFor: NSDateFormatter = NSDateFormatter()
                dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
                
                if likeCount == nil {
                    likeCount = 0
                }
                
                var thumbnail_url = subJson["thumbnail_url"].string
                if thumbnail_url == nil {
                    thumbnail_url = ""
                }
                
                var vertical_screen = subJson["vertical_screen"].bool
                if vertical_screen == nil {
                    vertical_screen = false
                }
                
                if video_url != nil {
                    print(video_url)
                    self.videoUrl = video_url!
                    
                    let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: "", question_content: "", video_url: video_url, likeCount: likeCount, liked_by_user: "not checked", frontCamera: frontCamera, createdAt: yourDate, views: views, featuredQuestion: featuredQuestion, followingCreator: "not checked", thumbnail_url: thumbnail_url, vertical_screen: vertical_screen)
                    self.answer = answer
                    
                }
                
                self.tableView.reloadData()

                
        }
    }
    
    func loadQuestion() {
        let url = globalurl + "api/questions/" + questionId
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                if value == nil {
                    value = []
                }
                
                let subJson = JSON(value!)
                print("JSON: \(subJson)")
                let content = subJson["content"].string
                let id = subJson["_id"].string
                var answercount = subJson["answercount"].number?.integerValue
                var creatorname = subJson["creatorname"].string
                if creatorname == nil {
                    creatorname = ""
                }
                var creator = subJson["creator"].string
                if creator == nil {
                    creator = ""
                }
                let createdAt = subJson["created_at"].string
                var likecount = subJson["likes"].number?.integerValue
                if likecount == nil {
                    likecount = 0
                }
                let dateFor: NSDateFormatter = NSDateFormatter()
                dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
                if answercount == nil {
                    answercount = 0
                }
                
                var channelId = subJson["channel_id"].string
                var channelName = subJson["channel_name"].string
                
                if channelId == nil {
                    channelId = ""
                }
                
                if channelName == nil {
                    channelName = ""
                }
                
                var thumbnail_url = subJson["thumbnail_url"].string
                if thumbnail_url == nil {
                    thumbnail_url = ""
                }
                
                let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: false, currentuser: false, createdAt: yourDate, creator: creator, likecount: likecount, channel_id: channelId, channel_name: channelName, thumbnail_url: thumbnail_url)
                self.question = question
                self.tableView.reloadData()
        }
    }
    
    // MARK: - tableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("myQuestionTitleCell", forIndexPath: indexPath) as! MyQuestionTitleTableViewCell
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
        
            if question == nil {
                
            } else {
                let content = question!.content
                
                cell.contentTextView.text = "\(content)"
                cell.contentTextView.selectable = false
                cell.contentTextView.editable = false
                cell.contentTextView.userInteractionEnabled = false
                
                let answercount = question!.answercount
                
                cell.answerCountLabel.text =  "\(answercount)"
                
                let likecount = question!.likecount
                let formattedlikecount = likecount.abbreviateNumberAtThousand()
                cell.likeCountLabel.text = "\(formattedlikecount)"
//                cell.likeCountTextView.editable = false
//                cell.likeCountTextView.selectable = false
                
                let date = question!.createdAt
                let timeAgo = timeAgoSinceDate(date, numericDates: true)
                
                cell.timeAgoLabel.text = timeAgo
                
                let creatorname = question!.creatorname
                
                let postedText = "posted by "
                let myFirstString = NSMutableAttributedString(string: postedText, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 12.0)!])
                
                let creatornameText = "\(creatorname)"
                let mySecondString = NSMutableAttributedString(string: creatornameText, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 12.0)!])
                
                let result = NSMutableAttributedString()
                result.appendAttributedString(myFirstString)
                result.appendAttributedString(mySecondString)
                
                cell.postedByTextView.attributedText = result
                cell.postedByTextView.textColor = UIColor(red:0.63, green:0.63, blue:0.62, alpha:1.0)
                
                cell.postedByTextView.editable = false
                cell.postedByTextView.selectable = false
                
                cell.postedByButton.addTarget(self, action: "postedByTapped:", forControlEvents: .TouchUpInside)
                cell.contentView.bringSubviewToFront(cell.postedByButton)
                
                if fromFeatured {
                    cell.channelButton.hidden = true
                    cell.postedByTextView.hidden = true
                    cell.timeAgoLabel.hidden = true
                    cell.contentView.backgroundColor = UIColor(red:1.0, green:0.97, blue:0.61, alpha:1.0)
                } else {
                    cell.postedByTextView.hidden = false
                    cell.timeAgoLabel.hidden = false
                    cell.contentView.backgroundColor = UIColor.clearColor()
                    
                    var channelName = question!.channel_name
                    if channelName == "" {
                        channelName = "Other"
                    } else {
                        cell.channelButton.addTarget(self, action: "goToChannel:", forControlEvents: .TouchUpInside)
                    }
                    cell.channelButton.hidden = false
                    cell.channelButton.setTitle(channelName, forState: .Normal)
                    cell.channelButton.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
                    cell.channelButton.layer.cornerRadius = 5
                    cell.channelButton.sizeToFit()
                    cell.channelButton.tag = indexPath.row
                }
            }
            
            
            
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("answeredQuestionCell", forIndexPath: indexPath) as! AnsweredQuestionTableViewCell
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            if answer == nil {
                let videoUrl = self.videoUrl
                
                let newURL = NSURL(string: videoUrl)
                cell.player = AVPlayer(URL: newURL!)
                cell.playerController.player = cell.player
                
                cell.videoView.addSubview(cell.playerController.view)
                cell.player.pause()
                
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                
                cell.playerController.view.userInteractionEnabled = true
                
                let view = UIView(frame: CGRectMake(cell.videoView.frame.origin.x, cell.videoView.frame.origin.y, cell.videoView.frame.size.width, cell.videoView.frame.size.height))
                cell.videoView.addSubview(view)
            } else {
                let creator = answer!.creator
                
                let date = answer!.createdAt
                let timeAgo = timeAgoSinceDate(date, numericDates: true)
                
                cell.timeAgoLabel.text = timeAgo
                
                let views = answer!.views
                let abbrevViews = views.addCommas(views)
                cell.viewCountLabel.text = "\(abbrevViews) views"
                
                cell.profileImageView.image = UIImage(named: "Placeholder")
                if let cachedImageResult = imageCache[creator] {
                    print("pull from cache")
                    cell.profileImageView.image = UIImage(data: cachedImageResult!)
                } else {
                    cell.profileImageView.image = UIImage(named: "Placeholder")
                    
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
                
                cell.nameTextView.text = answer!.creatorname
                cell.nameTextView.selectable = false
                
                cell.nameButton.addTarget(self, action: "nameTapped:", forControlEvents: .TouchUpInside)
                cell.nameButton.tag = indexPath.row
                cell.contentView.bringSubviewToFront(cell.nameButton)
                
                let videoUrl = answer!.video_url
                
                let newURL = NSURL(string: videoUrl)
                cell.player = AVPlayer(URL: newURL!)
                cell.playerController.player = cell.player
                
//                let frontCamera = answer!.frontCamera
//                
//                if frontCamera {
//                    cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
//                }
//                
//                if CGAffineTransformIsIdentity(cell.playerController.view.transform) {
//                    if frontCamera {
//                        cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
//                    }
//                } else {
//                    if frontCamera {
//                        
//                    } else {
//                        cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
//                    }
//                }
                cell.videoView.addSubview(cell.playerController.view)
                cell.player.pause()
                
                if indexPath.row == 0 {
                    cell.player.play()
                    Answers.logCustomEventWithName("Video Viewed",
                        customAttributes: ["where":"AnsweredQuestionVC", "row": 0])
                    let url = globalurl + "api/answers/" + answer!.id + "/viewed/"
                    
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
                
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                
                cell.playerController.view.userInteractionEnabled = true
                
                let view = UIView(frame: CGRectMake(cell.videoView.frame.origin.x, cell.videoView.frame.origin.y, cell.videoView.frame.size.width, cell.videoView.frame.size.height))
                cell.videoView.addSubview(view)
                
                print(CMTimeGetSeconds((cell.player.currentItem?.asset.duration)!))
                print(CMTimeGetSeconds((cell.player.currentItem?.currentTime())!))
                
                let tapGesture = UITapGestureRecognizer(target: self, action: "singleTapped:")
                view.addGestureRecognizer(tapGesture)
                view.tag = indexPath.row
                
                cell.likeImageView.image = UIImage(named: "Heart")
                cell.likeImageView.hidden = true
                cell.likeImageView.contentMode = UIViewContentMode.ScaleAspectFill
                cell.videoView.bringSubviewToFront(cell.likeImageView)
                
                let doubleTapGesture = UITapGestureRecognizer()
                doubleTapGesture.numberOfTapsRequired = 2
                doubleTapGesture.addTarget(self, action: "doubleTapped:")
                view.addGestureRecognizer(doubleTapGesture)
                
                let likeCount = answer!.likeCount
                let abbrevLikeCount = likeCount.addCommas(likeCount)
                cell.likeCountTextView.text = "\(abbrevLikeCount) likes"
                cell.videoView.bringSubviewToFront(cell.likeCountTextView)
                cell.videoView.bringSubviewToFront(cell.heartImageView)
                
                cell.extraButton.addTarget(self, action: "extraButtonTapped:", forControlEvents: .TouchUpInside)
                cell.extraButton.tag = indexPath.row
                
                cell.likeButton.tag = indexPath.row
                cell.likeButton.addTarget(self, action: "toggleLike:", forControlEvents: .TouchUpInside)
                cell.videoView.bringSubviewToFront(cell.likeButton)
                
                let followingCreator = self.answer!.followingCreator
                
                cell.followButton.tag = indexPath.row
                cell.followButton.addTarget(self, action: "toggleFollow:", forControlEvents: .TouchUpInside)
                
                if creator == userid {
                    cell.followButton.hidden = true
                } else if followingCreator == "not checked" {
                    
                    cell.followButton.selected = false
                    
                    let url = globalurl + "api/user/" + userid + "/follows/" + creator
                    
                    Alamofire.request(.GET, url, parameters: nil)
                        .responseJSON { response in
                            let result = response.result.value
                            print(result)
                            if result == nil {
                                print("Not Following")
                                cell.followButton.selected = false
                                cell.followButton.hidden = false
                                self.answer!.followingCreator = "not following"
                            } else {
                                print("Already Following")
                                cell.followButton.hidden = true
                                self.answer!.followingCreator = "already following"
                            }
                    }
                } else if followingCreator == "not following" {
                    cell.followButton.selected = false
                    cell.followButton.hidden = false
                } else if followingCreator == "already following" {
                    cell.followButton.hidden = true
                } else if followingCreator == "just followed" {
                    cell.followButton.selected = true
                    cell.followButton.hidden = false
                }
                
                
                let liked_by_user = answer!.liked_by_user
                
                if liked_by_user == "true" {
                    cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                    cell.heartImageView.image = UIImage(named: "redHeartOutline")
                } else if liked_by_user == "not checked" {
                    let url = globalurl + "api/answers/" + answer!.id + "/likecheck/" + userid
                    
                    Alamofire.request(.GET, url, parameters: nil)
                        .responseJSON { response in
                            let result = response.result.value
                            print(result)
                            if result == nil {
                                print("Gobi")
                                cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
                                cell.heartImageView.image = UIImage(named: "grayHeartOutline")
                                self.answer!.liked_by_user = "false"
                            } else {
                                print("Liked")
                                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                                cell.heartImageView.image = UIImage(named: "redHeartOutline")
                                self.answer!.liked_by_user = "true"
                            }
                    }
                } else if liked_by_user == "false" {
                    cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
                    cell.heartImageView.image = UIImage(named: "grayHeartOutline")
                }

            }
            
            return cell
        }
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("segueFromAnsweredQuestionToAnswers", sender: self)
    }
    
    // MARK: - tableView functions
    func goToChannel(sender: UIButton) {
        self.performSegueWithIdentifier("segueFromAnsweredQuestionToFeed", sender: self)
    }
    
    func postedByTapped(sender:UIButton) {
        print("buttonTapped")
        postedBy = true
        Answers.logCustomEventWithName("Username Tapped",
            customAttributes: ["method": "postedBy", "where": "AnsweredQuestionVC"])
        self.performSegueWithIdentifier("segueFromAnsweredQuestionToProfile", sender: self)
    }
    
    func nameTapped(sender:UIButton) {
        print("buttonClicked")
        Answers.logCustomEventWithName("Username Tapped",
            customAttributes: ["method": "nameOnAnswer", "where": "AnsweredQuestionVC"])
        self.performSegueWithIdentifier("segueFromAnsweredQuestionToProfile", sender: self)
    }
    
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
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 1)) as! AnsweredQuestionTableViewCell
        if cell.player.rate > 0 {
            cell.player.pause()
            cell.likeImageView.alpha = 0.7
            cell.likeImageView.image = UIImage(named: "playImage")
            cell.likeImageView.hidden = false
        }
        
        let answerId = answer!.id
        let answerUrl = batonUrl + "answers/\(answerId)"
        var questionContent = self.question!.content
        if questionContent.characters.count > 80 {
            let ss1: String = (questionContent as NSString).substringToIndex(80)
            questionContent = ss1 + "..."
            
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
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
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            print("Cancel Pressed", terminator: "")
        }
        let copyLinkButton = UIAlertAction(title: "Copy Video URL", style: UIAlertActionStyle.Default) { (alert) -> Void in
            
            UIPasteboard.generalPasteboard().string = "\(answerUrl)"
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
        alert.addAction(shareToTwitterButton)
        alert.addAction(facebookButton)
        alert.addAction(messageButton)
        alert.addAction(copyLinkButton)
        alert.addAction(reportButton)
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func toggleFollow(sender:UIButton!) {
        
        if sender.selected == false {
            sender.selected = true
            let url = globalurl + "api/user/" + userid + "/follows/" + answer!.creator
            
            Alamofire.request(.POST, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Already Followed")
                    } else {
                        print("Following")
                        self.answer!.followingCreator = "just followed"
                    }
            }
        } else {
            sender.selected = false
            let url = globalurl + "api/user/" + userid + "/unfollows/" + answer!.creator
            
            Alamofire.request(.DELETE, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Could not remove")
                    } else {
                        print("Removed")
                        self.answer!.followingCreator = "not following"
                    }
            }
        }
    }
    
    func toggleLike(sender: UIButton!) {
        print("button hit")
        let tag = sender.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 1)) as! AnsweredQuestionTableViewCell
        
        if answer!.liked_by_user == "true" {
            print("unliked")
            self.answer!.likeCount -= 1
            self.answer!.liked_by_user = "false"
            cell.likeCountTextView.text = "\(self.answer!.likeCount) likes"
            cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
            cell.heartImageView.image = UIImage(named: "grayHeartOutline")
            
            let url = globalurl + "api/answers/" + answerId + "/unlikednotifs/" + userid
            
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Not liked")
                    } else {
                        print("Unliked")
                        Answers.logCustomEventWithName("Unike",
                            customAttributes: ["where": "AnsweredQuestionVC"])
                        
                    }
            }
        } else {
            print("liked")
            self.answer!.likeCount += 1
            self.answer!.liked_by_user = "true"
            cell.likeCountTextView.text = "\(self.answer!.likeCount) likes"
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
                        Answers.logCustomEventWithName("Like",
                            customAttributes: ["method": "Button", "where": "AnsweredQuestionVC"])
                        
                    }
            }
        }
    }
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        print("Double Tap")
        let tag = sender.view?.tag
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 1)) as! AnsweredQuestionTableViewCell
        cell.likeImageView.image = UIImage(named: "Heart")
        cell.likeImageView.hidden = false
        cell.likeImageView.alpha = 1
        cell.player.play()
        
        if answer!.liked_by_user == "true" {
            
        } else {
            self.answer!.likeCount += 1
            self.answer!.liked_by_user = "true"
            cell.likeCountTextView.text = "\(self.answer!.likeCount) likes"
            cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
            cell.heartImageView.image = UIImage(named: "redHeartOutline")
            
            let url = globalurl + "api/answers/" + self.answerId + "/likednotifs/" + userid
            
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Already liked")
                    } else {
                        print("Liked")
                        Answers.logCustomEventWithName("Like",
                            customAttributes: ["method": "Double Tap", "where": "AnsweredQuestionVC"])
                        
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
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 1)) as! AnsweredQuestionTableViewCell
        if (cell.player.rate > 0) {
            cell.player.pause()
            Answers.logCustomEventWithName("Pause Clicked",
                customAttributes: ["where": "AnsweredQuestionVC","row": tag!])
            cell.likeImageView.alpha = 0.7
            cell.likeImageView.image = UIImage(named: "playImage")
            cell.likeImageView.hidden = false
        } else {
            if cell.likeImageView.image == UIImage(named: "replayImage") {
                let url = globalurl + "api/answers/" + answerId + "/viewed/"
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
            cell.player.play()
            Answers.logCustomEventWithName("Play Clicked",
                customAttributes: ["where": "AnsweredQuestionVC","row": tag!])
            Answers.logCustomEventWithName("Video Viewed",
                customAttributes: ["where":"AnsweredQuestionVC", "row": 0])
            cell.likeImageView.hidden = true
        }
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromAnsweredQuestionToAnswers" {
            let answerVC: AnswersViewController = segue.destinationViewController as! AnswersViewController
            let content = self.question!.content
            let id = self.question!.id
            let creatorname = self.question!.creatorname
            let question = self.question!
            answerVC.content = content
            answerVC.id = id
            answerVC.creatorname = creatorname
            answerVC.question = question
        } else if segue.identifier == "segueFromAnsweredQuestionToProfile" {
            if postedBy {
                let profileVC: ProfileViewController = segue.destinationViewController as! ProfileViewController
                for cell in tableView.visibleCells {
                    if cell.isKindOfClass(AnsweredQuestionTableViewCell) {
                        let cell = cell as! AnsweredQuestionTableViewCell
                        cell.player.pause()
                    }
                }
                let creatorId = question!.creator
                let creatorname = question!.creatorname
                profileVC.fromOtherVC = true
                profileVC.creatorId = creatorId
                profileVC.creatorname = creatorname
            } else {
                let profileVC: ProfileViewController = segue.destinationViewController as! ProfileViewController
                for cell in tableView.visibleCells {
                    if cell.isKindOfClass(AnsweredQuestionTableViewCell) {
                        let cell = cell as! AnsweredQuestionTableViewCell
                        cell.player.pause()
                    }
                }
                let creatorId = answer!.creator
                let creatorname = answer!.creatorname
                profileVC.fromOtherVC = true
                profileVC.creatorId = creatorId
                profileVC.creatorname = creatorname
            }
            
        } else if segue.identifier == "segueFromAnsweredQuestionToFeed" {
            let feedVC: FeedViewController = segue.destinationViewController as! FeedViewController
            let channelId = question!.channel_id
            let channelName = question!.channel_name
            feedVC.fromSpecificChannel = true
            feedVC.channelId = channelId
            feedVC.channelName = channelName
        }
    }

    
}
