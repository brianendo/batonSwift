//
//  AnswersViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 12/3/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import AWSS3
import AVKit
import AVFoundation
import Alamofire
import SwiftyJSON

class AnswersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var relayButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    
    var content = ""
    var id = ""
    var creatorname = ""
    var fromProfile = false
    var question: Question?
    var fromFollowing = false
    var nameIndex = 0
    var questionName = false
    
//    var idArray = [String]()
//    var videoUrlArray = [String]()
//    var creatornameArray = [String]()
//    var likeCountArray = [Int]()
//    var frontCameraArray = [Bool]()
    var answerArray = [Answer]()
    
    override func viewWillAppear(animated: Bool) {
        if fromFollowing {
            self.navigationController?.hidesBarsOnSwipe = false
            self.navigationController?.navigationBar.hidden = false
            if question == nil {
                self.loadQuestion()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Relays"
        // Do any additional setup after loading the view.
        self.tabBarController?.tabBar.hidden = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
//        if fromProfile {
//            relayButton.removeFromSuperview()
//            bottomLayoutConstraint.constant = 0
//            self.view.layoutIfNeeded()
//        }
        
        if fromFollowing {
            
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 300
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.relayButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.relayButton.layer.borderWidth = 0.5
        
        self.loadAnswers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadQuestion() {
        let newUrl = globalurl + "api/questions/" + self.id
        
        Alamofire.request(.GET, newUrl, parameters: nil)
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
    
    func loadAnswers(){
        let url = globalurl + "api/questions/" + id + "/answers/"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                let json = JSON(response.result.value!)
                print("JSON: \(json)")
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
                    var views = subJson["views"].number?.integerValue
                    if views == nil {
                        views = 0
                    }
                    
                    if frontCamera == nil {
                        frontCamera = true
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
                        self.answerArray.append(answer)
                        self.answerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })

//                        self.videoUrlArray.append(video_url!)
//                        self.creatornameArray.append(creatorname!)
//                        self.idArray.append(id!)
//                        self.likeCountArray.append(likeCount!)
//                        self.frontCameraArray.append(frontCamera!)
                    }
                    
                    self.tableView.reloadData()
                }
                
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
            return "\(components.year)y"
        } else if (components.year >= 1){
            if (numericDates){
                return "1y"
            } else {
                return "Last year"
            }
        } else if (components.month >= 2) {
            return "\(components.month)mo"
        } else if (components.month >= 1){
            if (numericDates){
                return "1mo"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear >= 2) {
            return "\(components.weekOfYear)w"
        } else if (components.weekOfYear >= 1){
            if (numericDates){
                return "1w"
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath) as! QuestionTitleTableViewCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            cell.contentTextView.text = "\(self.content)"
            cell.contentTextView.selectable = false
            
            if question == nil {
                
            } else {
                let answercount = question!.answercount
                
                cell.answerCountLabel.text =  "\(answercount)"
                
                let likecount = question!.likecount
                cell.likeCountTextView.text = "\(likecount)"
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
            let cell = tableView.dequeueReusableCellWithIdentifier("AnswerCell", forIndexPath: indexPath) as! AnswerTableViewCell
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            let creator = answerArray[indexPath.row].creator
            
            let date = answerArray[indexPath.row].createdAt
            let timeAgo = timeAgoSinceDate(date, numericDates: true)
            
            cell.timeAgoLabel.text = timeAgo
            
            let views = answerArray[indexPath.row].views
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
            
            cell.nameTextView.text = answerArray[indexPath.row].creatorname
            cell.nameTextView.selectable = false
            
            cell.nameButton.addTarget(self, action: "nameTapped:", forControlEvents: .TouchUpInside)
            cell.nameButton.tag = indexPath.row
            cell.contentView.bringSubviewToFront(cell.nameButton)
            
            let videoUrl = answerArray[indexPath.row].video_url
            let cloudUrl = cloudfrontUrl + "video.m3u8"
            
            let newURL = NSURL(string: videoUrl)
            cell.player = AVPlayer(URL: newURL!)
            cell.playerController.player = cell.player
            
            let frontCamera = answerArray[indexPath.row].frontCamera
            
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
//            self.addChildViewController(cell.playerController)
            cell.videoView.addSubview(cell.playerController.view)
//            cell.playerController.didMoveToParentViewController(self)
            cell.player.pause()
            
            if indexPath.row == 0 {
                cell.player.play()
                
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
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            cell.playerController.view.userInteractionEnabled = true
            
//            let view = UIView(frame: cell.playerController.view.frame)
//            cell.addSubview(view)
            
            let view = UIView(frame: CGRectMake(cell.videoView.frame.origin.x, cell.videoView.frame.origin.y, cell.videoView.frame.size.width, cell.videoView.frame.size.height))
            cell.videoView.addSubview(view)
            
            print(CMTimeGetSeconds((cell.player.currentItem?.asset.duration)!))
            print(CMTimeGetSeconds((cell.player.currentItem?.currentTime())!))
            
            let tapGesture = UITapGestureRecognizer(target: self, action: "singleTapped:")
            view.addGestureRecognizer(tapGesture)
            view.tag = indexPath.row
            
            cell.likeImageView.image = UIImage(named: "Heart")
            cell.likeImageView.hidden = true
            cell.videoView.bringSubviewToFront(cell.likeImageView)
            
            let doubleTapGesture = UITapGestureRecognizer()
            doubleTapGesture.numberOfTapsRequired = 2
            doubleTapGesture.addTarget(self, action: "doubleTapped:")
            view.addGestureRecognizer(doubleTapGesture)
            
            let likeCount = self.answerArray[indexPath.row].likeCount
            cell.likeCountTextView.text = "\(likeCount) likes"
            cell.videoView.bringSubviewToFront(cell.likeCountTextView)
            cell.videoView.bringSubviewToFront(cell.heartImageView)
            
            
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
                
                let url = globalurl + "api/user/" + userid + "/follows/" + answerArray[indexPath.row].creator
                
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

            
            let liked_by_user = self.answerArray[indexPath.row].liked_by_user
            
            print(cell.subviews)
            
            if liked_by_user == true {
                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                cell.heartImageView.image = UIImage(named: "redHeartOutline")
            } else {
                let url = globalurl + "api/answers/" + answerArray[indexPath.row].id + "/likecheck/" + userid
                
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
                            self.answerArray[indexPath.row].liked_by_user = true
                        }
                }
            }
            
            
            
            return cell
        }
        
    }
    
    func postedByTapped(sender:UIButton) {
        print("buttonTapped")
        questionName = true
        self.performSegueWithIdentifier("segueFromAnswersToProfile", sender: self)
    }
    
    func nameTapped(sender:UIButton) {
        print("buttonClicked")
        let tag = sender.tag
        nameIndex = tag
        self.performSegueWithIdentifier("segueFromAnswersToProfile", sender: self)
    }
    
    func toggleFollow(sender:UIButton!) {
        let tag = sender.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 1)) as! AnswerTableViewCell
        let creatorId = self.answerArray[tag].creator
        
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
    
    func toggleLike(sender: UIButton!) {
        print("button hit")
        let currentLiked = self.answerArray[sender.tag].liked_by_user
        let tag = sender.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 1)) as! AnswerTableViewCell
        let answerId = self.answerArray[sender.tag].id
        
        if currentLiked == true {
            print("unliked")
            
            let url = globalurl + "api/answers/" + answerId + "/unlikednotifs/" + userid
            
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        
                    } else {
                        print("unliked")
                        self.answerArray[tag].likeCount -= 1
                        self.answerArray[tag].liked_by_user = false
                        let likeCount = self.answerArray[tag].likeCount
                        cell.likeCountTextView.text = "\(likeCount) likes"
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
                        self.answerArray[tag].likeCount += 1
                        self.answerArray[tag].liked_by_user = true
                        let likeCount = self.answerArray[tag].likeCount
                        cell.likeCountTextView.text = "\(likeCount) likes"
                        cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                        cell.heartImageView.image = UIImage(named: "redHeartOutline")
                    }
            }
        }
    }
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        print("Double Tap")
        let tag = sender.view?.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 1)) as! AnswerTableViewCell
        
        cell.likeImageView.hidden = false
        
        UIView.animateWithDuration(1.0, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            cell.likeImageView.alpha = 0
            }) { (success) -> Void in
                cell.likeImageView.alpha = 1
                cell.likeImageView.hidden = true
                
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
                            self.answerArray[tag!].likeCount += 1
                            self.answerArray[tag!].liked_by_user = true
                            let likeCount = self.answerArray[tag!].likeCount
                            cell.likeCountTextView.text = "\(likeCount) likes"
                            cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                            cell.heartImageView.image = UIImage(named: "redHeartOutline")
                        }
                }
