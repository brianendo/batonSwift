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


class FollowingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchController : UISearchController!
    
    var counter = 0
    var answerArray = [Answer]()
    var questionArray = [Question]()
    var selectedIndexPath = 0
    var questionIndex = 0
    var headerView: UIView?
    var question: Question?
    var fromRelays = true
    var tag = 0
    
    var filteredUsers = [String]()
    var filteredId = [String]()
    var users = ["Jimmy", "Butler", "Ramon Sessions"]
    var userIndexPath = 0
    
    let label = UILabel(frame: CGRectMake(0, 0, 400, 400))
    
    var refreshControl:UIRefreshControl!
    
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
                    self.questionArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })

                    self.tableView.reloadData()
                }
        }
    }
    
    func loadAnswers(){
        let url = globalurl + "api/users/" + userid + "/followinganswers/"
        
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
                    var question_id = subJson["question_id"].string
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
                                    self.answerArray.append(answer)
                                    self.answerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })

                                    self.tableView.reloadData()

                                    
                            }
                        } else {
                            let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: question_content, video_url: video_url, likeCount: likeCount, liked_by_user: false, frontCamera: frontCamera, createdAt: yourDate, views: views)
                            self.answerArray.append(answer)
                            self.answerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })

                            self.tableView.reloadData()

                            
                        }
                    }
                    
                    self.tableView.reloadData()
                }
                
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: nil)
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
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.scrollsToTop = true
        
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.navigationItem.titleView = searchController.searchBar
        
