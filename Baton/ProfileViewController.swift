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
import KeychainSwift
import JWTDecode
import TwitterKit
import MessageUI
import FBSDKShareKit
import Crashlytics

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    @IBOutlet weak var closeButton: UIButton!
    
    
    // MARK: - Variables
    let keychain = KeychainSwift()
    var myQuestionArray = [Question]()
    var myAnswerArray = [Answer]()
    var myLikedAnswerArray = [Answer]()
    var myFeaturedAnswerArray = [Answer]()
    var followerCount = 0
    var followingCount = 0
    var counter = 0
    var questionIndex = 0
    var profileDescription = ""
    var fromOtherVC = false
    var creatorId = ""
    var id = ""
    var creatorname = ""
    var views = 0
    var ifFollowing = false
    var twitterUsername = ""
    var refreshControl:UIRefreshControl!
    let label = UILabel(frame: CGRectMake(0, 0, 400, 400))
    var noFeaturedAnswers = false
    var noQuestions = false
    var noAnswers = false
    var noLikedAnswers = false
    var fromVideo = false
    var selectedIndexPath = 0
    let interactor = Interactor()
    var mytag = 0
    
    // MARK: - viewWill/viewDid
    override func viewDidDisappear(animated: Bool) {
        for cell in tableView.visibleCells {
            if cell.isKindOfClass(ProfileRelayTableViewCell) {
                let cell = cell as! ProfileRelayTableViewCell
                cell.player.pause()
            } else if cell.isKindOfClass(ProfileLikedTableViewCell) {
                let cell = cell as! ProfileLikedTableViewCell
                cell.player.pause()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.tabBarController != nil {
            self.tabBarController!.tabBar.hidden = false
        }
        
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if fromOtherVC {
            id = self.creatorId
            self.navigationItem.title = creatorname
            self.navigationItem.rightBarButtonItem = nil
            self.loadIfFollowing()
            if fromVideo {
                closeButton.hidden = false
            } else {
                closeButton.hidden = true
                self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem
            }
        } else {
            id = userid
            closeButton.hidden = true
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.title = myUsername
            self.navigationItem.rightBarButtonItem = self.settingsBarButton
            
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70
        self.tableView.scrollsToTop = true
        
        self.loadViewInfo()
        self.loadFollowInfo()
        
        self.myQuestionArray.removeAll(keepCapacity: true)
//        self.loadMyQuestions()
        
        self.myAnswerArray.removeAll(keepCapacity: true)
//        self.loadMyAnswers()
        
        self.myLikedAnswerArray.removeAll(keepCapacity: true)
//        self.loadMyLikedAnswers()
        
        self.myFeaturedAnswerArray.removeAll(keepCapacity: true)
        self.loadMyFeaturedAnswers()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        
        label.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, 300)
        label.textAlignment = NSTextAlignment.Center
        label.text = "No Notifications"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 30)
        label.numberOfLines = 0
        self.tableView.addSubview(label)
        label.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFeed", name: "askedQuestion", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFeed", name: "submittedAnswer", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFeed", name: "questionEdited", object: nil)
    }
    
    // MARK: - load functions
    func loadFollowInfo() {
        
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
                            print("JSON: \(json)")
                            print(json["token"].string)
                            let newtoken = json["token"].string
                            self.keychain.set(newtoken!, forKey: "JWT")
                            token = newtoken
                            
                            let headers = [
                                "Authorization": "\(token!)"
                            ]
                            
                            let url = globalurl + "api/users/" + self.id
                            
                            Alamofire.request(.GET, url, parameters: nil, headers: headers)
                                .responseJSON { response in
                                    var value = response.result.value
                                    
                                    if value == nil {
                                        value = []
                                    } else {
                                        let json = JSON(value!)
                                        print("JSON: \(json)")
                                        var followerCount = json["followerCount"].number?.integerValue
                                        var followingCount = json["followingCount"].number?.integerValue
                                        var bio = json["bio"].string
                                        let twitterUsername = json["twitter_username"].string
                                        
                                        if bio == nil {
                                            bio = ""
                                        }
                                        
                                        if twitterUsername == nil {
                                            
                                        } else {
                                            self.twitterUsername = twitterUsername!
                                        }
                                        
                                        if followerCount == nil {
                                            followerCount = 0
                                        }
                                        
                                        if followingCount == nil {
                                            followingCount = 0
                                        }
                                        
                                        mybio = bio!
                                        self.followerCount = followerCount!
                                        self.followingCount = followingCount!
                                        
                                        self.tableView.reloadData()
                                    }
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
                                print("JSON: \(json)")
                                print(json["token"].string)
                                let newtoken = json["token"].string
                                self.keychain.set(newtoken!, forKey: "JWT")
                                token = newtoken
                                
                                let headers = [
                                    "Authorization": "\(token!)"
                                ]
                                
                                let url = globalurl + "api/users/" + self.id
                                
                                Alamofire.request(.GET, url, parameters: nil, headers: headers)
                                    .responseJSON { response in
                                        var value = response.result.value
                                        
                                        if value == nil {
                                            value = []
                                        } else {
                                            let json = JSON(value!)
                                            print("JSON: \(json)")
                                            var followerCount = json["followerCount"].number?.integerValue
                                            var followingCount = json["followingCount"].number?.integerValue
                                            var bio = json["bio"].string
                                            let twitterUsername = json["twitter_username"].string
                                            
                                            if bio == nil {
                                                bio = ""
                                            }
                                            
                                            if twitterUsername == nil {
                                                
                                            } else {
                                                self.twitterUsername = twitterUsername!
                                            }
                                            
                                            if followerCount == nil {
                                                followerCount = 0
                                            }
                                            
                                            if followingCount == nil {
                                                followingCount = 0
                                            }
                                            
                                            mybio = bio!
                                            self.followerCount = followerCount!
                                            self.followingCount = followingCount!
                                            
                                            self.tableView.reloadData()
                                        }
                                }
                            }
                            
                            
                    }
                } else {
                    let headers = [
                        "Authorization": "\(token!)"
                    ]
                    
                    let url = globalurl + "api/users/" + id
                    
                    Alamofire.request(.GET, url, parameters: nil, headers: headers)
                        .responseJSON { response in
                            var value = response.result.value
                            
                            if value == nil {
                                value = []
                            } else {
                                let json = JSON(value!)
                                print("JSON: \(json)")
                                var followerCount = json["followerCount"].number?.integerValue
                                var followingCount = json["followingCount"].number?.integerValue
                                var bio = json["bio"].string
                                let twitterUsername = json["twitter_username"].string
                                
                                if bio == nil {
                                    bio = ""
                                }
                                
                                if twitterUsername == nil {
                                    
                                } else {
                                    self.twitterUsername = twitterUsername!
                                }
                                
                                if followerCount == nil {
                                    followerCount = 0
                                }
                                
                                if followingCount == nil {
                                    followingCount = 0
                                }
                                
                                mybio = bio!
                                self.followerCount = followerCount!
                                self.followingCount = followingCount!
                                
                                self.tableView.reloadData()
                            }
                    }
                }
            }
            
        } catch {
            print("Failed to decode JWT: \(error)")
        }
    }
    
    // Check if current user is following this user
    func loadIfFollowing() {
        let url = globalurl + "api/user/" + userid + "/follows/" + id
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                let result = response.result.value
                print(result)
                if result == nil {
                    print("Not Following")
                    self.ifFollowing = false
                    let section = NSIndexSet.init(index: 0)
                    self.tableView.reloadSections(section, withRowAnimation: .None)
                } else {
                    print("Already Following")
                    self.ifFollowing = true
                    let section = NSIndexSet.init(index: 0)
                    self.tableView.reloadSections(section, withRowAnimation: .None)
                }
        }
    }
    
    // Find cumulative views of user
    func loadViewInfo() {
        let url = globalurl + "api/users/" + id + "/views"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                }
                let json = JSON(value!)
                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    var views = subJson["total"].number?.integerValue
                    
                    if views == nil {
                        views = 0
                    }
                    
                    self.views = views!
                    
                    let section = NSIndexSet.init(index: 0)
                    self.tableView.reloadSections(section, withRowAnimation: .None)
                }
        }
    }
    
    func loadMyQuestions() {
        
        let url = globalurl + "api/myquestions/" + id
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                    self.noQuestions = true
                    if self.counter == 1 {
                        self.label.text = "No posts"
                        self.label.hidden = false
                    }
                } else {
                    let json = JSON(value!)
                    print("JSON: \(json)")
                    for (_,subJson):(String, JSON) in json {
                        //Do something you want
                        if self.counter == 1{
                           self.label.hidden = true
                        }
                        
                        self.noQuestions = false
                        let content = subJson["content"].string
                        let id = subJson["_id"].string
                        var answercount = subJson["answercount"].number?.integerValue
                        let creatorname = subJson["creatorname"].string
                        let creator = subJson["creator"].string
                        let createdAt = subJson["created_at"].string
                        var likecount = subJson["likes"].number?.integerValue
                        var channelId = subJson["channel_id"].string
                        var channelName = subJson["channel_name"].string
                        
                        if channelId == nil {
                            channelId = ""
                        }
                        
                        if channelName == nil {
                            channelName = ""
                        }
                        
                        if likecount == nil {
                            likecount = 0
                        }
                        
                        let dateFor: NSDateFormatter = NSDateFormatter()
                        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
                        
                        if answercount == nil {
                            answercount = 0
                        }
                        
                        var thumbnail_url = subJson["thumbnail_url"].string
                        if thumbnail_url == nil {
                            thumbnail_url = ""
                        }
                        
                        let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: false, currentuser: false, createdAt: yourDate, creator: creator, likecount: likecount, channel_id: channelId, channel_name: channelName, thumbnail_url: thumbnail_url)
                        self.myQuestionArray.append(question)
//                        self.tableView.reloadData()
                    }
                    let section = NSIndexSet.init(index: 2)
                    self.tableView.reloadSections(section, withRowAnimation: .None)
                }
                
            }
    }
    
    func loadMyAnswers() {
        
        let url = globalurl + "api/users/" + id + "/answers/"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                    self.noAnswers = true
                    if self.counter == 2{
                        self.label.text = "No relays"
                        self.label.hidden = false
                    }
                    
                } else {
                    let json = JSON(value!)
                    print("JSON: \(json)")
                    for (_,subJson):(String, JSON) in json {
                        //Do something you want
                        if self.counter == 2 {
                            self.label.hidden = true
                        }
                        self.noAnswers = false
                        var content = subJson["content"].string
                        let id = subJson["_id"].string
                        let creator = subJson["creator"].string
                        let creatorname = subJson["creatorname"].string
                        let question_id = subJson["question_id"].string
                        let video_url = subJson["video_url"].string
                        var likeCount = subJson["likes"].int
                        var frontCamera = subJson["frontCamera"].bool
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
                        
                        if frontCamera == nil {
                            frontCamera = false
                        }
                        
                        if content == nil {
                            content = ""
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
                            
                            if question_content == "" {
                                
//                                let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: question_content, video_url: video_url, likeCount: likeCount, liked_by_user: false, frontCamera: frontCamera, createdAt: yourDate, views: views, featuredQuestion: featuredQuestion)
//                                self.myAnswerArray.append(answer)
//                                self.myAnswerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
//                                self.tableView.reloadData()
                                
                                let url = globalurl + "api/questions/" + question_id!
                                
                                Alamofire.request(.GET, url, parameters: nil)
                                    .responseJSON { response in
                                        var value = response.result.value
                                        
                                        if value == nil {
                                            value = []
                                        }
                                        
                                        
                                        let json = JSON(value!)
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
                                        self.myAnswerArray.append(answer)
                                        self.myAnswerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
//                                        self.tableView.reloadData()


                                        
                                }
                            } else {
                                let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: question_content, video_url: video_url, likeCount: likeCount, liked_by_user: "not checked", frontCamera: frontCamera, createdAt: yourDate, views: views, featuredQuestion: featuredQuestion, followingCreator: "not checked", thumbnail_url: thumbnail_url, vertical_screen: vertical_screen)
                                self.myAnswerArray.append(answer)
                                self.myAnswerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                
//                                self.tableView.reloadData()

                            }
                        }

                    }
                    let section = NSIndexSet.init(index: 2)
                    self.tableView.reloadSections(section, withRowAnimation: .None)
