//
//  ProfileViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 11/3/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MobileCoreServices
import AWSS3
import AVFoundation
import AVKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var myQuestionArray = [Question]()
    var myAnswerArray = [Answer]()
    var myLikedAnswerArray = [Answer]()
    var followerCount = 0
    var followingCount = 0
    
    var counter = 0
    var questionIndex = 0
    var profileDescription = ""
    
    var fromOtherVC = false
    var creatorId = ""
    var id = ""
    var creatorname = ""
    
    var refreshControl:UIRefreshControl!
    
    func loadFollowInfo() {
        
        let url = globalurl + "api/users/" + id
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                } else {
                    let json = JSON(value!)
                    print("JSON: \(json)")
                    var followerCount = json["followerCount"].number?.integerValue
                    var followingCount = json["followingCount"].number?.integerValue
                    
                    if followerCount == nil {
                        followerCount = 0
                    }
                    
                    if followingCount == nil {
                        followingCount = 0
                    }
                    
                    self.followerCount = followerCount!
                    self.followingCount = followingCount!
                    
                    self.tableView.reloadData()
                }
        }
    }
    
    func loadMyQuestions() {
        
        let url = globalurl + "api/myquestions/" + id
        
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
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: answered, currentuser: user, createdAt: yourDate, creator: creator, likecount: likecount)
                    self.myQuestionArray.append(question)
                    
                    self.tableView.reloadData()
                }
        }
    }
    
    func loadMyAnswers() {
        
        let url = globalurl + "api/users/" + id + "/answers/"
        
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
                    var content = subJson["content"].string
                    let id = subJson["_id"].string
                    let creator = subJson["creator"].string
                    let creatorname = subJson["creatorname"].string
                    let question_id = subJson["question_id"].string
                    let video_url = subJson["video_url"].string
                    var likeCount = subJson["likes"].int
                    var frontCamera = subJson["frontCamera"].bool
                    var views = subJson["views"].number?.integerValue
                    if views == nil {
                        views = 0
                    }
                    
                    var question_content = subJson["question_content"].string
                    if question_content == nil {
                        question_content = ""
                    }
                    
                    let createdAt = subJson["created_at"].string
                    let dateFor: NSDateFormatter = NSDateFormatter()
                    dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
                    
                    if frontCamera == nil {
                        frontCamera = true
                    }
                    
                    if content == nil {
                        content = ""
                    }
                    
                    if likeCount == nil {
                        likeCount = 0
                    }
                    
                    if video_url != nil {
                        
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
                                    
                                    let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: content, video_url: video_url, likeCount: likeCount, liked_by_user: false, frontCamera: frontCamera, createdAt: yourDate, views: views)
                                    self.myAnswerArray.append(answer)
                                    self.myAnswerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                    self.tableView.reloadData()
                                    
                                    
                            }
                        } else {
                            let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: question_content, video_url: video_url, likeCount: likeCount, liked_by_user: false, frontCamera: frontCamera, createdAt: yourDate, views: views)
                            self.myAnswerArray.append(answer)
                            self.myAnswerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                            
                            self.tableView.reloadData()
                        }
                    }
                }
        }
    }
    
    func loadMyLikedAnswers() {
        
        let url = globalurl + "api/users/" + id + "/mylikedanswers/"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                print("myLikedAnswer")
                if value == nil {
                    value = []
                }
                
                let json = JSON(value!)
                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    var content = subJson["content"].string
                    let id = subJson["_id"].string
                    let creator = subJson["creator"].string
                    let creatorname = subJson["creatorname"].string
                    let question_id = subJson["question_id"].string
                    let video_url = subJson["video_url"].string
                    var likeCount = subJson["likes"].int
                    var frontCamera = subJson["frontCamera"].bool
                    let createdAt = subJson["created_at"].string
                    let dateFor: NSDateFormatter = NSDateFormatter()
                    dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
                    var views = subJson["views"].number?.integerValue
                    if views == nil {
                        views = 0
                    }
                    
                    var question_content = subJson["question_content"].string
                    if question_content == nil {
                        question_content = ""
                    }
                    
                    if frontCamera == nil {
                        frontCamera = true
                    }
                    
                    if content == nil {
                        content = ""
                    }
                    
                    if likeCount == nil {
                        likeCount = 0
                    }
                    
                    if video_url != nil {
                        
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
                                    
                                    let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: content, video_url: video_url, likeCount: likeCount, liked_by_user: false, frontCamera: frontCamera, createdAt: yourDate, views: views)
                                    self.myLikedAnswerArray.append(answer)
                                    self.myLikedAnswerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                    self.tableView.reloadData()
                                    
                                    
                            }
                        } else {
                            let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: question_content, video_url: video_url, likeCount: likeCount, liked_by_user: false, frontCamera: frontCamera, createdAt: yourDate, views: views)
                            self.myLikedAnswerArray.append(answer)
                            self.myLikedAnswerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                            
                            self.tableView.reloadData()
                        }
                    }
                    
                }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        for cell in tableView.visibleCells {
            if cell.isKindOfClass(ProfileRelayTableViewCell) {
                let cell = cell as! ProfileRelayTableViewCell
                cell.player.pause()
            } else if cell.isKindOfClass(ProfileLikedTableViewCell) {
                let cell = cell as! ProfileLikedTableViewCell
                cell.player.pause()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if fromOtherVC {
            id = self.creatorId
            self.navigationItem.title = creatorname
        } else {
            id = userid
            self.navigationItem.title = name
        }
        
        // Do any additional setup after loading the view.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70
        
        self.loadFollowInfo()
        
        self.myQuestionArray.removeAll(keepCapacity: true)
        self.loadMyQuestions()
        
        self.myAnswerArray.removeAll(keepCapacity: true)
        self.loadMyAnswers()
        
        self.myLikedAnswerArray.removeAll(keepCapacity: true)
        self.loadMyLikedAnswers()
        
        self.refreshControl = UIRefreshControl()
        //        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFeed", name: "askedQuestion", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFeed", name: "submittedAnswer", object: nil)
    }
    
    func refreshFeed() {
        self.myQuestionArray.removeAll(keepCapacity: true)
        self.myAnswerArray.removeAll(keepCapacity: true)
        self.myLikedAnswerArray.removeAll(keepCapacity: true)
        
        self.loadFollowInfo()
        self.loadMyQuestions()
        self.loadMyAnswers()
        self.loadMyLikedAnswers()
        
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        self.myQuestionArray.removeAll(keepCapacity: true)
        self.myAnswerArray.removeAll(keepCapacity: true)
        self.myLikedAnswerArray.removeAll(keepCapacity: true)
        
        self.loadFollowInfo()
        self.loadMyQuestions()
        self.loadMyAnswers()
        self.loadMyLikedAnswers()
        
        self.tableView.reloadData()
        
        
        
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            if counter == 0 {
                return myQuestionArray.count
            } else if counter == 1 {
                return myAnswerArray.count
            } else {
                return myLikedAnswerArray.count
            }
        }
        
    }
    
    func profileSegmentedControlChanged(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            print("Money")
            counter = 0
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            for cell in tableView.visibleCells {
                if cell.isKindOfClass(ProfileRelayTableViewCell) {
                    let cell = cell as! ProfileRelayTableViewCell
                    cell.player.pause()
                } else if cell.isKindOfClass(ProfileLikedTableViewCell) {
                    let cell = cell as! ProfileLikedTableViewCell
                    cell.player.pause()
                }
            }
        } else if sender.selectedSegmentIndex == 1 {
            print("Mayweather")
            counter = 1
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            for cell in tableView.visibleCells {
                if cell.isKindOfClass(ProfileLikedTableViewCell) {
                    let cell = cell as! ProfileLikedTableViewCell
                    cell.player.pause()
                }
            }
            self.tableView.reloadData()
        } else {
            counter = 2
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            for cell in tableView.visibleCells {
                if cell.isKindOfClass(ProfileRelayTableViewCell) {
                    let cell = cell as! ProfileRelayTableViewCell
                    cell.player.pause()
                }
            }
        }
        
        self.tableView.reloadData()
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: ProfileTableViewCell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as! ProfileTableViewCell
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            if fromOtherVC {
                cell.profileButton.setTitle("FOLLOW", forState: .Normal)
            }
            
            cell.profileButton.layer.borderWidth = 1
            cell.profileButton.layer.borderColor = UIColor.blueColor().CGColor
            
            if profileDescription == "" {
                cell.profileDescriptionLabel.hidden = true
            } else {
                cell.profileDescriptionLabel.text = profileDescription
            }
            
            cell.followersButton.titleLabel?.textAlignment = .Center
            let stringFollowers = "\(self.followerCount)\nfollowers"
            print(stringFollowers)
            if let range = stringFollowers.rangeOfString("followers") {
                print(range)
                print(stringFollowers.startIndex..<range.startIndex)
                let firstPart = stringFollowers[stringFollowers.startIndex..<range.startIndex]
                print(firstPart) // print Hello
                let index: Int = stringFollowers.startIndex.distanceTo(range.startIndex)
                let myMutableString = NSMutableAttributedString(string: stringFollowers, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 13.0)!])
                myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 13.0)!, range: NSRange(location: index, length: 9))
                print(myMutableString)
                cell.followersButton.titleLabel?.textColor = UIColor.blackColor()
                cell.followersButton.setAttributedTitle(myMutableString, forState: .Normal)
            }
            
            
            cell.followingButton.titleLabel?.textAlignment = .Center
            let stringFollowing = "\(self.followingCount)\nfollowing"
            print(stringFollowing)
            if let range = stringFollowing.rangeOfString("following") {
                print(range)
                print(stringFollowing.startIndex..<range.startIndex)
                let firstPart = stringFollowing[stringFollowing.startIndex..<range.startIndex]
                print(firstPart) // print Hello
                let index: Int = stringFollowing.startIndex.distanceTo(range.startIndex)
                let myMutableString = NSMutableAttributedString(string: stringFollowing, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 13.0)!])
                myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 13.0)!, range: NSRange(location: index, length: 9))
                print(myMutableString)
                cell.followingButton.titleLabel?.textColor = UIColor.blackColor()
                cell.followingButton.setAttributedTitle(myMutableString, forState: .Normal)
            }
            
            
            cell.viewButton.titleLabel?.textAlignment = .Center
            let postedText = "1.2k\n"
            let myFirstString = NSMutableAttributedString(string: postedText, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 13.0)!])
            
            let creatornameText = "views"
            let mySecondString = NSMutableAttributedString(string: creatornameText, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 13.0)!])
            
            let result = NSMutableAttributedString()
            result.appendAttributedString(myFirstString)
            result.appendAttributedString(mySecondString)
            
            cell.viewButton.titleLabel?.textColor = UIColor.blackColor()
            cell.viewButton.setAttributedTitle(result, forState: .Normal)

            
            cell.profileImageView.image = UIImage(named: "Placeholder")
            if let cachedImageResult = imageCache[id] {
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
                readRequest1.key =  id
                readRequest1.downloadingFileURL = downloadingFileURL1
                
                let task = transferManager.download(readRequest1)
                task.continueWithBlock { (task) -> AnyObject! in
                    if task.error != nil {
                        print("No Profile Pic")
                    } else {
                        let image = UIImage(contentsOfFile: downloadingFilePath1)
                        let imageData = UIImageJPEGRepresentation(image!, 1.0)
                        imageCache[self.id] = imageData
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
        }
        else if indexPath.section == 1 {
//            let cell: ProfileSegmentedTableViewCell = tableView.dequeueReusableCellWithIdentifier("SegmentedCell", forIndexPath: indexPath) as! ProfileSegmentedTableViewCell
//            
//            cell.preservesSuperviewLayoutMargins = false
//            cell.separatorInset = UIEdgeInsetsZero
//            cell.layoutMargins = UIEdgeInsetsZero
//            
//            cell.profileSegmentedControl.addTarget(self, action: "profileSegmentedControlChanged:", forControlEvents: .ValueChanged)
//            
//            return cell
            let cell: ProfileButtonsTableViewCell = tableView.dequeueReusableCellWithIdentifier("profileButtonsCell", forIndexPath: indexPath) as! ProfileButtonsTableViewCell
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            cell.pencilButton.addTarget(self, action: "toggleButton:", forControlEvents: .TouchUpInside)
            cell.recorderButton.addTarget(self, action: "toggleButton:", forControlEvents: .TouchUpInside)
            cell.heartButton.addTarget(self, action: "toggleButton:", forControlEvents: .TouchUpInside)
            cell.pencilButton.tag = 0
            cell.recorderButton.tag = 1
            cell.heartButton.tag = 2
            
            if counter == 0 {
                cell.pencilButton.selected = true
                cell.recorderButton.selected = false
                cell.heartButton.selected = false
            } else if counter == 1 {
                cell.pencilButton.selected = false
                cell.recorderButton.selected = true
                cell.heartButton.selected = false
            } else if counter == 2 {
                cell.pencilButton.selected = false
                cell.recorderButton.selected = false
                cell.heartButton.selected = true
            }
            
            return cell

        }
        if counter == 0 {
            let cell: ProfileQuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("profileQuestionCell", forIndexPath: indexPath) as! ProfileQuestionTableViewCell
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            let date = myQuestionArray[indexPath.row].createdAt
            let timeAgo = timeAgoSinceDate(date, numericDates: true)
            
            cell.timeAgoLabel.text = timeAgo
            
            cell.questionTextView.text = myQuestionArray[indexPath.row].content
            cell.questionTextView.userInteractionEnabled = false
            let answerCount = myQuestionArray[indexPath.row].answercount
            cell.answercountLabel.text = "\(answerCount)"
            
            let likecount = myQuestionArray[indexPath.row].likecount
            cell.likeCountTextView.text = "\(likecount)"
            cell.likeCountTextView.editable = false
            cell.likeCountTextView.selectable = false
            
            return cell
        } else if counter == 1 {
            let cell: ProfileRelayTableViewCell = tableView.dequeueReusableCellWithIdentifier("RelayCell", forIndexPath: indexPath) as! ProfileRelayTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            let date = myAnswerArray[indexPath.row].createdAt
            let timeAgo = timeAgoSinceDate(date, numericDates: true)
            
            cell.timeAgoLabel.text = timeAgo
            
            print(myAnswerArray[indexPath.row].question_content)
            cell.contentTextView.text = myAnswerArray[indexPath.row].question_content
            cell.contentTextView.userInteractionEnabled = false
           
            let videoUrl = myAnswerArray[indexPath.row].video_url
            
            let newURL = NSURL(string: videoUrl)
            cell.player = AVPlayer(URL: newURL!)
            cell.playerController.player = cell.player
            let frontCamera = myAnswerArray[indexPath.row].frontCamera
            
            print(frontCamera)
            if frontCamera == true {
                cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            }
//            cell.layoutIfNeeded()
//            self.addChildViewController(cell.playerController)
            cell.videoView.addSubview(cell.playerController.view)
//            cell.playerController.didMoveToParentViewController(self)
            cell.player.pause()
            
            if indexPath.row == 0 {
                cell.player.play()
                
                let url = globalurl + "api/answers/" + myAnswerArray[indexPath.row].id + "/viewed/"
                
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
            
            cell.questionContentButton.addTarget(self, action: "questionContentPressed:", forControlEvents: .TouchUpInside)
            cell.questionContentButton.tag = indexPath.row
            
            cell.playerController.view.userInteractionEnabled = true
            
            let view = UIView(frame: cell.playerController.view.frame)
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
            
            let likeCount = self.myAnswerArray[indexPath.row].likeCount
            print(likeCount)
            cell.likeCountTextView.text = "\(likeCount) likes"
            cell.videoView.bringSubviewToFront(cell.likeCountTextView)
            cell.videoView.bringSubviewToFront(cell.heartImageView)
            
            let views = myAnswerArray[indexPath.row].views
            cell.viewCountLabel.text = "\(views) views"
            
            cell.likeButton.tag = indexPath.row
            cell.likeButton.addTarget(self, action: "toggleLike:", forControlEvents: .TouchUpInside)
            cell.videoView.bringSubviewToFront(cell.likeButton)
            
            let liked_by_user = self.myAnswerArray[indexPath.row].liked_by_user
            
            if liked_by_user == true {
                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                cell.heartImageView.image = UIImage(named: "redHeartOutline")
            } else {
                let url = globalurl + "api/answers/" + myAnswerArray[indexPath.row].id + "/likecheck/" + userid
                
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
                            self.myAnswerArray[indexPath.row].liked_by_user = true
                        }
                }
            }
            
            return cell
            
        } else {
            
            let cell: ProfileLikedTableViewCell = tableView.dequeueReusableCellWithIdentifier("profileLikedCell", forIndexPath: indexPath) as! ProfileLikedTableViewCell
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            var question_content = myLikedAnswerArray[indexPath.row].question_content
            let question_id = myLikedAnswerArray[indexPath.row].question_id
            
            let creatorname = myLikedAnswerArray[indexPath.row].creatorname
            
            let postedText = "\(creatorname)"
            let myFirstString = NSMutableAttributedString(string: postedText, attributes: [NSForegroundColorAttributeName:UIColor.blackColor(), NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 12.0)!])
            
            let creatornameText = " relayed:"
            let mySecondString = NSMutableAttributedString(string: creatornameText, attributes: [NSForegroundColorAttributeName:UIColor.blackColor(), NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 12.0)!])
            
            let result = NSMutableAttributedString()
            result.appendAttributedString(myFirstString)
            result.appendAttributedString(mySecondString)
            
            cell.usernameButton.setAttributedTitle(result, forState: .Normal)
            cell.usernameButton.addTarget(self, action: "usernameTapped:", forControlEvents: .TouchUpInside)
            cell.usernameButton.tag = indexPath.row
            
            let creator = myLikedAnswerArray[indexPath.row].creator
            
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
                        self.myLikedAnswerArray[indexPath.row].question_content = question_content
                        cell.questionContentTextView.text = question_content
                        cell.questionContentTextView.editable = false
                        cell.questionContentTextView.selectable = false
                        for (_,subJson):(String, JSON) in json {
                            //Do something you want
                            
                        }
                }
            } else {
                cell.questionContentTextView.text = question_content
                cell.questionContentTextView.editable = false
                cell.questionContentTextView.selectable = false
            }
            
            cell.questionContentButton.addTarget(self, action: "questionContentPressed:", forControlEvents: .TouchUpInside)
            cell.contentView.bringSubviewToFront(cell.questionContentButton)
            cell.questionContentButton.tag = indexPath.row
            
            let videoUrl = myLikedAnswerArray[indexPath.row].video_url
            let cloudUrl = cloudfrontUrl + "video.m3u8"
            
            let newURL = NSURL(string: videoUrl)
            cell.player = AVPlayer(URL: newURL!)
            cell.playerController.player = cell.player
            
            let frontCamera = myLikedAnswerArray[indexPath.row].frontCamera
            print(frontCamera)
            
            if frontCamera {
                cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            }
            cell.layoutIfNeeded()
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
            
            let date = myLikedAnswerArray[indexPath.row].createdAt
            let timeAgo = timeAgoSinceDate(date, numericDates: true)
            
            cell.timeAgoLabel.text = timeAgo
            
            let views = myLikedAnswerArray[indexPath.row].views
            cell.viewCountLabel.text = "\(views) views"
            
            let doubleTapGesture = UITapGestureRecognizer()
            doubleTapGesture.numberOfTapsRequired = 2
            doubleTapGesture.addTarget(self, action: "doubleTapped:")
            view.addGestureRecognizer(doubleTapGesture)
            
            let likeCount = myLikedAnswerArray[indexPath.row].likeCount
            
            cell.likeCountTextView.text = "\(likeCount) likes"
            cell.videoView.bringSubviewToFront(cell.likeCountTextView)
            cell.videoView.bringSubviewToFront(cell.heartImageView)
            
            cell.likeButton.tag = indexPath.row
            cell.likeButton.addTarget(self, action: "toggleLike:", forControlEvents: .TouchUpInside)
            cell.videoView.bringSubviewToFront(cell.likeButton)
            
            if indexPath.row == 0 {
                cell.player.play()
                
                let url = globalurl + "api/answers/" + myLikedAnswerArray[indexPath.row].id + "/viewed/"
                
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
            
            let liked_by_user = self.myLikedAnswerArray[indexPath.row].liked_by_user
            
            if liked_by_user == true {
                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                cell.heartImageView.image = UIImage(named: "redHeartOutline")
            } else {
                let url = globalurl + "api/answers/" + myLikedAnswerArray[indexPath.row].id + "/likecheck/" + userid
                
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
                            self.myLikedAnswerArray[indexPath.row].liked_by_user = true
                        }
                }
            }
            
            return cell
            
        }
        
        
        
    }
    
    func usernameTapped(sender:UIButton) {
//        let tag = sender.tag
//        let profileVC = ProfileViewController()
//        let creatorId = myLikedAnswerArray[tag].creator
//        let creatorname = myLikedAnswerArray[tag].creatorname
//        profileVC.fromOtherVC = true
//        profileVC.creatorId = creatorId
//        profileVC.creatorname = creatorname
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewControllerWithIdentifier("profileVC")
//        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func toggleButton(sender: UIButton) {
        let tag = sender.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as! ProfileButtonsTableViewCell
        
        if tag == 0 {
            if counter == 0 {
                
            } else {
                counter = 0
                for cell in tableView.visibleCells {
                    if cell.isKindOfClass(ProfileRelayTableViewCell) {
                        let cell = cell as! ProfileRelayTableViewCell
                        cell.player.pause()
                    } else if cell.isKindOfClass(ProfileLikedTableViewCell) {
                        let cell = cell as! ProfileLikedTableViewCell
                        cell.player.pause()
                    }
                }
                cell.pencilButton.selected = true
                cell.recorderButton.selected = false
                cell.heartButton.selected = false
                self.tableView.reloadData()
            }
        } else if tag == 1 {
            if counter == 1 {
                
            } else {
                counter = 1
                for cell in tableView.visibleCells {
                    if cell.isKindOfClass(ProfileLikedTableViewCell) {
                        let cell = cell as! ProfileLikedTableViewCell
                        cell.player.pause()
                    }
                }
                cell.pencilButton.selected = false
                cell.recorderButton.selected = true
                cell.heartButton.selected = false
                self.tableView.reloadData()
            }
        } else if tag == 2 {
            if counter == 2 {
                
            } else {
                counter = 2
                for cell in tableView.visibleCells {
                    if cell.isKindOfClass(ProfileRelayTableViewCell) {
                        let cell = cell as! ProfileRelayTableViewCell
                        cell.player.pause()
                    }
                }
                cell.pencilButton.selected = false
                cell.recorderButton.selected = false
                cell.heartButton.selected = true
                self.tableView.reloadData()
            }
        }
    }
    
    func questionContentPressed(sender: UIButton) {
        if counter == 1 {
            let tag = sender.tag
            self.questionIndex = tag
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 2)) as! ProfileRelayTableViewCell
            if (cell.player.rate > 0) {
                cell.player.pause()
            } else {
                cell.player.play()
            }
            self.performSegueWithIdentifier("segueFromProfileToAnswers", sender: self)
        } else if counter == 2 {
            let tag = sender.tag
            self.questionIndex = tag
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 2)) as! ProfileLikedTableViewCell
            if (cell.player.rate > 0) {
                cell.player.pause()
            } else {
                cell.player.play()
            }
            self.performSegueWithIdentifier("segueFromProfileToAnswers", sender: self)
        }
        
        
    }
    
    func toggleLike(sender: UIButton!) {
        print("button hit")
        
        if counter == 1 {
            let currentLiked = self.myAnswerArray[sender.tag].liked_by_user
            let tag = sender.tag
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 2)) as! ProfileRelayTableViewCell
            let answerId = self.myAnswerArray[sender.tag].id
            
            if currentLiked == true {
                print("unliked")
                
                let url = globalurl + "api/answers/" + myAnswerArray[sender.tag].id + "/unlikednotifs/" + userid
                
                Alamofire.request(.PUT, url, parameters: nil)
                    .responseJSON { response in
                        let result = response.result.value
                        print(result)
                        if result == nil {
                            
                        } else {
                            print("unliked")
                            self.myAnswerArray[tag].likeCount -= 1
                            self.myAnswerArray[tag].liked_by_user = false
                            let likeCount = self.myAnswerArray[tag].likeCount
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
                            self.myAnswerArray[tag].likeCount += 1
                            self.myAnswerArray[tag].liked_by_user = true
                            let likeCount = self.myAnswerArray[tag].likeCount
                            cell.likeCountTextView.text = "\(likeCount) likes"
                            cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                            cell.heartImageView.image = UIImage(named: "redHeartOutline")
                        }
                }
            }
        } else if counter == 2 {
            let currentLiked = self.myLikedAnswerArray[sender.tag].liked_by_user
            let tag = sender.tag
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 2)) as! ProfileLikedTableViewCell
            let answerId = self.myLikedAnswerArray[sender.tag].id
            
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
                            self.myLikedAnswerArray[tag].likeCount -= 1
                            self.myLikedAnswerArray[tag].liked_by_user = false
                            let likeCount = self.myLikedAnswerArray[tag].likeCount
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
                            self.myLikedAnswerArray[tag].likeCount += 1
                            self.myLikedAnswerArray[tag].liked_by_user = true
                            let likeCount = self.myLikedAnswerArray[tag].likeCount
                            cell.likeCountTextView.text = "\(likeCount) likes"
                            cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                            cell.heartImageView.image = UIImage(named: "redHeartOutline")
                        }
                }
            }
        }
        
    }
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        print("Double Tap")
        let tag = sender.view?.tag
        
        if counter == 1 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 2)) as! ProfileRelayTableViewCell
            
            cell.likeImageView.hidden = false
            
            UIView.animateWithDuration(1.0, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                cell.likeImageView.alpha = 0
                }) { (success) -> Void in
                    cell.likeImageView.alpha = 1
                    cell.likeImageView.hidden = true
                    
                    let answerId = self.myAnswerArray[tag!].id
                    
                    let url = globalurl + "api/answers/" + answerId + "/likednotifs/" + userid
                    
                    Alamofire.request(.PUT, url, parameters: nil)
                        .responseJSON { response in
                            let result = response.result.value
                            print(result)
                            if result == nil {
                                print("Already liked")
                                
                            } else {
                                print("Liked")
                                self.myAnswerArray[tag!].likeCount += 1
                                self.myAnswerArray[tag!].liked_by_user = true
                                let likeCount = self.myAnswerArray[tag!].likeCount
                                cell.likeCountTextView.text = "\(likeCount) likes"
                                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                                cell.heartImageView.image = UIImage(named: "redHeartOutline")
                            }
                    }
            }
        } else if counter == 2 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 2)) as! ProfileLikedTableViewCell
            
            cell.likeImageView.hidden = false
            
            UIView.animateWithDuration(1.0, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                cell.likeImageView.alpha = 0
                }) { (success) -> Void in
                    cell.likeImageView.alpha = 1
                    cell.likeImageView.hidden = true
                    
                    let answerId = self.myLikedAnswerArray[tag!].id
                    
                    let url = globalurl + "api/answers/" + answerId + "/likednotifs/" + userid
                    
                    Alamofire.request(.PUT, url, parameters: nil)
                        .responseJSON { response in
                            let result = response.result.value
                            print(result)
                            if result == nil {
                                print("Already liked")
                                
                            } else {
                                print("Liked")
                                self.myLikedAnswerArray[tag!].likeCount += 1
                                self.myLikedAnswerArray[tag!].liked_by_user = true
                                let likeCount = self.myLikedAnswerArray[tag!].likeCount
                                cell.likeCountTextView.text = "\(likeCount) likes"
                                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                                cell.heartImageView.image = UIImage(named: "redHeartOutline")
                            }
                    }
            }
        }
        
    }
    
    func singleTapped(sender: UITapGestureRecognizer) {
        print("Tapped")
        let tag = sender.view?.tag
        
        if counter == 1 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 2)) as! ProfileRelayTableViewCell
            if (cell.player.rate > 0) {
                cell.player.pause()
            } else {
                cell.player.play()
            }
        } else if counter == 2 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 2)) as! ProfileLikedTableViewCell
            if (cell.player.rate > 0) {
                cell.player.pause()
            } else {
                cell.player.play()
            }
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            
        } else {
            if counter == 0 {
                self.performSegueWithIdentifier("segueFromProfileToAnswers", sender: self)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            } else {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromProfileToAnswers" {
            let answerVC: AnswersViewController = segue.destinationViewController as! AnswersViewController
            if counter == 0 {
                let indexPath = self.tableView.indexPathForSelectedRow
                let content = self.myQuestionArray[indexPath!.row].content
                let id = self.myQuestionArray[indexPath!.row].id
                let creatorname = self.myQuestionArray[indexPath!.row].creatorname
                let question = self.myQuestionArray[indexPath!.row]
                answerVC.content = content
                answerVC.id = id
                answerVC.creatorname = creatorname
                answerVC.fromProfile = true
                answerVC.question = question
            } else if counter == 1 {
                let indexPath = self.questionIndex
                let content = self.myAnswerArray[indexPath].question_content
                let id = self.myAnswerArray[indexPath].question_id
                answerVC.content = content
                answerVC.id = id
                answerVC.fromFollowing = true
            } else if counter == 2 {
                let indexPath = self.questionIndex
                let content = self.myLikedAnswerArray[indexPath].question_content
                let id = self.myLikedAnswerArray[indexPath].question_id
                answerVC.content = content
                answerVC.id = id
                answerVC.fromFollowing = true
            }
            
        } else if segue.identifier == "segueFromProfileToFollowers" {
            let userListVC: UserListViewController = segue.destinationViewController as! UserListViewController
            userListVC.counter = "followers"
            userListVC.id = self.id
        } else if segue.identifier == "segueFromProfileToFollowing" {
            let userListVC: UserListViewController = segue.destinationViewController as! UserListViewController
            userListVC.counter = "following"
            userListVC.id = self.id
        }
    }
    
    @IBAction func imageButtonClicked(sender: UIButton) {
        print("Clicked")
        if fromOtherVC {
            
        } else  {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let libButton = UIAlertAction(title: "Select photo from library", style: UIAlertActionStyle.Default) { (alert) -> Void in
                let photoLibraryController = UIImagePickerController()
                photoLibraryController.delegate = self
                photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                
                let mediaTypes:[String] = [kUTTypeImage as String]
                photoLibraryController.mediaTypes = mediaTypes
                photoLibraryController.allowsEditing = true
                
                self.presentViewController(photoLibraryController, animated: true, completion: nil)
            }
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
                let cameraButton = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.Default) { (alert) -> Void in
                    print("Take Photo", terminator: "")
                    let cameraController = UIImagePickerController()
                    //if it is then create an instance of UIImagePickerController
                    cameraController.delegate = self
                    cameraController.sourceType = UIImagePickerControllerSourceType.Camera
                    
                    let mediaTypes:[String] = [kUTTypeImage as String]
                    //pass in the image as data
                    
                    cameraController.mediaTypes = mediaTypes
                    cameraController.allowsEditing = true
                    
                    self.presentViewController(cameraController, animated: true, completion: nil)
                    
                }
                alert.addAction(cameraButton)
            } else {
                print("Camera not available", terminator: "")
                
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                print("Cancel Pressed", terminator: "")
            }
            
            alert.addAction(libButton)
            alert.addAction(cancelButton)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        let squareImage = RBSquareImage(editedImage)
        
        // Save image in S3 with the userID
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let testFileURL1 = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp"))
        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        
        let data = UIImageJPEGRepresentation(squareImage, 0.01)
        data!.writeToURL(testFileURL1, atomically: true)
        uploadRequest1.bucket = S3BucketName
        uploadRequest1.key =  userid
        uploadRequest1.body = testFileURL1
        
        
        let task = transferManager.upload(uploadRequest1)
        task.continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                print("Error: \(task.error)", terminator: "")
            } else {
//                self.download()
                self.tableView.reloadData()
                print("Upload successful", terminator: "")
            }
            return nil
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
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
            if cell.isKindOfClass(ProfileRelayTableViewCell) {
                let indexPath = tableView.indexPathForCell(cell)
                let cellRect = tableView.rectForRowAtIndexPath(indexPath!)
                let superView = tableView.superview
                let convertedRect = tableView.convertRect(cellRect, toView: superView)
                let intersect = CGRectIntersection(tableView.frame, convertedRect)
                let visibleHeight = CGRectGetHeight(intersect)
                let cellHeight = tableView.frame.height * 0.6
                let cell = cell as! ProfileRelayTableViewCell
                
                if visibleHeight > cellHeight {
                    if (cell.player.rate > 0) {
                        let url = globalurl + "api/answers/" + myAnswerArray[(indexPath?.row)!].id + "/viewed/"
                        
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
                        let url = globalurl + "api/answers/" + myAnswerArray[(indexPath?.row)!].id + "/viewed/"
                        
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
            else if cell.isKindOfClass(ProfileLikedTableViewCell) {
                let indexPath = tableView.indexPathForCell(cell)
                let cellRect = tableView.rectForRowAtIndexPath(indexPath!)
                let superView = tableView.superview
                let convertedRect = tableView.convertRect(cellRect, toView: superView)
                let intersect = CGRectIntersection(tableView.frame, convertedRect)
                let visibleHeight = CGRectGetHeight(intersect)
                let cellHeight = tableView.frame.height * 0.6
                let cell = cell as! ProfileLikedTableViewCell
                
                if visibleHeight > cellHeight {
                    if (cell.player.rate > 0) {
                        let url = globalurl + "api/answers/" + myLikedAnswerArray[(indexPath?.row)!].id + "/viewed/"
                        
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
                        let url = globalurl + "api/answers/" + myLikedAnswerArray[(indexPath?.row)!].id + "/viewed/"
                        
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
    
    
    func RBSquareImage(image: UIImage) -> UIImage {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        
        var edge: CGFloat
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }
        
        let posX = (originalWidth  - edge) / 2.0
        let posY = (originalHeight - edge) / 2.0
        
        let cropSquare = CGRectMake(posX, posY, edge, edge)
        
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
        return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
    }
    

}
