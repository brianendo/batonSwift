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
    
    var idArray = [String]()
    var videoUrlArray = [String]()
    var creatornameArray = [String]()
    var likeCountArray = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBarController?.tabBar.hidden = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        if fromProfile {
            relayButton.removeFromSuperview()
            bottomLayoutConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 300
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.loadAnswers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadAnswers(){
        let url = globalurl + "api/questions/" + id + "/answers/"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                let json = JSON(response.result.value!)
                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    let id = subJson["_id"].string
                    let creatorname = subJson["creatorname"].string
                    let video_url = subJson["video_url"].string
                    var likeCount = subJson["likes"].int
                    if likeCount == nil {
                        likeCount = 0
                    }
                    
                    if video_url != nil {
                        print(video_url)
                        self.videoUrlArray.append(video_url!)
                        self.creatornameArray.append(creatorname!)
                        self.idArray.append(id!)
                        self.likeCountArray.append(likeCount!)
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
            
            cell.contentTextView.text = self.content
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("AnswerCell", forIndexPath: indexPath) as! AnswerTableViewCell
            
            cell.nameTextView.text = creatornameArray[indexPath.row]
            
            let videoUrl = videoUrlArray[indexPath.row]
            
            let newURL = NSURL(string: videoUrl)
            cell.player = AVPlayer(URL: newURL!)
            cell.playerController.player = cell.player
            cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
            self.addChildViewController(cell.playerController)
            cell.videoView.addSubview(cell.playerController.view)
            cell.playerController.didMoveToParentViewController(self)
            cell.player.pause()
            
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
            
            let likeCount = self.likeCountArray[indexPath.row]
            cell.likeCountTextView.text = "\(likeCount)"
            cell.videoView.bringSubviewToFront(cell.likeCountTextView)
            
            return cell
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
                
                let answerId = self.idArray[tag!]
                
                let url = globalurl + "api/answers/" + answerId + "/liked/" + userid
                
                Alamofire.request(.PUT, url, parameters: nil)
                    .responseJSON { response in
                        let result = response.result.value
                        print(result)
                        if result == nil {
                            print("Already liked")
                        } else {
                            print("Liked")
                            self.likeCountArray[tag!] += 1
                            self.tableView.reloadData()
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
            return idArray.count
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
                    cell.player.play()
                } else {
                    cell.player.pause()
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromAnswerToTakeVideo" {
            let takeVideoVC: TakeVideoViewController = segue.destinationViewController as! TakeVideoViewController
            takeVideoVC.content = self.content
            takeVideoVC.id = self.id
        }
    }
    
    @IBAction func relayButtonPressed(sender: UIButton) {
        self.performSegueWithIdentifier("segueFromAnswerToTakeVideo", sender: self)
    }
    
    
    

}