//                let thankurl = globalurl + "api/answers/" + answerId + "/thanked/"
//                Alamofire.request(.PUT, thankurl, parameters: nil)
//                    .responseJSON { response in
//                }
        }
        
        
    }
    
    func singleTapped(sender: UITapGestureRecognizer) {
        print("Tapped")
        let tag = sender.view?.tag
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 1)) as! AnswerTableViewCell
        if (cell.player.rate > 0) {
            cell.player.pause()
        } else {
            cell.player.play()
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return answerArray.count
        }
    }
    
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
            if cell.isKindOfClass(AnswerTableViewCell) {
                let indexPath = tableView.indexPathForCell(cell)
                let cellRect = tableView.rectForRowAtIndexPath(indexPath!)
                let superView = tableView.superview
                let convertedRect = tableView.convertRect(cellRect, toView: superView)
                let intersect = CGRectIntersection(tableView.frame, convertedRect)
                let visibleHeight = CGRectGetHeight(intersect)
                let cellHeight = tableView.frame.height * 0.6
                let cell = cell as! AnswerTableViewCell
                
                if visibleHeight > cellHeight {
                    // Check is playing is already playing
                    if (cell.player.rate > 0) {
                        print("Playing")
                        
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
                    } else {
                        print("Reached")
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
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromAnswerToTakeVideo" {
            let takeVideoVC: TakeVideoViewController = segue.destinationViewController as! TakeVideoViewController
            for cell in tableView.visibleCells {
                if cell.isKindOfClass(AnswerTableViewCell) {
                    let cell = cell as! AnswerTableViewCell
                    cell.player.pause()
                }
            }
            takeVideoVC.content = self.content
            takeVideoVC.id = self.id
        } else if segue.identifier == "segueFromAnswersToProfile" {
            if questionName {
                let profileVC: ProfileViewController = segue.destinationViewController as! ProfileViewController
                for cell in tableView.visibleCells {
                    if cell.isKindOfClass(AnswerTableViewCell) {
                        let cell = cell as! AnswerTableViewCell
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
                    if cell.isKindOfClass(AnswerTableViewCell) {
                        let cell = cell as! AnswerTableViewCell
                        cell.player.pause()
                    }
                }
                let creatorId = answerArray[nameIndex].creator
                let creatorname = answerArray[nameIndex].creatorname
                profileVC.fromOtherVC = true
                profileVC.creatorId = creatorId
                profileVC.creatorname = creatorname
            }
            
        }
    }
    
    @IBAction func relayButtonPressed(sender: UIButton) {
        self.performSegueWithIdentifier("segueFromAnswerToTakeVideo", sender: self)
    }
    
    
    

}
