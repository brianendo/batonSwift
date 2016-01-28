//
//  UserListViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 1/14/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AWSS3

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var counter = ""
    var userIdArray = [String]()
    var usernameArray = [String]()
    var indexPath = 0
    var id = ""
    
    func loadUsers() {
        if counter == "followers" {
            let url = globalurl + "api/followers/" + id
            
            Alamofire.request(.GET, url, parameters: nil)
                .responseJSON { response in
                    var value = response.result.value
                    
                    if value == nil {
                        value = []
                    }
                    let json = JSON(value!)
                    print("JSON: \(json)")
                    for (_,subJson):(String, JSON) in json {
                        let json = JSON(value!)
                        print("JSON: \(json)")
                        let userId = subJson["sender"].string
                        let username = subJson["sendername"].string
                        
                        self.userIdArray.append(userId!)
                        self.usernameArray.append(username!)
                        
                        self.tableView.reloadData()
                    }
            }
        } else if counter == "following" {
            let url = globalurl + "api/following/" + id
            
            Alamofire.request(.GET, url, parameters: nil)
                .responseJSON { response in
                    var value = response.result.value
                    
                    if value == nil {
                        value = []
                    }
                    let json = JSON(value!)
                    print("JSON: \(json)")
                    for (_,subJson):(String, JSON) in json {
                        let json = JSON(value!)
                        print("JSON: \(json)")
                        let userId = subJson["recipient"].string
                        let username = subJson["recipientname"].string
                        
                        self.userIdArray.append(userId!)
                        self.usernameArray.append(username!)
                        
                        self.tableView.reloadData()
                    }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        self.loadUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserTableViewCell
        
        cell.nameTextView.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        cell.nameTextView.textColor = UIColor.blackColor()
        cell.nameTextView.userInteractionEnabled = false
        
        let name = usernameArray[indexPath.row]
        
        cell.nameTextView.text = name
        
        
        
        let creator = userIdArray[indexPath.row]
        
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
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userIdArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.indexPath = indexPath.row
        self.performSegueWithIdentifier("segueFromUserListToProfile", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromUserListToProfile" {
            let profileVC: ProfileViewController = segue.destinationViewController as! ProfileViewController
            let creatorId = userIdArray[indexPath]
            let creatorname = usernameArray[indexPath]
            profileVC.fromOtherVC = true
            profileVC.creatorId = creatorId
            profileVC.creatorname = creatorname
        }
    }

}
