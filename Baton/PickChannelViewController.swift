//
//  PickChannelViewController.swift
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
import Alamofire
import SwiftyJSON
import Crashlytics

class PickChannelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postButton: UIButton!
    
    var selectedIndexPath = -1
    var channelIdArray = [String]()
    var channelNameArray = [String]()
    let keychain = KeychainSwift()
    var questionText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        postButton.hidden = true
        
        loadChannels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    print("No answers")
                }
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    
                    let id = subJson["_id"].string
                    let name = subJson["name"].string
                    
                    self.channelIdArray.append(id!)
                    self.channelNameArray.append(name!)
                    
                }
                self.tableView.reloadData()
                
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else  {
          return 40
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else {
            let view = UIView()
            view.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.95, alpha:1.0)
            let label = UILabel(frame: CGRectMake(view.frame.origin.x, view.frame.origin.y, 200, 40))
            label.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, view.frame.origin.y + 20)
            label.textAlignment = NSTextAlignment.Center
            label.text = "Pick a channel:"
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
            label.numberOfLines = 0
            view.addSubview(label)
            return view
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return channelIdArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: PickChannelTableViewCell = tableView.dequeueReusableCellWithIdentifier("PickChannelCell", forIndexPath: indexPath) as! PickChannelTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            cell.userInteractionEnabled = false
            cell.titleLabel.text = questionText
            
            return cell
        } else {
            let cell: PickChannelTableViewCell = tableView.dequeueReusableCellWithIdentifier("PickChannelCell", forIndexPath: indexPath) as! PickChannelTableViewCell
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            let name = channelNameArray[indexPath.row]
            cell.titleLabel.text = name
            cell.titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            
        } else {
            postButton.hidden = false
            selectedIndexPath = indexPath.row
        }
    }
    
    
    @IBAction func postButtonPressed(sender: UIButton) {
        
        let channel_id = channelIdArray[selectedIndexPath]
        let channel_name = channelNameArray[selectedIndexPath]
        // Check if JWT is valid before posting question
        var token = keychain.get("JWT")
        
        do {
            if token == nil {
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
                            let newtoken = json["token"].string
                            self.keychain.set(newtoken!, forKey: "JWT")
                            token = newtoken
                            
                            let headers = [
                                "Authorization": "\(token!)"
                            ]
                            let url = globalurl + "api/questions"
                            let parameters = [
                                "content": self.questionText,
                                "creatorname": myUsername,
                                "creator": userid,
                                "answercount": 0,
                                "likes": 0,
                                "channel_id": channel_id,
                                "channel_name": channel_name
                            ]
                            Alamofire.request(.POST, url, parameters: parameters as? [String : AnyObject], headers: headers)
                                .responseJSON { response in
                                    print(response.response?.statusCode)
                                    Answers.logCustomEventWithName("Question submitted",
                                        customAttributes: ["channel": "Top Posts", "username": myUsername])
                                    // Update feed with new question
                                    NSNotificationCenter.defaultCenter().postNotificationName("askedQuestion", object: self)
                                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3])!, animated: true)
                            }
                        }
                        
                        
                }
            } else {
                let jwt = try decode(token!)
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
                                let newtoken = json["token"].string
                                self.keychain.set(newtoken!, forKey: "JWT")
                                token = newtoken
                                
                                let headers = [
                                    "Authorization": "\(token!)"
                                ]
                                let url = globalurl + "api/questions"
                                let parameters = [
                                    "content": self.questionText,
                                    "creatorname": myUsername,
                                    "creator": userid,
                                    "answercount": 0,
                                    "likes": 0,
                                    "channel_id": channel_id,
                                    "channel_name": channel_name
                                ]
                                Alamofire.request(.POST, url, parameters: parameters as? [String : AnyObject], headers: headers)
                                    .responseJSON { response in
                                        print(response.response?.statusCode)
                                        Answers.logCustomEventWithName("Question submitted",
                                            customAttributes: ["channel": "Top Posts", "username": myUsername])
                                        // Update feed with new question
                                        NSNotificationCenter.defaultCenter().postNotificationName("askedQuestion", object: self)
                                        self.navigationController?.popToViewController((self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3])!, animated: true)
                                }
                            }
                            
                            
                    }
                } else {
                    let headers = [
                        "Authorization": "\(token!)"
                    ]
                    
                    let url = globalurl + "api/questions"
                    let parameters = [
                        "content": questionText,
                        "creatorname": myUsername,
                        "creator": userid,
                        "answercount": 0,
                        "likes": 0,
                        "channel_id": channel_id,
                        "channel_name": channel_name
                    ]
                    Alamofire.request(.POST, url, parameters: parameters as? [String : AnyObject], headers: headers)
                        .responseJSON { response in
                            print(response.request)
                            print(response.response)
                            print(response.result)
                            print(response.response?.statusCode)
                            Answers.logCustomEventWithName("Question submitted",
                                customAttributes: ["channel": "Top Posts", "username": myUsername])
                            NSNotificationCenter.defaultCenter().postNotificationName("askedQuestion", object: self)
                            self.navigationController?.popToViewController((self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3])!, animated: true)
                            
                    }
                }
 
            }
        } catch {
            print("Failed to decode JWT: \(error)")
        }
    }
    

}
