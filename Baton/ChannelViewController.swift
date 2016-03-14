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

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    let keychain = KeychainSwift()
    var channelIdArray = [String]()
    var channelNameArray = [String]()
    var counter = -1
    var myChannelIdArray = [String]()
    var myChannelNameArray = [String]()
    var section = 0
    
    
    // MARK: - viewDid/viewWill
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        self.navigationItem.title = "Channels"
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.addTarget(self, action: "popToRoot:", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.setTitle("Back ", forState: UIControlState.Normal)
        backButton.setImage(UIImage(named: "backButton"), forState: .Normal)
        backButton.setTitleColor(UIColor(red:0.91, green:0.27, blue:0.27, alpha:1.0), forState: .Normal)
        backButton.sizeToFit()
        backButton.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        backButton.titleLabel!.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.rightBarButtonItem = backButtonItem
        
        self.navigationItem.hidesBackButton = true
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.scrollsToTop = true
        
        
        self.loadChannels()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - loadFunctions
    
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
                        self.channelIdArray.append(id!)
                        self.channelNameArray.append(name!)
//                        if self.myChannelIdArray.contains(id!) {
//                            
//                        } else {
//                            self.channelIdArray.append(id!)
//                            self.channelNameArray.append(name!)
//                            
//                        }
                    }
                    
                    
                    
                }
                self.tableView.reloadData()
                
        }
    }
    
    
    func popToRoot(sender:UIBarButtonItem){
        self.navigationController!.popToRootViewControllerAnimated(true)
    }

    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return "My Channels:"
