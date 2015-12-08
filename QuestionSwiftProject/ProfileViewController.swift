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
    
    var counter = 0
    
    var refreshControl:UIRefreshControl!
    
    func loadMyQuestions() {
        let url = globalurl + "api/myquestions/" + userid
        
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
                    
                    let dateFor: NSDateFormatter = NSDateFormatter()
                    dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
                    
                    if creator == userid{
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
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: answered, currentuser: user, createdAt: yourDate, creator: creator)
                    self.myQuestionArray.append(question)
                    
                    self.tableView.reloadData()
                }
        }
    }
    
    func loadMyAnswers() {
        let url = globalurl + "api/users/" + userid + "/answers/"
        
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
                    let creatorname = subJson["creatorname"].string
                    let question_id = subJson["question_id"].string
                    let video_url = subJson["video_url"].string
                    var likeCount = subJson["likeCount"].int
                    
                    if likeCount == nil {
                        likeCount = 0
                    }
                    
                    if video_url != nil {
                        
                        let newUrl = globalurl + "api/questions/" + question_id!
                        
                        Alamofire.request(.GET, newUrl, parameters: nil)
                            .responseJSON { response in
                                var value = response.result.value
                                
                                if value == nil {
                                    value = []
                                }
                                
                                let json = JSON(value!)
                                print("JSON: \(json)")
                                
                                let question_content = json["content"].string
                                
                                let answer = Answer(content: content, creatorname: creatorname, id: id, question_id: question_id, question_content: question_content, video_url: video_url, likeCount: likeCount)
                                self.myAnswerArray.append(answer)
                                
                                self.tableView.reloadData()
                                
                        }
                    }
                    
                }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70
        
        self.myQuestionArray.removeAll(keepCapacity: true)
        self.loadMyQuestions()
        
        self.myAnswerArray.removeAll(keepCapacity: true)
        self.loadMyAnswers()
        
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
        
        self.loadMyQuestions()
        self.loadMyAnswers()
        
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        self.myQuestionArray.removeAll(keepCapacity: true)
        self.myAnswerArray.removeAll(keepCapacity: true)
        
        self.loadMyQuestions()
        self.loadMyAnswers()
        
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
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if counter == 0 {
                return myQuestionArray.count
            } else {
                return myAnswerArray.count
            }
        }
        
    }
    
    func profileSegmentedControlChanged(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            print("Money")
            counter = 0
        } else {
            print("Mayweather")
            counter = 1
            self.tableView.reloadData()
        }
        
        self.tableView.reloadData()
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: ProfileTableViewCell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as! ProfileTableViewCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.profileSegmentedControl.addTarget(self, action: "profileSegmentedControlChanged:", forControlEvents: .ValueChanged)
            cell.nameLabel.text = name
            
            cell.profileImageView.image = UIImage(named: "Placeholder")
            if let cachedImageResult = imageCache[currentUser] {
                print("pull from cache")
                cell.profileImageView.image = UIImage(data: cachedImageResult!)
            } else {
                // 3
                cell.profileImageView.image = UIImage(named: "BatPic")
                
                // 4
                let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp-download")
                let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                
                
                let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
                readRequest1.bucket = S3BucketName
                readRequest1.key =  userid
                readRequest1.downloadingFileURL = downloadingFileURL1
                
                let task = transferManager.download(readRequest1)
                task.continueWithBlock { (task) -> AnyObject! in
                    if task.error != nil {
                        print("No Profile Pic")
                    } else {
                        let image = UIImage(contentsOfFile: downloadingFilePath1)
                        let imageData = UIImageJPEGRepresentation(image!, 1.0)
                        imageCache[currentUser] = imageData
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
            let cell: ProfileQuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("profileQuestionCell", forIndexPath: indexPath) as! ProfileQuestionTableViewCell
            
            cell.questionTextView.text = myQuestionArray[indexPath.row].content
            cell.questionTextView.userInteractionEnabled = false
            let answerCount = myQuestionArray[indexPath.row].answercount
            cell.answercountLabel.text = "\(answerCount)"
            
            return cell
        } else {
            let cell: ProfileRelayTableViewCell = tableView.dequeueReusableCellWithIdentifier("RelayCell", forIndexPath: indexPath) as! ProfileRelayTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            print(myAnswerArray[indexPath.row].question_content)
            cell.contentTextView.text = myAnswerArray[indexPath.row].question_content
            cell.contentTextView.userInteractionEnabled = false
           
            let videoUrl = myAnswerArray[indexPath.row].video_url
            
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
            
            
//            let likeCount = self.likeCountArray[indexPath.row]
//            cell.likeCountTextView.text = "\(likeCount)"
//            cell.videoView.bringSubviewToFront(cell.likeCountTextView)
            
            return cell
            
        }
        
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 150
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            
        } else {
            if counter == 0 {
                self.performSegueWithIdentifier("segueFromProfileToAnswers", sender: self)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            } else {
//                self.performSegueWithIdentifier("showThankedAnswerVC", sender: self)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "profileToMyQuestionVC" {
            let myQuestionVC: MyQuestionViewController = segue.destinationViewController as! MyQuestionViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let content = self.myQuestionArray[indexPath!.row].content
            let id = self.myQuestionArray[indexPath!.row].id
            myQuestionVC.content = content
            myQuestionVC.id = id
        } else if segue.identifier == "showThankedAnswerVC" {
            let thankedAnswerVC: ThankedAnswerViewController = segue.destinationViewController as! ThankedAnswerViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let id = self.myAnswerArray[indexPath!.row].question_id
            thankedAnswerVC.id = id
        } else if segue.identifier == "segueFromProfileToAnswers" {
            let answerVC: AnswersViewController = segue.destinationViewController as! AnswersViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let content = self.myQuestionArray[indexPath!.row].content
            let id = self.myQuestionArray[indexPath!.row].id
            let creatorname = self.myQuestionArray[indexPath!.row].creatorname
            answerVC.content = content
            answerVC.id = id
            answerVC.creatorname = creatorname
            answerVC.fromProfile = true
        }
    }
    
    @IBAction func imageButtonClicked(sender: UIButton) {
        print("Clicked")
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
                    cell.player.play()
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