//                    self.tableView.reloadData()
                }
                
            }
    }
    
    func loadMyFeaturedAnswers() {
        
        let url = globalurl + "api/users/" + id + "/featuredanswers/"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                    self.noFeaturedAnswers = true
                    if self.counter == 0 {
                        self.label.text = "No featured relays"
                        self.label.hidden = false
                    }
                } else {
                    let json = JSON(value!)
                    print("JSON: \(json)")
                    for (_,subJson):(String, JSON) in json {
                        //Do something you want
                        if self.counter == 0 {
                            self.label.hidden = true
                        }
                        self.noFeaturedAnswers = false
                        var content = subJson["content"].string
                        let id = subJson["_id"].string
                        let creator = subJson["creator"].string
                        let creatorname = subJson["creatorname"].string
                        let question_id = subJson["question_id"].string
                        let video_url = subJson["video_url"].string
                        var likeCount = subJson["likes"].int
                        var frontCamera = subJson["frontCamera"].bool
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
                        
                        if frontCamera == nil {
                            frontCamera = false
                        }
                        
                        if content == nil {
                            content = ""
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
                                        self.myFeaturedAnswerArray.append(answer)
                                        self.myFeaturedAnswerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
//                                        self.tableView.reloadData()
                                        
                                        
                                        
                                }
                            } else {
                                let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: question_content, video_url: video_url, likeCount: likeCount, liked_by_user: "not checked", frontCamera: frontCamera, createdAt: yourDate, views: views, featuredQuestion: featuredQuestion, followingCreator: "not checked", thumbnail_url: thumbnail_url, vertical_screen: vertical_screen)
                                self.myFeaturedAnswerArray.append(answer)
                                self.myFeaturedAnswerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                
//                                self.tableView.reloadData()
                                
                            }
                        }
                    }
                    let section = NSIndexSet.init(index: 2)
                    self.tableView.reloadSections(section, withRowAnimation: .None)
                }
                
            }
    }
    
    func loadMyLikedAnswers() {
        
        let url = globalurl + "api/users/" + id + "/mylikedanswers/"
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                print("myLikedAnswer")
                if value == nil {
                    value = []
                    self.noLikedAnswers = true
                    if self.counter == 3 {
                        self.label.text = "No likes"
                        self.label.hidden = false
                    }
                    
                } else {
                    let json = JSON(value!)
//                    print("JSON: \(json)")
                    print("Get count of json objects \(json.count)")
                    for (_,subJson):(String, JSON) in json {
                        //Do something you want
                        if self.counter == 3 {
                            self.label.hidden = true
                        }
                       
                        self.noLikedAnswers = false
                        var content = subJson["content"].string
                        let id = subJson["_id"].string
                        let creator = subJson["creator"].string
                        let creatorname = subJson["creatorname"].string
                        let question_id = subJson["question_id"].string
                        let video_url = subJson["video_url"].string
                        var likeCount = subJson["likes"].int
                        var frontCamera = subJson["frontCamera"].bool
                        let createdAt = subJson["created_at"].string
                        let dateFor: NSDateFormatter = NSDateFormatter()
                        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
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
                        
                        if frontCamera == nil {
                            frontCamera = false
                        }
                        
                        if content == nil {
                            content = ""
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
                            
                            if question_content == "" {
//                                let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: content, video_url: video_url, likeCount: likeCount, liked_by_user: "true", frontCamera: frontCamera, createdAt: yourDate, views: views, featuredQuestion: featuredQuestion, followingCreator: "not checked")
//                                self.myLikedAnswerArray.append(answer)
//                                self.myLikedAnswerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                //                                        self.tableView.reloadData()
//                                let section = NSIndexSet.init(index: 2)
//                                self.tableView.reloadSections(section, withRowAnimation: .None)
                                
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
                                        
                                        let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: content, video_url: video_url, likeCount: likeCount, liked_by_user: "true", frontCamera: frontCamera, createdAt: yourDate, views: views, featuredQuestion: featuredQuestion, followingCreator: "not checked", thumbnail_url: thumbnail_url, vertical_screen: vertical_screen)
                                        self.myLikedAnswerArray.append(answer)
                                        self.myLikedAnswerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
//                                        self.tableView.reloadData()
//                                        let section = NSIndexSet.init(index: 2)
//                                        self.tableView.reloadSections(section, withRowAnimation: .None)
                                        
                                
                                }
                            } else {
                                let answer = Answer(content: "", creator: creator, creatorname: creatorname, id: id, question_id: question_id, question_content: question_content, video_url: video_url, likeCount: likeCount, liked_by_user: "true", frontCamera: frontCamera, createdAt: yourDate, views: views, featuredQuestion: featuredQuestion, followingCreator: "not checked", thumbnail_url: thumbnail_url, vertical_screen: vertical_screen)
                                self.myLikedAnswerArray.append(answer)
                                self.myLikedAnswerArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                
//                                self.tableView.reloadData()
//                                let section = NSIndexSet.init(index: 2)
//                                self.tableView.reloadSections(section, withRowAnimation: .None)
                            }
                        }
                        
                    }
                    let section = NSIndexSet.init(index: 2)
                    self.tableView.reloadSections(section, withRowAnimation: .None)
                }
                
                
        }
    }
    
    // MARK: - refreshControl
    func refreshFeed() {
        self.myQuestionArray.removeAll(keepCapacity: true)
        self.myAnswerArray.removeAll(keepCapacity: true)
        self.myLikedAnswerArray.removeAll(keepCapacity: true)
        self.myFeaturedAnswerArray.removeAll(keepCapacity: true)
        
        self.loadMyFeaturedAnswers()
        self.loadViewInfo()
        self.loadFollowInfo()
        self.loadMyQuestions()
        self.loadMyAnswers()
        self.loadMyLikedAnswers()
        
        self.tableView.reloadData()
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        self.myQuestionArray.removeAll(keepCapacity: true)
        self.myAnswerArray.removeAll(keepCapacity: true)
        self.myLikedAnswerArray.removeAll(keepCapacity: true)
        self.myFeaturedAnswerArray.removeAll(keepCapacity: true)
        
        self.loadMyFeaturedAnswers()
        self.loadViewInfo()
        self.loadFollowInfo()
        self.loadMyQuestions()
        self.loadMyAnswers()
        self.loadMyLikedAnswers()
        
        self.tableView.reloadData()
        
        let delayInSeconds = 1.0;
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            self.refreshControl!.endRefreshing()
        }
    }
    
    // MARK: - tableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            if counter == 0 {
                if myFeaturedAnswerArray.count == 0 {
                    return 0
                } else {
                    label.hidden = true
                    return myFeaturedAnswerArray.count
                }
            } else if counter == 1 {
                if myQuestionArray.count == 0 {
                    return 0
                } else {
                    label.hidden = true
                    return myQuestionArray.count
                }
            } else if counter == 2 {
                if myAnswerArray.count == 0 {
                    return 0
                } else {
                    label.hidden = true
                    return myAnswerArray.count
                }
            } else {
                if myLikedAnswerArray.count == 0 {
                    return 0
                } else {
                    label.hidden = true
                    return myLikedAnswerArray.count
                }
            }
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Section for profile information
        if indexPath.section == 0 {
            let cell: ProfileTableViewCell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as! ProfileTableViewCell
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.profileButton.layer.borderWidth = 1
            
            
            if fromOtherVC {
                if id == userid {
                    cell.profileButton.setTitle("EDIT PROFILE", forState: .Normal)
                    cell.profileButton.backgroundColor = UIColor.clearColor()
                    cell.profileButton.layer.borderColor = UIColor.blueColor().CGColor
                } else {
                    cell.profileButton.setTitle("FOLLOW", forState: .Normal)
                    cell.profileButton.setTitle("FOLLOWING", forState: .Selected)
                    cell.profileButton.setTitleColor(UIColor.whiteColor(), forState: .Selected)
                    
                    cell.profileButton.selected = false
                    
                    if self.ifFollowing == true {
                        cell.profileButton.selected = true
                        cell.profileButton.backgroundColor = UIColor(red:0.39, green:0.91, blue:0.61, alpha:1.0)
                        cell.profileButton.layer.borderColor = UIColor(red:0.39, green:0.91, blue:0.61, alpha:1.0).CGColor
                    } else {
                        cell.profileButton.selected = false
                        cell.profileButton.layer.borderColor = UIColor.blueColor().CGColor
                        cell.profileButton.backgroundColor = UIColor.clearColor()
                    }
                }
            } else {
                cell.profileButton.layer.borderColor = UIColor.blueColor().CGColor
                cell.profileButton.backgroundColor = UIColor.clearColor()
            }
            
            
            cell.profileButton.addTarget(self, action: "toggleProfileButton:", forControlEvents: .TouchUpInside)
            
            if mybio == "" {
                cell.twitterTopSpaceToBioConstraint.constant = -20
                cell.profileDescriptionLabel.hidden = true
            } else {
                cell.twitterTopSpaceToBioConstraint.constant = 10
                cell.profileDescriptionLabel.hidden = false
                cell.profileDescriptionLabel.text = mybio
            }
            
            if twitterUsername == "" {
                cell.twitterButton.hidden = true
                cell.twitterButtonHeightConstant.constant = 0
            } else {
                cell.twitterButton.hidden = false
                cell.twitterButtonHeightConstant.constant = 22
                cell.twitterButton.addTarget(self, action: "twitterButtonPressed:", forControlEvents: .TouchUpInside)
            }
            let myFollowerCount = self.followerCount.abbreviateNumber()
//            let myFollowerCount = (10100).abbreviateNumber()
            cell.followersButton.titleLabel?.textAlignment = .Center
            let stringFollowers = "\(myFollowerCount)\nfollowers"
            print(stringFollowers)
            if let range = stringFollowers.rangeOfString("followers") {
                print(range)
                print(stringFollowers.startIndex..<range.startIndex)
                let firstPart = stringFollowers[stringFollowers.startIndex..<range.startIndex]
                print(firstPart) // print Hello
                let index: Int = stringFollowers.startIndex.distanceTo(range.startIndex)
                let myMutableString = NSMutableAttributedString(string: stringFollowers, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 13.0)!])
                myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 13.0)!, range: NSRange(location: index, length: 9))
                cell.followersButton.titleLabel?.textColor = UIColor.blackColor()
                cell.followersButton.setAttributedTitle(myMutableString, forState: .Normal)
            }
            
            let myFollowingCount = self.followingCount.abbreviateNumber()
            cell.followingButton.titleLabel?.textAlignment = .Center
            let stringFollowing = "\(myFollowingCount)\nfollowing"
            print(stringFollowing)
            if let range = stringFollowing.rangeOfString("following") {
                print(range)
                print(stringFollowing.startIndex..<range.startIndex)
                let firstPart = stringFollowing[stringFollowing.startIndex..<range.startIndex]
                print(firstPart) // print Hello
                let index: Int = stringFollowing.startIndex.distanceTo(range.startIndex)
                let myMutableString = NSMutableAttributedString(string: stringFollowing, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 13.0)!])
                myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 13.0)!, range: NSRange(location: index, length: 9))
                cell.followingButton.titleLabel?.textColor = UIColor.blackColor()
                cell.followingButton.setAttributedTitle(myMutableString, forState: .Normal)
            }
            
            
            let profileviews = self.views.abbreviateNumber()
            
            cell.viewButton.titleLabel?.textAlignment = .Center
            let postedText = "\(profileviews)\n"
            let myFirstString = NSMutableAttributedString(string: postedText, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 13.0)!])
            
            let creatornameText = "views"
            let mySecondString = NSMutableAttributedString(string: creatornameText, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 13.0)!])
            
            let result = NSMutableAttributedString()
            result.appendAttributedString(myFirstString)
            result.appendAttributedString(mySecondString)
            
            cell.viewButton.titleLabel?.textColor = UIColor.blackColor()
            cell.viewButton.setAttributedTitle(result, forState: .Normal)

            
            cell.profileImageView.image = UIImage(named: "Placeholder")
            if let cachedImageResult = imageCache[id] {
                print("pull from cache")
                cell.profileImageView.image = UIImage(data: cachedImageResult!)
            } else {
                cell.profileImageView.image = UIImage(named: "Placeholder")
                
                let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp-download")
                let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                
                let key = "profilePics/" + id
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
                        imageCache[self.id] = imageData
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
        // Section for the profile buttons to switch between answers, posts, likes
        else if indexPath.section == 1 {
            let cell: ProfileButtonsTableViewCell = tableView.dequeueReusableCellWithIdentifier("profileButtonsCell", forIndexPath: indexPath) as! ProfileButtonsTableViewCell
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            cell.personalButton.addTarget(self, action: "toggleButton:", forControlEvents: .TouchUpInside)
            cell.pencilButton.addTarget(self, action: "toggleButton:", forControlEvents: .TouchUpInside)
            cell.recorderButton.addTarget(self, action: "toggleButton:", forControlEvents: .TouchUpInside)
            cell.heartButton.addTarget(self, action: "toggleButton:", forControlEvents: .TouchUpInside)
            
            cell.personalButton.tag = 0
            cell.pencilButton.tag = 1
            cell.recorderButton.tag = 2
            cell.heartButton.tag = 3
            
            if counter == 0 {
                cell.personalButton.selected = true
                cell.pencilButton.selected = false
                cell.recorderButton.selected = false
                cell.heartButton.selected = false
            } else if counter == 1 {
                cell.personalButton.selected = false
                cell.pencilButton.selected = true
                cell.recorderButton.selected = false
                cell.heartButton.selected = false
            } else if counter == 2 {
                cell.personalButton.selected = false
                cell.pencilButton.selected = false
                cell.recorderButton.selected = true
                cell.heartButton.selected = false
            } else if counter == 3 {
                cell.personalButton.selected = false
                cell.pencilButton.selected = false
                cell.recorderButton.selected = false
                cell.heartButton.selected = true
            }
            
            return cell

        }
        // Sections for the user's featured answers
        if counter == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("likePreviewCell", forIndexPath: indexPath) as! FeaturedPreviewTableViewCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            let creator = myFeaturedAnswerArray[indexPath.row].creator
            
            let date = myFeaturedAnswerArray[indexPath.row].createdAt
            let timeAgo = timeAgoSinceDate(date, numericDates: true)
            
            
            let views = myFeaturedAnswerArray[indexPath.row].views
            let abbrevViews = views.addCommas(views)
            cell.viewCountLabel.text = "\(abbrevViews) views"
            
            
            cell.nameLabel.text = myFeaturedAnswerArray[indexPath.row].creatorname
            let likeCount = self.myFeaturedAnswerArray[indexPath.row].likeCount
            let abbrevLikeCount = likeCount.addCommas(likeCount)
            cell.likeCountLabel.text = "\(abbrevLikeCount) likes"
            cell.usernameButton.hidden = true
            
            let question_content = myFeaturedAnswerArray[indexPath.row].question_content
            cell.questionContentLabel.text = question_content
            
            
            return cell

//            let cell: ProfileRelayTableViewCell = tableView.dequeueReusableCellWithIdentifier("RelayCell", forIndexPath: indexPath) as! ProfileRelayTableViewCell
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
//            
//            cell.preservesSuperviewLayoutMargins = false
//            cell.separatorInset = UIEdgeInsetsZero
//            cell.layoutMargins = UIEdgeInsetsZero
//            
//            let date = myFeaturedAnswerArray[indexPath.row].createdAt
//            let timeAgo = timeAgoSinceDate(date, numericDates: true)
//            
//            cell.timeAgoLabel.text = timeAgo
//            
//            print(myFeaturedAnswerArray[indexPath.row].question_content)
//            cell.contentTextView.text = myFeaturedAnswerArray[indexPath.row].question_content
//            cell.contentTextView.userInteractionEnabled = false
            
//            let videoUrl = myFeaturedAnswerArray[indexPath.row].video_url
//            let newURL = NSURL(string: videoUrl)
//            cell.player = AVPlayer(URL: newURL!)
//            cell.playerController.player = cell.player
//            cell.player.pause()
            
//            let frontCamera = myFeaturedAnswerArray[indexPath.row].frontCamera
//            
//            print(frontCamera)
//            if frontCamera == true {
//                cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
//            }
//            if CGAffineTransformIsIdentity(cell.playerController.view.transform) {
//                if frontCamera {
//                    cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
//                }
//            } else {
//                if frontCamera {
//                    
//                } else {
//                    cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
//                }
//            }
//            cell.videoView.addSubview(cell.playerController.view)
            
            
//            if indexPath.row == 0 {
//                
//                let url = globalurl + "api/answers/" + myFeaturedAnswerArray[indexPath.row].id + "/viewed/"
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
//            }
            
//            cell.questionContentButton.addTarget(self, action: "questionContentPressed:", forControlEvents: .TouchUpInside)
//            cell.questionContentButton.tag = indexPath.row
//            
//            cell.playerController.view.userInteractionEnabled = true
//            
//            let view = UIView(frame: cell.playerController.view.frame)
//            cell.videoView.addSubview(view)
//            
//            let tapGesture = UITapGestureRecognizer(target: self, action: "singleTapped:")
//            view.addGestureRecognizer(tapGesture)
//            view.tag = indexPath.row
//            
//            cell.likeImageView.image = UIImage(named: "playImage")
//            cell.likeImageView.hidden = false
//            cell.likeImageView.alpha = 0.7
//            cell.likeImageView.contentMode = UIViewContentMode.ScaleAspectFill
//            cell.videoView.bringSubviewToFront(cell.likeImageView)
//            
//            let doubleTapGesture = UITapGestureRecognizer()
//            doubleTapGesture.numberOfTapsRequired = 2
//            doubleTapGesture.addTarget(self, action: "doubleTapped:")
//            view.addGestureRecognizer(doubleTapGesture)
//            
//            let likeCount = self.myFeaturedAnswerArray[indexPath.row].likeCount
//            print(likeCount)
//            let abbrevLikeCount = likeCount.addCommas(likeCount)
//            cell.likeCountTextView.text = "\(abbrevLikeCount) likes"
//            cell.videoView.bringSubviewToFront(cell.likeCountTextView)
//            cell.videoView.bringSubviewToFront(cell.heartImageView)
//            
//            let views = myFeaturedAnswerArray[indexPath.row].views
//            let abbrevViews = views.addCommas(views)
//            cell.viewCountLabel.text = "\(abbrevViews) views"
//            
//            cell.likeButton.tag = indexPath.row
//            cell.likeButton.addTarget(self, action: "toggleLike:", forControlEvents: .TouchUpInside)
//            cell.videoView.bringSubviewToFront(cell.likeButton)
//            
//            cell.extraButton.tag = indexPath.row
//            cell.extraButton.addTarget(self, action: "extraButtonTapped:", forControlEvents: .TouchUpInside)
            
//            let liked_by_user = self.myFeaturedAnswerArray[indexPath.row].liked_by_user
            
//            if liked_by_user == "true" {
//                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                cell.heartImageView.image = UIImage(named: "redHeartOutline")
//            } else if liked_by_user == "not checked"{
//                let url = globalurl + "api/answers/" + myFeaturedAnswerArray[indexPath.row].id + "/likecheck/" + userid
//                
//                Alamofire.request(.GET, url, parameters: nil)
//                    .responseJSON { response in
//                        let result = response.result.value
//                        print(result)
//                        if result == nil {
//                            print("Gobi")
//                            cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
//                            cell.heartImageView.image = UIImage(named: "grayHeartOutline")
//                            self.myFeaturedAnswerArray[indexPath.row].liked_by_user = "false"
//                        } else {
//                            print("Liked")
//                            cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                            cell.heartImageView.image = UIImage(named: "redHeartOutline")
//                            self.myFeaturedAnswerArray[indexPath.row].liked_by_user = "true"
//                        }
//                }
//            } else if liked_by_user == "false" {
//                cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
//                cell.heartImageView.image = UIImage(named: "grayHeartOutline")
//            }
            
//            return cell
            
        } else if counter == 1 {
            let cell: ProfileQuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("profileQuestionCell", forIndexPath: indexPath) as! ProfileQuestionTableViewCell
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            let date = myQuestionArray[indexPath.row].createdAt
            let timeAgo = timeAgoSinceDate(date, numericDates: true)
            
            cell.timeAgoLabel.text = timeAgo
            
            cell.questionTextView.text = myQuestionArray[indexPath.row].content
            cell.questionTextView.userInteractionEnabled = false
            let answerCount = myQuestionArray[indexPath.row].answercount
            cell.answercountLabel.text = "\(answerCount)"
            
            let likecount = myQuestionArray[indexPath.row].likecount
            let formattedlikecount = likecount.abbreviateNumberAtThousand()
            cell.likeCountLabel.text = "\(formattedlikecount)"
//            cell.likeCountTextView.editable = false
//            cell.likeCountTextView.selectable = false
            
            var channelName = myQuestionArray[indexPath.row].channel_name
            if channelName == "" {
                channelName = "Other"
            } else {
                cell.channelButton.addTarget(self, action: "goToChannel:", forControlEvents: .TouchUpInside)
            }
            
            cell.channelButton.hidden = false
            cell.channelButton.setTitle(channelName, forState: .Normal)
            cell.channelButton.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
            cell.channelButton.layer.cornerRadius = 5
            cell.channelButton.sizeToFit()
            cell.channelButton.tag = indexPath.row
            
            
            return cell
        }
        // Section for the user's videos
        else if counter == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("likePreviewCell", forIndexPath: indexPath) as! FeaturedPreviewTableViewCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            let creator = myAnswerArray[indexPath.row].creator
            
            let date = myAnswerArray[indexPath.row].createdAt
            let timeAgo = timeAgoSinceDate(date, numericDates: true)
            
            
            let views = myAnswerArray[indexPath.row].views
            let abbrevViews = views.addCommas(views)
            cell.viewCountLabel.text = "\(abbrevViews) views"
            
            
            cell.nameLabel.text = myAnswerArray[indexPath.row].creatorname
            let likeCount = self.myAnswerArray[indexPath.row].likeCount
            let abbrevLikeCount = likeCount.addCommas(likeCount)
            cell.likeCountLabel.text = "\(abbrevLikeCount) likes"
            cell.usernameButton.hidden = true
            
            let question_content = myAnswerArray[indexPath.row].question_content
            cell.questionContentLabel.text = question_content
            
            
            return cell
