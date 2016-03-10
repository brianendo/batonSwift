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

class AnswersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate {

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
    
    // MARK: - viewWill/viewDid
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "videoEnd",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: nil)
        // Changes navController if from a followingVC
        if fromFollowing {
            self.navigationController?.hidesBarsOnSwipe = false
            self.navigationController?.navigationBar.hidden = false
            if question == nil {
                self.loadQuestion()
            }
        }
//        self.relayButton.backgroundColor = UIColor.whiteColor()
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: nil)
        
        // Pauses cells when leaving vc
        for cell in tableView.visibleCells {
            if cell.isKindOfClass(AnswerTableViewCell) {
                let cell = cell as! AnswerTableViewCell
                if (cell.player.rate > 0) {
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

        self.navigationItem.title = "Relays"
        self.tabBarController?.tabBar.hidden = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 300
        self.tableView.scrollsToTop = true
        
        
        self.relayButton.layer.borderColor = UIColor(red:0.17, green:0.18, blue:0.29, alpha:1.0).CGColor
        self.relayButton.layer.borderWidth = 0.5
//        self.relayButton.backgroundColor = UIColor.whiteColor()
        
        self.relayButton.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.93, alpha:1.0)
        
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
//            self.answerArray.removeAll(keepCapacity: true)
            self.loadFeaturedAnswers()
        } else {
//            self.answerArray.removeAll(keepCapacity: true)
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
                        
//                        self.tableView.reloadData()
                    }
                    dispatch_async(dispatch_get_main_queue(),{
                        self.tableView.reloadData()
                    })
                }
                
//                dispatch_async(dispatch_get_main_queue(),{
//                    self.tableView.reloadData()
//                })
                
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
                        
//                        self.tableView.reloadData()
                    }
                    dispatch_async(dispatch_get_main_queue(),{
                        self.tableView.reloadData()
                    })
                }
//                dispatch_async(dispatch_get_main_queue(),{
//                    self.tableView.reloadData()
//                })
                
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
            let cell = tableView.dequeueReusableCellWithIdentifier("answerPreviewCell", forIndexPath: indexPath) as! AnswerPreviewTableViewCell
            
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
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
//                cell.nameButton.addTarget(self, action: "nameTapped:", forControlEvents: .TouchUpInside)
//                cell.nameButton.tag = indexPath.row
//                cell.contentView.bringSubviewToFront(cell.nameButton)
                
                
//                let tapGesture = UITapGestureRecognizer(target: self, action: "singleTapped:")
//                view.addGestureRecognizer(tapGesture)
//                view.tag = indexPath.row
                
                
            }
        
            
            return cell
