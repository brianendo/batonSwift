//
//  VideoViewController.swift
//  Baton
//
//  Created by Brian Endo on 3/9/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import AWSS3
import Alamofire
import SwiftyJSON
import JWTDecode
import KeychainSwift
import Crashlytics
import TwitterKit
import MessageUI
import FBSDKShareKit


class VideoViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var questionContentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likebutton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var pauseImageView: UIImageView!
    @IBOutlet weak var yourTakeButton: UIButton!
    
    
    
    let keychain = KeychainSwift()
    var answer:Answer!
    var videoUrl = ""
    var player: AVPlayer!
    var playerController: AVPlayerViewController!
    var vertical_screen = true
    var indexPath = 0
    var videoTime = 0.0
    
    override func viewWillDisappear(animated: Bool) {
        pauseImageView.hidden = true
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if player != nil {
            player.pause()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "videoEnd",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: nil)
        yourTakeButton.hidden = true
        pauseImageView.hidden = true
//        self.progressView.layer.sublayers?.removeAll()
//        if player != nil {
//            let seconds : Int64 = 0
//            let preferredTimeScale : Int32 = 1
//            let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
//            
//            player.seekToTime(seekTime)
//            player.play()
//            self.animateProgressView(self.videoTime)
//        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        yourTakeButton.hidden = true
        pauseImageView.hidden = true
        if player != nil {
            self.progressView.layer.sublayers?.removeAll()
            let seconds : Int64 = 0
            let preferredTimeScale : Int32 = 1
            let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
            
            player.seekToTime(seekTime)
//            player.play()
            
            let delay = 0.5
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.player.play()
                self.animateProgressView(self.videoTime)
            }
            
//            self.animateProgressView(self.videoTime)
        }
    }
    
    func videoEnd() {
        yourTakeButton.hidden = false
        pauseImageView.image = UIImage(named: "replayImage")
        pauseImageView.hidden = false
        
        if (player.rate > 0) {
            
        } else {
            
            let seconds : Int64 = 0
            let preferredTimeScale : Int32 = 1
            let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
            
            player.seekToTime(seekTime)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseImageView.alpha = 0.7
        pauseImageView.contentMode = UIViewContentMode.ScaleAspectFill
        pauseImageView.hidden = true
        
        nameLabel.text = answer.creatorname
        questionContentLabel.text = answer.question_content
        
        let views = answer.views
        let abbrevViews = views.addCommas(views)
        viewCountLabel.text = "\(abbrevViews) views"
        
        let likeCount = answer.likeCount
        let abbrevLikeCount = likeCount.addCommas(likeCount)
        let likeText = "  \(abbrevLikeCount)"
        likebutton.setTitle(likeText, forState: .Normal)
        
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
        profileImageView.clipsToBounds = true
        
        let creator = answer.creator
        if let cachedImageResult = imageCache[creator] {
            print("pull from cache")
            profileImageView.image = UIImage(data: cachedImageResult!)
        } else {
            // 3
            profileImageView.image = UIImage(named: "Placeholder")
            
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
                            self.profileImageView.image = UIImage(contentsOfFile: downloadingFilePath1)
                            self.profileImageView.setNeedsLayout()
                            
                    })
                    print("Fetched image")
                }
                return nil
            }
        }
        
        
        let newURL = NSURL(string: answer.video_url)
        player = AVPlayer(URL: newURL!)
        playerController = AVPlayerViewController()
        playerController.player = player
        playerController.view.frame = CGRectMake(videoView.frame.origin.x, videoView.frame.origin.y, videoView.frame.size.width, videoView.frame.size.height)
        playerController.showsPlaybackControls = false
        if answer.vertical_screen {
           playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        }
        playerController.view.userInteractionEnabled = false
        playerController.view.hidden = false
        self.videoView.addSubview(playerController.view)
        playerController.view.backgroundColor = UIColor(red:0.17, green:0.18, blue:0.29, alpha:1.0)
        videoView.bringSubviewToFront(closeButton)
        videoView.bringSubviewToFront(pauseImageView)
        let tapGesture = UITapGestureRecognizer(target: self, action: "singleTapped:")
        videoView.addGestureRecognizer(tapGesture)
        
        videoView.bringSubviewToFront(yourTakeButton)
        
        let time = CMTimeGetSeconds((self.player.currentItem?.asset.duration)!)
        print(time)
        let intTime = Double(time)
        print(intTime)
        self.videoTime = intTime
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [UIColor(white: 0.0, alpha: 0.6).CGColor,UIColor(white: 0.0, alpha: 0.3).CGColor, UIColor(white: 0.0, alpha: 0.0).CGColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.colors = [UIColor(white: 0.0, alpha: 0.6).CGColor,UIColor.clearColor().CGColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientView.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        let liked_by_user = answer.liked_by_user
        
        if liked_by_user == "true" {
            likebutton.setTitleColor(UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1), forState: .Normal)
            likebutton.setImage(UIImage(named: "bigRedHeart"), forState: .Normal)
        } else if liked_by_user == "not checked" {
            let url = globalurl + "api/answers/" + answer.id + "/likecheck/" + userid
            
            Alamofire.request(.GET, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Gobi")
                        self.likebutton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                        self.likebutton.setImage(UIImage(named: "whiteHeart"), forState: .Normal)
                        self.answer.liked_by_user = "false"
                    } else {
                        print("Liked")
                        self.likebutton.setTitleColor(UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1), forState: .Normal)
                        self.likebutton.setImage(UIImage(named: "bigRedHeart"), forState: .Normal)
                        self.answer.liked_by_user = "true"
                    }
            }
        } else if liked_by_user == "false" {
            likebutton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            likebutton.setImage(UIImage(named: "whiteHeart"), forState: .Normal)
        }
        
        likebutton.addTarget(self, action: "toggleLike:", forControlEvents: .TouchUpInside)


    }
    
    func singleTapped(sender: UITapGestureRecognizer) {
        print("Tapped")
        if (player.rate > 0) {
            yourTakeButton.hidden = true
            player.pause()
            pauseLayer(progressView.layer)
            pauseImageView.image = UIImage(named: "playImage")
            pauseImageView.hidden = false
        } else {
            if pauseImageView.image == UIImage(named: "replayImage") {
                yourTakeButton.hidden = true
                self.progressView.layer.sublayers?.removeAll()
                self.animateProgressView(self.videoTime)
//                let url = globalurl + "api/answers/" + answerArray[tag!].id + "/viewed/"
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
            }
            yourTakeButton.hidden = true
            resumeLayer(progressView.layer)
            player.play()
            pauseImageView.hidden = true
        }
        
    }
    
    func pauseLayer(layer: CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    func resumeLayer(layer: CALayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
    
    func animateProgressView(duration: Double) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = progressView.bounds
        
        gradientLayer.locations = [0.0, 1.0]
        
        let colorTop: AnyObject = UIColor(red: 255.0/255.0, green: 213.0/255.0, blue: 63.0/255.0, alpha: 1.0).CGColor
        let colorBottom: AnyObject = UIColor(red: 255.0/255.0, green: 198.0/255.0, blue: 5.0/255.0, alpha: 1.0).CGColor
        let arrayOfColors: [AnyObject] = [colorTop, colorBottom]
        gradientLayer.colors = arrayOfColors
        
        let path: UIBezierPath = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(CGRectGetWidth(progressView.frame), 0))
        
        //Create a CAShape Layer
        let pathLayer: CAShapeLayer = CAShapeLayer()
        pathLayer.frame = self.view.bounds
        pathLayer.path = path.CGPath
        pathLayer.backgroundColor = UIColor.clearColor().CGColor
        pathLayer.strokeColor = UIColor.blackColor().CGColor
        pathLayer.fillColor = nil
        pathLayer.lineWidth = 12.0
        pathLayer.strokeStart = 0.0
        pathLayer.strokeEnd = 0.0
        
        gradientLayer.mask = pathLayer
        self.progressView.layer.addSublayer(gradientLayer)
        
        //Add the layer to your view's layer
//        self.progressView.layer.addSublayer(pathLayer)
//        var newDuration = duration
//        if player.rate == 0 {
//            newDuration = duration + 0.5
//        }
        
        //This is basic animation, quite a few other methods exist to handle animation see the reference site answers
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.delegate = self
        pathAnimation.fromValue = CGFloat(0.0)
        pathAnimation.toValue = CGFloat(1.0)
        pathAnimation.duration = duration
        pathAnimation.delegate = self
        pathAnimation.removedOnCompletion = false
        pathAnimation.additive = true
        pathAnimation.fillMode = kCAFillModeForwards
        //Animation will happen right away
        pathLayer.addAnimation(pathAnimation, forKey: "strokeEnd")
    }
    
    func toggleLike(sender: UIButton!) {
        print("button hit")
        let currentLiked = answer.liked_by_user
        let answerId = answer.id
        
        if currentLiked == "true" {
            print("unliked")
            answer.likeCount -= 1
            answer.liked_by_user = "false"
            let likeCount = answer.likeCount
            let abbrevLikeCount = likeCount.addCommas(likeCount)
            let likeText = "  \(abbrevLikeCount)"
            likebutton.setTitle(likeText, forState: .Normal)
            likebutton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            likebutton.setImage(UIImage(named: "whiteHeart"), forState: .Normal)
            
            let url = globalurl + "api/answers/" + answerId + "/unlikednotifs/" + userid
            
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        
                    } else {
                        print("unliked")
//                        Answers.logCustomEventWithName("Unlike",
//                            customAttributes: ["where": "AnswersVC"])
                        
                    }
            }
        } else {
            print("liked")
            
            answer.likeCount += 1
            answer.liked_by_user = "true"
            let likeCount = answer.likeCount
            let abbrevLikeCount = likeCount.addCommas(likeCount)
            let likeText = "  \(abbrevLikeCount)"
            likebutton.setTitle(likeText, forState: .Normal)
            likebutton.setTitleColor(UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1), forState: .Normal)
            likebutton.setImage(UIImage(named: "bigRedHeart"), forState: .Normal)
            
            let url = globalurl + "api/answers/" + answerId + "/likednotifs/" + userid
            
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
                    let result = response.result.value
                    print(result)
                    if result == nil {
                        print("Already liked")
                        
                    } else {
                        print("Liked")
//                        Answers.logCustomEventWithName("Like",
//                            customAttributes: ["method": "Button", "where": "AnswersVC"])
                        
                    }
            }
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        if player.rate > 0 {
            player.pause()
            pauseImageView.image = UIImage(named: "playImage")
            pauseImageView.hidden = false
            pauseLayer(progressView.layer)
        }
        let creator = answer.creator
        let answerId = answer.id
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
            var questionContent = self.answer.question_content
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
            
            var questionContent = self.answer.question_content
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
            var questionContent = self.answer.question_content
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
    
    
    @IBAction func likeButtonPressed(sender: UIButton) {
    }
    
    @IBAction func takeVideoButtonPressed(sender: UIButton) {
    }
    
    @IBAction func yourTakeButtonPressed(sender: UIButton) {
    }
    
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