//            let cell: ProfileRelayTableViewCell = tableView.dequeueReusableCellWithIdentifier("RelayCell", forIndexPath: indexPath) as! ProfileRelayTableViewCell
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
//            
//            cell.preservesSuperviewLayoutMargins = false
//            cell.separatorInset = UIEdgeInsetsZero
//            cell.layoutMargins = UIEdgeInsetsZero
//            
//            let date = myAnswerArray[indexPath.row].createdAt
//            let timeAgo = timeAgoSinceDate(date, numericDates: true)
//            
//            cell.timeAgoLabel.text = timeAgo
//            
//            cell.contentTextView.text = myAnswerArray[indexPath.row].question_content
//            cell.contentTextView.userInteractionEnabled = false
           
//            let videoUrl = myAnswerArray[indexPath.row].video_url
//            let newURL = NSURL(string: videoUrl)
//            cell.player = AVPlayer(URL: newURL!)
//            cell.playerController.player = cell.player
//            cell.player.pause()
            
//            let frontCamera = myAnswerArray[indexPath.row].frontCamera
            
//            if frontCamera == true {
//                cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
//            }
//            if CGAffineTransformIsIdentity(cell.playerController.view.transform) {
//                if frontCamera {
//                    cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
//                }
//            } else {
//                if frontCamera {
//                    
//                } else {
//                    cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
//                }
//            }
//            cell.videoView.addSubview(cell.playerController.view)
            
            
//            if indexPath.row == 0 {
//                
//                let url = globalurl + "api/answers/" + myAnswerArray[indexPath.row].id + "/viewed/"
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
//            }
            
//            cell.questionContentButton.addTarget(self, action: "questionContentPressed:", forControlEvents: .TouchUpInside)
//            cell.questionContentButton.tag = indexPath.row
//            
//            cell.playerController.view.userInteractionEnabled = true
//            
//            let view = UIView(frame: cell.playerController.view.frame)
//            cell.videoView.addSubview(view)
//            
//            let tapGesture = UITapGestureRecognizer(target: self, action: "singleTapped:")
//            view.addGestureRecognizer(tapGesture)
//            view.tag = indexPath.row
//            
//            cell.likeImageView.image = UIImage(named: "playImage")
//            cell.likeImageView.hidden = false
//            cell.likeImageView.alpha = 0.7
//            cell.likeImageView.contentMode = UIViewContentMode.ScaleAspectFill
//            cell.videoView.bringSubviewToFront(cell.likeImageView)
//            
//            let doubleTapGesture = UITapGestureRecognizer()
//            doubleTapGesture.numberOfTapsRequired = 2
//            doubleTapGesture.addTarget(self, action: "doubleTapped:")
//            view.addGestureRecognizer(doubleTapGesture)
            
//            let likeCount = self.myAnswerArray[indexPath.row].likeCount
//            print(likeCount)
//            cell.likeCountTextView.text = "\(likeCount) likes"
//            cell.videoView.bringSubviewToFront(cell.likeCountTextView)
//            cell.videoView.bringSubviewToFront(cell.heartImageView)
//            
//            let views = myAnswerArray[indexPath.row].views
//            let abbrevViews = views.addCommas(views)
//            cell.viewCountLabel.text = "\(abbrevViews) views"
//            
//            cell.likeButton.tag = indexPath.row
//            cell.likeButton.addTarget(self, action: "toggleLike:", forControlEvents: .TouchUpInside)
//            cell.videoView.bringSubviewToFront(cell.likeButton)
//            
//            cell.extraButton.tag = indexPath.row
//            cell.extraButton.addTarget(self, action: "extraButtonTapped:", forControlEvents: .TouchUpInside)
            
