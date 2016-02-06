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
import Firebase
import AWSS3
import KeychainSwift
import JWTDecode

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let keychain = KeychainSwift()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var questionArray = [Question]()
    var myQuestionArray = [Question]()
    var hotQuestionArray = [Question]()
    var selectedIndexPath = 0
    var currentPage = 0
    private var lastContentOffset: CGFloat = 0
    var isLoading = false
    var counter = 0
    
    var refreshControl:UIRefreshControl!
    
    func loadData() {
        let url = globalurl + "api/questions-ordered/" + userid
        
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
                    let anonymous = subJson["anonymous"].string
                    var answercount = subJson["answercount"].number?.integerValue
                    var creatorname = subJson["creatorname"].string
                    let answeredBy = subJson["answered_by"]
                    let creator = subJson["creator"].string
                    var answered = false
                    var user = false
                    let createdAt = subJson["created_at"].string
                    var likecount = subJson["likes"].number?.integerValue
                    
                    if likecount == nil {
                        likecount = 0
                    }
                    
                    let dateFor: NSDateFormatter = NSDateFormatter()
                    dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
                    
                    if creator == userid {
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
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: answered, currentuser: user, createdAt: yourDate, creator: creator, likecount: likecount)
                    self.questionArray.append(question)
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
                
                let json = JSON(value!)
//                print("JSON: \(json)")
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
                    var likecount = subJson["likes"].number?.integerValue
                    
                    if likecount == nil {
                        likecount = 0
                    }
                    
                    let dateFor: NSDateFormatter = NSDateFormatter()
                    dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
                    
                    if creator == userid {
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
                    
                    if creatorname == nil {
                        creatorname = "Anonymous"
                    } else if anonymous == "true" {
                        creatorname = "Anonymous"
                    }
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: answered, currentuser: user, createdAt: yourDate, creator: creator, likecount: likecount)
                    self.hotQuestionArray.append(question)
                    self.hotQuestionArray.sortInPlace({ $0.likecount > $1.likecount })
                    
                    self.tableView.reloadData()
                }
        }
    }
    
    func loadPaginatedData() {
        let url = globalurl + "api/questions/page/" + "\(self.currentPage)"
        
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

                    let id = subJson["_id"].string
                    let content = subJson["content"].string
                    var answercount = subJson["answercount"].number?.integerValue
                    var creatorname = subJson["creatorname"].string
                    let answeredBy = subJson["answered_by"]
                    let creator = subJson["creator"].string
                    var answered = false
                    var user = false
                    let createdAt = subJson["created_at"].string
                    
                    var likecount = subJson["likes"].number?.integerValue
                    
                    if likecount == nil {
                        likecount = 0
                    }
                    
                    let dateFor: NSDateFormatter = NSDateFormatter()
                    dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let yourDate: NSDate? = dateFor.dateFromString(createdAt!)
                    
                    if creator == userid {
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
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: answered, currentuser: user, createdAt: yourDate, creator: creator, likecount: likecount)
                    self.questionArray.append(question)
                    
                    self.tableView.reloadData()
                }
        }
    }
    
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
                    var likecount = subJson["likes"].number?.integerValue
                    
                    if likecount == nil {
                        likecount = 0
                    }
                    
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
                    
                    if creatorname == nil {
                        creatorname = "Anonymous"
                    } else if anonymous == "true" {
                        creatorname = "Anonymous"
                    }
                    
                    let question = Question(content: content, creatorname: creatorname, id: id, answercount: answercount, answered: answered, currentuser: user, createdAt: yourDate, creator: creator, likecount: likecount)
                    self.myQuestionArray.append(question)

                    self.tableView.reloadData()
                }
        }
    }
    
    func loadUserInfo() {
//        let url = globalurl + "api/currentuser"
//        let parameters = [
//            "firebase_id": currentUser
//        ]
//        
//        Alamofire.request(.POST, url, parameters: parameters)
//            .responseJSON { response in
//                var value = response.result.value
//                
//                if value == nil {
//                    value = []
//                } else {
//                    let json = JSON(value!)
//                    print("JSON: \(json)")
//                    let currentuserid = json["_id"].string
//                    let firstname = json["firstname"].string
//                    let lastname = json["lastname"].string
//                    
//                    name = firstname! + " " + lastname!
//                    userid = currentuserid!
//                    
//                    self.tableView.reloadData()
//                    self.loadData()
//                    self.loadHotQuestionData()
//                }
//        }
        let url = globalurl + "api/users/" + userid
        
        var token = keychain.get("JWT")
        print(token)
        
        do {
            
            let jwt = try decode(token!)
            print(jwt)
            print(jwt.body)
            print(jwt.expiresAt)
            print(jwt.expired)
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
                            print("JSON: \(json)")
                            print(json["token"].string)
                            let newtoken = json["token"].string
                            self.keychain.set(newtoken!, forKey: "JWT")
                            token = newtoken
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
                                        print("JSON: \(json)")
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
                                        
                                        self.tableView.reloadData()
                                        self.loadData()
                                        self.loadHotQuestionData()
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
                            print("JSON: \(json)")
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
                            
                            self.tableView.reloadData()
                            self.loadData()
                            self.loadHotQuestionData()
                        }
                }
            }
        } catch {
            print("Failed to decode JWT: \(error)")
        }
        
