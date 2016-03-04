//
//  ChannelViewController.swift
//  Baton
//
//  Created by Brian Endo on 2/15/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import JWTDecode
import Crashlytics

class ChannelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let keychain = KeychainSwift()
    var channelIdArray = [String]()
    var channelNameArray = [String]()
    var counter = -1
    var myChannelIdArray = [String]()
    var myChannelNameArray = [String]()
    var section = 0
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
        
        // Check if there are any unread notifications
        if userid != "" {
            self.checkNotifications()
        }
    }
    
    // Check if there are any unread notifications
    func checkNotifications() {
        
        let url = globalurl + "api/unreadnotifications/" + userid
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                print(response.response?.statusCode)
                
                let statuscode = response.response?.statusCode
                if statuscode == 200 {
                    print("unread notifcations")
                    let tabItem = self.tabBarController?.viewControllers![2]
                    tabItem?.tabBarItem.badgeValue = "1"
                    NSNotificationCenter.defaultCenter().postNotificationName("newNotification", object: self)
                } else if statuscode == 400 {
                    print("no new notifications")
                    let tabItem = self.tabBarController?.viewControllers![2]
                    tabItem?.tabBarItem.badgeValue = nil
                } else if statuscode == 404 {
                    
                } else {
                    
                }
        }
        
    }
    
    func loadUserInfo() {
        
        // Grab JWT token and then verify if token is expired!
        var token = keychain.get("JWT")
        
        do {
            
            if token == nil {
                var refresh_token = keychain.get("refresh_token")
                
                if refresh_token == nil {
                    refresh_token = ""
                }
                
                // Use refresh token to get new JWT
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
                            //                            print("JSON: \(json)")
                            //                            print(json["token"].string)
                            let newtoken = json["token"].string
                            self.keychain.set(newtoken!, forKey: "JWT")
                            token = newtoken
                            
                            // Use JWT to access users route
                            let headers = [
                                "Authorization": "\(token!)"
                            ]
                            let url = globalurl + "api/users/" + userid
                            Alamofire.request(.GET, url, parameters: nil, headers: headers)
                                .responseJSON { response in
                                    var value = response.result.value
                                    
                                    let statuscode = (response.response?.statusCode)!
                                    print(statuscode)
                                    
                                    if value == nil {
                                        value = []
                                    } else {
                                        let json = JSON(value!)
                                        //                                        print("JSON: \(json)")
                                        let firstname = json["firstname"].string
                                        let lastname = json["lastname"].string
                                        var username = json["username"].string
                                        let email = json["email"].string
                                        
                                        name = firstname! + " " + lastname!
                                        
                                        if username == nil {
                                            username = firstname! + lastname!
                                        } else {
                                            username = username!
                                        }
                                        
                                        myfirstname = firstname!
                                        mylastname = lastname!
                                        myUsername = username!
                                        
                                        if email ==  nil {
                                            myemail = ""
                                        } else {
                                            myemail = email!
                                        }
                                        
                                        let channels = json["channels"]
                                        if channels ==  nil {
                                            
                                        } else {
                                            for (_,subJson):(String, JSON) in channels {
                                                let channelId = subJson["_id"].string
                                                let channelName = subJson["name"].string
                                                
                                                self.myChannelIdArray.append(channelId!)
                                                self.myChannelNameArray.append(channelName!)
                                            }
                                        }
                                        
                                        let deviceToken = json["deviceToken"].string
                                        
                                        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
                                            let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil)
                                            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                                            
                                            UIApplication.sharedApplication().registerForRemoteNotifications()
                                            }
                                        
                                        
                                        
                                        self.tableView.reloadData()
                                        // Load all types of questions
                                        self.loadChannels()
                                    }
                            }
                        }
                        
                        
                }
            } else {
                let jwt = try decode(token!)
                
                // Check if JWT expired
                if jwt.expired == true {
                    var refresh_token = keychain.get("refresh_token")
                    
                    if refresh_token == nil {
                        refresh_token = ""
                    }
                    
                    // Use refresh token to get new JWT
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
                                //                            print("JSON: \(json)")
                                //                            print(json["token"].string)
                                let newtoken = json["token"].string
                                self.keychain.set(newtoken!, forKey: "JWT")
                                token = newtoken
                                
                                // Use JWT to access users route
                                let headers = [
                                    "Authorization": "\(token!)"
                                ]
                                let url = globalurl + "api/users/" + userid
                                Alamofire.request(.GET, url, parameters: nil, headers: headers)
                                    .responseJSON { response in
                                        var value = response.result.value
                                        
                                        let statuscode = (response.response?.statusCode)!
                                        print(statuscode)
                                        
                                        if value == nil {
                                            value = []
                                        } else {
                                            let json = JSON(value!)
                                            //                                        print("JSON: \(json)")
                                            let firstname = json["firstname"].string
                                            let lastname = json["lastname"].string
                                            var username = json["username"].string
                                            let email = json["email"].string
                                            
                                            name = firstname! + " " + lastname!
                                            
                                            if username == nil {
                                                username = firstname! + lastname!
                                            } else {
                                                username = username!
                                            }
                                            
                                            myfirstname = firstname!
                                            mylastname = lastname!
                                            myUsername = username!
                                            
                                            if email ==  nil {
                                                myemail = ""
                                            } else {
                                                myemail = email!
                                            }
                                            
                                            let channels = json["channels"]
                                            if channels ==  nil {
                                                
                                            } else {
                                                for (_,subJson):(String, JSON) in channels {
                                                    let channelId = subJson["_id"].string
                                                    let channelName = subJson["name"].string
                                                    
                                                    self.myChannelIdArray.append(channelId!)
                                                    self.myChannelNameArray.append(channelName!)
                                                }
                                            }
                                            
                                            let deviceToken = json["deviceToken"].string
                                            if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
                                                let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil)
                                                UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                                                
                                                UIApplication.sharedApplication().registerForRemoteNotifications()
                                            }
                                            
                                            
                                            
                                            self.tableView.reloadData()
                                            // Load all types of questions
                                            self.loadChannels()
                                        }
                                }
                            }
                            
                            
                    }
                } else {
                    let headers = [
                        "Authorization": "\(token!)"
                    ]
                    let url = globalurl + "api/users/" + userid
                    Alamofire.request(.GET, url, parameters: nil, headers: headers)
                        .responseJSON { response in
                            var value = response.result.value
                            
                            let statuscode = response.response?.statusCode
                            print(statuscode)
                            
                            if value == nil {
                                value = []
                            } else {
                                let json = JSON(value!)
                                //                            print("JSON: \(json)")
                                let firstname = json["firstname"].string
                                let lastname = json["lastname"].string
                                var username = json["username"].string
                                let email = json["email"].string
                                
                                name = firstname! + " " + lastname!
                                
                                if username == nil {
                                    username = firstname! + lastname!
                                } else {
                                    username = username!
                                }
                                
                                myfirstname = firstname!
                                mylastname = lastname!
                                myUsername = username!
                                
                                if email ==  nil {
                                    myemail = ""
                                } else {
                                    myemail = email!
                                }
                                
                                let channels = json["channels"]
                                if channels ==  nil {
                                    
                                } else {
                                    for (_,subJson):(String, JSON) in channels {
                                        let channelId = subJson["_id"].string
                                        let channelName = subJson["name"].string
                                        
                                        self.myChannelIdArray.append(channelId!)
                                        self.myChannelNameArray.append(channelName!)
                                    }
                                }
                                
                                let deviceToken = json["deviceToken"].string
                                if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
                                    let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil)
                                    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                                    
                                    UIApplication.sharedApplication().registerForRemoteNotifications()
                                }
                                
                                self.tableView.reloadData()
                                self.loadChannels()
                            }
                    }
                }
            }
            
        } catch {
            print("Failed to decode JWT: \(error)")
        }
        
        
    }
    
    func updateFollow() {
        
        // Use JWT to access updatefollow route
        var token = keychain.get("JWT")
        
        do {
            let jwt = try decode(token!)
            //            print(jwt)
            //            print(jwt.body)
            //            print(jwt.expiresAt)
            //            print(jwt.expired)
            if jwt.expired == true {
                var refresh_token = keychain.get("refresh_token")
                
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
                            //                            print("JSON: \(json)")
                            //                            print(json["token"].string)
                            let newtoken = json["token"].string
                            self.keychain.set(newtoken!, forKey: "JWT")
                            token = newtoken
                            
                            let headers = [
                                "Authorization": "\(token!)"
                            ]
                            let url = globalurl + "api/updatefollow/" + userid
                            Alamofire.request(.PUT, url, parameters: nil, headers: headers)
                                .responseJSON { response in
                                    print(response.response?.statusCode)
                                    let statuscode = response.response?.statusCode
                                    if statuscode == 200 {
                                        print("follow updated")
                                    } else if statuscode == 400 {
                                        print("unable to update follow")
                                    } else if statuscode == 404 {
                                        
                                    } else {
                                        
                                    }
                                    
                            }
                        }
                        
                        
                }
            } else {
                let headers = [
                    "Authorization": "\(token!)"
                ]
                let url = globalurl + "api/updatefollow/" + userid
                Alamofire.request(.PUT, url, parameters: nil, headers: headers)
                    .responseJSON { response in
                        print(response.response?.statusCode)
                        
                        let statuscode = response.response?.statusCode
                        if statuscode == 200 {
                            print("follow updated")
                        } else if statuscode == 400 {
                            print("unable to update follow")
                        } else if statuscode == 404 {
                            
                        } else {
                            
                        }
                        
                }
            }
        } catch {
            print("Failed to decode JWT: \(error)")
        }
    }
    
    func loadChannels() {
        let newUrl = globalurl + "api/channels/"
        
        Alamofire.request(.GET, newUrl, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                }
                
                let json = JSON(value!)
                //                print("JSON: \(json)")
                if json == [] {
                    print("No channels")
                }
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    
                    let id = subJson["_id"].string
                    let name = subJson["name"].string
                    
                    if name == nil  {
                        
                    } else {
                        if self.myChannelIdArray.contains(id!) {
                            
                        } else {
                            self.channelIdArray.append(id!)
                            self.channelNameArray.append(name!)
                            
                        }
                    }
                    
                    
                    
                }
                self.tableView.reloadData()
                
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Empty data
        do {
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let documentsDirectory = paths[0]
            let documentsDirectoryURL = NSURL(fileURLWithPath: paths[0])
            
            let directoryContents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentsDirectory)
            
            var totalMegaBytes: Double = 0
            var nrOfFiles = 0
            
            for filename in directoryContents {
                let file = documentsDirectoryURL.URLByAppendingPathComponent(filename)
                
                
                let fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(file.path!)
                let fileSize = fileAttributes[NSFileSize] as! Double
                totalMegaBytes += fileSize/1024/1024
                
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(file)
                    nrOfFiles++
                }catch let error as NSError{
                    print("> Emptying sandbox: could not delete file", filename, error)
                }
            }
            
            print("> Emptying sandbox: Removed \(nrOfFiles) files with a total of \(round(totalMegaBytes))MB")
            
        } catch let error as NSError {
            print("> Emptying sandbox: Error emptying sandbox", error)
        }
        
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        let label = UILabel.init(frame: CGRectMake(0, 0, 100, 30))
        label.text = "B"
        label.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, view.frame.origin.y + 20)
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: "Futura", size: 34)
        label.textColor = UIColor(red:0.91, green:0.27, blue:0.27, alpha:1.0)
        
        self.navigationItem.titleView = label
        
        let isLoggedIn = keychain.get("ISLOGGEDIN")
        if (isLoggedIn != "1") {
            // Reauthenticate user in LogIn storyboard
            let login = UIStoryboard(name: "LogIn", bundle: nil)
            let loginVC = login.instantiateInitialViewController()
            self.presentViewController(loginVC!, animated: true, completion: nil)
        } else {
            // Check if the suer ID is available
            let id = keychain.get("ID")
            if id == nil {
                // Reauthenticate user in LogIn storyboard
                let login = UIStoryboard(name: "LogIn", bundle: nil)
                let loginVC = login.instantiateInitialViewController()
                self.presentViewController(loginVC!, animated: true, completion: nil)
            } else {
                // Set the global userid variable with the id in keychain
                userid = id!
                
                // Set tableView
                self.tableView.dataSource = self
                self.tableView.delegate = self
                self.tableView.rowHeight = UITableViewAutomaticDimension
                self.tableView.scrollsToTop = true
                
                self.updateFollow()
                self.loadUserInfo()
                self.checkNotifications()
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "My Channels:"
        } else {
            if channelIdArray.count == 0 {
                return ""
            } else {
               return "Channels:"
            }
            
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2 + myChannelIdArray.count
        } else {
            return channelIdArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell: ChannelTitleTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChannelTitleCell", forIndexPath: indexPath) as! ChannelTitleTableViewCell
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsetsZero
                cell.layoutMargins = UIEdgeInsetsZero
                
                cell.titleLabel.text = "Today's Top Posts"
                cell.toggleChannelButton.hidden = true
                
                return cell
            } else if indexPath.row == 1 {
                let cell: ChannelTitleTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChannelTitleCell", forIndexPath: indexPath) as! ChannelTitleTableViewCell
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsetsZero
                cell.layoutMargins = UIEdgeInsetsZero
                
                cell.toggleChannelButton.hidden = true
                if myChannelIdArray.count == 0 {
                    cell.titleLabel.text = "Multi Channel ( +2 channels )"
                    cell.backgroundColor = UIColor(white:0.98, alpha:1.0)
                    cell.titleLabel.textColor = UIColor(white:0.65, alpha:1.0)
                    cell.userInteractionEnabled = false
                } else if myChannelNameArray.count == 1 {
                    cell.titleLabel.text = "Multi Channel ( +1 channel )"
                    cell.backgroundColor = UIColor(white:0.98, alpha:1.0)
                    cell.titleLabel.textColor = UIColor(white:0.65, alpha:1.0)
                    cell.userInteractionEnabled = false
                }else {
                    var channelNames = ""
                    let count = myChannelNameArray.count
//                    for name in myChannelNameArray {
//                        channelNames = channelNames + " " + name
//                    }
                    let lastIndex = count - 1
                    var index: Int
                    for index = 0; index < count; ++index {
                        if index < lastIndex {
                            channelNames = channelNames + myChannelNameArray[index] + "+"
                        } else {
                            channelNames = channelNames + myChannelNameArray[index]
                        }
                    }
                    
                    cell.titleLabel.text = "Multi Channel ( " + channelNames + " )"
                    cell.backgroundColor = UIColor.whiteColor()
                    cell.userInteractionEnabled = true
                    cell.titleLabel.textColor = UIColor.blackColor()
                }
                
                return cell
            }else {
                let cell: ChannelTitleTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChannelTitleCell", forIndexPath: indexPath) as! ChannelTitleTableViewCell
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsetsZero
                cell.layoutMargins = UIEdgeInsetsZero
                
                let channelTitle = myChannelNameArray[(indexPath.row-2)]
                cell.toggleChannelButton.hidden = false
                cell.titleLabel.text = channelTitle
                cell.toggleChannelButton.addTarget(self, action: "toggleChannel:", forControlEvents: .TouchUpInside)
                cell.toggleChannelButton.selected = true
                cell.toggleChannelButton.tag = (indexPath.row-2)
                return cell
            }
        } else {
            let cell: ChannelTitleTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChannelTitleCell", forIndexPath: indexPath) as! ChannelTitleTableViewCell
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            let name = channelNameArray[indexPath.row]
            
            cell.titleLabel.text = name
            cell.toggleChannelButton.hidden = false
            cell.toggleChannelButton.addTarget(self, action: "toggleChannel:", forControlEvents: .TouchUpInside)
            cell.toggleChannelButton.tag = indexPath.row
            cell.toggleChannelButton.selected = false
            return cell
        }
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            counter = -2
            self.performSegueWithIdentifier("segueToFeed", sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else if indexPath.section == 0 && indexPath.row == 1 {
            counter = -1
            self.performSegueWithIdentifier("segueToFeed", sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else if indexPath.section == 0 {
            counter = indexPath.row - 2
            section = indexPath.section
            self.performSegueWithIdentifier("segueToFeed", sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            counter = indexPath.row
            section = indexPath.section
            self.performSegueWithIdentifier("segueToFeed", sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        }
    }
    
    func toggleChannel(sender: UIButton) {
        let tag = sender.tag
        
        if sender.selected == false {
            
            let channelId = channelIdArray[tag]
            let channelName = channelNameArray[tag]
            sender.selected = true
            myChannelIdArray.append(channelId)
            myChannelNameArray.append(channelName)
            channelIdArray.removeAtIndex(tag)
            channelNameArray.removeAtIndex(tag)
            
            self.tableView.reloadData()
            
            let url = globalurl + "api/joinchannel"
            let parameters = [
                "userid": userid,
                "channel_id": channelId,
                "channel_name": channelName
            ]
            Alamofire.request(.POST, url, parameters: parameters)
                .responseJSON { response in
                    print(response.request)
                    print(response.response)
                    print(response.result)
                    print(response.response?.statusCode)
                    var value = response.result.value
                    
                    if value == nil {
                        value = []
                    }
                    
                    let json = JSON(value!)
                    print(json)
                    
            }
        } else if sender.selected == true {
            print("Reached")
            let channelId = myChannelIdArray[tag]
            let channelName = myChannelNameArray[tag]
            
            sender.selected = false
            channelIdArray.append(channelId)
            channelNameArray.append(channelName)
            myChannelIdArray.removeAtIndex(tag)
            myChannelNameArray.removeAtIndex(tag)
            
            self.tableView.reloadData()
            
            let url = globalurl + "api/removechannel"
            let parameters = [
                "userid": userid,
                "channel_id": channelId,
                "channel_name": channelName
            ]
            Alamofire.request(.POST, url, parameters: parameters)
                .responseJSON { response in
                    print(response.request)
                    print(response.response)
                    print(response.result)
                    print(response.response?.statusCode)
                    var value = response.result.value
                    
                    if value == nil {
                        value = []
                    }
                    
                    let json = JSON(value!)
                    print(json)
                    
            }
        }
        
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToFeed" {
            if counter == -2 {
                Answers.logCustomEventWithName("Channel Clicked",
                    customAttributes: ["name": "Top Posts"])
            }
            else if counter == -1 {
                let feedVC: FeedViewController = segue.destinationViewController as! FeedViewController
                feedVC.myChannelIdArray = myChannelIdArray
                feedVC.fromFavorites = true
                feedVC.channelName = "Multi Channel"
                Answers.logCustomEventWithName("Channel Clicked",
                    customAttributes: ["name": "Multi Channel"])
            }
            else {
                if section == 0 {
                    let feedVC: FeedViewController = segue.destinationViewController as! FeedViewController
                    let channelId = myChannelIdArray[counter]
                    let channelName = myChannelNameArray[counter]
                    feedVC.fromSpecificChannel = true
                    feedVC.channelId = channelId
                    feedVC.channelName = channelName
                    Answers.logCustomEventWithName("Channel Clicked",
                        customAttributes: ["name": channelName])
                } else {
                    let feedVC: FeedViewController = segue.destinationViewController as! FeedViewController
                    let channelId = channelIdArray[counter]
                    let channelName = channelNameArray[counter]
                    feedVC.fromSpecificChannel = true
                    feedVC.channelId = channelId
                    feedVC.channelName = channelName
                    Answers.logCustomEventWithName("Channel Clicked",
                        customAttributes: ["name": channelName])
                }
                
                
            }
        }
    }

}
