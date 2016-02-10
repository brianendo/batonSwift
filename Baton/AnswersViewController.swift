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

class AnswersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    let keychain = KeychainSwift()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var relayButton: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var moreInfoBarButton: UIBarButtonItem!
    
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
    
    override func viewWillAppear(animated: Bool) {
        if fromFollowing {
            self.navigationController?.hidesBarsOnSwipe = false
            self.navigationController?.navigationBar.hidden = false
            if question == nil {
                self.loadQuestion()
            }
        }
       
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: nil)
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
        // Do any additional setup after loading the view.
        self.tabBarController?.tabBar.hidden = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 300
        
        self.relayButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.relayButton.layer.borderWidth = 0.5
        
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
                
                
                let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: false, currentuser: false, createdAt: yourDate, creator: creator, likecount: likecount)
                
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
                }
                
                let json = JSON(value!)
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
                    
                    if video_url != nil {
                        print(video_url)
                        
                        let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: "", question_content: "", video_url: video_url, likeCount: likeCount, liked_by_user: false, frontCamera: frontCamera, createdAt: yourDate, views: views, featuredQuestion: featuredQuestion)
                        self.answerArray.append(answer)
                        self.answerArray.sortInPlace({ $0.likeCount > $1.likeCount })
                    }
                    
                    self.tableView.reloadData()
                }
                
        }
        
    }
    
    func loadFeaturedAnswers(){
        let url = globalurl + "api/featuredquestions/" + id + "/answers/"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                if value == nil {
                    value = []
                }
                
                let json = JSON(value!)
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
                    
                    if video_url != nil {
                        print(video_url)
                        
                        let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: "", question_content: "", video_url: video_url, likeCount: likeCount, liked_by_user: false, frontCamera: frontCamera, createdAt: yourDate, views: views, featuredQuestion: featuredQuestion)
                        self.answerArray.append(answer)
                        self.answerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                    }
                    
                    self.tableView.reloadData()
                }
                
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
                
                if fromFeatured {
                    cell.postedByTextView.hidden = true
                    cell.timeAgoLabel.hidden = true
                    cell.contentView.backgroundColor = UIColor(red:1.0, green:0.97, blue:0.61, alpha:1.0)
                } else {
                    cell.postedByTextView.hidden = false
                    cell.timeAgoLabel.hidden = false
                    cell.contentView.backgroundColor = UIColor.clearColor()
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("AnswerCell", forIndexPath: indexPath) as! AnswerTableViewCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
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
//            if let cachedImageResult = imageCache[creator] {
//                print("pull from cache")
//                cell.profileImageView.image = UIImage(data: cachedImageResult!)
//            } else {
//                // 3
//                cell.profileImageView.image = UIImage(named: "Placeholder")
//                
//                // 4
//                let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp-download")
//                let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
//                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
//                
//                
//                let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
//                readRequest1.bucket = S3BucketName
//                readRequest1.key =  creator
//                readRequest1.downloadingFileURL = downloadingFileURL1
//                
//                let task = transferManager.download(readRequest1)
//                task.continueWithBlock { (task) -> AnyObject! in
//                    if task.error != nil {
//                        print("No Profile Pic")
//                    } else {
//                        let image = UIImage(contentsOfFile: downloadingFilePath1)
//                        let imageData = UIImageJPEGRepresentation(image!, 1.0)
//                        imageCache[creator] = imageData
//                        dispatch_async(dispatch_get_main_queue()
//                            , { () -> Void in
//                                cell.profileImageView.image = UIImage(contentsOfFile: downloadingFilePath1)
//                                cell.setNeedsLayout()
//                                
//                        })
//                        print("Fetched image")
//                    }
//                    return nil
//                }
//            }
            
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
            cell.videoView.addSubview(cell.playerController.view)
            cell.player.pause()
            
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
            
            let likeCount = self.answerArray[indexPath.row].likeCount
            cell.likeCountTextView.text = "\(likeCount) likes"
            cell.videoView.bringSubviewToFront(cell.likeCountTextView)
            cell.videoView.bringSubviewToFront(cell.heartImageView)
            
            
            cell.likeButton.tag = indexPath.row
            cell.likeButton.addTarget(self, action: "toggleLike:", forControlEvents: .TouchUpInside)
            cell.videoView.bringSubviewToFront(cell.likeButton)
            
            cell.followButton.hidden = true
            
//            if creator == userid {
//                cell.followButton.hidden = true
//            } else {
//                cell.followButton.tag = indexPath.row
//                cell.followButton.addTarget(self, action: "toggleFollow:", forControlEvents: .TouchUpInside)
//                cell.followButton.setImage(UIImage(named: "addperson"), forState: .Normal)
//                cell.followButton.setImage(UIImage(named: "addedperson"), forState: .Selected)
//                cell.followButton.selected = false
//                
//                let url = globalurl + "api/user/" + userid + "/follows/" + answerArray[indexPath.row].creator
//                
//                Alamofire.request(.GET, url, parameters: nil)
//                    .responseJSON { response in
//                        let result = response.result.value
//                        print(result)
//                        if result == nil {
//                            print("Not Following")
//                            cell.followButton.selected = false
//                            cell.followButton.hidden = false
//                        } else {
//                            print("Already Following")
//                            cell.followButton.selected = true
//                        }
//                }
//            }
            
            cell.extraButton.addTarget(self, action: "extraButtonTapped:", forControlEvents: .TouchUpInside)
            cell.extraButton.tag = indexPath.row
            
//            let liked_by_user = self.answerArray[indexPath.row].liked_by_user
            
//            if liked_by_user == true {
//                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                cell.heartImageView.image = UIImage(named: "redHeartOutline")
//            } else {
//                let url = globalurl + "api/answers/" + answerArray[indexPath.row].id + "/likecheck/" + userid
//                
//                Alamofire.request(.GET, url, parameters: nil)
//                    .responseJSON { response in
//                        let result = response.result.value
//                        print(result)
//                        if result == nil {
//                            print("Gobi")
//                            cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
//                            cell.heartImageView.image = UIImage(named: "grayHeartOutline")
//                        } else {
//                            print("Liked")
//                            cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                            cell.heartImageView.image = UIImage(named: "redHeartOutline")
//                            self.answerArray[indexPath.row].liked_by_user = true
//                        }
//                }
//            }
            
            
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let cell = cell as! AnswerTableViewCell
            
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
            
            
            if creator == userid {
                cell.followButton.hidden = true
            } else {
                cell.followButton.tag = indexPath.row
                cell.followButton.addTarget(self, action: "toggleFollow:", forControlEvents: .TouchUpInside)
                cell.followButton.setImage(UIImage(named: "addperson"), forState: .Normal)
                cell.followButton.setImage(UIImage(named: "addedperson"), forState: .Selected)
                cell.followButton.selected = false
                
                let url = globalurl + "api/user/" + userid + "/follows/" + answerArray[indexPath.row].creator
                
                Alamofire.request(.GET, url, parameters: nil)
                    .responseJSON { response in
                        let result = response.result.value
                        print(result)
                        if result == nil {
                            print("Not Following")
                            cell.followButton.selected = false
                            cell.followButton.hidden = false
                        } else {
                            print("Already Following")
                            cell.followButton.selected = true
                        }
                }
            }
            let liked_by_user = self.answerArray[indexPath.row].liked_by_user
            
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
        let deleteButton = UIAlertAction(title: "Delete relay", style: UIAlertActionStyle.Default) { (alert) -> Void in
            print("Video deleted")
            
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
            
//            let url = globalurl + "api/answers/" + answerId + "/creator/" + userid
//            Alamofire.request(.DELETE, url, parameters: nil)
//                .responseJSON { response in
//                    print(response.request)
//                    print(response.response)
//                    print(response.result)
//                    print(response.response?.statusCode)
//            }
//            self.answerArray.removeAtIndex(tag)
//            self.tableView.reloadData()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            print("Cancel Pressed", terminator: "")
        }
        
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
        self.performSegueWithIdentifier("segueFromAnswersToProfile", sender: self)
    }
    
    func nameTapped(sender:UIButton) {
        print("buttonClicked")
        let tag = sender.tag
        nameIndex = tag
        questionName = false
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
                        //                        cell.player.play()
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
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 1)) as! AnswerTableViewCell
        cell.likeImageView.image = UIImage(named: "Heart")
        cell.likeImageView.hidden = false
        cell.likeImageView.alpha = 1
        cell.player.play()
        
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
        }
        
        
    }
    
    func singleTapped(sender: UITapGestureRecognizer) {
        print("Tapped")
        let tag = sender.view?.tag
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 1)) as! AnswerTableViewCell
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if answerArray.count == 0 {
                label.hidden = false
                return 0
            } else {
                label.hidden = true
                return answerArray.count
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
                    
                    if (cell.player.rate > 0) {
                        print("Playing")
                        NSNotificationCenter.defaultCenter().addObserver(self,
                            selector: "videoEnd",
                            name: AVPlayerItemDidPlayToEndTimeNotification,
                            object: nil)
                        
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
                        NSNotificationCenter.defaultCenter().addObserver(self,
                            selector: "videoEnd",
                            name: AVPlayerItemDidPlayToEndTimeNotification,
                            object: nil)
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
            
        }
    }
    
    @IBAction func moreInfoButtonTapped(sender: UIBarButtonItem) {
        let creator = (question?.creator)! as String
        let questionId = (question?.id)! as String
        let answerCount = question?.answercount
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
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
            
//            let url = globalurl + "api/questions/" + questionId + "/creator/" + userid
//            Alamofire.request(.DELETE, url, parameters: nil)
//                .responseJSON { response in
//                    print(response.request)
//                    print(response.response)
//                    print(response.result)
//                    print(response.response?.statusCode)
//                    NSNotificationCenter.defaultCenter().postNotificationName("askedQuestion", object: self)
//                    self.navigationController?.popViewControllerAnimated(true)
//            }
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            print("Cancel Pressed", terminator: "")
        }
        
        alert.addAction(reportButton)
        if creator == userid {
            if answerCount == 0 {
                alert.addAction(deleteButton)
            }
        }
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func relayButtonPressed(sender: UIButton) {
        self.performSegueWithIdentifier("segueFromAnswerToTakeVideo", sender: self)
    }
    
    
    

}