//        self.definesPresentationContext = true
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 300
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        // Do any additional setup after loading the view.
        self.loadAnswers()
        self.loadQuestions()
        
        label.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, 300)
        label.textAlignment = NSTextAlignment.Center
        label.text = "No Notifications"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 32)
        label.numberOfLines = 0
        self.tableView.addSubview(label)
        label.hidden = true
        
        self.refreshControl = UIRefreshControl()
        //        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        for cell in tableView.visibleCells {
            if cell.isKindOfClass(FollowingAnswerTableViewCell) {
                let cell = cell as! FollowingAnswerTableViewCell
                if (cell.player.rate > 0) {
                    cell.player.pause()
                    cell.likeImageView.image = UIImage(named: "playImage")
                    cell.likeImageView.hidden = false
                    cell.likeImageView.alpha = 0.7
                }
            }
        }
        
        self.filteredUsers.removeAll(keepCapacity: true)
        self.filteredId.removeAll(keepCapacity: true)
        let url = globalurl + "api/usersearch/" + searchText.lowercaseString
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                }
                
                let json = JSON(value!)
                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    let id = subJson["_id"].string
                    let name = subJson["username"].string
                    
                    if self.filteredUsers.contains(name!) {
                        
                    } else {
                        self.filteredUsers.append(name!)
                        self.filteredId.append(id!)
                    }
                    
                    self.tableView.reloadData()
                }
        }
        self.tableView.reloadData()
    }
    
    func refresh(sender:AnyObject){
        // Code to refresh table view
        self.questionArray.removeAll(keepCapacity: true)
        self.answerArray.removeAll(keepCapacity: true)
        
        //        self.currentPage = 0
        self.loadAnswers()
        self.loadQuestions()
        //        self.loadPaginatedData()
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
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active  {
            return filteredUsers.count
        }
        if counter == 0 {
            if answerArray.count == 0 {
                label.text = "No Relays"
                label.hidden = false
                return 0
            } else {
                label.hidden = true
                return answerArray.count
            }
        } else {
            if questionArray.count == 0 {
                label.text = "No Posts"
                label.hidden = false
                return 0
            } else {
                label.hidden = true
                return questionArray.count
            }
        }
       
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchController.active {
            return 0
        } else {
            return 60
        }
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if searchController.active {
            return nil
        } else {
            let cell: FollowHeaderTableViewCell = tableView.dequeueReusableCellWithIdentifier("followingHeaderCell") as! FollowHeaderTableViewCell
            
            cell.relayButton.addTarget(self, action: "toggleButton:", forControlEvents: .TouchUpInside)
            cell.relayButton.tag = 0
            if counter == 0 {
                cell.relayButton.selected = true
                cell.relayButton.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.93, alpha:1.0)
            } else {
                cell.relayButton.selected = false
                cell.relayButton.backgroundColor = UIColor.whiteColor()
            }
            
            cell.postButton.addTarget(self, action: "toggleButton:", forControlEvents: .TouchUpInside)
            cell.postButton.tag = 1
            
            if counter == 1 {
                cell.postButton.selected = true
                cell.postButton.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.93, alpha:1.0)
            } else {
                cell.postButton.selected = false
                cell.postButton.backgroundColor = UIColor.whiteColor()
            }
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view
        self.headerView = headerView
    }
    
    func toggleButton(sender: UIButton) {
        let header = headerView as! FollowHeaderTableViewCell
        let relayButton: UIButton = header.relayButton
        let postButton: UIButton = header.postButton
        
        if sender.tag == 0 {
            if counter == 0 {
                
            } else {
                counter = 0
                header.setNeedsDisplay()
                header.setNeedsLayout()
                self.tableView.reloadData()
            }
        } else {
            if counter == 1 {
                
                
            } else {
                counter = 1
                for cell in tableView.visibleCells {
                    if cell.isKindOfClass(FollowingAnswerTableViewCell) {
                        let cell = cell as! FollowingAnswerTableViewCell
                        if (cell.player.rate > 0) {
                            cell.player.pause()
                            cell.likeImageView.image = UIImage(named: "playImage")
                            cell.likeImageView.hidden = false
                            cell.likeImageView.alpha = 0.7
                        }
                    }
                }
                header.setNeedsDisplay()
                header.setNeedsLayout()
                self.tableView.reloadData()
            }
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if searchController.active {
            let cell: FollowingSearchTableViewCell = tableView.dequeueReusableCellWithIdentifier("searchCell", forIndexPath: indexPath) as! FollowingSearchTableViewCell
            let user = filteredUsers[indexPath.row]
            let id = filteredId[indexPath.row]
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            cell.nameLabel.text = user
            
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
                        imageCache[id] = imageData
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
        if counter == 0 {
            let cell: FollowingAnswerTableViewCell = tableView.dequeueReusableCellWithIdentifier("followingAnswerCell", forIndexPath: indexPath) as! FollowingAnswerTableViewCell
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            var question_content = answerArray[indexPath.row].question_content
            let question_id = answerArray[indexPath.row].question_id
            
            let creatorname = answerArray[indexPath.row].creatorname
            let userText = creatorname + " relayed:"
            
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
//            if indexPath.row == 0 {
//                cell.player.play()
//            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            cell.playerController.view.userInteractionEnabled = true
            
            let view = UIView(frame: CGRectMake(cell.videoView.frame.origin.x, cell.videoView.frame.origin.y, cell.videoView.frame.size.width, cell.videoView.frame.size.height))
            cell.videoView.addSubview(view)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: "singleTapped:")
            view.addGestureRecognizer(tapGesture)
            view.tag = indexPath.row
            
            cell.likeImageView.image = UIImage(named: "playImage")
            cell.likeImageView.hidden = false
            cell.likeImageView.alpha = 0.7
            cell.likeImageView.contentMode = UIViewContentMode.ScaleAspectFill
            cell.videoView.bringSubviewToFront(cell.likeImageView)
            
            let date = answerArray[indexPath.row].createdAt
            let timeAgo = timeAgoSinceDate(date, numericDates: true)
            
            cell.timeAgoLabel.text = timeAgo
            
            let views = answerArray[indexPath.row].views
            cell.viewCountLabel.text = "\(views) views"
            
            let doubleTapGesture = UITapGestureRecognizer()
            doubleTapGesture.numberOfTapsRequired = 2
            doubleTapGesture.addTarget(self, action: "doubleTapped:")
            view.addGestureRecognizer(doubleTapGesture)
            
            let likeCount = answerArray[indexPath.row].likeCount
            
            cell.likeCountTextView.text = "\(likeCount) likes"
            cell.videoView.bringSubviewToFront(cell.likeCountTextView)
            cell.videoView.bringSubviewToFront(cell.heartImageView)
            
            cell.likeButton.tag = indexPath.row
            cell.likeButton.addTarget(self, action: "toggleLike:", forControlEvents: .TouchUpInside)
            cell.videoView.bringSubviewToFront(cell.likeButton)
            
//            if indexPath.row == 0 {
//                cell.player.play()
//                
//                let url = globalurl + "api/answers/" + answerArray[indexPath.row].id + "/viewed/"
//                
//                Alamofire.request(.PUT, url, parameters: nil)
//                    .responseJSON { response in
//                        let result = response.result.value
//                        print(result)
//                        if result == nil {
//                            print("Not viewed")
//                            
//                        } else {
//                            print("Viewed")
//                        }
//                }
//            }
            
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
                            self.answerArray[indexPath.row].liked_by_user = false
                        } else {
                            print("Liked")
                            cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                            cell.heartImageView.image = UIImage(named: "redHeartOutline")
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
            
            let postedText = "\(creatorname)"
            let myFirstString = NSMutableAttributedString(string: postedText, attributes: [NSForegroundColorAttributeName:UIColor.blackColor(), NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 12.0)!])
            
            let creatornameText = " posted:"
            let mySecondString = NSMutableAttributedString(string: creatornameText, attributes: [NSForegroundColorAttributeName:UIColor.blackColor(), NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 12.0)!])
            
            let result = NSMutableAttributedString()
            result.appendAttributedString(myFirstString)
            result.appendAttributedString(mySecondString)
            
            cell.usernameButton.setAttributedTitle(result, forState: .Normal)
            cell.usernameButton.addTarget(self, action: "usernameTapped:", forControlEvents: .TouchUpInside)
            cell.usernameButton.tag = indexPath.row
            
            cell.contentTextView.text = content
            
            cell.contentTextView.font = UIFont(name: "HelveticaNeue", size: 16)
            cell.contentTextView.userInteractionEnabled = false
            
            return cell
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
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            print("Cancel Pressed", terminator: "")
        }
        
        alert.addAction(reportButton)
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func usernameTapped(sender: UIButton) {
        let tag = sender.tag
        if counter == 0 {
            fromRelays = true
            self.tag = tag
           self.performSegueWithIdentifier("segueFromFollowingToProfile", sender: self)
        } else if counter == 1 {
            fromRelays = false
            self.tag = tag
            self.performSegueWithIdentifier("segueFromFollowingToProfile", sender: self)
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
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 0)) as! FollowingAnswerTableViewCell
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
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 0)) as! FollowingAnswerTableViewCell
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
        
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 0)) as! FollowingAnswerTableViewCell
        if (cell.player.rate > 0) {
            cell.player.pause()
            cell.likeImageView.alpha = 0.7
            cell.likeImageView.image = UIImage(named: "playImage")
            cell.likeImageView.hidden = false
        } else {
            cell.player.play()
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "videoEnd",
                name: AVPlayerItemDidPlayToEndTimeNotification,
                object: nil)
            cell.likeImageView.hidden = true
        }
        
    }
    
    func videoEnd() {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: nil)
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchController.active {
            userIndexPath = indexPath.row
            self.performSegueWithIdentifier("segueFromSearchToProfile", sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
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
                answerVC.fromFollowing = true
                self.navigationController?.hidesBarsOnSwipe = false
                self.navigationController?.navigationBarHidden = false
            } else {
                let indexPath = self.tableView.indexPathForSelectedRow
                let content = self.questionArray[indexPath!.row].content
                let id = self.questionArray[indexPath!.row].id
                let creatorname = self.questionArray[indexPath!.row].creatorname
                let question = self.questionArray[indexPath!.row]
                self.selectedIndexPath = indexPath!.row
                answerVC.content = content
                answerVC.id = id
                answerVC.creatorname = creatorname
                answerVC.question = question
            }
        } else if segue.identifier == "segueFromFollowingToProfile" {
            if fromRelays {
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
            } else {
                let profileVC: ProfileViewController = segue.destinationViewController as! ProfileViewController
                for cell in tableView.visibleCells {
                    if cell.isKindOfClass(FollowingAnswerTableViewCell) {
                        let cell = cell as! FollowingAnswerTableViewCell
                        cell.player.pause()
                    }
                }
                let creatorId = questionArray[tag].creator
                let creatorname = questionArray[tag].creatorname
                profileVC.fromOtherVC = true
                profileVC.creatorId = creatorId
                profileVC.creatorname = creatorname
            }

        } else if segue.identifier == "segueFromSearchToProfile" {
            let profileVC: ProfileViewController = segue.destinationViewController as! ProfileViewController
            let creatorId = filteredId[userIndexPath]
            let creatorname = filteredUsers[userIndexPath]
            profileVC.fromOtherVC = true
            profileVC.creatorId = creatorId
            profileVC.creatorname = creatorname
//            if searchController.active {
//                
//            }

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
//                        cell.player.play()
                    }
                } else {
                    cell.player.pause()
                }
            }
        }
    }
    

}
