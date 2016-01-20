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
    
    func loadAnswer() {
        let url = globalurl + "api/answers/" + answerId
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                let json = JSON(response.result.value!)
                print("JSON: \(json)")
                let creatorname = json["creatorname"].string
                let creator = json["creator"].string
                let video_url = json["video_url"].string
                var likeCount = json["likes"].int
                let frontCamera = json["frontCamera"].bool
                if likeCount == nil {
                    likeCount = 0
                }
                
                if video_url != nil {
                    print(video_url)
                    self.videoUrl = video_url!
                    self.creatorName = creatorname!
                    self.likeCount = likeCount!
                    self.creator = creator!
                    self.frontCamera = frontCamera!
                }
                
                self.tableView.reloadData()
                
        }
    }
    
    func loadQuestion() {
        let url = globalurl + "api/questions/" + questionId
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                let json = JSON(response.result.value!)
                print("JSON: \(json)")
                let content = json["content"].string
                
                self.contentText = content!
                self.tableView.reloadData()
                
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 300
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
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
            let cell: MyQuestionTitleTableViewCell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath) as! MyQuestionTitleTableViewCell
            
            cell.contentTextView.text = self.contentText
            
            return cell
        } else {
            let cell: AnsweredQuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("AnswerCell", forIndexPath: indexPath) as! AnsweredQuestionTableViewCell
            
            cell.profileImageView.image = UIImage(named: "Placeholder")
            if let cachedImageResult = imageCache[self.creator] {
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
                readRequest1.key =  self.creator
                readRequest1.downloadingFileURL = downloadingFileURL1
                
                let task = transferManager.download(readRequest1)
                task.continueWithBlock { (task) -> AnyObject! in
                    if task.error != nil {
                        print("No Profile Pic")
                    } else {
                        let image = UIImage(contentsOfFile: downloadingFilePath1)
                        let imageData = UIImageJPEGRepresentation(image!, 1.0)
                        imageCache[self.creator] = imageData
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
            

            
            cell.nameTextView.text = self.creatorName
            
            let videoUrl = self.videoUrl
            
            let newURL = NSURL(string: videoUrl)
            cell.player = AVPlayer(URL: newURL!)
            cell.playerController.player = cell.player
            
            if frontCamera == true {
                cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            }
            
//            self.addChildViewController(cell.playerController)
            cell.videoView.addSubview(cell.playerController.view)
//            cell.playerController.didMoveToParentViewController(self)
            cell.player.play()
            
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
            cell.videoView.bringSubviewToFront(cell.likeImageView)
            
            let doubleTapGesture = UITapGestureRecognizer()
            doubleTapGesture.numberOfTapsRequired = 2
            doubleTapGesture.addTarget(self, action: "doubleTapped:")
            view.addGestureRecognizer(doubleTapGesture)
            
            let likeCount = self.likeCount
            
            cell.likeCountTextView.text = "\(likeCount)"
            cell.videoView.bringSubviewToFront(cell.likeCountTextView)
            cell.videoView.bringSubviewToFront(cell.heartImageView)
            
            cell.likeButton.tag = indexPath.row
            cell.likeButton.addTarget(self, action: "toggleLike:", forControlEvents: .TouchUpInside)
            cell.videoView.bringSubviewToFront(cell.likeButton)
            
            if indexPath.row == 0 {
                cell.player.play()
                
                let url = globalurl + "api/answers/" + self.answerId + "/viewed/"
                
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
                cell.followButton.setTitle("Follow", forState: .Normal)
                cell.followButton.setTitle("Following", forState: .Selected)
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
            
            if liked_by_user == true {
                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                cell.heartImageView.image = UIImage(named: "RedHeart")
            } else {
                let url = globalurl + "api/answers/" + self.answerId + "/likecheck/" + userid
                
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
                            self.liked_by_user = true
                        }
                }
            }

            
            return cell
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
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 1)) as! AnswerTableViewCell
        
        if liked_by_user == true {
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
                        self.likeCount -= 1
                        self.liked_by_user = false
                        cell.likeCountTextView.text = "\(self.likeCount)"
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
                        self.likeCount += 1
                        self.liked_by_user = true
                        cell.likeCountTextView.text = "\(self.likeCount)"
                        cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                        cell.heartImageView.image = UIImage(named: "RedHeart")
                    }
            }
        }
    }
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        print("Double Tap")
        let tag = sender.view?.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 1)) as! AnsweredQuestionTableViewCell
        
        cell.likeImageView.hidden = false
        
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
                            self.likeCount += 1
                            self.tableView.reloadData()
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
        } else {
            cell.player.play()
        }
        
    }

    
}