//        } else {
//            if channelIdArray.count == 0 {
//                return ""
//            } else {
//               return "Channels:"
//            }
//            
//        }
        return ""
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return 2 + myChannelIdArray.count
//        } else {
//            return channelIdArray.count
//        }
        return channelIdArray.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            if indexPath.row == 0 {
//                let cell: ChannelTitleTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChannelTitleCell", forIndexPath: indexPath) as! ChannelTitleTableViewCell
//                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
//                cell.preservesSuperviewLayoutMargins = false
//                cell.separatorInset = UIEdgeInsetsZero
//                cell.layoutMargins = UIEdgeInsetsZero
//                
//                cell.titleLabel.text = "Today's Top Posts"
//                cell.toggleChannelButton.hidden = true
//                
//                return cell
//            }
//            else if indexPath.row == 1 {
//                let cell: ChannelTitleTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChannelTitleCell", forIndexPath: indexPath) as! ChannelTitleTableViewCell
//                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
//                cell.preservesSuperviewLayoutMargins = false
//                cell.separatorInset = UIEdgeInsetsZero
//                cell.layoutMargins = UIEdgeInsetsZero
//                
//                cell.toggleChannelButton.hidden = true
//                if myChannelIdArray.count == 0 {
//                    cell.titleLabel.text = "Multi Channel ( +2 channels )"
//                    cell.backgroundColor = UIColor(white:0.98, alpha:1.0)
//                    cell.titleLabel.textColor = UIColor(white:0.65, alpha:1.0)
//                    cell.userInteractionEnabled = false
//                } else if myChannelNameArray.count == 1 {
//                    cell.titleLabel.text = "Multi Channel ( +1 channel )"
//                    cell.backgroundColor = UIColor(white:0.98, alpha:1.0)
//                    cell.titleLabel.textColor = UIColor(white:0.65, alpha:1.0)
//                    cell.userInteractionEnabled = false
//                }else {
//                    var channelNames = ""
//                    let count = myChannelNameArray.count
//                    let lastIndex = count - 1
//                    var index: Int
//                    for index = 0; index < count; ++index {
//                        if index < lastIndex {
//                            channelNames = channelNames + myChannelNameArray[index] + "+"
//                        } else {
//                            channelNames = channelNames + myChannelNameArray[index]
//                        }
//                    }
//                    
//                    cell.titleLabel.text = "Multi Channel ( " + channelNames + " )"
//                    cell.backgroundColor = UIColor.whiteColor()
//                    cell.userInteractionEnabled = true
//                    cell.titleLabel.textColor = UIColor.blackColor()
//                }
//                
//                return cell
//            }else {
//                let cell: ChannelTitleTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChannelTitleCell", forIndexPath: indexPath) as! ChannelTitleTableViewCell
//                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
//                cell.preservesSuperviewLayoutMargins = false
//                cell.separatorInset = UIEdgeInsetsZero
//                cell.layoutMargins = UIEdgeInsetsZero
//                
//                let channelTitle = myChannelNameArray[(indexPath.row-2)]
//                cell.toggleChannelButton.hidden = false
//                cell.titleLabel.text = channelTitle
//                cell.toggleChannelButton.addTarget(self, action: "toggleChannel:", forControlEvents: .TouchUpInside)
//                cell.toggleChannelButton.selected = true
//                cell.toggleChannelButton.tag = (indexPath.row-2)
//                return cell
//            }
//        } else {
//            let cell: ChannelTitleTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChannelTitleCell", forIndexPath: indexPath) as! ChannelTitleTableViewCell
//            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
//            cell.preservesSuperviewLayoutMargins = false
//            cell.separatorInset = UIEdgeInsetsZero
//            cell.layoutMargins = UIEdgeInsetsZero
//            
//            let name = channelNameArray[indexPath.row]
//            
//            cell.titleLabel.text = name
//            cell.toggleChannelButton.hidden = false
//            cell.toggleChannelButton.addTarget(self, action: "toggleChannel:", forControlEvents: .TouchUpInside)
//            cell.toggleChannelButton.tag = indexPath.row
//            cell.toggleChannelButton.selected = false
//            return cell
//        }
        if indexPath.row == 0 {
            let cell: ChannelTitleTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChannelTitleCell", forIndexPath: indexPath) as! ChannelTitleTableViewCell
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            cell.titleLabel.text = "All Posts"
            cell.toggleChannelButton.hidden = true
            
            return cell
        }
        else {
            let cell: ChannelTitleTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChannelTitleCell", forIndexPath: indexPath) as! ChannelTitleTableViewCell
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            let channelTitle = channelNameArray[(indexPath.row-1)]
            cell.toggleChannelButton.hidden = true
            cell.titleLabel.text = channelTitle
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.section == 0 && indexPath.row == 0 {
//            counter = -2
//            self.performSegueWithIdentifier("segueToFeed", sender: self)
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        } else if indexPath.section == 0 && indexPath.row == 1 {
//            counter = -1
//            self.performSegueWithIdentifier("segueToFeed", sender: self)
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        } else if indexPath.section == 0 {
//            counter = indexPath.row - 2
//            section = indexPath.section
//            self.performSegueWithIdentifier("segueToFeed", sender: self)
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        } else {
//            counter = indexPath.row
//            section = indexPath.section
//            self.performSegueWithIdentifier("segueToFeed", sender: self)
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        }
        if indexPath.row == 0 {
            counter = -2
//            self.performSegueWithIdentifier("segueToFeed", sender: self)
            self.navigationController?.popToRootViewControllerAnimated(true)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            counter = indexPath.row - 1
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
                    customAttributes: ["name": "All Posts"])
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
//                if section == 0 {
//                    let feedVC: FeedViewController = segue.destinationViewController as! FeedViewController
//                    let channelId = myChannelIdArray[counter]
//                    let channelName = myChannelNameArray[counter]
//                    feedVC.fromSpecificChannel = true
//                    feedVC.channelId = channelId
//                    feedVC.channelName = channelName
//                    Answers.logCustomEventWithName("Channel Clicked",
//                        customAttributes: ["name": channelName])
//                } else {
//                    let feedVC: FeedViewController = segue.destinationViewController as! FeedViewController
//                    let channelId = channelIdArray[counter]
//                    let channelName = channelNameArray[counter]
//                    feedVC.fromSpecificChannel = true
//                    feedVC.channelId = channelId
//                    feedVC.channelName = channelName
//                    Answers.logCustomEventWithName("Channel Clicked",
//                        customAttributes: ["name": channelName])
//                }
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
