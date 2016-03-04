//
//  FeedViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 10/29/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AWSS3
import KeychainSwift
import JWTDecode
import Crashlytics

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    let keychain = KeychainSwift()
    var questionArray = [Question]()
    var hotQuestionArray = [Question]()
    var featuredQuestionArray = [Question]()
    var selectedIndexPath = 0
    var currentPage = 0
    private var lastContentOffset: CGFloat = 0
    var isLoading = false
    var counter = 0
    var selectedRow = 1
    var recordedRow = 1
    var refreshControl:UIRefreshControl!
    var fromSpecificChannel = false
    var channelId = ""
    var channelName = ""
    var myChannelIdArray:[String]!
    var fromFavorites = false
    
    // MARK: - viewWill/viewDid
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool) {
        // Makes sure tabBar is not hidden because AnswersVC hides it
        self.tabBarController!.tabBar.hidden = false
        
        if userid != "" {
            self.checkNotifications()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Load")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        self.tableView.scrollsToTop = true
        
        // Remove all from arrays
        self.questionArray.removeAll(keepCapacity: true)
        self.hotQuestionArray.removeAll(keepCapacity: true)
        self.featuredQuestionArray.removeAll(keepCapacity: true)
        
        let label = UILabel.init(frame: CGRectMake(0, 0, 100, 30))
        
        if fromSpecificChannel {
            label.text = self.channelName
            self.loadChannelData()
        } else if fromFavorites {
            label.text = self.channelName
            self.loadFavoritesData()
        } else {
            label.text = "Top Posts"
            self.loadHotQuestionData()
            self.loadFeaturedData()
        }
        
        label.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, view.frame.origin.y + 20)
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        label.textColor = UIColor(red:0.91, green:0.27, blue:0.27, alpha:1.0)
        self.navigationItem.titleView = label
        
//        if (!fromSpecificChannel) {
//            let label = UILabel.init(frame: CGRectMake(0, 0, 100, 30))
//            label.text = "Top Posts"
//            label.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, view.frame.origin.y + 20)
//            label.textAlignment = NSTextAlignment.Center
//            label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
//            label.textColor = UIColor(red:0.91, green:0.27, blue:0.27, alpha:1.0)
//            self.navigationItem.titleView = label
////            self.loadData()
//            self.loadHotQuestionData()
//            self.loadFeaturedData()
//        } else {
//            let label = UILabel.init(frame: CGRectMake(0, 0, 100, 30))
//            label.text = self.channelName
//            label.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, view.frame.origin.y + 20)
//            label.textAlignment = NSTextAlignment.Center
//            label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
//            label.textColor = UIColor(red:0.91, green:0.27, blue:0.27, alpha:1.0)
//            self.navigationItem.titleView = label
////            self.loadTopChannelData()
//            self.loadChannelData()
//        }
        
        
        // Add Notification observers
        // Increase answercount when user answers question
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeFeed", name: "submittedAnswer", object: nil)
        // Refresh feed if user asks a question
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFeed", name: "askedQuestion", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFeed", name: "questionEdited", object: nil)
        // Add function to segmented control
//        self.segmentedControl.addTarget(self, action: "profileSegmentedControlChanged:", forControlEvents: .ValueChanged)
        
        // Add refreshControl and its own function
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
 
    }
    
    // MARK: - loadData functions
    
    func loadChannelData() {
        let url = globalurl + "api/channelquestions-ordered/" + channelId
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                }
                self.questionArray.removeAll(keepCapacity: true)
                
                let json = JSON(value!)
                //                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    let content = subJson["content"].string
                    let id = subJson["_id"].string
                    var answercount = subJson["answercount"].number?.integerValue
                    let creatorname = subJson["creatorname"].string
                    let creator = subJson["creator"].string
                    let createdAt = subJson["created_at"].string
                    var likecount = subJson["likes"].number?.integerValue
                    let featured = subJson["featured"].bool
                    var channelId = subJson["channel_id"].string
                    var channelName = subJson["channel_name"].string
                    
                    if channelId == nil {
                        channelId = ""
                    }
                    
                    if channelName == nil {
                        channelName = ""
                    }
                    
                    if featured == true {
                        continue
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
                    
                    
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: false, currentuser: false, createdAt: yourDate, creator: creator, likecount: likecount, channel_id: channelId, channel_name: channelName)
                    
                    self.questionArray.append(question)
                    // Order by date from most recent to latest
                    self.questionArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                    
                    
