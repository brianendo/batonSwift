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

class FeaturedVideoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    var answerArray = [Answer]()
    var questionIndex = 0
    var tag = 0
    var selectedIndexPath = 0
    let interactor = Interactor()
    
    // MARK: viewWill/viewDid
    override func viewWillDisappear(animated: Bool) {
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Pause players when leaving vc
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
    
    // MARK: - loadFunctions
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
                                        
                                        let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: content, video_url: video_url, likeCount: likeCount, liked_by_user: "not checked", frontCamera: frontCamera, createdAt: yourDate, views: views, featuredQuestion: featuredQuestion, followingCreator: "not checked", thumbnail_url: thumbnail_url, vertical_screen: vertical_screen)
                                        self.answerArray.append(answer)
                                        self.answerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                }
                            } else {
                                let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: question_content, video_url: video_url, likeCount: likeCount, liked_by_user: "not checked", frontCamera: frontCamera, createdAt: yourDate, views: views, featuredQuestion: featuredQuestion, followingCreator: "not checked", thumbnail_url: thumbnail_url, vertical_screen: vertical_screen)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("featuredPreviewCell", forIndexPath: indexPath) as! FeaturedPreviewTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
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
        cell.usernameButton.addTarget(self, action: "usernameTapped:", forControlEvents: .TouchUpInside)
        cell.usernameButton.tag = indexPath.row
        
        let question_content = answerArray[indexPath.row].question_content
        cell.questionContentLabel.text = question_content
        
        
        return cell
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! FeaturedPreviewTableViewCell
        
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
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath = indexPath.row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("segueFromFeaturedToVideoPage", sender: self)
    }
    
    // MARK: - tableView functions
    
    func usernameTapped(sender: UIButton) {
        let tag = sender.tag
        self.tag = tag
        Answers.logCustomEventWithName("Username Tapped",
            customAttributes: ["method": "nameLable", "where": "FeaturedPreview"])
        self.performSegueWithIdentifier("segueFromFeaturedToProfile", sender: self)
        
    }
    
    func questionContentPressed(sender: UIButton) {
        let tag = sender.tag
        self.questionIndex = tag
        self.performSegueWithIdentifier("segueFromFeaturedToAnswers", sender: self)
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
            let creatorId = answerArray[tag].creator
            let creatorname = answerArray[tag].creatorname
            profileVC.fromOtherVC = true
            profileVC.creatorId = creatorId
            profileVC.creatorname = creatorname
            self.navigationController?.hidesBarsOnSwipe = false
            self.navigationController?.navigationBarHidden = false
            
        } else if segue.identifier == "segueFromFeaturedToVideoPage" {
            let videoPageVC: VideoPageViewController = segue.destinationViewController as! VideoPageViewController
            videoPageVC.transitioningDelegate = self
            videoPageVC.interactor = interactor
            videoPageVC.answers = answerArray
            videoPageVC.indexPath = self.selectedIndexPath
            videoPageVC.fromFollowing = true
        }
    }
    
}

extension FeaturedVideoViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
