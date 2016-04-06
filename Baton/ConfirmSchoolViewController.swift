//
//  ConfirmSchoolViewController.swift
//  Baton
//
//  Created by Brian Endo on 3/29/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SCLAlertView

class ConfirmSchoolViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    var searchController : UISearchController!
    var filteredSchoolNames = [String]()
    var filteredSchoolIds = [String]()
    var filteredLocations = [String]()
    var filteredLocked = [Bool]()
    var firstName = ""
    var lastName = ""
    var profileImageUrl = ""
    var facebookId = ""
    var email = ""
    var schoolName = ""
    var schoolId = ""
    var type = ""
    
    // MARK: - Keyboard
    func registerForKeyboardNotifications ()-> Void   {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SuggestSchoolViewController.keyboardWillShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SuggestSchoolViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications () -> Void {
        let center:  NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.bottomLayoutConstraint.constant = keyboardFrame.size.height
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.bottomLayoutConstraint.constant = 0
    }
    
    override func viewWillAppear(animated: Bool) {
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.deregisterFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"Back", style:.Plain, target:nil, action:nil)
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = "Pick your school"
        // Do any additional setup after loading the view.
        self.searchController = UISearchController(searchResultsController:  nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.barTintColor = UIColor(red:0.17, green:0.18, blue:0.29, alpha:1.0)
        
        // Prevents black screen
        self.definesPresentationContext = true
        // Prevents presentation context to overlap
        self.extendedLayoutIncludesOpaqueBars = true
        
        tableView.tableHeaderView = self.searchController.searchBar
        
        tableView.tableFooterView = UIView()
        
        if type == "high school" {
            self.loadHighSchools()
        } else if type == "college" {
            self.loadColleges()
        }
        
//        self.loadHighSchools()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadHighSchools() {
        let url = globalurl + "api/recentHighSchools"
        
        Alamofire.request(.GET, url, parameters: nil, headers: nil)
            .responseJSON { response in
                var value = response.result.value
                
                self.filteredSchoolNames.removeAll(keepCapacity: true)
                self.filteredSchoolIds.removeAll(keepCapacity: true)
                self.filteredLocations.removeAll(keepCapacity: true)
                self.filteredLocked.removeAll(keepCapacity: true)
                print(value)
                
                if value == nil {
                    value = []
                    self.tableView.reloadData()
                } else {
                    let json = JSON(value!)
                    for (_,subJson):(String, JSON) in json {
                        let id = subJson["_id"].string
                        let name = subJson["name"].string
                        var location = subJson["location"].string
                        if location == nil {
                            location = ""
                        }
                        var locked = subJson["locked"].bool
                        if locked == nil {
                            locked = true
                        }
                        print(name)
                        
                        if self.filteredSchoolIds.contains(id!) {
                            
                        } else {
                            self.filteredSchoolNames.append(name!)
                            self.filteredSchoolIds.append(id!)
                            self.filteredLocations.append(location!)
                            self.filteredLocked.append(locked!)
                        }
                        
                        self.tableView.reloadData()
                    }
                }
                
                
        }

    }
    
    func loadColleges() {
        let url = globalurl + "api/recentColleges"
        
        Alamofire.request(.GET, url, parameters: nil, headers: nil)
            .responseJSON { response in
                var value = response.result.value
                
                self.filteredSchoolNames.removeAll(keepCapacity: true)
                self.filteredSchoolIds.removeAll(keepCapacity: true)
                self.filteredLocations.removeAll(keepCapacity: true)
                self.filteredLocked.removeAll(keepCapacity: true)
                print(value)
                
                if value == nil {
                    value = []
                    self.tableView.reloadData()
                } else {
                    let json = JSON(value!)
                    for (_,subJson):(String, JSON) in json {
                        let id = subJson["_id"].string
                        let name = subJson["name"].string
                        var location = subJson["location"].string
                        if location == nil {
                            location = ""
                        }
                        var locked = subJson["locked"].bool
                        if locked == nil {
                            locked = true
                        }
                        print(name)
                        
                        if self.filteredSchoolIds.contains(id!) {
                            
                        } else {
                            self.filteredSchoolNames.append(name!)
                            self.filteredSchoolIds.append(id!)
                            self.filteredLocations.append(location!)
                            self.filteredLocked.append(locked!)
                        }
                        
                        self.tableView.reloadData()
                    }
                }
                
                
        }
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.autocapitalizationType = UITextAutocapitalizationType.None
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        if searchController.active {
            
        } else {
           print("ended")
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        print(searchText)
        
        if searchText == "" {
            
        } else {
            
            if type == "high school" {
                let url = globalurl + "api/highschoolsearch"
                let parameters = [
                    "searchText": searchText
                ]
                
                Alamofire.request(.POST, url, parameters: parameters, headers: nil)
                    .responseJSON { response in
                        var value = response.result.value
                        
                        self.filteredSchoolNames.removeAll(keepCapacity: true)
                        self.filteredSchoolIds.removeAll(keepCapacity: true)
                        self.filteredLocations.removeAll(keepCapacity: true)
                        self.filteredLocked.removeAll(keepCapacity: true)
                        print(value)
                        
                        if value == nil {
                            value = []
                            self.tableView.reloadData()
                        } else {
                            let json = JSON(value!)
                            for (_,subJson):(String, JSON) in json {
                                let id = subJson["_id"].string
                                let name = subJson["name"].string
                                var location = subJson["location"].string
                                if location == nil {
                                    location = ""
                                }
                                var locked = subJson["locked"].bool
                                if locked == nil {
                                    locked = true
                                }
                                print(name)
                                
                                if self.filteredSchoolIds.contains(id!) {
                                    
                                } else {
                                    self.filteredSchoolNames.append(name!)
                                    self.filteredSchoolIds.append(id!)
                                    self.filteredLocations.append(location!)
                                    self.filteredLocked.append(locked!)
                                }
                                
                                self.tableView.reloadData()
                            }
                        }
                        
                        
                }
            } else if type == "college" {
                let url = globalurl + "api/collegesearch"
                let parameters = [
                    "searchText": searchText
                ]
                
                Alamofire.request(.POST, url, parameters: parameters, headers: nil)
                    .responseJSON { response in
                        var value = response.result.value
                        
                        self.filteredSchoolNames.removeAll(keepCapacity: true)
                        self.filteredSchoolIds.removeAll(keepCapacity: true)
                        self.filteredLocations.removeAll(keepCapacity: true)
                        self.filteredLocked.removeAll(keepCapacity: true)
                        print(value)
                        
                        if value == nil {
                            value = []
                            self.tableView.reloadData()
                        } else {
                            let json = JSON(value!)
                            for (_,subJson):(String, JSON) in json {
                                let id = subJson["_id"].string
                                let name = subJson["name"].string
                                var location = subJson["location"].string
                                if location == nil {
                                    location = ""
                                }
                                var locked = subJson["locked"].bool
                                if locked == nil {
                                    locked = true
                                }
                                print(name)
                                
                                if self.filteredSchoolIds.contains(id!) {
                                    
                                } else {
                                    self.filteredSchoolNames.append(name!)
                                    self.filteredSchoolIds.append(id!)
                                    self.filteredLocations.append(location!)
                                    self.filteredLocked.append(locked!)
                                }
                                
                                self.tableView.reloadData()
                            }
                        }
                        
                        
                }
            }
            
            
 
        }
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        schoolName = filteredSchoolNames[indexPath.row]
        schoolId = filteredSchoolIds[indexPath.row]
        let locked = filteredLocked[indexPath.row]
        if locked == true {
            self.performSegueWithIdentifier("segueToLockedSchool", sender: self)
        } else {
            self.performSegueWithIdentifier("segueToUsernameFromPickSchool", sender: self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        let alertView = SCLAlertView()
//        alertView.addButton("Yes") {
//            print("Yes tapped")
//            self.performSegueWithIdentifier("segueToUsernameFromPickSchool", sender: self)
//        }
//        alertView.addButton("No") {
//            print("No tapped")
//            alertView.hideView()
//        }
//        alertView.showCloseButton = false
//        alertView.showSuccess("Do you go to American?", subTitle: "This alert view has buttons")
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSchoolNames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: SchoolTableViewCell = tableView.dequeueReusableCellWithIdentifier("schoolCell", forIndexPath: indexPath) as! SchoolTableViewCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        let name = filteredSchoolNames[indexPath.row]
        cell.nameLabel.text = name
        
        let location = filteredLocations[indexPath.row]
        cell.locationLabel.text = location
        
        return cell
    }
    
    
    @IBAction func suggestSchoolButtonPressed(sender: UIButton) {
        self.performSegueWithIdentifier("segueToSuggestSchool", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToUsernameFromPickSchool" {
            let usernameVC: UsernameViewController = segue.destinationViewController as! UsernameViewController
            usernameVC.firstname = firstName
            usernameVC.lastname = lastName
            usernameVC.profileImageUrl = profileImageUrl
            usernameVC.facebookId = facebookId
            usernameVC.email = email
            usernameVC.fromFB = true
            usernameVC.schoolName = schoolName
            usernameVC.schoolId = schoolId
            usernameVC.type = type
        } else if segue.identifier == "segueToLockedSchool" {
            let lockedSchoolVC: LockedSchoolViewController = segue.destinationViewController as! LockedSchoolViewController
            lockedSchoolVC.schoolName = schoolName
            lockedSchoolVC.fromSuggest = false
            lockedSchoolVC.channelId = schoolId
            lockedSchoolVC.userEmail = email
        } else if segue.identifier == "segueToSuggestSchool" {
            let suggestSchoolVC: SuggestSchoolViewController = segue.destinationViewController as! SuggestSchoolViewController
            suggestSchoolVC.firstname = firstName
            suggestSchoolVC.lastname = lastName
            suggestSchoolVC.email = email
            suggestSchoolVC.type = type
        }
    }
    

}