//            let liked_by_user = self.myAnswerArray[indexPath.row].liked_by_user
//            
//            if liked_by_user == true {
//                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                cell.heartImageView.image = UIImage(named: "redHeartOutline")
//            } else {
//                let url = globalurl + "api/answers/" + myAnswerArray[indexPath.row].id + "/likecheck/" + userid
//                
//                Alamofire.request(.GET, url, parameters: nil)
//                    .responseJSON { response in
//                        let result = response.result.value
//                        print(result)
//                        if result == nil {
//                            print("Gobi")
//                            cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
//                            cell.heartImageView.image = UIImage(named: "grayHeartOutline")
//                        } else {
//                            print("Liked")
//                            cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                            cell.heartImageView.image = UIImage(named: "redHeartOutline")
//                            self.myAnswerArray[indexPath.row].liked_by_user = true
//                        }
//                }
//            }
            
            return cell
            
        }
        // Section with the liked videos
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("likePreviewCell", forIndexPath: indexPath) as! FeaturedPreviewTableViewCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            let creator = myLikedAnswerArray[indexPath.row].creator
            
            let date = myLikedAnswerArray[indexPath.row].createdAt
            let timeAgo = timeAgoSinceDate(date, numericDates: true)
            
            
            let views = myLikedAnswerArray[indexPath.row].views
            let abbrevViews = views.addCommas(views)
            cell.viewCountLabel.text = "\(abbrevViews) views"
            
            
            cell.nameLabel.text = myLikedAnswerArray[indexPath.row].creatorname
            let likeCount = self.myLikedAnswerArray[indexPath.row].likeCount
            let abbrevLikeCount = likeCount.addCommas(likeCount)
            cell.likeCountLabel.text = "\(abbrevLikeCount) likes"
            cell.usernameButton.hidden = false
            cell.usernameButton.addTarget(self, action: "usernameTapped:", forControlEvents: .TouchUpInside)
            cell.usernameButton.tag = indexPath.row
            cell.contentView.bringSubviewToFront(cell.usernameButton)
            
            let question_content = myLikedAnswerArray[indexPath.row].question_content
            cell.questionContentLabel.text = question_content
            
            
            return cell
//            let cell: ProfileLikedTableViewCell = tableView.dequeueReusableCellWithIdentifier("profileLikedCell", forIndexPath: indexPath) as! ProfileLikedTableViewCell
//            
//            cell.preservesSuperviewLayoutMargins = false
//            cell.separatorInset = UIEdgeInsetsZero
//            cell.layoutMargins = UIEdgeInsetsZero
//            
//            var question_content = myLikedAnswerArray[indexPath.row].question_content
//            let question_id = myLikedAnswerArray[indexPath.row].question_id
//            
//            let creatorname = myLikedAnswerArray[indexPath.row].creatorname
//            
//            let postedText = "\(creatorname)"
//            let myFirstString = NSMutableAttributedString(string: postedText, attributes: [NSForegroundColorAttributeName:UIColor.blackColor(), NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 12.0)!])
//            
//            let creatornameText = " relayed:"
//            let mySecondString = NSMutableAttributedString(string: creatornameText, attributes: [NSForegroundColorAttributeName:UIColor.blackColor(), NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 12.0)!])
//            
//            let result = NSMutableAttributedString()
//            result.appendAttributedString(myFirstString)
//            result.appendAttributedString(mySecondString)
//            
//            cell.usernameButton.setAttributedTitle(result, forState: .Normal)
//            cell.usernameButton.tag = indexPath.row
            
//            let creator = myLikedAnswerArray[indexPath.row].creator
//            cell.profileImageView.image = UIImage(named: "Placeholder")
//            if let cachedImageResult = imageCache[creator] {
//                print("pull from cache")
//                cell.profileImageView.image = UIImage(data: cachedImageResult!)
//            } else {
//                cell.profileImageView.image = UIImage(named: "Placeholder")
//                
//                let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp-download")
//                let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
//                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
//                
//                
//                let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
//                readRequest1.bucket = S3BucketName
//                readRequest1.key =  creator
//                readRequest1.downloadingFileURL = downloadingFileURL1
//                
//                let task = transferManager.download(readRequest1)
//                task.continueWithBlock { (task) -> AnyObject! in
//                    if task.error != nil {
//                        print("No Profile Pic")
//                    } else {
//                        let image = UIImage(contentsOfFile: downloadingFilePath1)
//                        let imageData = UIImageJPEGRepresentation(image!, 1.0)
//                        imageCache[creator] = imageData
//                        dispatch_async(dispatch_get_main_queue()
//                            , { () -> Void in
//                                cell.profileImageView.image = UIImage(contentsOfFile: downloadingFilePath1)
//                                cell.setNeedsLayout()
//                                
//                        })
//                        print("Fetched image")
//                    }
//                    return nil
//                }
//            }
//            
//            
//            
//            if question_content == "" {
//                let url = globalurl + "api/questions/" + question_id
//                
//                Alamofire.request(.GET, url, parameters: nil)
//                    .responseJSON { response in
//                        let json = JSON(response.result.value!)
//                        print("JSON: \(json)")
//                        if json == [] {
//                            print("No answers")
//                        }
//                        let content = json["content"].string
//                        print(content)
//                        question_content = content!
//                        self.myLikedAnswerArray[indexPath.row].question_content = question_content
//                        cell.questionContentTextView.text = question_content
//                        cell.questionContentTextView.editable = false
//                        cell.questionContentTextView.selectable = false
//                }
//            } else {
//                cell.questionContentTextView.text = question_content
//                cell.questionContentTextView.editable = false
//                cell.questionContentTextView.selectable = false
//            }
            
//            cell.questionContentTextView.text = question_content
//            cell.questionContentTextView.editable = false
//            cell.questionContentTextView.selectable = false
//            
//            cell.questionContentButton.addTarget(self, action: "questionContentPressed:", forControlEvents: .TouchUpInside)
//            cell.contentView.bringSubviewToFront(cell.questionContentButton)
//            cell.questionContentButton.tag = indexPath.row
            
//            let videoUrl = myLikedAnswerArray[indexPath.row].video_url
//            let newURL = NSURL(string: videoUrl)
//            cell.player = AVPlayer(URL: newURL!)
//            cell.playerController.player = cell.player
//            cell.player.pause()
            
//            let frontCamera = myLikedAnswerArray[indexPath.row].frontCamera
//            print(frontCamera)
//            
//            if frontCamera {
//                cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
//            }
//            if CGAffineTransformIsIdentity(cell.playerController.view.transform) {
//                if frontCamera {
//                    cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
//                }
//            } else {
//                if frontCamera {
//                    
//                } else {
//                    cell.playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
//                }
//            }
//            cell.videoView.addSubview(cell.playerController.view)
//            
//            
//            
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
//            
//            cell.playerController.view.userInteractionEnabled = true
//            
//            let view = UIView(frame: CGRectMake(cell.videoView.frame.origin.x, cell.videoView.frame.origin.y, cell.videoView.frame.size.width, cell.videoView.frame.size.height))
//            cell.videoView.addSubview(view)
//            
//            let tapGesture = UITapGestureRecognizer(target: self, action: "singleTapped:")
//            view.addGestureRecognizer(tapGesture)
//            view.tag = indexPath.row
//            
//            cell.likeImageView.image = UIImage(named: "playImage")
//            cell.likeImageView.hidden = false
//            cell.likeImageView.alpha = 0.7
//            cell.likeImageView.contentMode = UIViewContentMode.ScaleAspectFill
//            cell.videoView.bringSubviewToFront(cell.likeImageView)
//            
//            let date = myLikedAnswerArray[indexPath.row].createdAt
//            let timeAgo = timeAgoSinceDate(date, numericDates: true)
//            
//            cell.timeAgoLabel.text = timeAgo
//            
//            let views = myLikedAnswerArray[indexPath.row].views
//            let abbrevViews = views.addCommas(views)
//            cell.viewCountLabel.text = "\(abbrevViews) views"
//            
//            let doubleTapGesture = UITapGestureRecognizer()
//            doubleTapGesture.numberOfTapsRequired = 2
//            doubleTapGesture.addTarget(self, action: "doubleTapped:")
//            view.addGestureRecognizer(doubleTapGesture)
//            
//            let likeCount = myLikedAnswerArray[indexPath.row].likeCount
//            let abbrevLikeCount = likeCount.addCommas(likeCount)
//            cell.likeCountTextView.text = "\(abbrevLikeCount) likes"
//            cell.videoView.bringSubviewToFront(cell.likeCountTextView)
//            cell.videoView.bringSubviewToFront(cell.heartImageView)
//            
//            cell.likeButton.tag = indexPath.row
//            cell.likeButton.addTarget(self, action: "toggleLike:", forControlEvents: .TouchUpInside)
//            cell.videoView.bringSubviewToFront(cell.likeButton)
//            
//            cell.extraButton.tag = indexPath.row
//            cell.extraButton.addTarget(self, action: "extraButtonTapped:", forControlEvents: .TouchUpInside)
            
//            if indexPath.row == 0 {
//                
//                let url = globalurl + "api/answers/" + myLikedAnswerArray[indexPath.row].id + "/viewed/"
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
//            }
//            
//            let liked_by_user = self.myLikedAnswerArray[indexPath.row].liked_by_user
//            
//            if liked_by_user == "true" {
//                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                cell.heartImageView.image = UIImage(named: "redHeartOutline")
//            } else if liked_by_user == "not checked" {
//                let url = globalurl + "api/answers/" + myLikedAnswerArray[indexPath.row].id + "/likecheck/" + userid
//                
//                Alamofire.request(.GET, url, parameters: nil)
//                    .responseJSON { response in
//                        let result = response.result.value
//                        print(result)
//                        if result == nil {
//                            print("Gobi")
//                            cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
//                            cell.heartImageView.image = UIImage(named: "grayHeartOutline")
//                            self.myLikedAnswerArray[indexPath.row].liked_by_user = "false"
//                        } else {
//                            print("Liked")
//                            cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                            cell.heartImageView.image = UIImage(named: "redHeartOutline")
//                            self.myLikedAnswerArray[indexPath.row].liked_by_user = "true"
//                        }
//                }
//            } else if liked_by_user == "false" {
//                cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
//                cell.heartImageView.image = UIImage(named: "grayHeartOutline")
//            }
            