//                    self.tableView.reloadData()
                }
                dispatch_async(dispatch_get_main_queue(),{
                    self.tableView.reloadData()
                })
        }
    }

    
    func loadFavoritesData() {
        let url = globalurl + "api/favoritechannels-ordered/"
        let parameters = [
            "channelArray" : myChannelIdArray
        ]
        
        Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                }
                
                self.questionArray.removeAll(keepCapacity: true)
                
                let json = JSON(value!)
                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    let content = subJson["content"].string
                    let id = subJson["_id"].string
                    var answercount = subJson["answercount"].number?.integerValue
                    let creatorname = subJson["creatorname"].string
                    let creator = subJson["creator"].string
                    let createdAt = subJson["created_at"].string
                    var likecount = subJson["likes"].number?.integerValue
                    let featured = subJson["featured"].bool
                    var channelId = subJson["channel_id"].string
                    var channelName = subJson["channel_name"].string
                    
                    if channelId == nil {
                        channelId = ""
                    }
                    
                    if channelName == nil {
                        channelName = ""
                    }
                    
                    if featured == true {
                        continue
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
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: false, currentuser: false, createdAt: yourDate, creator: creator, likecount: likecount, channel_id: channelId, channel_name: channelName)
                    self.questionArray.append(question)
                    // Order by date from most recent to latest
                    self.questionArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                    
                    
                    
                }
                dispatch_async(dispatch_get_main_queue(),{
                    self.tableView.reloadData()
                })
        }
    }
    
    func loadTopFavoriteData() {
        let url = globalurl + "api/favoritechannels-hottest/"
        let parameters = [
            "channelArray" : myChannelIdArray
        ]
        
        Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON)
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
                    var answercount = subJson["answercount"].number?.integerValue
                    let creatorname = subJson["creatorname"].string
                    let creator = subJson["creator"].string
                    let createdAt = subJson["created_at"].string
                    var likecount = subJson["likes"].number?.integerValue
                    let featured = subJson["featured"].bool
                    var channelId = subJson["channel_id"].string
                    var channelName = subJson["channel_name"].string
                    
                    if channelId == nil {
                        channelId = ""
                    }
                    
                    if channelName == nil {
                        channelName = ""
                    }
                    
                    if featured == true {
                        continue
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
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: false, currentuser: false, createdAt: yourDate, creator: creator, likecount: likecount, channel_id: channelId, channel_name: channelName)
                    self.hotQuestionArray.append(question)
                    // Order by date from most recent to latest
                    self.hotQuestionArray.sortInPlace({ $0.likecount > $1.likecount })
                    
                    
                    
                }
                dispatch_async(dispatch_get_main_queue(),{
                    self.tableView.reloadData()
                })
        }
    }
    
    func loadTopChannelData() {
        let url = globalurl + "api/channelquestions-hottest/" + channelId
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                }
                
                let json = JSON(value!)
                //                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    let content = subJson["content"].string
                    let id = subJson["_id"].string
                    var answercount = subJson["answercount"].number?.integerValue
                    let creatorname = subJson["creatorname"].string
                    let creator = subJson["creator"].string
                    let createdAt = subJson["created_at"].string
                    var likecount = subJson["likes"].number?.integerValue
                    let featured = subJson["featured"].bool
                    var channelId = subJson["channel_id"].string
                    var channelName = subJson["channel_name"].string
                    
                    if channelId == nil {
                        channelId = ""
                    }
                    
                    if channelName == nil {
                        channelName = ""
                    }
                    
                    if featured == true {
                        continue
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
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: false, currentuser: false, createdAt: yourDate, creator: creator, likecount: likecount, channel_id: channelId, channel_name: channelName)
                    self.hotQuestionArray.append(question)
                    // Order by date from most recent to latest
                    self.hotQuestionArray.sortInPlace({ $0.likecount > $1.likecount })
                    
                    
                    
                }
                dispatch_async(dispatch_get_main_queue(),{
                    self.tableView.reloadData()
                })
        }
    }
    
    
    
    // Get featured questions
    func loadFeaturedData() {
        let url = globalurl + "api/questions-featured/" + userid
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                } else {
                    self.featuredQuestionArray.removeAll(keepCapacity: true)
                    let json = JSON(value!)
                    //                print("JSON: \(json)")
                    for (_,subJson):(String, JSON) in json {
                        //Do something you want
                        let content = subJson["content"].string
                        let id = subJson["_id"].string
                        var answercount = subJson["answercount"].number?.integerValue
                        //                    var creatorname = subJson["creatorname"].string
                        //                    let creator = subJson["creator"].string
                        let createdAt = subJson["created_at"].string
                        var likecount = subJson["likes"].number?.integerValue
                        let inactive = subJson["inactive"].bool
                        var channelId = subJson["channel_id"].string
                        var channelName = subJson["channel_name"].string
                        var newVersionActive = subJson["newVersionActive"].bool
                        
                        if newVersionActive == nil {
                            newVersionActive = false
                        }
                        
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
                        print(inactive)
                        print(newVersionActive)
                        
                        if inactive == true {
                            if newVersionActive! {
                                let question = Question(content: content, creatorname: "", id: id, answercount: answercount, answered: false, currentuser: false, createdAt: yourDate, creator: "", likecount: likecount, channel_id: channelId, channel_name: channelName)
                                self.featuredQuestionArray.append(question)
                                self.featuredQuestionArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                
                                
                                self.tableView.reloadData()
                            } else {
                                continue
                            }
                        } else {
                            let question = Question(content: content, creatorname: "", id: id, answercount: answercount, answered: false, currentuser: false, createdAt: yourDate, creator: "", likecount: likecount, channel_id: channelId, channel_name: channelName)
                            self.featuredQuestionArray.append(question)
                            self.featuredQuestionArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                            
                            
                            self.tableView.reloadData()
                        }
                        
                        
                        
                }
                
                
                }
        }
    }
    
    // Get questions ordered by date from most recent to latest
    func loadData() {
        let url = globalurl + "api/questions-ordered/" + userid
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                }
                self.questionArray.removeAll(keepCapacity: true)
                let json = JSON(value!)
//                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    let content = subJson["content"].string
                    let id = subJson["_id"].string
                    var answercount = subJson["answercount"].number?.integerValue
                    let creatorname = subJson["creatorname"].string
                    let creator = subJson["creator"].string
                    let createdAt = subJson["created_at"].string
                    var likecount = subJson["likes"].number?.integerValue
                    let featured = subJson["featured"].bool
                    var channelId = subJson["channel_id"].string
                    var channelName = subJson["channel_name"].string
                    
                    if channelId == nil {
                        channelId = ""
                    }
                    
                    if channelName == nil {
                        channelName = ""
                    }
                    
                    if featured == true {
                        continue
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
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: false, currentuser: false, createdAt: yourDate, creator: creator, likecount: likecount, channel_id: channelId, channel_name: channelName)
                    self.questionArray.append(question)
                    // Order by date from most recent to latest
                    self.questionArray.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })

                    
                    self.tableView.reloadData()
                }
        }
    }
    
    func loadHotQuestionData() {
        let url = globalurl + "api/questions-hottest/" + userid
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                }
                self.hotQuestionArray.removeAll(keepCapacity: true)
                let json = JSON(value!)
