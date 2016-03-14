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
import KeychainSwift
import JWTDecode
import Crashlytics
import TwitterKit
import MessageUI
import FBSDKShareKit

class AnswersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var relayButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var moreInfoBarButton: UIBarButtonItem!
    
    // MARK: - Variables
    let keychain = KeychainSwift()
    var content = ""
    var id = ""
    var creatorname = ""
    var fromProfile = false
    var question: Question?
    var fromFollowing = false
    var nameIndex = 0
    var questionName = false
    var fromFeatured = false
    var answerArray = [Answer]()
    let label = UILabel(frame: CGRectMake(0, 0, 400, 400))
    var indexPath = 0
    let interactor = Interactor()
    var fromVideo = false
    
    // MARK: - viewWill/viewDid
    override func viewWillAppear(animated: Bool) {
        // Changes navController if from a followingVC
        if fromFollowing {
            self.navigationController?.hidesBarsOnSwipe = false
            self.navigationController?.navigationBar.hidden = false
            if question == nil {
                self.loadQuestion()
            }
        }
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }
    
    func dismissVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if fromVideo {
            // Create left and right button for navigation item
            let leftButton =  UIBarButtonItem(title: "X", style:   UIBarButtonItemStyle.Plain, target: self, action: "dismissVC")
            leftButton.tintColor = UIColor.whiteColor()
            leftButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 22)!], forState: .Normal)
            
            // Create two buttons for the navigation item
            self.navigationItem.leftBarButtonItem = leftButton
        }
        
        self.navigationItem.title = "Relays"
        self.tabBarController?.tabBar.hidden = true
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 300
        self.tableView.scrollsToTop = true
        
        self.moreInfoBarButton.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor(red:0.91, green:0.27, blue:0.27, alpha:1.0), NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 28)!], forState: .Normal)
        
        label.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, 300)
        label.textAlignment = NSTextAlignment.Center
        label.text = "No Answers"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 30)
        label.numberOfLines = 0
        self.tableView.addSubview(label)
        label.hidden = true
        
        if fromFeatured {
            self.loadFeaturedAnswers()
        } else {
            self.loadAnswers()
        }
        
        // Refresh feed if user asks a question
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFeed", name: "madeVideo", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshQuestion", name: "questionEdited", object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - loadFunctions
    
    func refreshFeed(){
        if fromFeatured {
            self.loadFeaturedAnswers()
        } else {
            self.loadAnswers()
        }
        
    }
    
    func refreshQuestion() {
        self.loadQuestion()
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
    
    func loadAnswers(){
        let url = globalurl + "api/questions/" + id + "/answers/"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                if value == nil {
                    value = []
                    print("No answers")
                    self.label.hidden = false
                } else {
                    self.answerArray.removeAll(keepCapacity: true)
                    let json = JSON(value!)
                    //                print("JSON: \(json)")
                    if json == [] {
                        print("No answers")
                    }
                    for (_,subJson):(String, JSON) in json {
                        //Do something you want
                        
                        self.label.hidden = true
                        
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
                        
                        var question_id = subJson["question_id"].string
                        if question_id == nil {
                            question_id = ""
                        }
                        var question_content = subJson["question_content"].string
                        if question_content == nil {
                            question_content = ""
                        }
                        
                        if video_url != nil {
                            print(video_url)
                            
                            let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: question_content, video_url: video_url, likeCount: likeCount, liked_by_user: "not checked", frontCamera: frontCamera, createdAt: yourDate, views: views, featuredQuestion: featuredQuestion, followingCreator: "not checked", thumbnail_url: thumbnail_url, vertical_screen: vertical_screen)
                            self.answerArray.append(answer)
                            self.answerArray.sortInPlace({ $0.likeCount > $1.likeCount })
                        }
                        
                    }
                    dispatch_async(dispatch_get_main_queue(),{
                        self.tableView.reloadData()
                    })
                }
                
        }
        
    }
    
    // Loads answers from featured questions
    func loadFeaturedAnswers(){
        let url = globalurl + "api/featuredquestions/" + id + "/answers/"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                if value == nil {
                    value = []
                    self.label.hidden = false
                } else {
                    self.answerArray.removeAll(keepCapacity: true)
                    let json = JSON(value!)
                    //                print("JSON: \(json)")
                    if json == [] {
                        print("No answers")
                    }
                    for (_,subJson):(String, JSON) in json {
                        //Do something you want
                        self.label.hidden = true
                        
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
                        
                        var question_id = subJson["question_id"].string
                        if question_id == nil {
                            question_id = ""
                        }
                        var question_content = subJson["question_content"].string
                        if question_content == nil {
                            question_content = ""
                        }
                        
                        if video_url != nil {
                            print(video_url)
                            
                            let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: question_content, video_url: video_url, likeCount: likeCount, liked_by_user: "not checked", frontCamera: frontCamera, createdAt: yourDate, views: views, featuredQuestion: featuredQuestion, followingCreator: "not checked", thumbnail_url: thumbnail_url, vertical_screen: vertical_screen)
                            self.answerArray.append(answer)
                            self.answerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                        }
                        
                    }
                    dispatch_async(dispatch_get_main_queue(),{
                        self.tableView.reloadData()
                    })
                }
                
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
            if answerArray.count == 0 {
                return 0
            } else {
                label.hidden = true
                return answerArray.count
            }
            
        }
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
                cell.contentTextView.text = question!.content
                let answercount = question!.answercount
                
                cell.answerCountLabel.text =  "\(answercount)"
                
                let likecount = question!.likecount
                let formattedlikecount = likecount.abbreviateNumberAtThousand()
                cell.likeCountLabel.text = "\(formattedlikecount)"
                cell.likeCountLabel.alpha = 2
                
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
            let cell = tableView.dequeueReusableCellWithIdentifier("answerPreviewCell", forIndexPath: indexPath) as! AnswerPreviewTableViewCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            if answerArray.count == 0 {
                
            } else {
                let creator = answerArray[indexPath.row].creator
                
                let date = answerArray[indexPath.row].createdAt
                let timeAgo = timeAgoSinceDate(date, numericDates: true)
                
                
                let views = answerArray[indexPath.row].views
                let abbrevViews = views.addCommas(views)
                cell.viewCountLabel.text = "\(abbrevViews) views"
                
                
                cell.nameLabel.text = answerArray[indexPath.row].creatorname
                let likeCount = self.answerArray[indexPath.row].likeCount
                let abbrevLikeCount = likeCount.addCommas(likeCount)
                cell.likeCountLabel.text = "\(abbrevLikeCount) likes"
                cell.usernameButton.addTarget(self, action: "nameTapped:", forControlEvents: .TouchUpInside)
                cell.usernameButton.tag = indexPath.row
                cell.contentView.bringSubviewToFront(cell.usernameButton)
                
                
            }

            return cell
        }
        
    }
    
    // Separate data binding between cellForRow and willDisplayCell. Better in willDisplayCell
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let cell = cell as! AnswerPreviewTableViewCell
            
            if answerArray.count == 0 {
                
            } else {
                
                let answerId = answerArray[indexPath.row].id
                
                if let cachedImageResult = imageCache[answerId] {
                    print("pull from cache")
                    cell.previewImageView.image = UIImage(data: cachedImageResult!)
                } else {
                    let thumbnail_url = answerArray[indexPath.row].thumbnail_url
                    let newURL = NSURL(string: thumbnail_url)
                    let data = NSData(contentsOfURL: newURL!)
                    imageCache[answerId] = data
                    cell.previewImageView.image  = UIImage(data: data!)
                }
                
                
                let creator = answerArray[indexPath.row].creator
                
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
            }
            
            
        }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            
            self.indexPath = indexPath.row
            self.performSegueWithIdentifier("segueToVideoPage", sender: self)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
    
    // MARK: - tableViewCell functions
    
    func goToChannel(sender: UIButton) {
        self.performSegueWithIdentifier("segueFromAnswersToFeed", sender: self)
    }
    
    func postedByTapped(sender:UIButton) {
        print("buttonTapped")
        questionName = true
        Answers.logCustomEventWithName("Username Tapped",
            customAttributes: ["method": "postedBy", "where": "AnswersVC"])
        self.performSegueWithIdentifier("segueFromAnswersToProfile", sender: self)
    }
    
    func nameTapped(sender:UIButton) {
        print("buttonClicked")
        let tag = sender.tag
        nameIndex = tag
        questionName = false
        Answers.logCustomEventWithName("Username Tapped",
            customAttributes: ["method": "nameOnAnswer", "where": "AnswersVC"])
        self.performSegueWithIdentifier("segueFromAnswersToProfile", sender: self)
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromAnswerToTakeVideo" {
            let takeVideoVC: TakeVideoViewController = segue.destinationViewController as! TakeVideoViewController
            takeVideoVC.content = self.content
            takeVideoVC.id = self.id
            takeVideoVC.fromFeatured = self.fromFeatured
        } else if segue.identifier == "segueFromAnswersToProfile" {
            if questionName {
                let profileVC: ProfileViewController = segue.destinationViewController as! ProfileViewController
                let creatorId = question!.creator
                let creatorname = question!.creatorname
                profileVC.fromOtherVC = true
                profileVC.creatorId = creatorId
                profileVC.creatorname = creatorname
            } else {
                let profileVC: ProfileViewController = segue.destinationViewController as! ProfileViewController
                let creatorId = answerArray[nameIndex].creator
                let creatorname = answerArray[nameIndex].creatorname
                profileVC.fromOtherVC = true
                profileVC.creatorId = creatorId
                profileVC.creatorname = creatorname
            }
            
        } else if segue.identifier == "segueFromAnswersToFeed" {
            let feedVC: FeedViewController = segue.destinationViewController as! FeedViewController
            let channelId = question!.channel_id
            let channelName = question!.channel_name
            feedVC.fromSpecificChannel = true
            feedVC.channelId = channelId
            feedVC.channelName = channelName
        } else if segue.identifier == "segueToEditPost" {
            let nav = segue.destinationViewController as! UINavigationController
            let askQuestionVC: AskQuestionViewController = nav.topViewController as! AskQuestionViewController
            askQuestionVC.forEditPost = true
            askQuestionVC.content = question!.content
            askQuestionVC.questionId = question!.id
        } else if segue.identifier == "segueFromAnswersToVideo" {
            let videoVC: VideoViewController = segue.destinationViewController as! VideoViewController
            let videoUrl = answerArray[self.indexPath].video_url
            let vertical_screen = answerArray[self.indexPath].vertical_screen
            videoVC.videoUrl = videoUrl
            videoVC.vertical_screen = vertical_screen
        } else if segue.identifier == "segueToVideoPage" {
            let videoPageVC: VideoPageViewController = segue.destinationViewController as! VideoPageViewController
            videoPageVC.transitioningDelegate = self
            videoPageVC.interactor = interactor
            videoPageVC.answers = answerArray
            videoPageVC.indexPath = self.indexPath
        } else if segue.identifier == "segueFromAnswersToProfileNav" {
            let nav = segue.destinationViewController as! UINavigationController
            let profileVC: ProfileViewController = nav.topViewController as! ProfileViewController
            let creatorId = answerArray[nameIndex].creator
            let creatorname = answerArray[nameIndex].creatorname
            profileVC.fromOtherVC = true
            profileVC.creatorId = creatorId
            profileVC.creatorname = creatorname
            profileVC.fromVideo = true
        }
    }
    
    // MARK: - IBAction
    @IBAction func moreInfoButtonTapped(sender: UIBarButtonItem) {
        let creator = (question?.creator)! as String
        let questionId = (question?.id)! as String
        let answerCount = question?.answercount
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let editButton = UIAlertAction(title: "Edit Post", style: UIAlertActionStyle.Default) { (alert) -> Void in
            print("Edit post")
            
            self.performSegueWithIdentifier("segueToEditPost", sender: self)
        }
        let reportButton = UIAlertAction(title: "Report Post", style: UIAlertActionStyle.Default) { (alert) -> Void in
            print("Post reported")
            
            let parameters = [
                "type" : "reported post",
                "creator": userid,
                "questionId": questionId
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
        let deleteButton = UIAlertAction(title: "Delete Post", style: UIAlertActionStyle.Default) { (alert) -> Void in
            print("Post deleted")
            
            var token = self.keychain.get("JWT")
            print(token)
            
            do {
                
                let jwt = try decode(token!)
                print(jwt)
                print(jwt.body)
                print(jwt.expiresAt)
                print(jwt.expired)
                if jwt.expired == true {
                    var refresh_token = self.keychain.get("refresh_token")
                    
                    if refresh_token == nil {
                        refresh_token = ""
                    }
                    
                    let url = globalurl + "api/changetoken/"
                    
                    let parameters = [
                        "refresh_token": refresh_token! as String
                    ]
                    
                    Alamofire.request(.POST, url, parameters: parameters)
                        .responseJSON { response in
                            var value = response.result.value
                            
                            if value == nil {
                                value = []
                            } else {
                                let json = JSON(value!)
                                print("JSON: \(json)")
                                print(json["token"].string)
                                let newtoken = json["token"].string
                                self.keychain.set(newtoken!, forKey: "JWT")
                                token = newtoken
                                
                                let headers = [
                                    "Authorization": "\(token!)"
                                ]
                                
                                let url = globalurl + "api/questions/" + questionId + "/creator/" + userid
                                Alamofire.request(.DELETE, url, parameters: nil, headers: headers)
                                    .responseJSON { response in
                                        print(response.request)
                                        print(response.response)
                                        print(response.result)
                                        print(response.response?.statusCode)
                                        NSNotificationCenter.defaultCenter().postNotificationName("askedQuestion", object: self)
                                        self.navigationController?.popViewControllerAnimated(true)
                                }
                            }
                            
                            
                    }
                } else {
                    let headers = [
                        "Authorization": "\(token!)"
                    ]
                    
                    let url = globalurl + "api/questions/" + questionId + "/creator/" + userid
                    Alamofire.request(.DELETE, url, parameters: nil, headers: headers)
                        .responseJSON { response in
                            print(response.request)
                            print(response.response)
                            print(response.result)
                            print(response.response?.statusCode)
                            NSNotificationCenter.defaultCenter().postNotificationName("askedQuestion", object: self)
                            self.navigationController?.popViewControllerAnimated(true)
                    }
                }
            } catch {
                print("Failed to decode JWT: \(error)")
            }
            
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            print("Cancel Pressed", terminator: "")
        }
        
        if creator == userid {
            alert.addAction(editButton)
            if answerCount == 0 {
                alert.addAction(deleteButton)
            }
        } else {
            alert.addAction(reportButton)
        }
        
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func relayButtonPressed(sender: UIButton) {
        Answers.logCustomEventWithName("Record Method",
            customAttributes: ["method":"From Answers"])
        self.performSegueWithIdentifier("segueFromAnswerToTakeVideo", sender: self)
    }
    
    
    

}

extension AnswersViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