//        let headers = [
//            "Authorization": "\(token!)"
//        ]
//        
//        Alamofire.request(.GET, url, parameters: nil, headers: headers)
//            .responseJSON { response in
//                var value = response.result.value
//                
//                let statuscode = response.response?.statusCode
//                print(statuscode)
//                
//                if value == nil {
//                    value = []
//                } else {
//                    let json = JSON(value!)
//                    print("JSON: \(json)")
//                    let firstname = json["firstname"].string
//                    let lastname = json["lastname"].string
//                    var username = json["username"].string
//                    let email = json["email"].string
//                    
//                    name = firstname! + " " + lastname!
//                    
//                    if username == nil {
//                        username = firstname! + lastname!
//                    } else {
//                        username = username!
//                    }
//                    
//                    myfirstname = firstname!
//                    mylastname = lastname!
//                    myUsername = username!
//                    
//                    if email ==  nil {
//                        myemail = ""
//                    } else {
//                        myemail = email!
//                    }
//                    
//                    self.tableView.reloadData()
//                    self.loadData()
//                    self.loadHotQuestionData()
//                }
//        }
    }
    
    func updateFollow() {
        let url = globalurl + "api/updatefollow/" + userid
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                var value = response.result.value
                
                if value == nil {
                    value = []
                }
                
        }
    }
    
    func checkNotifications() {
        let url = globalurl + "api/unreadnotifications/" + userid
        
        Alamofire.request(.GET, url, parameters: nil)
            .responseJSON { response in
                print(response.request)
                print(response.response)
                print(response.result)
                print(response.response?.statusCode)
                
                let statuscode = response.response?.statusCode
                if statuscode == 200 {
                    print("unread notifcations")
                    let tabItem = self.tabBarController?.viewControllers![2]
                    tabItem?.tabBarItem.image = UIImage(named: "bellUnread")
                } else if statuscode == 400 {
                    print("no new notifications")
                    let tabItem = self.tabBarController?.viewControllers![2]
                    tabItem?.tabBarItem.image = UIImage(named: "thickerBell")
                } else if statuscode == 404 {
                    
                } else {
                    
                }
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
        self.checkNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        let isLoggedIn = keychain.get("ISLOGGEDIN")
        if (isLoggedIn != "1") {
            let login = UIStoryboard(name: "LogIn", bundle: nil)
            let loginVC = login.instantiateInitialViewController()
            self.presentViewController(loginVC!, animated: true, completion: nil)
        } else {
//            let id = prefs.valueForKey("ID") as? String
//            print(id)
            let id = keychain.get("ID")
            if id == nil {
                let login = UIStoryboard(name: "LogIn", bundle: nil)
                let loginVC = login.instantiateInitialViewController()
                self.presentViewController(loginVC!, animated: true, completion: nil)
            } else {
                userid = id!
                self.tableView.dataSource = self
                self.tableView.delegate = self
                self.tableView.tableFooterView = UIView()
                self.tableView.rowHeight = UITableViewAutomaticDimension
                self.tableView.estimatedRowHeight = 80
                self.tableView.scrollsToTop = true
                
                self.questionArray.removeAll(keepCapacity: true)
                self.myQuestionArray.removeAll(keepCapacity: true)
                self.updateFollow()
                self.loadUserInfo()
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeFeed", name: "submittedAnswer", object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFeed", name: "askedQuestion", object: nil)
                
                self.segmentedControl.addTarget(self, action: "profileSegmentedControlChanged:", forControlEvents: .ValueChanged)
            }
        }
        
        
//        ref.observeAuthEventWithBlock({ authData in
//            if authData != nil {
//                // user authenticated
//                print(authData.uid)
//                currentUser = authData.uid
//                
//                self.tableView.dataSource = self
//                self.tableView.delegate = self
//                
//                self.tableView.rowHeight = UITableViewAutomaticDimension
//                self.tableView.estimatedRowHeight = 80
//                
//                self.questionArray.removeAll(keepCapacity: true)
//                self.myQuestionArray.removeAll(keepCapacity: true)
//                
//                self.loadUserInfo()
//                NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeFeed", name: "submittedAnswer", object: nil)
//                 NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFeed", name: "askedQuestion", object: nil)
//                
//                self.segmentedControl.addTarget(self, action: "profileSegmentedControlChanged:", forControlEvents: .ValueChanged)
//            } else {
//                // No user is signed in
//                let login = UIStoryboard(name: "LogIn", bundle: nil)
//                let loginVC = login.instantiateInitialViewController()
//                self.presentViewController(loginVC!, animated: true, completion: nil)
//            }
//        })

        // Do any additional setup after loading the view.
        self.refreshControl = UIRefreshControl()
//        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func profileSegmentedControlChanged(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            print("Money")
            counter = 0
        } else if sender.selectedSegmentIndex == 1 {
            print("Mayweather")
            counter = 1
        }
        
        self.tableView.reloadData()
        
    }
    
    func changeFeed(){
        let count = questionArray[selectedIndexPath].answercount
        questionArray[selectedIndexPath].answercount = count + 1
        questionArray[selectedIndexPath].answered = true
        self.tableView.reloadData()
    }
    
    func refreshFeed(){
        self.questionArray.removeAll(keepCapacity: true)
        self.hotQuestionArray.removeAll(keepCapacity: true)
        
//        self.currentPage = 0
//        self.loadPaginatedData()
        self.loadData()
        self.loadHotQuestionData()
        self.tableView.reloadData()
    }
    
    func refresh(sender:AnyObject){
        // Code to refresh table view
        self.questionArray.removeAll(keepCapacity: true)
        self.hotQuestionArray.removeAll(keepCapacity: true)
        
//        self.currentPage = 0
        self.loadData()
        self.loadHotQuestionData()
//        self.loadPaginatedData()
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
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if counter == 0 {
            return questionArray.count
        } else {
            return hotQuestionArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if counter == 0 {
            let cell: QuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionTableViewCell
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            cell.questionTextView.text = questionArray[indexPath.row].content
            cell.questionTextView.userInteractionEnabled = false
            
            let creatorname = questionArray[indexPath.row].creatorname
            let answercount = questionArray[indexPath.row].answercount
            
            let answered = questionArray[indexPath.row].answered
            let userStatus = questionArray[indexPath.row].currentuser
            
            cell.answercountLabel.text =  "\(answercount)"
            
            let likecount = questionArray[indexPath.row].likecount
            let formattedlikecount = likecount.abbreviateNumber()
            cell.likecountTextView.text = "\(formattedlikecount)"
//            cell.likecountTextView.text = "9,999"
            cell.likecountTextView.editable = false
            cell.likecountTextView.selectable = false
            
            let date = questionArray[indexPath.row].createdAt
            let timeAgo = timeAgoSinceDate(date, numericDates: true)
            
            cell.timeAgoLabel.text = timeAgo
            
            let creator = questionArray[indexPath.row].creator
            
            return cell
        } else {
            let cell: QuestionTableViewCell = tableView.dequeueReusableCellWithIdentifier("QuestionCell", forIndexPath: indexPath) as! QuestionTableViewCell
            
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            
            cell.questionTextView.text = hotQuestionArray[indexPath.row].content
            cell.questionTextView.userInteractionEnabled = false
            
            let creatorname = hotQuestionArray[indexPath.row].creatorname
            let answercount = hotQuestionArray[indexPath.row].answercount
            
            let answered = hotQuestionArray[indexPath.row].answered
            let userStatus = hotQuestionArray[indexPath.row].currentuser
            
            cell.answercountLabel.text =  "\(answercount)"
            
            let likecount = hotQuestionArray[indexPath.row].likecount
            let formattedlikecount = likecount.abbreviateNumber()
            cell.likecountTextView.text = "\(formattedlikecount)"
            cell.likecountTextView.editable = false
            cell.likecountTextView.selectable = false
            
            let date = hotQuestionArray[indexPath.row].createdAt
            let timeAgo = timeAgoSinceDate(date, numericDates: true)
            
            cell.timeAgoLabel.text = timeAgo
            
            let creator = hotQuestionArray[indexPath.row].creator
            
            return cell
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToTakeVideoVC" {
            let takeVideoVC: TakeVideoViewController = segue.destinationViewController as! TakeVideoViewController
            let content = self.questionArray[selectedIndexPath].content
            let id = self.questionArray[selectedIndexPath].id
            takeVideoVC.content = content
            takeVideoVC.id = id
        } else if segue.identifier == "segueToAnswerVC" {
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
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("segueToAnswerVC", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let record = UITableViewRowAction(style: .Normal, title: "Record") { action, index in
            print("Record button tapped")
            self.selectedIndexPath = indexPath.row
            self.performSegueWithIdentifier("segueToTakeVideoVC", sender: self)
        }
        record.backgroundColor = UIColor.orangeColor()
        
        return [record]
    }
    
    @IBAction func askQuestionBarButtonPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("showAskQuestionVC", sender: self)
    }
    
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