//                print("JSON: \(json)")
                for (_,subJson):(String, JSON) in json {
                    //Do something you want
                    let content = subJson["content"].string
                    let id = subJson["_id"].string
                    var answercount = subJson["answercount"].number?.integerValue
                    let creatorname = subJson["creatorname"].string
                    let creator = subJson["creator"].string
                    let createdAt = subJson["created_at"].string
                    var likecount = subJson["likes"].number?.integerValue
                    let featured = subJson["featured"].bool
                    var channelId = subJson["channel_id"].string
                    var channelName = subJson["channel_name"].string
                    
                    if channelId == nil {
                        channelId = ""
                    }
                    
                    if channelName == nil {
                        channelName = ""
                    }
                    
                    if featured == true {
                        continue
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
                    
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: false, currentuser: false, createdAt: yourDate, creator: creator, likecount: likecount, channel_id: channelId, channel_name: channelName)
                    self.hotQuestionArray.append(question)
                    // Order by likes, from most to least
                    self.hotQuestionArray.sortInPlace({ $0.likecount > $1.likecount })
                    
                    self.tableView.reloadData()
                }
        }
    }
    
    // Function used for paginated data
//    func loadPaginatedData() {
//        let url = globalurl + "api/questions/page/" + "\(self.currentPage)"
//        
//        Alamofire.request(.GET, url, parameters: nil)
//            .responseJSON { response in
//                var value = response.result.value
//                
//                if value == nil {
//                    value = []
//                }
//                
//                let json = JSON(value!)
//                print("JSON: \(json)")
//                for (_,subJson):(String, JSON) in json {
//                    //Do something you want
//
//                    let id = subJson["_id"].string
//                    let content = subJson["content"].string
//                    var answercount = subJson["answercount"].number?.integerValue
//                    var creatorname = subJson["creatorname"].string
//                    let answeredBy = subJson["answered_by"]
//                    let creator = subJson["creator"].string
//                    var answered = false
//                    var user = false
//                    let createdAt = subJson["created_at"].string
//                    
//                    var likecount = subJson["likes"].number?.integerValue
//                    
//                    if likecount == nil {
//                        likecount = 0
//                    }
//                    
//                    let dateFor: NSDateFormatter = NSDateFormatter()
//                    dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//                    let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
//                    
//                    if creator == userid {
//                        user = true
//                    }
//                    
//                    for (_,subJson):(String, JSON) in answeredBy {
//                        let answerer = subJson.string
//                        if answerer == userid {
//                            answered = true
//                        }
//                    }
//                    
//                    if answercount == nil {
//                        answercount = 0
//                    }
//                    
//                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: answered, currentuser: user, createdAt: yourDate, creator: creator, likecount: likecount)
//                    self.questionArray.append(question)
//                    
//                    self.tableView.reloadData()
//                }
//        }
//    }
//    

    
    
    // MARK: - UISegmentedControl function
    func profileSegmentedControlChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            print("Money")
            counter = 0
            if fromSpecificChannel {
                if questionArray.count == 0 {
                    self.loadChannelData()
                }
            } else if fromFavorites {
                if questionArray.count == 0 {
                    self.loadFavoritesData()
                }
            }
            
            Answers.logCustomEventWithName("Top/New Segmented Control on Channels",
                customAttributes: ["from": channelName, "bar": "New"])
        } else if sender.selectedSegmentIndex == 1 {
            print("Mayweather")
            counter = 1
            if fromSpecificChannel {
                if hotQuestionArray.count == 0 {
                    self.loadTopChannelData()
                }
            } else if fromFavorites {
                if hotQuestionArray.count == 0 {
                    self.loadTopFavoriteData()
                }
            }
            
            Answers.logCustomEventWithName("Top/New Segmented Control on Channels",
                customAttributes: ["from": channelName, "bar": "Top"])
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Notification Center functions
    // Add 1 to answerCount through Notification Center
//    func changeFeed(){
//        let count = questionArray[selectedIndexPath].answercount
//        questionArray[selectedIndexPath].answercount = count + 1
//        questionArray[selectedIndexPath].answered = true
//        self.tableView.reloadData()
//    }
    
    func refreshFeed(){
        if fromSpecificChannel {
//            self.questionArray.removeAll(keepCapacity: true)
//            self.hotQuestionArray.removeAll(keepCapacity: true)
            self.counter = 0
            self.tableView.reloadData()
//            self.loadTopChannelData()
            self.loadChannelData()
        } else if fromFavorites {
//            self.questionArray.removeAll(keepCapacity: true)
//            self.hotQuestionArray.removeAll(keepCapacity: true)
            self.counter = 0
            self.tableView.reloadData()
            self.loadFavoritesData()
//            self.loadTopFavoriteData()
        } else {
//            self.questionArray.removeAll(keepCapacity: true)
//            self.hotQuestionArray.removeAll(keepCapacity: true)
//            self.featuredQuestionArray.removeAll(keepCapacity: true)
            //        self.currentPage = 0
            //        self.loadPaginatedData()
            self.loadFeaturedData()
//            self.loadData()
            self.loadHotQuestionData()
//            self.tableView.reloadData()
        }
        
    }
    
    // MARK: - refreshControl function
    func refresh(sender:AnyObject){
        if fromSpecificChannel {
            self.questionArray.removeAll(keepCapacity: true)
            self.hotQuestionArray.removeAll(keepCapacity: true)
            self.loadTopChannelData()
            self.loadChannelData()
            self.tableView.reloadData()
        } else if fromFavorites {
            self.questionArray.removeAll(keepCapacity: true)
            self.hotQuestionArray.removeAll(keepCapacity: true)
            self.loadFavoritesData()
            self.loadTopFavoriteData()
            self.tableView.reloadData()
        } else {
            self.questionArray.removeAll(keepCapacity: true)
            self.hotQuestionArray.removeAll(keepCapacity: true)
            self.featuredQuestionArray.removeAll(keepCapacity: true)
            //        self.currentPage = 0
            self.loadFeaturedData()
            self.loadData()
            self.loadHotQuestionData()
            //        self.loadPaginatedData()
            self.tableView.reloadData()
        }
        
        
        let delayInSeconds = 1.0;
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            self.refreshControl!.endRefreshing()
        }
    }

    
    
    // MARK: - tableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // New tab has a section for Featured questions and the new questions
        // Top tab only has a section for top questions
        if fromSpecificChannel {
            return 2
        } else if fromFavorites {
            return 2
        } else {
            return 2
        }
