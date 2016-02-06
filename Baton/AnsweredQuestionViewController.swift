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

class AnsweredQuestionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var questionId = ""
    var answerId = ""
    
    var videoUrl = ""
    var creatorName = ""
    var likeCount = 0
    var creator = ""
    var frontCamera = true
    
    var contentText = ""
    var liked_by_user = false
    var question: Question?
    var answer: Answer?
    var postedBy = false
    
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
                
                if frontCamera == nil {
                    frontCamera = false
                }
                
                
                if video_url != nil {
                    print(video_url)
                    self.videoUrl = video_url!
                    self.creatorName = creatorname!
                    self.likeCount = likeCount!
                    self.creator = creator!
                    self.frontCamera = frontCamera!
                }

                
                
                
                let createdAt = subJson["created_at"].string
                let dateFor: NSDateFormatter = NSDateFormatter()
                dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
                
                if likeCount == nil {
                    likeCount = 0
                }
                
                if video_url != nil {
                    print(video_url)
                    
                    let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: "", question_content: "", video_url: video_url, likeCount: likeCount, liked_by_user: false, frontCamera: frontCamera, createdAt: yourDate, views: views)
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
                let anonymous = subJson["anonymous"].string
                var answercount = subJson["answercount"].number?.integerValue
                var creatorname = subJson["creatorname"].string
                let answeredBy = subJson["answered_by"]
                let creator = subJson["creator"].string
                var answered = false
                var user = false
                let createdAt = subJson["created_at"].string
                var likecount = subJson["likes"].number?.integerValue
                
                if likecount == nil {
                    likecount = 0
                }
                
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
                
                let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: answered, currentuser: user, createdAt: yourDate, creator: creator, likecount: likecount)
                
                self.question = question
                
                self.tableView.reloadData()
                
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "videoEnd",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: nil)
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

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.scrollsToTop = true
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 300
        self.tabBarController?.tabBar.hidden = true
        
        
        self.loadQuestion()
        self.loadAnswer()
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
                let formattedlikecount = likecount.abbreviateNumber()
                cell.likeCountTextView.text = "\(formattedlikecount)"
                cell.likeCountTextView.editable = false
                cell.likeCountTextView.selectable = false
                
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
            }
            
            
            
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("answeredQuestionCell", forIndexPath: indexPath) as! AnsweredQuestionTableViewCell
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            if answer == nil {
                let videoUrl = self.videoUrl
                let cloudUrl = cloudfrontUrl + "video.m3u8"
                
                let newURL = NSURL(string: videoUrl)
                cell.player = AVPlayer(URL: newURL!)
                cell.playerController.player = cell.player
                
                //            self.addChildViewController(cell.playerController)
                cell.videoView.addSubview(cell.playerController.view)
                //            cell.playerController.didMoveToParentViewController(self)
                cell.player.pause()
                
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                
                cell.playerController.view.userInteractionEnabled = true
                
                //            let view = UIView(frame: cell.playerController.view.frame)
                //            cell.addSubview(view)
                
                let view = UIView(frame: CGRectMake(cell.videoView.frame.origin.x, cell.videoView.frame.origin.y, cell.videoView.frame.size.width, cell.videoView.frame.size.height))
                cell.videoView.addSubview(view)
            } else {
                let creator = answer!.creator
                
                let date = answer!.createdAt
                let timeAgo = timeAgoSinceDate(date, numericDates: true)
                
                cell.timeAgoLabel.text = timeAgo
                
                let views = answer!.views
                cell.viewCountLabel.text = "\(views) views"
                
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
                    readRequest1.key =  creator
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
                let cloudUrl = cloudfrontUrl + "video.m3u8"
                
                let newURL = NSURL(string: videoUrl)
                cell.player = AVPlayer(URL: newURL!)
                cell.playerController.player = cell.player
                
                let frontCamera = answer!.frontCamera
                
                if frontCamera {
                    cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
                }
                
                if CGAffineTransformIsIdentity(cell.playerController.view.transform) {
                    if frontCamera {
                        cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
                    }
                } else {
                    if frontCamera {
                        
                    } else {
                        cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
                    }
                }
                cell.videoView.addSubview(cell.playerController.view)
                cell.player.pause()
                
                if indexPath.row == 0 {
                    cell.player.play()
                    
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
                cell.likeCountTextView.text = "\(likeCount) likes"
                cell.videoView.bringSubviewToFront(cell.likeCountTextView)
                cell.videoView.bringSubviewToFront(cell.heartImageView)
                
                cell.extraButton.addTarget(self, action: "extraButtonTapped:", forControlEvents: .TouchUpInside)
                cell.extraButton.tag = indexPath.row
                
                cell.likeButton.tag = indexPath.row
                cell.likeButton.addTarget(self, action: "toggleLike:", forControlEvents: .TouchUpInside)
                cell.videoView.bringSubviewToFront(cell.likeButton)
                
                if creator == userid {
                    cell.followButton.hidden = true
                } else {
                    cell.followButton.tag = indexPath.row
                    cell.followButton.addTarget(self, action: "toggleFollow:", forControlEvents: .TouchUpInside)
                    cell.followButton.setImage(UIImage(named: "addperson"), forState: .Normal)
                    cell.followButton.setImage(UIImage(named: "addedperson"), forState: .Selected)
                    //                cell.followButton.setTitle("Follow", forState: .Normal)
                    //                cell.followButton.setTitle("Following", forState: .Selected)
                    cell.followButton.selected = false
                    
                    let url = globalurl + "api/user/" + userid + "/follows/" + creator
                    
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
                }
                
                
                let liked_by_user = answer!.liked_by_user
                
                print(cell.subviews)
                
                if liked_by_user == true {
                    cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                    cell.heartImageView.image = UIImage(named: "redHeartOutline")
                } else {
                    let url = globalurl + "api/answers/" + answer!.id + "/likecheck/" + userid
                    
                    Alamofire.request(.GET, url, parameters: nil)
                        .responseJSON { response in
                            let result = response.result.value
                            print(result)
                            if result == nil {
                                print("Gobi")
                                cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
                                cell.heartImageView.image = UIImage(named: "grayHeartOutline")
                            } else {
                                print("Liked")
                                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                                cell.heartImageView.image = UIImage(named: "redHeartOutline")
                                self.answer!.liked_by_user = true
                            }
                    }
                }

            }
            
            return cell
        }
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("segueFromAnsweredQuestionToAnswers", sender: self)
    }
    
    func postedByTapped(sender:UIButton) {
        print("buttonTapped")
        postedBy = true
        self.performSegueWithIdentifier("segueFromAnsweredQuestionToProfile", sender: self)
    }
    
    func nameTapped(sender:UIButton) {
        print("buttonClicked")
        self.performSegueWithIdentifier("segueFromAnsweredQuestionToProfile", sender: self)
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
        
        let creator = answer!.creator
        let answerId = answer!.id
        
        
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
        
        alert.addAction(reportButton)
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
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
            
        }
    }
    
    func toggleFollow(sender:UIButton!) {
        let tag = sender.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 1)) as! AnswerTableViewCell
        
        if sender.selected == false {
            sender.selected = true
            let url = globalurl + "api/user/" + userid + "/follows/" + creator
            
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
            let url = globalurl + "api/user/" + userid + "/unfollows/" + creator
            
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
    
    func toggleLike(sender: UIButton!) {
        print("button hit")
        let tag = sender.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 1)) as! AnsweredQuestionTableViewCell
        
        if answer!.liked_by_user == true {
            print("unliked")
            
            let url = globalurl + "api/answers/" + answerId + "/unlikednotifs/" + userid
            
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Already liked")
                    } else {
                        print("Liked")
                        self.answer!.likeCount -= 1
                        self.answer!.liked_by_user = false
                        cell.likeCountTextView.text = "\(self.answer!.likeCount) likes"
                        cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
                        cell.heartImageView.image = UIImage(named: "grayHeartOutline")
                    }
            }
        } else {
            print("liked")
            
            let url = globalurl + "api/answers/" + answerId + "/likednotifs/" + userid
            
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Already liked")
                        
                    } else {
                        print("Liked")
                        self.answer!.likeCount += 1
                        self.answer!.liked_by_user = true
                        cell.likeCountTextView.text = "\(self.answer!.likeCount) likes"
                        cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                        cell.heartImageView.image = UIImage(named: "redHeartOutline")
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
        UIView.animateWithDuration(1.0, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            cell.likeImageView.alpha = 0
            }) { (success) -> Void in
                cell.likeImageView.alpha = 1
                cell.likeImageView.hidden = true
                
                let url = globalurl + "api/answers/" + self.answerId + "/liked/" + userid
                
                Alamofire.request(.PUT, url, parameters: nil)
                    .responseJSON { response in
                        let result = response.result.value
                        print(result)
                        if result == nil {
                            print("Already liked")
                        } else {
                            print("Liked")
                            self.answer!.likeCount += 1
                            cell.likeCountTextView.text = "\(self.answer!.likeCount) likes"
                            cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                            cell.heartImageView.image = UIImage(named: "redHeartOutline")
                        }
                }
        }
        
        
    }
    
    func singleTapped(sender: UITapGestureRecognizer) {
        print("Tapped")
        let tag = sender.view?.tag
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 1)) as! AnsweredQuestionTableViewCell
        if (cell.player.rate > 0) {
            cell.player.pause()
            cell.likeImageView.alpha = 0.7
            cell.likeImageView.image = UIImage(named: "playImage")
            cell.likeImageView.hidden = false
        } else {
            cell.player.play()
            cell.likeImageView.hidden = true
        }
        
    }
    
    func videoEnd() {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as! AnsweredQuestionTableViewCell
        cell.likeImageView.image = UIImage(named: "replayImage")
        cell.likeImageView.alpha = 0.7
        cell.likeImageView.hidden = false
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
        
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        
        cell.player.seekToTime(seekTime)
    }

    
}
