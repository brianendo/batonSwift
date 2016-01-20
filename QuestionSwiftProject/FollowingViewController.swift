//
//  FollowingViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 1/15/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import AWSS3
import Alamofire
import SwiftyJSON
import AVKit
import AVFoundation

class FollowingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var counter = 0
    var answerArray = [Answer]()
    var questionArray = [Question]()
    var selectedIndexPath = 0
    var questionIndex = 0
    
    func loadQuestions() {
        let url = globalurl + "api/users/" + userid + "/followingquestions"
        
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
                    var answercount = subJson["answercount"].number?.integerValue
                    var creatorname = subJson["creatorname"].string
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
                    
                    if answercount == nil {
                        answercount = 0
                    }
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: answered, currentuser: user, createdAt: yourDate, creator: creator, likecount: likecount)
                    self.questionArray.append(question)
                    
                    self.tableView.reloadData()
                }
        }
    }
    
    func loadAnswers(){
        let url = globalurl + "api/users/" + userid + "/followinganswers/"
        
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
                    var question_id = subJson["question_id"].string
                    
                    if question_id == nil {
                        question_id = ""
                    }
                    
                    if frontCamera == nil {
                        frontCamera = true
                    }
                    
                    if likeCount == nil {
                        likeCount = 0
                    }
                    
                    if video_url != nil {
                        print(video_url)
                        
                        let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: "", video_url: video_url, likeCount: likeCount, liked_by_user: false, frontCamera: frontCamera)
                        self.answerArray.append(answer)
                    }
                    
                    self.tableView.reloadData()
                }
                
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        for cell in tableView.visibleCells {
            if cell.isKindOfClass(FollowingAnswerTableViewCell) {
                let indexPath = tableView.indexPathForCell(cell)
                let cellRect = tableView.rectForRowAtIndexPath(indexPath!)
                let superView = tableView.superview
                let convertedRect = tableView.convertRect(cellRect, toView: superView)
                let intersect = CGRectIntersection(tableView.frame, convertedRect)
                let visibleHeight = CGRectGetHeight(intersect)
                let cellHeight = tableView.frame.height * 0.6
                let cell = cell as! FollowingAnswerTableViewCell
                
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

        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 300
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        // Do any additional setup after loading the view.
        self.loadAnswers()
        self.loadQuestions()
        
        segmentedControl.addTarget(self, action: "profileSegmentedControlChanged:", forControlEvents: .ValueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func profileSegmentedControlChanged(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            print("Money")
            counter = 0
        } else if sender.selectedSegmentIndex == 1 {
            print("Mayweather")
            counter = 1
            for cell in tableView.visibleCells {
                if cell.isKindOfClass(FollowingAnswerTableViewCell) {
                    let indexPath = tableView.indexPathForCell(cell)
                    let cellRect = tableView.rectForRowAtIndexPath(indexPath!)
                    let superView = tableView.superview
                    let convertedRect = tableView.convertRect(cellRect, toView: superView)
                    let intersect = CGRectIntersection(tableView.frame, convertedRect)
                    let visibleHeight = CGRectGetHeight(intersect)
                    let cellHeight = tableView.frame.height * 0.6
                    let cell = cell as! FollowingAnswerTableViewCell
                    
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
            self.tableView.reloadData()
        }
        
        self.tableView.reloadData()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if counter == 0 {
            return answerArray.count
        } else {
            return questionArray.count
        }
       
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if counter == 0 {
            let cell: FollowingAnswerTableViewCell = tableView.dequeueReusableCellWithIdentifier("followingAnswerCell", forIndexPath: indexPath) as! FollowingAnswerTableViewCell
            
            var question_content = answerArray[indexPath.row].question_content
            let question_id = answerArray[indexPath.row].question_id
            
            let creatorname = answerArray[indexPath.row].creatorname
            let userText = creatorname + " relayed:"
            
            cell.usernameButton.setTitle(userText, forState: .Normal)
            
            let creator = answerArray[indexPath.row].creator
            
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
            
            if question_content == "" {
                let url = globalurl + "api/questions/" + question_id
                
                Alamofire.request(.GET, url, parameters: nil)
                    .responseJSON { response in
                        let json = JSON(response.result.value!)
                        print("JSON: \(json)")
                        if json == [] {
                            print("No answers")
                        }
                        let content = json["content"].string
                        print(content)
                        question_content = content!
                        self.answerArray[indexPath.row].question_content = question_content
                        cell.questionContentButton.setTitle(question_content, forState: .Normal)
                        cell.questionContentButton.titleLabel!.text = question_content
                        cell.questionContentButton.titleLabel!.numberOfLines = 0
                        cell.questionContentButton.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
                        cell.questionContentButton.sizeToFit()
                        cell.questionContentButton.layoutIfNeeded()
                        let buttonLabel = cell.questionContentButton.titleLabel
                        cell.questionContentButton.frame = CGRect(x: (buttonLabel?.frame.origin.x)!, y: (buttonLabel?.frame.origin.y)!, width: (buttonLabel?.frame.width)!, height: (buttonLabel?.frame.height)!)
                        cell.questionContentHeight.constant = cell.questionContentButton.titleLabel!.frame.size.height
                        cell.questionContentButton.layoutIfNeeded()
                        
                        for (_,subJson):(String, JSON) in json {
                            //Do something you want
                            
                        }
                }
            } else {
                cell.questionContentButton.setTitle(question_content, forState: .Normal)
                cell.questionContentButton.titleLabel?.text = question_content
                cell.questionContentButton.titleLabel!.numberOfLines = 0
                cell.questionContentButton.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
                cell.questionContentButton.layoutIfNeeded()
                cell.questionContentButton.sizeToFit()
                let buttonLabel = cell.questionContentButton.titleLabel
                cell.questionContentButton.frame = CGRect(x: (buttonLabel?.frame.origin.x)!, y: (buttonLabel?.frame.origin.y)!, width: (buttonLabel?.frame.width)!, height: (buttonLabel?.frame.height)!)
                cell.questionContentHeight.constant = cell.questionContentButton.titleLabel!.frame.size.height
                cell.questionContentButton.layoutIfNeeded()
                
            }
            
            cell.questionContentButton.addTarget(self, action: "questionContentPressed:", forControlEvents: .TouchUpInside)
            cell.questionContentButton.tag = indexPath.row
            
            let videoUrl = answerArray[indexPath.row].video_url
            let cloudUrl = cloudfrontUrl + "video.m3u8"
            
            let newURL = NSURL(string: videoUrl)
            cell.player = AVPlayer(URL: newURL!)
            cell.playerController.player = cell.player
            
            let frontCamera = answerArray[indexPath.row].frontCamera
            
            if frontCamera {
                cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            }
            //            self.addChildViewController(cell.playerController)
            cell.videoView.addSubview(cell.playerController.view)
            
            cell.player.pause()
            if indexPath.row == 0 {
                cell.player.play()
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            cell.playerController.view.userInteractionEnabled = true
            
            let view = UIView(frame: CGRectMake(cell.videoView.frame.origin.x, cell.videoView.frame.origin.y, cell.videoView.frame.size.width, cell.videoView.frame.size.height))
            cell.videoView.addSubview(view)
            
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
            
            let likeCount = answerArray[indexPath.row].likeCount
            
            cell.likeCountTextView.text = "\(likeCount)"
            cell.videoView.bringSubviewToFront(cell.likeCountTextView)
            cell.videoView.bringSubviewToFront(cell.heartImageView)
            
            cell.likeButton.tag = indexPath.row
            cell.likeButton.addTarget(self, action: "toggleLike:", forControlEvents: .TouchUpInside)
            cell.videoView.bringSubviewToFront(cell.likeButton)
            
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
            
            let liked_by_user = self.answerArray[indexPath.row].liked_by_user
            
            if liked_by_user == true {
                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                cell.heartImageView.image = UIImage(named: "RedHeart")
            } else {
                let url = globalurl + "api/answers/" + answerArray[indexPath.row].id + "/likecheck/" + userid
                
                Alamofire.request(.GET, url, parameters: nil)
                    .responseJSON { response in
                        let result = response.result.value
                        print(result)
                        if result == nil {
                            print("Gobi")
                            cell.likeCountTextView.textColor = UIColor(red: 0.776, green: 0.776, blue: 0.776, alpha: 1)
                            cell.heartImageView.image = UIImage(named: "GrayHeart")
                        } else {
                            print("Liked")
                            cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                            cell.heartImageView.image = UIImage(named: "RedHeart")
                            self.answerArray[indexPath.row].liked_by_user = true
                        }
                }
            }

            
            return cell
        } else {
            let cell: FollowingQuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("followingQuestionCell", forIndexPath: indexPath) as! FollowingQuestionTableViewCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
            
            let creatorname = questionArray[indexPath.row].creatorname
            let content = questionArray[indexPath.row].content
            
            let creator = questionArray[indexPath.row].creator
            
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
            
            let userText = creatorname + " posted:"
            
            cell.usernameButton.setTitle(userText, forState: .Normal)
            cell.contentTextView.text = content
            
            cell.contentTextView.font = UIFont(name: "HelveticaNeue", size: 16)
            cell.contentTextView.userInteractionEnabled = false
            
            return cell
        }
        
    }
    
    func questionContentPressed(sender: UIButton) {
        let tag = sender.tag
        self.questionIndex = tag
        self.performSegueWithIdentifier("segueFromFollowingToAnswers", sender: self)
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
                        print("Already liked")
                    } else {
                        print("Liked")
                        self.answerArray[tag].likeCount -= 1
                        self.answerArray[tag].liked_by_user = false
                        let likeCount = self.answerArray[tag].likeCount
                        cell.likeCountTextView.text = "\(likeCount)"
                        cell.likeCountTextView.textColor = UIColor(red: 0.776, green: 0.776, blue: 0.776, alpha: 1)
                        cell.heartImageView.image = UIImage(named: "GrayHeart")
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
                        cell.likeCountTextView.text = "\(likeCount)"
                        cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                        cell.heartImageView.image = UIImage(named: "RedHeart")
                    }
            }
        }
    }
    
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        print("Double Tap")
        let tag = sender.view?.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 0)) as! FollowingAnswerTableViewCell
        
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
                            cell.likeCountTextView.text = "\(likeCount)"
                            cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                            cell.heartImageView.image = UIImage(named: "RedHeart")
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
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 0)) as! FollowingAnswerTableViewCell
        if (cell.player.rate > 0) {
            cell.player.pause()
        } else {
            cell.player.play()
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if counter == 1 {
            self.performSegueWithIdentifier("segueFromFollowingToAnswers", sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromFollowingToAnswers" {
            let answerVC: AnswersViewController = segue.destinationViewController as! AnswersViewController
            if counter == 0 {
                let indexPath = self.questionIndex
                let content = self.answerArray[indexPath].question_content
                let id = self.answerArray[indexPath].question_id
                answerVC.content = content
                answerVC.id = id
            } else {
                let indexPath = self.tableView.indexPathForSelectedRow
                let content = self.questionArray[indexPath!.row].content
                let id = self.questionArray[indexPath!.row].id
                let creatorname = self.questionArray[indexPath!.row].creatorname
                self.selectedIndexPath = indexPath!.row
                answerVC.content = content
                answerVC.id = id
                answerVC.creatorname = creatorname
            }
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
            if cell.isKindOfClass(FollowingAnswerTableViewCell) {
                let indexPath = tableView.indexPathForCell(cell)
                let cellRect = tableView.rectForRowAtIndexPath(indexPath!)
                let superView = tableView.superview
                let convertedRect = tableView.convertRect(cellRect, toView: superView)
                let intersect = CGRectIntersection(tableView.frame, convertedRect)
                let visibleHeight = CGRectGetHeight(intersect)
                let cellHeight = tableView.frame.height * 0.6
                let cell = cell as! FollowingAnswerTableViewCell
                
                if visibleHeight > cellHeight {
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
    

}