//        if counter == 0 {
//            return 2
//        } else {
//            return 1
//        }
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (fromSpecificChannel || fromFavorites) {
            if section == 0 {
                return 1
            } else {
                if counter == 0 {
                    return questionArray.count
                } else {
                    return hotQuestionArray.count
                }
            }
        } else {
            if section == 0 {
                return featuredQuestionArray.count
            } else {
                return hotQuestionArray.count
            }
        }
        
//        if counter == 0 {
//            if section == 0 {
//                return featuredQuestionArray.count
//            } else {
//                return questionArray.count
//            }
//        } else {
//            return hotQuestionArray.count
//        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (fromSpecificChannel || fromFavorites) {
            if indexPath.section == 0 {
                let cell: FeedSegmentedTableViewCell = tableView.dequeueReusableCellWithIdentifier("SegmentedCell", forIndexPath: indexPath) as! FeedSegmentedTableViewCell
                
                cell.segmentedControl.addTarget(self, action: "profileSegmentedControlChanged:", forControlEvents: .ValueChanged)
                if counter == 0 {
                    cell.segmentedControl.selectedSegmentIndex = 0
                } else {
                    cell.segmentedControl.selectedSegmentIndex = 1
                }
                
                return cell
            } else {
                if counter == 0 {
                    let cell: QuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionTableViewCell
                    
                    cell.contentView.backgroundColor = UIColor.clearColor()
                    
                    if fromSpecificChannel {
                        cell.channelButton.hidden = true
                    } else if fromFavorites {
                        var channelName = questionArray[indexPath.row].channel_name
                        if channelName == "" {
                            channelName = "Other"
                        }
                        cell.channelButton.setTitle(channelName, forState: .Normal)
                        cell.channelButton.hidden = false
                        cell.channelButton.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
                        cell.channelButton.layer.cornerRadius = 5
                        cell.channelButton.sizeToFit()
                        cell.channelButton.tag = indexPath.row
                    }
                    
                    
                    
                    cell.preservesSuperviewLayoutMargins = false
                    cell.separatorInset = UIEdgeInsetsZero
                    cell.layoutMargins = UIEdgeInsetsZero
                    
                    cell.questionTextView.text = questionArray[indexPath.row].content
                    cell.questionTextView.userInteractionEnabled = false
                    
                    let answercount = questionArray[indexPath.row].answercount
                    cell.answercountLabel.text =  "\(answercount)"
                    
                    let likecount = questionArray[indexPath.row].likecount
                    let formattedlikecount = likecount.abbreviateNumberAtThousand()
                    cell.likecountTextView.text = "\(formattedlikecount)"
                    cell.likecountTextView.editable = false
                    cell.likecountTextView.selectable = false
                    
                    let date = questionArray[indexPath.row].createdAt
                    let timeAgo = timeAgoSinceDate(date, numericDates: true)
                    
                    cell.timeAgoLabel.text = timeAgo
                    
                    return cell
                } else {
                    let cell: QuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionTableViewCell
                    
                    cell.contentView.backgroundColor = UIColor.clearColor()
                    
                    if fromSpecificChannel {
                        cell.channelButton.hidden = true
                    } else if fromFavorites {
                        var channelName = hotQuestionArray[indexPath.row].channel_name
                        if channelName == "" {
                            channelName = "Other"
                        }
                        cell.channelButton.setTitle(channelName, forState: .Normal)
                        cell.channelButton.hidden = false
                        cell.channelButton.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
                        cell.channelButton.layer.cornerRadius = 5
                        cell.channelButton.sizeToFit()
                        cell.channelButton.tag = indexPath.row
                    }
                    
                    cell.preservesSuperviewLayoutMargins = false
                    cell.separatorInset = UIEdgeInsetsZero
                    cell.layoutMargins = UIEdgeInsetsZero
                    
                    cell.questionTextView.text = hotQuestionArray[indexPath.row].content
                    cell.questionTextView.userInteractionEnabled = false
                    
                    let answercount = hotQuestionArray[indexPath.row].answercount
                    cell.answercountLabel.text =  "\(answercount)"
                    
                    let likecount = hotQuestionArray[indexPath.row].likecount
                    let formattedlikecount = likecount.abbreviateNumberAtThousand()
                    cell.likecountTextView.text = "\(formattedlikecount)"
                    cell.likecountTextView.editable = false
                    cell.likecountTextView.selectable = false
                    
                    let date = hotQuestionArray[indexPath.row].createdAt
                    let timeAgo = timeAgoSinceDate(date, numericDates: true)
                    
                    cell.timeAgoLabel.text = timeAgo
                    
                    return cell
                }
                
            }
        } else {
            if indexPath.section == 0 {
                let cell: QuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionTableViewCell
                
                // Makes cell separators go to both ends
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsetsZero
                cell.layoutMargins = UIEdgeInsetsZero
                
                cell.channelButton.hidden = true
                
                cell.questionTextView.text = featuredQuestionArray[indexPath.row].content
                cell.questionTextView.userInteractionEnabled = false
                
                let answercount = featuredQuestionArray[indexPath.row].answercount
                
                cell.answercountLabel.text =  "\(answercount)"
                
                let likecount = featuredQuestionArray[indexPath.row].likecount
                let formattedlikecount = likecount.abbreviateNumberAtThousand()
                cell.likecountTextView.text = "\(formattedlikecount)"
                cell.likecountTextView.editable = false
                cell.likecountTextView.selectable = false
                
                cell.timeAgoLabel.text = ""
                cell.contentView.backgroundColor = UIColor(red:1.0, green:0.97, blue:0.61, alpha:1.0)
                
                return cell
                
            } else {
                let cell: QuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionTableViewCell
                
                cell.contentView.backgroundColor = UIColor.clearColor()
                
                cell.preservesSuperviewLayoutMargins = false
                cell.separatorInset = UIEdgeInsetsZero
                cell.layoutMargins = UIEdgeInsetsZero
                
                var channelName = hotQuestionArray[indexPath.row].channel_name
                if channelName == "" {
                    channelName = "Other"
                }
                
                cell.channelButton.hidden = false
                cell.channelButton.setTitle(channelName, forState: .Normal)
                cell.channelButton.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
                cell.channelButton.layer.cornerRadius = 5
                cell.channelButton.sizeToFit()
                cell.channelButton.tag = indexPath.row
                //            cell.channelButton.addTarget(self, action: "goToChannel:", forControlEvents: .TouchUpInside)
                
                cell.questionTextView.text = hotQuestionArray[indexPath.row].content
                cell.questionTextView.userInteractionEnabled = false
                
                let answercount = hotQuestionArray[indexPath.row].answercount
                cell.answercountLabel.text =  "\(answercount)"
                
                let likecount = hotQuestionArray[indexPath.row].likecount
                let formattedlikecount = likecount.abbreviateNumberAtThousand()
                cell.likecountTextView.text = "\(formattedlikecount)"
                cell.likecountTextView.editable = false
                cell.likecountTextView.selectable = false
                
                let date = hotQuestionArray[indexPath.row].createdAt
                let timeAgo = timeAgoSinceDate(date, numericDates: true)
                
                cell.timeAgoLabel.text = timeAgo
                
                return cell
            }
            
        }
