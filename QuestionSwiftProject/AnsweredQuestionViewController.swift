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

class AnsweredQuestionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var questionId = ""
    var answerId = ""
    
    var videoUrl = ""
    var creatorName = ""
    var likeCount = 0
    
    var contentText = ""
    
    func loadAnswer() {
        let url = globalurl + "api/answers/" + answerId
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                let json = JSON(response.result.value!)
                print("JSON: \(json)")
                let creatorname = json["creatorname"].string
                let video_url = json["video_url"].string
                var likeCount = json["likes"].int
                if likeCount == nil {
                    likeCount = 0
                }
                
                if video_url != nil {
                    print(video_url)
                    self.videoUrl = video_url!
                    self.creatorName = creatorname!
                    self.likeCount = likeCount!
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
            
            cell.nameTextView.text = self.creatorName
            
            let videoUrl = self.videoUrl
            
            let newURL = NSURL(string: videoUrl)
            cell.player = AVPlayer(URL: newURL!)
            cell.playerController.player = cell.player
            cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            self.addChildViewController(cell.playerController)
            cell.videoView.addSubview(cell.playerController.view)
            cell.playerController.didMoveToParentViewController(self)
            cell.player.play()
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            cell.playerController.view.userInteractionEnabled = true
            
            let view = UIView(frame: cell.playerController.view.frame)
            cell.addSubview(view)
            
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
            
            return cell
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