//            return cell
            
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            if counter == 0 {
                let cell = cell as! FeaturedPreviewTableViewCell
                
                let answerId = myFeaturedAnswerArray[indexPath.row].id
                
                if let cachedImageResult = imageCache[answerId] {
                    print("pull from cache")
                    cell.previewImageView.image = UIImage(data: cachedImageResult!)
                } else {
                    let thumbnail_url = myFeaturedAnswerArray[indexPath.row].thumbnail_url
                    let newURL = NSURL(string: thumbnail_url)
                    let data = NSData(contentsOfURL: newURL!)
                    imageCache[answerId] = data
                    cell.previewImageView.image  = UIImage(data: data!)
                }
                
                let creator = myFeaturedAnswerArray[indexPath.row].creator
                
                
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
//                let cell = cell as! ProfileRelayTableViewCell
//                
//                let videoUrl = myFeaturedAnswerArray[indexPath.row].video_url
//                let newURL = NSURL(string: videoUrl)
//                cell.player = AVPlayer(URL: newURL!)
//                cell.playerController.player = cell.player
//                cell.player.pause()
                
//                if indexPath.row == 0 {
//                    
//                    let url = globalurl + "api/answers/" + myFeaturedAnswerArray[indexPath.row].id + "/viewed/"
//                    
//                    Alamofire.request(.PUT, url, parameters: nil)
//                        .responseJSON { response in
//                            let result = response.result.value
//                            print(result)
//                            if result == nil {
//                                print("Not viewed")
//                                
//                            } else {
//                                print("Viewed")
//                            }
//                    }
//                }
                
//                let liked_by_user = self.myFeaturedAnswerArray[indexPath.row].liked_by_user
//                
//                if liked_by_user == "true" {
//                    cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                    cell.heartImageView.image = UIImage(named: "redHeartOutline")
//                } else if liked_by_user == "not checked"{
//                    let url = globalurl + "api/answers/" + myFeaturedAnswerArray[indexPath.row].id + "/likecheck/" + userid
//                    
//                    Alamofire.request(.GET, url, parameters: nil)
//                        .responseJSON { response in
//                            let result = response.result.value
//                            if result == nil {
//                                print("Not liked")
//                                cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
//                                cell.heartImageView.image = UIImage(named: "grayHeartOutline")
//                                self.myFeaturedAnswerArray[indexPath.row].liked_by_user = "false"
//                            } else {
//                                print("Liked")
//                                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                                cell.heartImageView.image = UIImage(named: "redHeartOutline")
//                                self.myFeaturedAnswerArray[indexPath.row].liked_by_user = "true"
//                            }
//                    }
//                } else if liked_by_user == "false" {
//                    cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
//                    cell.heartImageView.image = UIImage(named: "grayHeartOutline")
//                }
                
            }
            else if counter == 2 {
                let cell = cell as! FeaturedPreviewTableViewCell
                
                let answerId = myAnswerArray[indexPath.row].id
                
                if let cachedImageResult = imageCache[answerId] {
                    print("pull from cache")
                    cell.previewImageView.image = UIImage(data: cachedImageResult!)
                } else {
                    let thumbnail_url = myAnswerArray[indexPath.row].thumbnail_url
                    let newURL = NSURL(string: thumbnail_url)
                    let data = NSData(contentsOfURL: newURL!)
                    imageCache[answerId] = data
                    cell.previewImageView.image  = UIImage(data: data!)
                }
                
                let creator = myAnswerArray[indexPath.row].creator
                
                
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

//                let cell = cell as! ProfileRelayTableViewCell
//                
//                let videoUrl = myAnswerArray[indexPath.row].video_url
//                let newURL = NSURL(string: videoUrl)
//                cell.player = AVPlayer(URL: newURL!)
//                cell.playerController.player = cell.player
//                cell.player.pause()
                
//                if indexPath.row == 0 {
//                    
//                    let url = globalurl + "api/answers/" + myAnswerArray[indexPath.row].id + "/viewed/"
//                    
//                    Alamofire.request(.PUT, url, parameters: nil)
//                        .responseJSON { response in
//                            let result = response.result.value
//                            print(result)
//                            if result == nil {
//                                print("Not viewed")
//                                
//                            } else {
//                                print("Viewed")
//                            }
//                    }
//                }
                
//                let likeCount = self.myAnswerArray[indexPath.row].likeCount
//                print(likeCount)
//                let abbrevLikeCount = likeCount.addCommas(likeCount)
//                cell.likeCountTextView.text = "\(abbrevLikeCount) likes"
//
//                
//                let liked_by_user = self.myAnswerArray[indexPath.row].liked_by_user
//                
//                if liked_by_user == "true" {
//                    cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                    cell.heartImageView.image = UIImage(named: "redHeartOutline")
//                } else if liked_by_user == "not checked"{
//                    let url = globalurl + "api/answers/" + myAnswerArray[indexPath.row].id + "/likecheck/" + userid
//                    
//                    Alamofire.request(.GET, url, parameters: nil)
//                        .responseJSON { response in
//                            let result = response.result.value
//                            if result == nil {
//                                print("Not liked")
//                                cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
//                                cell.heartImageView.image = UIImage(named: "grayHeartOutline")
//                                self.myAnswerArray[indexPath.row].liked_by_user = "false"
//                            } else {
//                                print("Liked")
//                                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                                cell.heartImageView.image = UIImage(named: "redHeartOutline")
//                                self.myAnswerArray[indexPath.row].liked_by_user = "true"
//                            }
//                    }
//                } else if liked_by_user == "false" {
//                    cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
//                    cell.heartImageView.image = UIImage(named: "grayHeartOutline")
//                }

                
            } else if counter == 3 {
                let cell = cell as! FeaturedPreviewTableViewCell
                
                let answerId = myLikedAnswerArray[indexPath.row].id
                
                if let cachedImageResult = imageCache[answerId] {
                    print("pull from cache")
                    cell.previewImageView.image = UIImage(data: cachedImageResult!)
                } else {
                    let thumbnail_url = myLikedAnswerArray[indexPath.row].thumbnail_url
                    let newURL = NSURL(string: thumbnail_url)
                    let data = NSData(contentsOfURL: newURL!)
                    imageCache[answerId] = data
                    cell.previewImageView.image  = UIImage(data: data!)
                }
                
                let creator = myLikedAnswerArray[indexPath.row].creator
                
                
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
                
//                let cell = cell as! ProfileLikedTableViewCell
//                
//                let videoUrl = myLikedAnswerArray[indexPath.row].video_url
//                let newURL = NSURL(string: videoUrl)
//                cell.player = AVPlayer(URL: newURL!)
//                cell.playerController.player = cell.player
//                cell.player.pause()
//                
//                let creator = myLikedAnswerArray[indexPath.row].creator
//                cell.profileImageView.image = UIImage(named: "Placeholder")
//                if let cachedImageResult = imageCache[creator] {
//                    print("pull from cache")
//                    cell.profileImageView.image = UIImage(data: cachedImageResult!)
//                } else {
//                    cell.profileImageView.image = UIImage(named: "Placeholder")
//                    
//                    let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp-download")
//                    let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
//                    let transferManager = AWSS3TransferManager.defaultS3TransferManager()
//                    
//                    let key = "profilePics/" + creator
//                    let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
//                    readRequest1.bucket = S3BucketName
//                    readRequest1.key =  key
//                    readRequest1.downloadingFileURL = downloadingFileURL1
//                    
//                    let task = transferManager.download(readRequest1)
//                    task.continueWithBlock { (task) -> AnyObject! in
//                        if task.error != nil {
//                            print("No Profile Pic")
//                        } else {
//                            let image = UIImage(contentsOfFile: downloadingFilePath1)
//                            let imageData = UIImageJPEGRepresentation(image!, 1.0)
//                            imageCache[creator] = imageData
//                            dispatch_async(dispatch_get_main_queue()
//                                , { () -> Void in
//                                    cell.profileImageView.image = UIImage(contentsOfFile: downloadingFilePath1)
//                                    cell.setNeedsLayout()
//                                    
//                            })
//                            print("Fetched image")
//                        }
//                        return nil
//                    }
//                }
                
//                var question_content = myLikedAnswerArray[indexPath.row].question_content
//                let question_id = myLikedAnswerArray[indexPath.row].question_id
//                
//                cell.questionContentTextView.text = question_content
//                cell.questionContentTextView.editable = false
//                cell.questionContentTextView.selectable = false
                
//                if question_content == "" {
//                    let url = globalurl + "api/questions/" + question_id
//                    
//                    Alamofire.request(.GET, url, parameters: nil)
//                        .responseJSON { response in
//                            let json = JSON(response.result.value!)
//                            print("JSON: \(json)")
//                            if json == [] {
//                                print("No answers")
//                            }
//                            let content = json["content"].string
//                            print(content)
//                            question_content = content!
//                            self.myLikedAnswerArray[indexPath.row].question_content = question_content
//                            cell.questionContentTextView.text = question_content
//                            cell.questionContentTextView.editable = false
//                            cell.questionContentTextView.selectable = false
//                    }
//                } else {
//                    
//                }
                
//                if indexPath.row == 0 {
//                    
//                    let url = globalurl + "api/answers/" + myLikedAnswerArray[indexPath.row].id + "/viewed/"
//                    
//                    Alamofire.request(.PUT, url, parameters: nil)
//                        .responseJSON { response in
//                            let result = response.result.value
//                            print(result)
//                            if result == nil {
//                                print("Not viewed")
//                                
//                            } else {
//                                print("Viewed")
//                            }
//                    }
//                }
                
//                let liked_by_user = self.myLikedAnswerArray[indexPath.row].liked_by_user
//                
//                if liked_by_user == "true" {
//                    cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                    cell.heartImageView.image = UIImage(named: "redHeartOutline")
//                } else if liked_by_user == "not checked" {
//                    let url = globalurl + "api/answers/" + myLikedAnswerArray[indexPath.row].id + "/likecheck/" + userid
//                    
//                    Alamofire.request(.GET, url, parameters: nil)
//                        .responseJSON { response in
//                            let result = response.result.value
//                            if result == nil {
//                                print("Not liked")
//                                cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
//                                cell.heartImageView.image = UIImage(named: "grayHeartOutline")
//                                self.myLikedAnswerArray[indexPath.row].liked_by_user = "false"
//                            } else {
//                                print("Liked")
//                                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
//                                cell.heartImageView.image = UIImage(named: "redHeartOutline")
//                                self.myLikedAnswerArray[indexPath.row].liked_by_user = "true"
//                            }
//                    }
//                } else if liked_by_user == "false" {
//                    cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
//                    cell.heartImageView.image = UIImage(named: "grayHeartOutline")
//                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            
        } else {
            if counter == 1 {
                Answers.logCustomEventWithName("Post Clicked",
                    customAttributes: ["from": "Profile"])
                self.performSegueWithIdentifier("segueFromProfileToAnswers", sender: self)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            } else {
                self.selectedIndexPath = indexPath.row
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                self.performSegueWithIdentifier("segueFromProfileToVideoPage", sender: self)
            }
        }
    }
    
    // MARK: - tableView functions
    func goToChannel(sender: UIButton) {
        questionIndex = sender.tag
        self.performSegueWithIdentifier("segueFromProfileToFeed", sender: self)
    }
    
    func twitterButtonPressed(sender: UIButton) {
        self.performSegueWithIdentifier("segueToWebView", sender: self)
    }
    
    func toggleButton(sender: UIButton) {
        let tag = sender.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as! ProfileButtonsTableViewCell
        
        if tag == 0 {
            if counter == 0 {
                
            } else {
                counter = 0
                Answers.logCustomEventWithName("Profile Tabs Clicked",
                    customAttributes: ["tab": "Featured"])
                for cell in tableView.visibleCells {
                    if cell.isKindOfClass(ProfileRelayTableViewCell) {
                        let cell = cell as! ProfileRelayTableViewCell
                        cell.player.pause()
                    } else if cell.isKindOfClass(ProfileLikedTableViewCell) {
                        let cell = cell as! ProfileLikedTableViewCell
                        cell.player.pause()
                    }
                }
                cell.personalButton.selected = true
                cell.pencilButton.selected = false
                cell.recorderButton.selected = false
                cell.heartButton.selected = false
                if myFeaturedAnswerArray.count == 0 {
                    if self.noFeaturedAnswers {
                        self.label.text = "No featured relays"
                        self.label.hidden = false
                    } else {
                       self.loadMyFeaturedAnswers()
                    }
                } else {
                    self.label.hidden = true
                }
                self.tableView.reloadData()
            }
        } else if tag == 1 {
            if counter == 1 {
                
            } else {
                counter = 1
                Answers.logCustomEventWithName("Profile Tabs Clicked",
                    customAttributes: ["tab": "Posts"])
                for cell in tableView.visibleCells {
                    if cell.isKindOfClass(ProfileRelayTableViewCell) {
                        let cell = cell as! ProfileRelayTableViewCell
                        cell.player.pause()
                    } else if cell.isKindOfClass(ProfileLikedTableViewCell) {
                        let cell = cell as! ProfileLikedTableViewCell
                        cell.player.pause()
                    }
                }
                cell.personalButton.selected = false
                cell.pencilButton.selected = true
                cell.recorderButton.selected = false
                cell.heartButton.selected = false
                if myQuestionArray.count == 0 {
                    if self.noQuestions {
                        self.label.text = "No posts"
                        self.label.hidden = false
                    } else {
                        self.loadMyQuestions()
                    }
                } else {
                    self.label.hidden = true
                }
                self.tableView.reloadData()
            }
        } else if tag == 2 {
            if counter == 2 {
                
            } else {
                counter = 2
                Answers.logCustomEventWithName("Profile Tabs Clicked",
                    customAttributes: ["tab": "Relays"])
                for cell in tableView.visibleCells {
                    if cell.isKindOfClass(ProfileRelayTableViewCell) {
                        let cell = cell as! ProfileRelayTableViewCell
                        cell.player.pause()
                    } else if cell.isKindOfClass(ProfileLikedTableViewCell) {
                        let cell = cell as! ProfileLikedTableViewCell
                        cell.player.pause()
                    }
                }
                cell.personalButton.selected = false
                cell.pencilButton.selected = false
                cell.recorderButton.selected = true
                cell.heartButton.selected = false
                if myAnswerArray.count == 0 {
                    if self.noAnswers {
                        self.label.text = "No relays"
                        self.label.hidden = false
                    } else {
                        self.loadMyAnswers()
                    }
                } else {
                    self.label.hidden = true
                }
                self.tableView.reloadData()
            }
        } else if tag == 3 {
            if counter == 3 {
                
            } else {
                counter = 3
                Answers.logCustomEventWithName("Profile Tabs Clicked",
                    customAttributes: ["tab": "Likes"])
                for cell in tableView.visibleCells {
                    if cell.isKindOfClass(ProfileRelayTableViewCell) {
                        let cell = cell as! ProfileRelayTableViewCell
                        cell.player.pause()
                    } else if cell.isKindOfClass(ProfileLikedTableViewCell) {
                        let cell = cell as! ProfileLikedTableViewCell
                        cell.player.pause()
                    }
                }
                cell.personalButton.selected = false
                cell.pencilButton.selected = false
                cell.recorderButton.selected = false
                cell.heartButton.selected = true
                if myLikedAnswerArray.count == 0 {
                    if self.noLikedAnswers {
                        self.label.text = "No likes"
                        self.label.hidden = false
                    } else {
                        self.loadMyLikedAnswers()
                    }
                } else {
                    self.label.hidden = true
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func questionContentPressed(sender: UIButton) {
        if counter == 0 {
            let tag = sender.tag
            self.questionIndex = tag
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 2)) as! ProfileRelayTableViewCell
            if (cell.player.rate > 0) {
                cell.player.pause()
            } else {
                cell.player.play()
            }
            self.performSegueWithIdentifier("segueFromProfileToAnswers", sender: self)
        } else if counter == 2 {
            let tag = sender.tag
            self.questionIndex = tag
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 2)) as! ProfileRelayTableViewCell
            if (cell.player.rate > 0) {
                cell.player.pause()
            } else {
                cell.player.play()
            }
            self.performSegueWithIdentifier("segueFromProfileToAnswers", sender: self)
        } else if counter == 3 {
            let tag = sender.tag
            self.questionIndex = tag
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 2)) as! ProfileLikedTableViewCell
            if (cell.player.rate > 0) {
                cell.player.pause()
            } else {
                cell.player.play()
            }
            self.performSegueWithIdentifier("segueFromProfileToAnswers", sender: self)
        }
        
        
    }
    
    func toggleProfileButton(sender: UIButton) {
        if sender.titleLabel?.text == "EDIT PROFILE" {
            self.performSegueWithIdentifier("segueToEditProfile", sender: self)
        } else {
            if sender.selected == false {
                self.ifFollowing = true
                sender.backgroundColor = UIColor(red:0.39, green:0.91, blue:0.61, alpha:1.0)
                sender.layer.borderColor = UIColor(red:0.39, green:0.91, blue:0.61, alpha:1.0).CGColor
                sender.selected = true
                let url = globalurl + "api/user/" + userid + "/follows/" + creatorId
                
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
                self.ifFollowing = false
                sender.backgroundColor = UIColor.clearColor()
                sender.layer.borderColor = UIColor.blueColor().CGColor
                let url = globalurl + "api/user/" + userid + "/unfollows/" + creatorId
                
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
    }
    
    func toggleLike(sender: UIButton!) {
        print("button hit")
        if counter == 0 {
            let currentLiked = self.myFeaturedAnswerArray[sender.tag].liked_by_user
            let tag = sender.tag
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 2)) as! ProfileRelayTableViewCell
            let answerId = self.myFeaturedAnswerArray[sender.tag].id
            
            if currentLiked == "true" {
                print("unliked")
                self.myFeaturedAnswerArray[tag].likeCount -= 1
                self.myFeaturedAnswerArray[tag].liked_by_user = "false"
                let likeCount = self.myFeaturedAnswerArray[tag].likeCount
                cell.likeCountTextView.text = "\(likeCount) likes"
                cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
                cell.heartImageView.image = UIImage(named: "grayHeartOutline")
                
                let url = globalurl + "api/answers/" + myFeaturedAnswerArray[sender.tag].id + "/unlikednotifs/" + userid
                
                Alamofire.request(.PUT, url, parameters: nil)
                    .responseJSON { response in
                        let result = response.result.value
                        print(result)
                        if result == nil {
                            
                        } else {
                            print("unliked")
                            Answers.logCustomEventWithName("Unlike",
                                customAttributes: ["where": "ProfileFeatured"])
                           
                        }
                }
            } else {
                print("liked")
                self.myFeaturedAnswerArray[tag].likeCount += 1
                self.myFeaturedAnswerArray[tag].liked_by_user = "true"
                let likeCount = self.myFeaturedAnswerArray[tag].likeCount
                cell.likeCountTextView.text = "\(likeCount) likes"
                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                cell.heartImageView.image = UIImage(named: "redHeartOutline")
                
                let url = globalurl + "api/answers/" + answerId + "/likednotifs/" + userid
                
                Alamofire.request(.PUT, url, parameters: nil)
                    .responseJSON { response in
                        let result = response.result.value
                        print(result)
                        if result == nil {
                            print("Already liked")
                            
                        } else {
                            print("Liked")
                            Answers.logCustomEventWithName("Like",
                                customAttributes: ["method": "Button", "where": "ProfileFeatured"])
                            
                        }
                }
            }
        } else if counter == 2 {
            let currentLiked = self.myAnswerArray[sender.tag].liked_by_user
            let tag = sender.tag
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 2)) as! ProfileRelayTableViewCell
            let answerId = self.myAnswerArray[sender.tag].id
            
            if currentLiked == "true" {
                print("unliked")
                self.myAnswerArray[tag].likeCount -= 1
                self.myAnswerArray[tag].liked_by_user = "false"
                let likeCount = self.myAnswerArray[tag].likeCount
                cell.likeCountTextView.text = "\(likeCount) likes"
                cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
                cell.heartImageView.image = UIImage(named: "grayHeartOutline")
                
                let url = globalurl + "api/answers/" + myAnswerArray[sender.tag].id + "/unlikednotifs/" + userid
                
                Alamofire.request(.PUT, url, parameters: nil)
                    .responseJSON { response in
                        let result = response.result.value
                        print(result)
                        if result == nil {
                            
                        } else {
                            print("unliked")
                            Answers.logCustomEventWithName("Unlike",
                                customAttributes: ["where": "ProfileRelays"])
                            
                        }
                }
            } else {
                print("liked")
                self.myAnswerArray[tag].likeCount += 1
                self.myAnswerArray[tag].liked_by_user = "true"
                let likeCount = self.myAnswerArray[tag].likeCount
                cell.likeCountTextView.text = "\(likeCount) likes"
                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                cell.heartImageView.image = UIImage(named: "redHeartOutline")
                
                let url = globalurl + "api/answers/" + answerId + "/likednotifs/" + userid
                
                Alamofire.request(.PUT, url, parameters: nil)
                    .responseJSON { response in
                        let result = response.result.value
                        print(result)
                        if result == nil {
                            print("Already liked")
                            
                        } else {
                            print("Liked")
                            Answers.logCustomEventWithName("Like",
                                customAttributes: ["method": "Button", "where": "ProfileRelays"])
                            
                        }
                }
            }
        } else if counter == 3 {
            
            
            let currentLiked = self.myLikedAnswerArray[sender.tag].liked_by_user
            let tag = sender.tag
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 2)) as! ProfileLikedTableViewCell
            let answerId = self.myLikedAnswerArray[sender.tag].id
            
            if currentLiked == "true" {
                print("unliked")
                self.myLikedAnswerArray[tag].likeCount -= 1
                self.myLikedAnswerArray[tag].liked_by_user = "false"
                let likeCount = self.myLikedAnswerArray[tag].likeCount
                cell.likeCountTextView.text = "\(likeCount) likes"
                cell.likeCountTextView.textColor = UIColor(white:0.54, alpha:1.0)
                cell.heartImageView.image = UIImage(named: "grayHeartOutline")
                
                let url = globalurl + "api/answers/" + answerId + "/unlikednotifs/" + userid
                
                Alamofire.request(.PUT, url, parameters: nil)
                    .responseJSON { response in
                        let result = response.result.value
                        print(result)
                        if result == nil {
                            
                        } else {
                            print("unliked")
                            Answers.logCustomEventWithName("Unlike",
                                customAttributes: ["where": "ProfileLikes"])
                            
                        }
                }
            } else {
                print("liked")
                self.myLikedAnswerArray[tag].likeCount += 1
                self.myLikedAnswerArray[tag].liked_by_user = "true"
                let likeCount = self.myLikedAnswerArray[tag].likeCount
                cell.likeCountTextView.text = "\(likeCount) likes"
                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                cell.heartImageView.image = UIImage(named: "redHeartOutline")
                
                let url = globalurl + "api/answers/" + answerId + "/likednotifs/" + userid
                
                Alamofire.request(.PUT, url, parameters: nil)
                    .responseJSON { response in
                        let result = response.result.value
                        print(result)
                        if result == nil {
                            print("Already liked")
                            
                        } else {
                            print("Liked")
                            Answers.logCustomEventWithName("Like",
                                customAttributes: ["method": "Button", "where": "ProfileLikes"])
                            
                        }
                }
            }
        }
        
    }
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        print("Double Tap")
        let tag = sender.view?.tag
        if counter == 0 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 2)) as! ProfileRelayTableViewCell
            let currentLiked = self.myFeaturedAnswerArray[tag!].liked_by_user
            cell.likeImageView.image = UIImage(named: "Heart")
            cell.likeImageView.hidden = false
            cell.likeImageView.alpha = 1
            cell.player.play()
            
            if currentLiked == "true" {
                
            } else {
                self.myFeaturedAnswerArray[tag!].likeCount += 1
                self.myFeaturedAnswerArray[tag!].liked_by_user = "true"
                let likeCount = self.myFeaturedAnswerArray[tag!].likeCount
                cell.likeCountTextView.text = "\(likeCount) likes"
                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                cell.heartImageView.image = UIImage(named: "redHeartOutline")
                
                let answerId = self.myFeaturedAnswerArray[tag!].id
                
                let url = globalurl + "api/answers/" + answerId + "/likednotifs/" + userid
                
                Alamofire.request(.PUT, url, parameters: nil)
                    .responseJSON { response in
                        let result = response.result.value
                        print(result)
                        if result == nil {
                            print("Already liked")
                            
                        } else {
                            print("Liked")
                            Answers.logCustomEventWithName("Like",
                                customAttributes: ["method": "Double Tap", "where": "ProfileFeatured"])
                            
                        }
                }
            }
            
            UIView.animateWithDuration(1.0, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                cell.likeImageView.alpha = 0
                }) { (success) -> Void in
                    cell.likeImageView.alpha = 1
                    cell.likeImageView.hidden = true
                    
                    
            }
        } else if counter == 2 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 2)) as! ProfileRelayTableViewCell
            let currentLiked = self.myAnswerArray[tag!].liked_by_user
            cell.likeImageView.image = UIImage(named: "Heart")
            cell.likeImageView.hidden = false
            cell.likeImageView.alpha = 1
            cell.player.play()
            
            if currentLiked == "true" {
                
            } else {
                self.myAnswerArray[tag!].likeCount += 1
                self.myAnswerArray[tag!].liked_by_user = "true"
                let likeCount = self.myAnswerArray[tag!].likeCount
                cell.likeCountTextView.text = "\(likeCount) likes"
                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                cell.heartImageView.image = UIImage(named: "redHeartOutline")
                
                let answerId = self.myAnswerArray[tag!].id
                
                let url = globalurl + "api/answers/" + answerId + "/likednotifs/" + userid
                
                Alamofire.request(.PUT, url, parameters: nil)
                    .responseJSON { response in
                        let result = response.result.value
                        print(result)
                        if result == nil {
                            print("Already liked")
                            
                        } else {
                            print("Liked")
                            Answers.logCustomEventWithName("Like",
                                customAttributes: ["method": "Double Tap", "where": "ProfileRelays"])
                            
                        }
                }
            }
            
            UIView.animateWithDuration(1.0, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                cell.likeImageView.alpha = 0
                }) { (success) -> Void in
                    cell.likeImageView.alpha = 1
                    cell.likeImageView.hidden = true
                    
                    
            }
        } else if counter == 3 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 2)) as! ProfileLikedTableViewCell
            let currentLiked = self.myLikedAnswerArray[tag!].liked_by_user
            cell.likeImageView.image = UIImage(named: "Heart")
            cell.likeImageView.hidden = false
            cell.likeImageView.alpha = 1
            cell.player.play()
            
            if currentLiked == "true" {
                
            } else {
                self.myLikedAnswerArray[tag!].likeCount += 1
                self.myLikedAnswerArray[tag!].liked_by_user = "true"
                let likeCount = self.myLikedAnswerArray[tag!].likeCount
                cell.likeCountTextView.text = "\(likeCount) likes"
                cell.likeCountTextView.textColor = UIColor(red: 0.91, green: 0.271, blue: 0.271, alpha: 1)
                cell.heartImageView.image = UIImage(named: "redHeartOutline")
                
                let answerId = self.myLikedAnswerArray[tag!].id
                
                let url = globalurl + "api/answers/" + answerId + "/likednotifs/" + userid
                
                Alamofire.request(.PUT, url, parameters: nil)
                    .responseJSON { response in
                        let result = response.result.value
                        print(result)
                        if result == nil {
                            print("Already liked")
                            
                        } else {
                            print("Liked")
                            Answers.logCustomEventWithName("Like",
                                customAttributes: ["method": "Double Tap", "where": "ProfileLikes"])
                            
                        }
                }
            }
            
            UIView.animateWithDuration(1.0, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                cell.likeImageView.alpha = 0
                }) { (success) -> Void in
                    cell.likeImageView.alpha = 1
                    cell.likeImageView.hidden = true
                    
                    
            }
        }
        
    }
    
    func singleTapped(sender: UITapGestureRecognizer) {
        print("Tapped")
        let tag = sender.view?.tag
        
        if counter == 0 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 2)) as! ProfileRelayTableViewCell
            if (cell.player.rate > 0) {
                cell.player.pause()
                Answers.logCustomEventWithName("Pause Clicked",
                    customAttributes: ["where": "ProfileFeatured","row": tag!])
                cell.likeImageView.alpha = 0.7
                cell.likeImageView.image = UIImage(named: "playImage")
                cell.likeImageView.hidden = false
            } else {
                cell.player.play()
                Answers.logCustomEventWithName("Play Clicked",
                    customAttributes: ["where": "ProfileFeatured","row": tag!])
                Answers.logCustomEventWithName("Video Viewed",
                    customAttributes: ["where":"ProfileFeatured", "row": tag!])
                let url = globalurl + "api/answers/" + myFeaturedAnswerArray[tag!].id + "/viewed/"
                
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
                NSNotificationCenter.defaultCenter().addObserver(self,
                    selector: "videoEnd",
                    name: AVPlayerItemDidPlayToEndTimeNotification,
                    object: nil)
                cell.likeImageView.hidden = true
            }
        } else if counter == 2 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 2)) as! ProfileRelayTableViewCell
            if (cell.player.rate > 0) {
                cell.player.pause()
                Answers.logCustomEventWithName("Pause Clicked",
                    customAttributes: ["where": "ProfileRelays","row": tag!])
                cell.likeImageView.alpha = 0.7
                cell.likeImageView.image = UIImage(named: "playImage")
                cell.likeImageView.hidden = false
            } else {
                cell.player.play()
                Answers.logCustomEventWithName("Play Clicked",
                    customAttributes: ["where": "ProfileRelays","row": tag!])
                Answers.logCustomEventWithName("Video Viewed",
                    customAttributes: ["where":"ProfileRelays", "row": tag!])
                let url = globalurl + "api/answers/" + myAnswerArray[tag!].id + "/viewed/"
                
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
                NSNotificationCenter.defaultCenter().addObserver(self,
                    selector: "videoEnd",
                    name: AVPlayerItemDidPlayToEndTimeNotification,
                    object: nil)
                cell.likeImageView.hidden = true
            }
        } else if counter == 3 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag!, inSection: 2)) as! ProfileLikedTableViewCell
            if (cell.player.rate > 0) {
                cell.player.pause()
                Answers.logCustomEventWithName("Pause Clicked",
                    customAttributes: ["where": "ProfileLikes","row": tag!])
                cell.likeImageView.alpha = 0.7
                cell.likeImageView.image = UIImage(named: "playImage")
                cell.likeImageView.hidden = false
            } else {
                cell.player.play()
                Answers.logCustomEventWithName("Play Clicked",
                    customAttributes: ["where": "ProfileLikes","row": tag!])
                Answers.logCustomEventWithName("Video Viewed",
                    customAttributes: ["where":"ProfileLikes", "row": tag!])
                let url = globalurl + "api/answers/" + myLikedAnswerArray[tag!].id + "/viewed/"
                
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
                NSNotificationCenter.defaultCenter().addObserver(self,
                    selector: "videoEnd",
                    name: AVPlayerItemDidPlayToEndTimeNotification,
                    object: nil)
                cell.likeImageView.hidden = true
            }
        }
        
    }
    
    func videoEnd() {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: nil)
        if counter == 0 {
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
                        cell.likeImageView.image = UIImage(named: "replayImage")
                        cell.likeImageView.hidden = false
                        cell.likeImageView.alpha = 0.7
                        if (cell.player.rate > 0) {
                            
                            
                        } else {
                            print("Reached")
                            Answers.logCustomEventWithName("Full View",
                                customAttributes: ["where":"ProfileFeatured"])
//                            let url = globalurl + "api/answers/" + myFeaturedAnswerArray[(indexPath?.row)!].id + "/viewed/"
//                            
//                            Alamofire.request(.PUT, url, parameters: nil)
//                                .responseJSON { response in
//                                    let result = response.result.value
//                                    print(result)
//                                    if result == nil {
//                                        print("Not viewed")
//                                        
//                                    } else {
//                                        print("Viewed")
//                                    }
//                            }
                            let seconds : Int64 = 0
                            let preferredTimeScale : Int32 = 1
                            let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
                            
                            cell.player.seekToTime(seekTime)
                            //                        cell.player.play()
                        }
                    } else {
                        cell.player.pause()
                    }
                }
            }
        } else if counter == 2 {
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
                        cell.likeImageView.image = UIImage(named: "replayImage")
                        cell.likeImageView.hidden = false
                        cell.likeImageView.alpha = 0.7
                        if (cell.player.rate > 0) {
                            
                            
                        } else {
                            print("Reached")
                            Answers.logCustomEventWithName("Full View",
                                customAttributes: ["where":"ProfileRelays"])
//                            let url = globalurl + "api/answers/" + myAnswerArray[(indexPath?.row)!].id + "/viewed/"
//                            
//                            Alamofire.request(.PUT, url, parameters: nil)
//                                .responseJSON { response in
//                                    let result = response.result.value
//                                    print(result)
//                                    if result == nil {
//                                        print("Not viewed")
//                                        
//                                    } else {
//                                        print("Viewed")
//                                    }
//                            }
                            let seconds : Int64 = 0
                            let preferredTimeScale : Int32 = 1
                            let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
                            
                            cell.player.seekToTime(seekTime)
                            //                        cell.player.play()
                        }
                    } else {
                        cell.player.pause()
                    }
                }
            }
        } else if counter == 3 {
            for cell in tableView.visibleCells {
                if cell.isKindOfClass(ProfileLikedTableViewCell) {
                    let indexPath = tableView.indexPathForCell(cell)
                    let cellRect = tableView.rectForRowAtIndexPath(indexPath!)
                    let superView = tableView.superview
                    let convertedRect = tableView.convertRect(cellRect, toView: superView)
                    let intersect = CGRectIntersection(tableView.frame, convertedRect)
                    let visibleHeight = CGRectGetHeight(intersect)
                    let cellHeight = tableView.frame.height * 0.6
                    let cell = cell as! ProfileLikedTableViewCell
                    
                    
                    if visibleHeight > cellHeight {
                        cell.likeImageView.image = UIImage(named: "replayImage")
                        cell.likeImageView.hidden = false
                        cell.likeImageView.alpha = 0.7
                        if (cell.player.rate > 0) {
                            
                            
                        } else {
                            print("Reached")
                            Answers.logCustomEventWithName("Full View",
                                customAttributes: ["where":"ProfileLikes"])
//                            let url = globalurl + "api/answers/" + myLikedAnswerArray[(indexPath?.row)!].id + "/viewed/"
//                            
//                            Alamofire.request(.PUT, url, parameters: nil)
//                                .responseJSON { response in
//                                    let result = response.result.value
//                                    print(result)
//                                    if result == nil {
//                                        print("Not viewed")
//                                        
//                                    } else {
//                                        print("Viewed")
//                                    }
//                            }
                            let seconds : Int64 = 0
                            let preferredTimeScale : Int32 = 1
                            let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
                            
                            cell.player.seekToTime(seekTime)
                            //                        cell.player.play()
                        }
                    } else {
                        cell.player.pause()
                    }
                }
            }
        }
        
        
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
    
    func extraButtonTapped(sender: UIButton) {
        let tag = sender.tag
        
        if counter == 0 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 2)) as! ProfileRelayTableViewCell
            if cell.player.rate > 0 {
                cell.player.pause()
                cell.likeImageView.alpha = 0.7
                cell.likeImageView.image = UIImage(named: "playImage")
                cell.likeImageView.hidden = false
            }
            let creator = myFeaturedAnswerArray[tag].creator
            let answerId = myFeaturedAnswerArray[tag].id
            let answerUrl = batonUrl + "answers/\(answerId)"
            var questionContent = myFeaturedAnswerArray[tag].question_content
            if questionContent.characters.count > 80 {
                let ss1: String = (questionContent as NSString).substringToIndex(80)
                questionContent = ss1 + "..."
                
            }
            
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
            let deleteButton = UIAlertAction(title: "Delete relay", style: UIAlertActionStyle.Default) { (alert) -> Void in
                print("Video deleted")
                
                let url = globalurl + "api/answers/" + answerId
                Alamofire.request(.DELETE, url, parameters: nil)
                    .responseJSON { response in
                        print(response.request)
                        print(response.response)
                        print(response.result)
                        print(response.response?.statusCode)
                }
                self.myFeaturedAnswerArray.removeAtIndex(tag)
                self.tableView.reloadData()
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                print("Cancel Pressed", terminator: "")
            }
            let copyLinkButton = UIAlertAction(title: "Copy Video URL", style: UIAlertActionStyle.Default) { (alert) -> Void in
                
                UIPasteboard.generalPasteboard().string = "\(answerUrl)"
            }
            let facebookButton = UIAlertAction(title: "Share to Facebook", style: UIAlertActionStyle.Default) { (alert) -> Void in
                let thumbnailUrl = "https://s3-us-west-1.amazonaws.com/batonapp/BatonHighQuality.png"
                let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
                
                content.contentURL = NSURL(string: answerUrl)
                content.contentTitle = "re: \"\(questionContent)\""
                content.contentDescription = "A platfrom concise video discussions every day"
                content.imageURL = NSURL(string: thumbnailUrl )
                FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
                
            }
            let messageButton = UIAlertAction(title: "Share through Message", style: UIAlertActionStyle.Default) { (alert) -> Void in
                
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
                let composer = TWTRComposer()
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
        } else if counter == 2 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 2)) as! ProfileRelayTableViewCell
            if cell.player.rate > 0 {
                cell.player.pause()
                cell.likeImageView.alpha = 0.7
                cell.likeImageView.image = UIImage(named: "playImage")
                cell.likeImageView.hidden = false
            }
            let creator = myAnswerArray[tag].creator
            let answerId = myAnswerArray[tag].id
            let answerUrl = batonUrl + "answers/\(answerId)"
            var questionContent = myAnswerArray[tag].question_content
            if questionContent.characters.count > 80 {
                let ss1: String = (questionContent as NSString).substringToIndex(80)
                questionContent = ss1 + "..."
                
            }
            
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
            let deleteButton = UIAlertAction(title: "Delete relay", style: UIAlertActionStyle.Default) { (alert) -> Void in
                print("Video deleted")
                
                let url = globalurl + "api/answers/" + answerId
                Alamofire.request(.DELETE, url, parameters: nil)
                    .responseJSON { response in
                        print(response.request)
                        print(response.response)
                        print(response.result)
                        print(response.response?.statusCode)
                }
                self.myAnswerArray.removeAtIndex(tag)
                self.tableView.reloadData()
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                print("Cancel Pressed", terminator: "")
            }
            let copyLinkButton = UIAlertAction(title: "Copy Video URL", style: UIAlertActionStyle.Default) { (alert) -> Void in
                
                UIPasteboard.generalPasteboard().string = "\(answerUrl)"
            }
            let facebookButton = UIAlertAction(title: "Share to Facebook", style: UIAlertActionStyle.Default) { (alert) -> Void in
                let thumbnailUrl = "https://s3-us-west-1.amazonaws.com/batonapp/BatonHighQuality.png"
                let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
                
                content.contentURL = NSURL(string: answerUrl)
                content.contentTitle = "re: \"\(questionContent)\""
                content.contentDescription = "A platfrom concise video discussions every day"
                content.imageURL = NSURL(string: thumbnailUrl )
                FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
                
            }
            let messageButton = UIAlertAction(title: "Share through Message", style: UIAlertActionStyle.Default) { (alert) -> Void in
                
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
                let composer = TWTRComposer()
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
        } else if counter == 3 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 2)) as! ProfileLikedTableViewCell
            if cell.player.rate > 0 {
                cell.player.pause()
                cell.likeImageView.alpha = 0.7
                cell.likeImageView.image = UIImage(named: "playImage")
                cell.likeImageView.hidden = false
            }
            let creator = myLikedAnswerArray[tag].creator
            let answerId = myLikedAnswerArray[tag].id
            let answerUrl = batonUrl + "answers/\(answerId)"
            var questionContent = myLikedAnswerArray[tag].question_content
            if questionContent.characters.count > 80 {
                let ss1: String = (questionContent as NSString).substringToIndex(80)
                questionContent = ss1 + "..."
                
            }
            
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
            let deleteButton = UIAlertAction(title: "Delete relay", style: UIAlertActionStyle.Default) { (alert) -> Void in
                print("Video deleted")
                
                let url = globalurl + "api/answers/" + answerId
                Alamofire.request(.DELETE, url, parameters: nil)
                    .responseJSON { response in
                        print(response.request)
                        print(response.response)
                        print(response.result)
                        print(response.response?.statusCode)
                }
                self.myLikedAnswerArray.removeAtIndex(tag)
                self.tableView.reloadData()
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                print("Cancel Pressed", terminator: "")
            }
            let copyLinkButton = UIAlertAction(title: "Copy Video URL", style: UIAlertActionStyle.Default) { (alert) -> Void in
                
                UIPasteboard.generalPasteboard().string = "\(answerUrl)"
            }
            let facebookButton = UIAlertAction(title: "Share to Facebook", style: UIAlertActionStyle.Default) { (alert) -> Void in
                let thumbnailUrl = "https://s3-us-west-1.amazonaws.com/batonapp/BatonHighQuality.png"
                let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
                
                content.contentURL = NSURL(string: answerUrl)
                content.contentTitle = "re: \"\(questionContent)\""
                content.contentDescription = "A platfrom concise video discussions every day"
                content.imageURL = NSURL(string: thumbnailUrl )
                FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
                
            }
            let messageButton = UIAlertAction(title: "Share through Message", style: UIAlertActionStyle.Default) { (alert) -> Void in
                
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
                let composer = TWTRComposer()
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
        
    }
    
    func usernameTapped(sender: UIButton) {
        let tag = sender.tag
        self.mytag = tag
        //        Answers.logCustomEventWithName("Username Tapped",
        //            customAttributes: ["method": "nameOnAnswer", "where": "FollowingAnswers"])
        self.performSegueWithIdentifier("segueToSelf", sender: self)
        
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFromProfileToAnswers" {
            let answerVC: AnswersViewController = segue.destinationViewController as! AnswersViewController
            if counter == 0 {
                let indexPath = self.questionIndex
                let content = self.myFeaturedAnswerArray[indexPath].question_content
                let id = self.myFeaturedAnswerArray[indexPath].question_id
                let featuredQuestion = self.myFeaturedAnswerArray[indexPath].featuredQuestion
                if featuredQuestion {
                    answerVC.fromFeatured = true
                }
                answerVC.content = content
                answerVC.id = id
                answerVC.fromFollowing = true
            } else if counter == 1 {
                let indexPath = self.tableView.indexPathForSelectedRow
                let content = self.myQuestionArray[indexPath!.row].content
                let id = self.myQuestionArray[indexPath!.row].id
                let creatorname = self.myQuestionArray[indexPath!.row].creatorname
                let question = self.myQuestionArray[indexPath!.row]
                answerVC.content = content
                answerVC.id = id
                answerVC.creatorname = creatorname
                answerVC.fromProfile = true
                answerVC.question = question
            } else if counter == 2 {
                let indexPath = self.questionIndex
                let content = self.myAnswerArray[indexPath].question_content
                let id = self.myAnswerArray[indexPath].question_id
                let featuredQuestion = self.myAnswerArray[indexPath].featuredQuestion
                if featuredQuestion {
                    answerVC.fromFeatured = true
                }
                answerVC.content = content
                answerVC.id = id
                answerVC.fromFollowing = true
            } else if counter == 3 {
                let indexPath = self.questionIndex
                let content = self.myLikedAnswerArray[indexPath].question_content
                let id = self.myLikedAnswerArray[indexPath].question_id
                let featuredQuestion = self.myLikedAnswerArray[indexPath].featuredQuestion
                if featuredQuestion {
                    answerVC.fromFeatured = true
                }
                answerVC.content = content
                answerVC.id = id
                answerVC.fromFollowing = true
            }
            
        } else if segue.identifier == "segueFromProfileToFollowers" {
            let userListVC: UserListViewController = segue.destinationViewController as! UserListViewController
            userListVC.counter = "followers"
            userListVC.id = self.id
        } else if segue.identifier == "segueFromProfileToFollowing" {
            let userListVC: UserListViewController = segue.destinationViewController as! UserListViewController
            userListVC.counter = "following"
            userListVC.id = self.id
        } else if segue.identifier == "segueToSelf" {
            Answers.logCustomEventWithName("Username Tapped",
                customAttributes: ["method": "nameOnAnswer", "where": "ProfileLikes"])
//            let mytag = sender!.tag
//            print(mytag)
            let profileVC: ProfileViewController = segue.destinationViewController as! ProfileViewController
            let creatorId = myLikedAnswerArray[mytag].creator
            let creatorname = myLikedAnswerArray[mytag].creatorname
            profileVC.fromOtherVC = true
            profileVC.creatorId = creatorId
            profileVC.creatorname = creatorname
        } else if segue.identifier == "segueToEditProfile" {
            let nav = segue.destinationViewController as! UINavigationController
            let editProfileVC: EditProfileTableViewController = nav.topViewController as! EditProfileTableViewController
            editProfileVC.twitterUsername = twitterUsername
        } else if segue.identifier == "segueToWebView" {
            let nav = segue.destinationViewController as! UINavigationController
            let webVC: WebViewController = nav.topViewController as! WebViewController
            let url = "http://twitter.com/" + twitterUsername
            
            webVC.urlToLoad = NSURL(string: url)
        } else if segue.identifier == "segueFromProfileToFeed" {
            let feedVC: FeedViewController = segue.destinationViewController as! FeedViewController
            let channelId = myQuestionArray[questionIndex].channel_id
            let channelName = myQuestionArray[questionIndex].channel_name
            feedVC.fromSpecificChannel = true
            feedVC.channelId = channelId
            feedVC.channelName = channelName
        } else if segue.identifier == "segueFromProfileToVideoPage" {
            let videoPageVC: VideoPageViewController = segue.destinationViewController as! VideoPageViewController
            videoPageVC.transitioningDelegate = self
            videoPageVC.interactor = interactor
            if counter == 0 {
                videoPageVC.answers = myFeaturedAnswerArray
            }
            if counter == 2 {
                videoPageVC.answers = myAnswerArray
            }
            if counter == 3 {
                videoPageVC.answers = myLikedAnswerArray
            }
            videoPageVC.indexPath = self.selectedIndexPath
            videoPageVC.fromFollowing = true
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func imageButtonClicked(sender: UIButton) {
        print("Clicked")
        if fromOtherVC {
            
        } else  {
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
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        let squareImage = RBSquareImage(editedImage)
        
        // Save image in S3 with the userID
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let testFileURL1 = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp"))
        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        
        let key = "profilePics/" + userid
        let data = UIImageJPEGRepresentation(squareImage, 0.1)
        data!.writeToURL(testFileURL1, atomically: true)
        uploadRequest1.bucket = S3BucketName
        uploadRequest1.key =  key
        uploadRequest1.body = testFileURL1
        
        
        let task = transferManager.upload(uploadRequest1)
        task.continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                print("Error: \(task.error)", terminator: "")
            } else {
                self.tableView.reloadData()
                print("Upload successful", terminator: "")
            }
            return nil
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    // MARK: - scrollView
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
                    if (cell.player.rate > 0) {
                        if counter == 0 {
//                            let url = globalurl + "api/answers/" + myFeaturedAnswerArray[(indexPath?.row)!].id + "/viewed/"
//                            
//                            Alamofire.request(.PUT, url, parameters: nil)
//                                .responseJSON { response in
//                                    let result = response.result.value
//                                    print(result)
//                                    if result == nil {
//                                        print("Not viewed")
//                                        
//                                    } else {
//                                        print("Viewed")
//                                    }
//                            }
                        } else {
//                            let url = globalurl + "api/answers/" + myAnswerArray[(indexPath?.row)!].id + "/viewed/"
//                            
//                            Alamofire.request(.PUT, url, parameters: nil)
//                                .responseJSON { response in
//                                    let result = response.result.value
//                                    print(result)
//                                    if result == nil {
//                                        print("Not viewed")
//                                        
//                                    } else {
//                                        print("Viewed")
//                                    }
//                            }
                        }
                        
                    } else {
                        if counter == 0 {
//                            let url = globalurl + "api/answers/" + myFeaturedAnswerArray[(indexPath?.row)!].id + "/viewed/"
//                            
//                            Alamofire.request(.PUT, url, parameters: nil)
//                                .responseJSON { response in
//                                    let result = response.result.value
//                                    print(result)
//                                    if result == nil {
//                                        print("Not viewed")
//                                        
//                                    } else {
//                                        print("Viewed")
//                                    }
//                            }
                            let seconds : Int64 = 0
                            let preferredTimeScale : Int32 = 1
                            let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
                            
                            cell.player.seekToTime(seekTime)
                        } else {
//                            let url = globalurl + "api/answers/" + myAnswerArray[(indexPath?.row)!].id + "/viewed/"
//                            
//                            Alamofire.request(.PUT, url, parameters: nil)
//                                .responseJSON { response in
//                                    let result = response.result.value
//                                    print(result)
//                                    if result == nil {
//                                        print("Not viewed")
//                                        
//                                    } else {
//                                        print("Viewed")
//                                    }
//                            }
                            let seconds : Int64 = 0
                            let preferredTimeScale : Int32 = 1
                            let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
                            
                            cell.player.seekToTime(seekTime)
                        }
                        
                    }
                } else {
                    cell.player.pause()
                }
            }
            else if cell.isKindOfClass(ProfileLikedTableViewCell) {
                let indexPath = tableView.indexPathForCell(cell)
                let cellRect = tableView.rectForRowAtIndexPath(indexPath!)
                let superView = tableView.superview
                let convertedRect = tableView.convertRect(cellRect, toView: superView)
                let intersect = CGRectIntersection(tableView.frame, convertedRect)
                let visibleHeight = CGRectGetHeight(intersect)
                let cellHeight = tableView.frame.height * 0.6
                let cell = cell as! ProfileLikedTableViewCell
                
                if visibleHeight > cellHeight {
                    if (cell.player.rate > 0) {
//                        let url = globalurl + "api/answers/" + myLikedAnswerArray[(indexPath?.row)!].id + "/viewed/"
//                        
//                        Alamofire.request(.PUT, url, parameters: nil)
//                            .responseJSON { response in
//                                let result = response.result.value
//                                print(result)
//                                if result == nil {
//                                    print("Not viewed")
//                                    
//                                } else {
//                                    print("Viewed")
//                                }
//                        }
                    } else {
//                        let url = globalurl + "api/answers/" + myLikedAnswerArray[(indexPath?.row)!].id + "/viewed/"
//                        
//                        Alamofire.request(.PUT, url, parameters: nil)
//                            .responseJSON { response in
//                                let result = response.result.value
//                                print(result)
//                                if result == nil {
//                                    print("Not viewed")
//                                    
//                                } else {
//                                    print("Viewed")
//                                }
//                        }
                        let seconds : Int64 = 0
                        let preferredTimeScale : Int32 = 1
                        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
                        
                        cell.player.seekToTime(seekTime)
                    }
                } else {
                    cell.player.pause()
                }
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

extension ProfileViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

extension Int {
    func addCommas(integer: Int) -> String {
        let fmt = NSNumberFormatter()
        fmt.numberStyle = .DecimalStyle
        let string = fmt.stringFromNumber(integer)
        
        return string!
    }
    
    func abbreviateNumberAtThousand() -> String {
        func floatToString(val: Float) -> String {
            var ret: NSString = NSString(format: "%.1f", val)
            
            let c = ret.characterAtIndex(ret.length - 1)
            
            if c == 46 {
                ret = ret.substringToIndex(ret.length - 1)
            }
            
            return ret as String
        }
        
        var abbrevNum = ""
        var num: Float = Float(self)
        
        if num >= 1000 {
            var abbrev = ["k","m","b"]
            
            for var i = abbrev.count-1; i >= 0; i-- {
                let sizeInt = pow(Double(10), Double((i+1)*3))
                let size = Float(sizeInt)
                
                if size <= num {
                    num = num/size
                    var numStr: String = floatToString(num)
                    if numStr.hasSuffix(".0") {
                        let startIndex = numStr.startIndex.advancedBy(0)
                        let endIndex = numStr.endIndex.advancedBy(-2)
                        let range = startIndex..<endIndex
                        numStr = numStr.substringWithRange( range )
                    }
                    
                    let suffix = abbrev[i]
                    abbrevNum = numStr+suffix
                }
            }
        } else {
            abbrevNum = "\(num)"
            let startIndex = abbrevNum.startIndex.advancedBy(0)
            let endIndex = abbrevNum.endIndex.advancedBy(-2)
            let range = startIndex..<endIndex
            abbrevNum = abbrevNum.substringWithRange( range )
        }
        
        return abbrevNum
    }
    
    func abbreviateNumber() -> String {
        func floatToString(val: Float) -> String {
            var ret: NSString = NSString(format: "%.1f", val)
            
            let c = ret.characterAtIndex(ret.length - 1)
            
            if c == 46 {
                ret = ret.substringToIndex(ret.length - 1)
            }
            
            return ret as String
        }
        
        var abbrevNum = ""
        var num: Float = Float(self)
        
        if num >= 10000 {
            var abbrev = ["k","m","b"]
            
            for var i = abbrev.count-1; i >= 0; i-- {
                let sizeInt = pow(Double(10), Double((i+1)*3))
                let size = Float(sizeInt)
                
                if size <= num {
                    num = num/size
                    var numStr: String = floatToString(num)
                    if numStr.hasSuffix(".0") {
                        let startIndex = numStr.startIndex.advancedBy(0)
                        let endIndex = numStr.endIndex.advancedBy(-2)
                        let range = startIndex..<endIndex
                        numStr = numStr.substringWithRange( range )
                    }
                    
                    let suffix = abbrev[i]
                    abbrevNum = numStr+suffix
                }
            }
        } else if num >= 1000 && num <= 9999 {
            abbrevNum = addCommas(self)
        } else {
            abbrevNum = "\(num)"
            let startIndex = abbrevNum.startIndex.advancedBy(0)
            let endIndex = abbrevNum.endIndex.advancedBy(-2)
            let range = startIndex..<endIndex
            abbrevNum = abbrevNum.substringWithRange( range )
        }
        
        return abbrevNum
    }
}