//        if counter == 0 {
//            // Section 0 is for featured questions
//            if indexPath.section == 0 {
//                let cell: QuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionTableViewCell
//                
//                // Makes cell separators go to both ends
//                cell.preservesSuperviewLayoutMargins = false
//                cell.separatorInset = UIEdgeInsetsZero
//                cell.layoutMargins = UIEdgeInsetsZero
//                
//                cell.channelButton.hidden = true
//                
//                cell.questionTextView.text = featuredQuestionArray[indexPath.row].content
//                cell.questionTextView.userInteractionEnabled = false
//                
//                let answercount = featuredQuestionArray[indexPath.row].answercount
//                
//                cell.answercountLabel.text =  "\(answercount)"
//                
//                let likecount = featuredQuestionArray[indexPath.row].likecount
//                let formattedlikecount = likecount.abbreviateNumber()
//                cell.likecountTextView.text = "\(formattedlikecount)"
//                cell.likecountTextView.editable = false
//                cell.likecountTextView.selectable = false
//                
//                cell.timeAgoLabel.text = ""
//                cell.contentView.backgroundColor = UIColor(red:1.0, green:0.97, blue:0.61, alpha:1.0)
//                
//                return cell
//                
//            }
//            
//            let cell: QuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionTableViewCell
//            
//            cell.contentView.backgroundColor = UIColor.clearColor()
//            
//            cell.preservesSuperviewLayoutMargins = false
//            cell.separatorInset = UIEdgeInsetsZero
//            cell.layoutMargins = UIEdgeInsetsZero
//            
//            var channelName = questionArray[indexPath.row].channel_name
//            if channelName == "" {
//                channelName = "Other"
//            }
//            
//            cell.channelButton.hidden = false
//            cell.channelButton.setTitle(channelName, forState: .Normal)
//            cell.channelButton.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
//            cell.channelButton.layer.cornerRadius = 5
//            cell.channelButton.sizeToFit()
////            cell.channelButton.addTarget(self, action: "goToChannel:", forControlEvents: .TouchUpInside)
//            
//            cell.questionTextView.text = questionArray[indexPath.row].content
//            cell.questionTextView.userInteractionEnabled = false
//            
//            let answercount = questionArray[indexPath.row].answercount
//            cell.answercountLabel.text =  "\(answercount)"
//            
//            let likecount = questionArray[indexPath.row].likecount
//            let formattedlikecount = likecount.abbreviateNumber()
//            cell.likecountTextView.text = "\(formattedlikecount)"
//            cell.likecountTextView.editable = false
//            cell.likecountTextView.selectable = false
//            
//            let date = questionArray[indexPath.row].createdAt
//            let timeAgo = timeAgoSinceDate(date, numericDates: true)
//            
//            cell.timeAgoLabel.text = timeAgo
//            
//            return cell
//        } else {
//            let cell: QuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionTableViewCell
//            
//            cell.contentView.backgroundColor = UIColor.clearColor()
//            
//            cell.preservesSuperviewLayoutMargins = false
//            cell.separatorInset = UIEdgeInsetsZero
//            cell.layoutMargins = UIEdgeInsetsZero
//            
//            cell.channelButton.hidden = true
//            
//            cell.questionTextView.text = hotQuestionArray[indexPath.row].content
//            cell.questionTextView.userInteractionEnabled = false
//            
//            let answercount = hotQuestionArray[indexPath.row].answercount
//            
//            cell.answercountLabel.text =  "\(answercount)"
//            
//            let likecount = hotQuestionArray[indexPath.row].likecount
//            let formattedlikecount = likecount.abbreviateNumber()
//            cell.likecountTextView.text = "\(formattedlikecount)"
//            cell.likecountTextView.editable = false
//            cell.likecountTextView.selectable = false
//            
//            let date = hotQuestionArray[indexPath.row].createdAt
//            let timeAgo = timeAgoSinceDate(date, numericDates: true)
//            
//            cell.timeAgoLabel.text = timeAgo
//            
//            return cell
//        }
        
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (fromSpecificChannel || fromFavorites) {
            if indexPath.section == 0 {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            } else {
                selectedRow = 1
                Answers.logCustomEventWithName("Post Clicked",
                    customAttributes: ["from": "Feed", "channel": channelName])
                self.performSegueWithIdentifier("segueToAnswerVC", sender: self)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        } else {
            if indexPath.section == 0 {
                selectedRow = 0
                Answers.logCustomEventWithName("Post Clicked",
                    customAttributes: ["from": "Feed", "channel": "Top Posts"])
                self.performSegueWithIdentifier("segueToAnswerVC", sender: self)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            } else {
                selectedRow = 1
                Answers.logCustomEventWithName("Post Clicked",
                    customAttributes: ["from": "Feed", "channel": "Top Posts"])
                self.performSegueWithIdentifier("segueToAnswerVC", sender: self)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
//        if counter == 0 {
//            // selectedRow helps indicate if user is going to a featured or regular question
//            if indexPath.section == 0 {
//                selectedRow = 0
//                self.performSegueWithIdentifier("segueToAnswerVC", sender: self)
//                tableView.deselectRowAtIndexPath(indexPath, animated: true)
//            } else {
//                selectedRow = 1
//                self.performSegueWithIdentifier("segueToAnswerVC", sender: self)
//                tableView.deselectRowAtIndexPath(indexPath, animated: true)
//            }
//        } else if counter == 1 {
//            self.performSegueWithIdentifier("segueToAnswerVC", sender: self)
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        }
        
    }
    
    // Must have to allow user to edit tableViewCell
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        // Creates the record action when swiping left
        let record = UITableViewRowAction(style: .Normal, title: "Record") { action, index in
            print("Record button tapped")
            self.selectedIndexPath = indexPath.row
            self.recordedRow = indexPath.section
            Answers.logCustomEventWithName("Record Method",
                customAttributes: ["method":"From Feed","userid":userid])
            self.performSegueWithIdentifier("segueToTakeVideoVC", sender: self)
        }
        record.backgroundColor = UIColor.orangeColor()
        
        return [record]
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToTakeVideoVC" {
            tableView.setEditing(false, animated: true)
            if (fromSpecificChannel || fromFavorites) {
                if counter == 0 {
                    let takeVideoVC: TakeVideoViewController = segue.destinationViewController as! TakeVideoViewController
                    let content = self.questionArray[selectedIndexPath].content
                    let id = self.questionArray[selectedIndexPath].id
                    takeVideoVC.content = content
                    takeVideoVC.id = id
                } else {
                    let takeVideoVC: TakeVideoViewController = segue.destinationViewController as! TakeVideoViewController
                    let content = self.hotQuestionArray[selectedIndexPath].content
                    let id = self.hotQuestionArray[selectedIndexPath].id
                    takeVideoVC.content = content
                    takeVideoVC.id = id
                }
                
            } else {
                if recordedRow == 0 {
                    let takeVideoVC: TakeVideoViewController = segue.destinationViewController as! TakeVideoViewController
                    let content = self.featuredQuestionArray[selectedIndexPath].content
                    let id = self.featuredQuestionArray[selectedIndexPath].id
                    takeVideoVC.content = content
                    takeVideoVC.id = id
                    takeVideoVC.fromFeatured = true
                } else if recordedRow == 1 {
                    let takeVideoVC: TakeVideoViewController = segue.destinationViewController as! TakeVideoViewController
                    let content = self.hotQuestionArray[selectedIndexPath].content
                    let id = self.hotQuestionArray[selectedIndexPath].id
                    takeVideoVC.content = content
                    takeVideoVC.id = id
                }
            }
//            if counter == 0 {
//                if recordedRow == 0 {
//                    let takeVideoVC: TakeVideoViewController = segue.destinationViewController as! TakeVideoViewController
//                    let content = self.featuredQuestionArray[selectedIndexPath].content
//                    let id = self.featuredQuestionArray[selectedIndexPath].id
//                    takeVideoVC.content = content
//                    takeVideoVC.id = id
//                    takeVideoVC.fromFeatured = true
//                } else if recordedRow == 1 {
//                    let takeVideoVC: TakeVideoViewController = segue.destinationViewController as! TakeVideoViewController
//                    let content = self.questionArray[selectedIndexPath].content
//                    let id = self.questionArray[selectedIndexPath].id
//                    takeVideoVC.content = content
//                    takeVideoVC.id = id
//                }
//            } else if counter == 1 {
//                let takeVideoVC: TakeVideoViewController = segue.destinationViewController as! TakeVideoViewController
//                let content = self.hotQuestionArray[selectedIndexPath].content
//                let id = self.hotQuestionArray[selectedIndexPath].id
//                takeVideoVC.content = content
//                takeVideoVC.id = id
//            }
            
        } else if segue.identifier == "segueToAnswerVC" {
            if fromSpecificChannel || fromFavorites {
                if counter == 0 {
                    let answerVC: AnswersViewController = segue.destinationViewController as! AnswersViewController
                    let indexPath = self.tableView.indexPathForSelectedRow
                    let content = self.questionArray[indexPath!.row].content
                    let id = self.questionArray[indexPath!.row].id
                    let creatorname = self.questionArray[indexPath!.row].creatorname
                    let question = self.questionArray[indexPath!.row]
                    self.selectedIndexPath = indexPath!.row
                    answerVC.content = content
                    answerVC.id = id
                    answerVC.creatorname = creatorname
                    answerVC.question = question
                } else {
                    let answerVC: AnswersViewController = segue.destinationViewController as! AnswersViewController
                    let indexPath = self.tableView.indexPathForSelectedRow
                    let content = self.hotQuestionArray[indexPath!.row].content
                    let id = self.hotQuestionArray[indexPath!.row].id
                    let creatorname = self.hotQuestionArray[indexPath!.row].creatorname
                    let question = self.hotQuestionArray[indexPath!.row]
                    self.selectedIndexPath = indexPath!.row
                    answerVC.content = content
                    answerVC.id = id
                    answerVC.creatorname = creatorname
                    answerVC.question = question
                }
            } else {
                if selectedRow == 0 {
                    let answerVC: AnswersViewController = segue.destinationViewController as! AnswersViewController
                    let indexPath = self.tableView.indexPathForSelectedRow
                    let content = self.featuredQuestionArray[indexPath!.row].content
                    let id = self.featuredQuestionArray[indexPath!.row].id
                    let creatorname = self.featuredQuestionArray[indexPath!.row].creatorname
                    let question = self.featuredQuestionArray[indexPath!.row]
                    self.selectedIndexPath = indexPath!.row
                    answerVC.content = content
                    answerVC.id = id
                    answerVC.creatorname = creatorname
                    answerVC.question = question
                    answerVC.fromFeatured = true
                } else if selectedRow == 1 {
                    let answerVC: AnswersViewController = segue.destinationViewController as! AnswersViewController
                    let indexPath = self.tableView.indexPathForSelectedRow
                    let content = self.hotQuestionArray[indexPath!.row].content
                    let id = self.hotQuestionArray[indexPath!.row].id
                    let creatorname = self.hotQuestionArray[indexPath!.row].creatorname
                    let question = self.hotQuestionArray[indexPath!.row]
                    self.selectedIndexPath = indexPath!.row
                    answerVC.content = content
                    answerVC.id = id
                    answerVC.creatorname = creatorname
                    answerVC.question = question
                }
            }
//            if counter == 0 {
//                if selectedRow == 0 {
//                    let answerVC: AnswersViewController = segue.destinationViewController as! AnswersViewController
//                    let indexPath = self.tableView.indexPathForSelectedRow
//                    let content = self.featuredQuestionArray[indexPath!.row].content
//                    let id = self.featuredQuestionArray[indexPath!.row].id
//                    let creatorname = self.featuredQuestionArray[indexPath!.row].creatorname
//                    let question = self.featuredQuestionArray[indexPath!.row]
//                    self.selectedIndexPath = indexPath!.row
//                    answerVC.content = content
//                    answerVC.id = id
//                    answerVC.creatorname = creatorname
//                    answerVC.question = question
//                    answerVC.fromFeatured = true
//                } else if selectedRow == 1 {
//                    let answerVC: AnswersViewController = segue.destinationViewController as! AnswersViewController
//                    let indexPath = self.tableView.indexPathForSelectedRow
//                    let content = self.questionArray[indexPath!.row].content
//                    let id = self.questionArray[indexPath!.row].id
//                    let creatorname = self.questionArray[indexPath!.row].creatorname
//                    let question = self.questionArray[indexPath!.row]
//                    self.selectedIndexPath = indexPath!.row
//                    answerVC.content = content
//                    answerVC.id = id
//                    answerVC.creatorname = creatorname
//                    answerVC.question = question
//                }
//            } else if counter == 1 {
//                let answerVC: AnswersViewController = segue.destinationViewController as! AnswersViewController
//                let indexPath = self.tableView.indexPathForSelectedRow
//                let content = self.hotQuestionArray[indexPath!.row].content
//                let id = self.hotQuestionArray[indexPath!.row].id
//                let creatorname = self.hotQuestionArray[indexPath!.row].creatorname
//                let question = self.hotQuestionArray[indexPath!.row]
//                self.selectedIndexPath = indexPath!.row
//                answerVC.content = content
//                answerVC.id = id
//                answerVC.creatorname = creatorname
//                answerVC.question = question
//                
//            }
        } else if segue.identifier == "showAskQuestionVC" {
            if fromSpecificChannel {
                let askQuestionVC: AskQuestionViewController = segue.destinationViewController as! AskQuestionViewController
                askQuestionVC.channelId = channelId
                askQuestionVC.channelName = channelName
                askQuestionVC.fromSpecificChannel = true
            }
            
        } else if segue.identifier == "segueFromFeedToSpecificChannel" {
            if fromFavorites {
                if counter == 0 {
                    let feedVC: FeedViewController = segue.destinationViewController as! FeedViewController
                    let mytag = sender!.tag
                    let channelId = questionArray[mytag].channel_id
                    let channelName = questionArray[mytag].channel_name
                    feedVC.fromSpecificChannel = true
                    feedVC.channelId = channelId
                    feedVC.channelName = channelName
                } else if counter == 1 {
                    let feedVC: FeedViewController = segue.destinationViewController as! FeedViewController
                    let mytag = sender!.tag
                    let channelId = hotQuestionArray[mytag].channel_id
                    let channelName = hotQuestionArray[mytag].channel_name
                    feedVC.fromSpecificChannel = true
                    feedVC.channelId = channelId
                    feedVC.channelName = channelName
                }
            } else {
                let feedVC: FeedViewController = segue.destinationViewController as! FeedViewController
                let mytag = sender!.tag
                let channelId = hotQuestionArray[mytag].channel_id
                let channelName = hotQuestionArray[mytag].channel_name
                feedVC.fromSpecificChannel = true
                feedVC.channelId = channelId
                feedVC.channelName = channelName
            }
            
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "segueFromFeedToSpecificChannel" {
            let mytag = sender!.tag
            if fromFavorites {
                if counter == 0 {
                    let channelId = questionArray[mytag].channel_id
                    if channelId == "" {
                        return false
                    } else {
                        return true
                    }
                } else {
                    let channelId = hotQuestionArray[mytag].channel_id
                    if channelId == "" {
                        return false
                    } else {
                        return true
                    }
                }
            } else {
                let channelId = hotQuestionArray[mytag].channel_id
                if channelId == "" {
                    return false
                } else {
                    return true
                }
            }
        } else {
            return true
        }
            
    }
    
    // MARK: - IBAction
    @IBAction func askQuestionBarButtonPressed(sender: UIBarButtonItem) {
        if channelName == "" {
            Answers.logCustomEventWithName("Ask Question Button Tapped",
                customAttributes: ["from": "Top Posts"])
        } else {
            Answers.logCustomEventWithName("Ask Question Button Tapped",
                customAttributes: ["from": channelName])
        }
        
        self.performSegueWithIdentifier("showAskQuestionVC", sender: self)
    }
    
    // Uncomment for pagination using willDisplayCell
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        let yOffset = tableView.contentOffset.y;
//        let height = tableView.contentSize.height - tableView.frame.height
//        let scrolledPercentage = yOffset / height;
//        
//        
//        // Check if all the conditions are met to allow loading the next page
//        //
//        if (scrolledPercentage > 0.6 && !self.isLoading) {
//            self.currentPage++
//            self.loadNextPage()
//        }
//        
//    }
    