//            let cell = tableView.dequeueReusableCellWithIdentifier("AnswerCell", forIndexPath: indexPath) as! AnswerTableViewCell
//            
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
//            
//            cell.preservesSuperviewLayoutMargins = false
//            cell.separatorInset = UIEdgeInsetsZero
//            cell.layoutMargins = UIEdgeInsetsZero
//            
//            if answerArray.count == 0 {
//                
//            } else {
//                let creator = answerArray[indexPath.row].creator
//                
//                let date = answerArray[indexPath.row].createdAt
//                let timeAgo = timeAgoSinceDate(date, numericDates: true)
//                
//                cell.timeAgoLabel.text = timeAgo
//                
//                let views = answerArray[indexPath.row].views
//                let abbrevViews = views.addCommas(views)
//                cell.viewCountLabel.text = "\(abbrevViews) views"
//                
//                
//                cell.nameTextView.text = answerArray[indexPath.row].creatorname
//                cell.nameTextView.selectable = false
//                
//                cell.nameButton.addTarget(self, action: "nameTapped:", forControlEvents: .TouchUpInside)
//                cell.nameButton.tag = indexPath.row
//                cell.contentView.bringSubviewToFront(cell.nameButton)
//                
//                cell.videoView.addSubview(cell.playerController.view)
//                
//                
//                cell.playerController.view.userInteractionEnabled = true
//                
//                let view = UIView(frame: CGRectMake(cell.videoView.frame.origin.x, cell.videoView.frame.origin.y, cell.videoView.frame.size.width, cell.videoView.frame.size.height))
//                cell.videoView.addSubview(view)
//
//                let tapGesture = UITapGestureRecognizer(target: self, action: "singleTapped:")
//                view.addGestureRecognizer(tapGesture)
//                view.tag = indexPath.row
//                
//                cell.likeImageView.image = UIImage(named: "Heart")
//                cell.likeImageView.hidden = true
//                cell.likeImageView.contentMode = UIViewContentMode.ScaleAspectFill
//                cell.videoView.bringSubviewToFront(cell.likeImageView)
//                
//                let doubleTapGesture = UITapGestureRecognizer()
//                doubleTapGesture.numberOfTapsRequired = 2
//                doubleTapGesture.addTarget(self, action: "doubleTapped:")
//                view.addGestureRecognizer(doubleTapGesture)
//                
//                let likeCount = self.answerArray[indexPath.row].likeCount
//                let abbrevLikeCount = likeCount.addCommas(likeCount)
//                cell.likeCountTextView.text = "\(abbrevLikeCount) likes"
//                cell.videoView.bringSubviewToFront(cell.likeCountTextView)
//                cell.videoView.bringSubviewToFront(cell.heartImageView)
//            }
//            
//            
//            cell.likeButton.tag = indexPath.row
//            cell.likeButton.addTarget(self, action: "toggleLike:", forControlEvents: .TouchUpInside)
//            cell.videoView.bringSubviewToFront(cell.likeButton)
//            
//            cell.extraButton.addTarget(self, action: "extraButtonTapped:", forControlEvents: .TouchUpInside)
//            cell.extraButton.tag = indexPath.row
//            
//            return cell
        }
        
    }
    
    // Separate data binding between cellForRow and willDisplayCell. Better in willDisplayCell
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let cell = cell as! AnswerPreviewTableViewCell
            
            if answerArray.count == 0 {
                
            } else {
                let thumbnail_url = answerArray[indexPath.row].thumbnail_url
                let newURL = NSURL(string: thumbnail_url)
                let data = NSData(contentsOfURL: newURL!)
                cell.previewImageView.image  = UIImage(data: data!)
                
                
                
                
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

//        if indexPath.section == 1 {
//            let cell = cell as! AnswerTableViewCell
//            
//            if answerArray.count == 0 {
//                
//            } else {
//                let videoUrl = answerArray[indexPath.row].video_url
//                let newURL = NSURL(string: videoUrl)
//                cell.player = AVPlayer(URL: newURL!)
//                cell.playerController.player = cell.player
//
//                cell.player.pause()
//                
//                if indexPath.row == 0 {
//                    cell.player.play()
//                    Answers.logCustomEventWithName("Video Viewed",
//                        customAttributes: ["where":"AnswersVC", "row": 0])
//                    NSNotificationCenter.defaultCenter().addObserver(self,
//                        selector: "videoEnd",
//                        name: AVPlayerItemDidPlayToEndTimeNotification,
//                        object: nil)
//                    
//                    let url = globalurl + "api/answers/" + answerArray[indexPath.row].id + "/viewed/"
//                    
//                    Alamofire.request(.PUT, url, parameters: nil)
//                        .responseJSON { response in
//                            let result = response.result.value
//                            print(result)
//                            if result == nil {
//                                print("Not viewed")
//                                
//                            } else {
//                                print("Viewed")
//                            }
//                    }
//                }
//                
//                
//                let creator = answerArray[indexPath.row].creator
//                
//                if let cachedImageResult = imageCache[creator] {
//                    print("pull from cache")
//                    cell.profileImageView.image = UIImage(data: cachedImageResult!)
//                } else {
//                    // 3
//                    cell.profileImageView.image = UIImage(named: "Placeholder")
//                    
//                    // 4
//                    let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp-download")
//                    let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
//                    let transferManager = AWSS3TransferManager.defaultS3TransferManager()
//                    
//                    let key = "profilePics/" + creator
//                    let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
//                    readRequest1.bucket = S3BucketName
//                    readRequest1.key =  key
//                    readRequest1.downloadingFileURL = downloadingFileURL1
//                    
//                    let task = transferManager.download(readRequest1)
//                    task.continueWithBlock { (task) -> AnyObject! in
//                        if task.error != nil {
//                            print("No Profile Pic")
//                        } else {
//                            let image = UIImage(contentsOfFile: downloadingFilePath1)
//                            let imageData = UIImageJPEGRepresentation(image!, 1.0)
//                            imageCache[creator] = imageData
//                            dispatch_async(dispatch_get_main_queue()
//                                , { () -> Void in
//                                    cell.profileImageView.image = UIImage(contentsOfFile: downloadingFilePath1)
//                                    cell.setNeedsLayout()
//                                    
//                            })
//                            print("Fetched image")
//                        }
//                        return nil
//                    }
//                }
//                let followingCreator = self.answerArray[indexPath.row].followingCreator
//                cell.followButton.tag = indexPath.row
//                cell.followButton.addTarget(self, action: "toggleFollow:", forControlEvents: .TouchUpInside)
//                //            cell.followButton.setImage(UIImage(named: "addperson"), forState: .Normal)
//                //            cell.followButton.setImage(UIImage(named: "addedperson"), forState: .Selected)
//                
//                if creator == userid {
//                    cell.followButton.hidden = true
//                } else if followingCreator == "not checked"{
//                    cell.followButton.selected = false
//                    
//                    let url = globalurl + "api/user/" + userid + "/follows/" + answerArray[indexPath.row].creator
//                    
//                    Alamofire.request(.GET, url, parameters: nil)
//                        .responseJSON { response in
//                            let result = response.result.value
//                            print(result)
//                            if result == nil {
//                                print("Not Following")
//                                cell.followButton.selected = false
//                                cell.followButton.hidden = false
//                                self.answerArray[indexPath.row].followingCreator = "not following"
//                            } else {
//                                print("Already Following")
//                                //                            cell.followButton.selected = true
//                                cell.followButton.hidden = true
//                                self.answerArray[indexPath.row].followingCreator = "already following"
//                            }
//                    }
//                } else if followingCreator == "not following" {
//                    cell.followButton.selected = false
//                    cell.followButton.hidden = false
//                } else if followingCreator == "already following" {
//                    cell.followButton.hidden = true
//                } else if followingCreator == "just followed" {
//                    cell.followButton.selected = true
//                    cell.followButton.hidden = false
//                }
//                
//                let liked_by_user = self.answerArray[indexPath.row].liked_by_user
//                
//                if liked_by_user == "true" {
//                    cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                    cell.heartImageView.image = UIImage(named: "redHeartOutline")
//                } else if liked_by_user == "not checked" {
//                    let url = globalurl + "api/answers/" + answerArray[indexPath.row].id + "/likecheck/" + userid
//                    
//                    Alamofire.request(.GET, url, parameters: nil)
//                        .responseJSON { response in
//                            let result = response.result.value
//                            print(result)
//                            if result == nil {
//                                print("Gobi")
//                                cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
//                                cell.heartImageView.image = UIImage(named: "grayHeartOutline")
//                                self.answerArray[indexPath.row].liked_by_user = "false"
//                            } else {
//                                print("Liked")
//                                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                                cell.heartImageView.image = UIImage(named: "redHeartOutline")
//                                self.answerArray[indexPath.row].liked_by_user = "true"
//                            }
//                    }
//                } else if liked_by_user == "false" {
//                    cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
//                    cell.heartImageView.image = UIImage(named: "grayHeartOutline")
//                }
//            }
//            
//            
//        }
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
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 1)) as! AnswerTableViewCell
        if cell.player.rate > 0 {
            cell.player.pause()
            cell.likeImageView.alpha = 0.7
            cell.likeImageView.image = UIImage(named: "playImage")
            cell.likeImageView.hidden = false
        }
        let creator = answerArray[tag].creator
        let answerId = answerArray[tag].id
        let answerUrl = batonUrl + "answers/\(answerId)"
        
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
        let copyLinkButton = UIAlertAction(title: "Copy Video URL", style: UIAlertActionStyle.Default) { (alert) -> Void in
            
            UIPasteboard.generalPasteboard().string = "\(answerUrl)"
        }
        let facebookButton = UIAlertAction(title: "Share to Facebook", style: UIAlertActionStyle.Default) { (alert) -> Void in
            var questionContent = self.question!.content
            if questionContent.characters.count > 80 {
                let ss1: String = (questionContent as NSString).substringToIndex(80)
                questionContent = ss1 + "..."
                
            }
            let thumbnailUrl = "https://s3-us-west-1.amazonaws.com/batonapp/BatonHighQuality.png"
            let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
            
            content.contentURL = NSURL(string: answerUrl)
            content.contentTitle = "re: \"\(questionContent)\""
            content.contentDescription = "A platfrom concise video discussions every day"
            content.imageURL = NSURL(string: thumbnailUrl )
            FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
            
        }
        let messageButton = UIAlertAction(title: "Share through Message", style: UIAlertActionStyle.Default) { (alert) -> Void in
            let answerUrl = batonUrl + "answers/\(answerId)"
            
            var questionContent = self.question!.content
            if questionContent.characters.count > 80 {
                let ss1: String = (questionContent as NSString).substringToIndex(80)
                questionContent = ss1 + "..."
                
            }
            
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
            
            let answerUrl = batonUrl + "answers/\(answerId)"
            let composer = TWTRComposer()
            var questionContent = self.question!.content
            if questionContent.characters.count > 80 {
                let ss1: String = (questionContent as NSString).substringToIndex(80)
//                let ss1Array = ss1.characters.split{$0 == " "}.map(String.init)
//                let index: String.Index = questionContent.startIndex.advancedBy(80)
//                let ss2:String = questionContent.substringToIndex(index)
                
                questionContent = ss1 + "..."
                
            }
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
        let deleteButton = UIAlertAction(title: "Delete relay", style: UIAlertActionStyle.Default) { (alert) -> Void in
            print("Video deleted")
            
            var token = self.keychain.get("JWT")
            
            do {
                
                let jwt = try decode(token!)
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
                                
                                let url = globalurl + "api/answers/" + answerId + "/creator/" + userid
                                Alamofire.request(.DELETE, url, parameters: nil, headers: headers)
                                    .responseJSON { response in
                                        print(response.request)
                                        print(response.response)
                                        print(response.result)
                                        print(response.response?.statusCode)
                                        self.answerArray.removeAtIndex(tag)
                                        self.tableView.reloadData()
                                }
                                
                            }
                            
                            
                    }
                } else {
                    let headers = [
                        "Authorization": "\(token!)"
                    ]
                    
                    let url = globalurl + "api/answers/" + answerId + "/creator/" + userid
                    Alamofire.request(.DELETE, url, parameters: nil, headers: headers)
                        .responseJSON { response in
                            print(response.request)
                            print(response.response)
                            print(response.result)
                            print(response.response?.statusCode)
                            self.answerArray.removeAtIndex(tag)
                            self.tableView.reloadData()
                    }
                    
                }
            } catch {
                print("Failed to decode JWT: \(error)")
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
        if creator == userid {
            alert.addAction(deleteButton)
        }
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
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
    
    func toggleFollow(sender:UIButton!) {
        let tag = sender.tag
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
                        self.answerArray[tag].followingCreator = "just followed"
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
                        self.answerArray[tag].followingCreator = "not following"
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
                        Answers.logCustomEventWithName("Unlike",
                            customAttributes: ["where": "AnswersVC"])
                        
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
                        Answers.logCustomEventWithName("Like",
                            customAttributes: ["method": "Button", "where": "AnswersVC"])
                        
                    }
            }
        }
    }
    
    func videoEnd() {
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
                    cell.likeImageView.image = UIImage(named: "replayImage")
                    cell.likeImageView.hidden = false
                    cell.likeImageView.alpha = 0.7
                    
                    if (cell.player.rate > 0) {
                        
                        
                    } else {
                        print("Reached")
                        Answers.logCustomEventWithName("Full View",
                            customAttributes: ["where":"AnswersVC"])
                        let seconds : Int64 = 0
                        let preferredTimeScale : Int32 = 1
                        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
                        
                        cell.player.seekToTime(seekTime)
                    }
                } else {
                    cell.player.pause()
                }
            }
        }
    }
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        print("Double Tap")
        
        let tag = sender.view?.tag
        let currentLiked = self.answerArray[tag!].liked_by_user
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 1)) as! AnswerTableViewCell
        cell.likeImageView.image = UIImage(named: "Heart")
        cell.likeImageView.hidden = false
        cell.likeImageView.alpha = 1
        cell.player.play()
        
        if currentLiked == "true" {
            
        } else {
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
                        Answers.logCustomEventWithName("Like",
                            customAttributes: ["method": "Double Tap", "where": "AnswersVC"])
                        
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
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 1)) as! AnswerTableViewCell
        if (cell.player.rate > 0) {
            cell.player.pause()
            Answers.logCustomEventWithName("Pause Clicked",
                customAttributes: ["where": "AnswersVC","row": tag!])
            cell.likeImageView.alpha = 0.7
            cell.likeImageView.image = UIImage(named: "playImage")
            cell.likeImageView.hidden = false
        } else {
            if cell.likeImageView.image == UIImage(named: "replayImage") {
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
            }
            cell.player.play()
            Answers.logCustomEventWithName("Play Clicked",
                customAttributes: ["where": "AnswersVC","row": tag!])
            Answers.logCustomEventWithName("Video Viewed",
                customAttributes: ["where":"AnswersVC", "row": tag!])
            cell.likeImageView.hidden = true
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
                    cell.likeImageView.hidden = true
                    
                    let cmTime = cell.player.currentItem?.currentTime()
                    let currentTime = CMTimeGetSeconds(cmTime!)
                    
                    if (cell.player.rate > 0) {
                        print("Playing")
                        print(currentTime)
                        
                    } else if currentTime > 0 {
                        cell.player.pause()
                        cell.likeImageView.image = UIImage(named: "playImage")
                        cell.likeImageView.hidden = false
                        cell.likeImageView.alpha = 0.7
                    }
                    else { 
                        print("Reached")
                        print(currentTime)
                        Answers.logCustomEventWithName("Video Viewed",
                            customAttributes: ["where":"AnswersVC", "row": (indexPath?.row)!])
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
    
    // MARK: - Segues
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
            takeVideoVC.fromFeatured = self.fromFeatured
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
            videoPageVC.answers = answerArray
            videoPageVC.indexPath = self.indexPath
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
            customAttributes: ["method":"From Answers","userid":userid,"username": myUsername])
//        self.relayButton.backgroundColor = UIColor(white:0.87, alpha:1.0)
        self.performSegueWithIdentifier("segueFromAnswerToTakeVideo", sender: self)
    }
    
    
    

}