//    func loadNextPage() {
//        if self.isLoading {
//            return
//        }
//        self.isLoading = true
//        
//        self.loadPaginatedData()
//        
//        self.isLoading = false
//    }
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        
//        if (self.lastContentOffset > scrollView.contentOffset.y) {
//            // move up
//        }
//        else if (self.lastContentOffset < scrollView.contentOffset.y) {
//            // move down
//            let offset = scrollView.contentOffset
//            let bounds = scrollView.bounds
//            let size = scrollView.contentSize
//            let inset = scrollView.contentInset
//            let y: CGFloat = offset.y + bounds.size.height - inset.bottom
//            let h: CGFloat = size.height
//            let reload_distance: CGFloat = 10
//            if(y > h + reload_distance) {
//                print("Load more rows")
//                self.currentPage++
//                self.loadPaginatedData()
//            }
//        }
//        self.lastContentOffset = scrollView.contentOffset.y
//        
//    }
    

}

func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
    let calendar = NSCalendar.currentCalendar()
    let unitFlags: NSCalendarUnit = [NSCalendarUnit.Minute, NSCalendarUnit.Hour, NSCalendarUnit.Day, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.Second]
    let now = NSDate()
    let earliest = now.earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:NSDateComponents = calendar.components(unitFlags, fromDate: earliest, toDate: latest, options: [])
    
    
    if (components.year >= 2) {
        return "\(components.year)y"
    } else if (components.year >= 1){
        if (numericDates){
            return "1y"
        } else {
            return "Last year"
        }
    } else if (components.month >= 2) {
        return "\(components.month)mo"
    } else if (components.month >= 1){
        if (numericDates){
            return "1mo"
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear >= 2) {
        return "\(components.weekOfYear)w"
    } else if (components.weekOfYear >= 1){
        if (numericDates){
            return "1w"
        } else {
            return "Last week"
        }
    } else if (components.day >= 2) {
        return "\(components.day)d"
    } else if (components.day >= 1){
        if (numericDates){
            return "1d"
        } else {
            return "Yesterday"
        }
    } else if (components.hour >= 2) {
        return "\(components.hour)h"
    } else if (components.hour >= 1){
        if (numericDates){
            return "1h"
        } else {
            return "An hour ago"
        }
    } else if (components.minute >= 2) {
        return "\(components.minute)m"
    } else if (components.minute >= 1){
        if (numericDates){
            return "1m"
        } else {
            return "A minute ago"
        }
    } else if (components.second >= 3) {
        return "\(components.second)s"
    } else {
        return "1s"
    }
    
}
