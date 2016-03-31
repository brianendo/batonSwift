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

class ConfirmSchoolViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchController : UISearchController!
    var filteredSchoolNames = [String]()
    var filteredSchoolIds = [String]()
    var firstName = ""
    var lastName = ""
    var profileImageUrl = ""
    var facebookId = ""
    var email = ""
    var schoolName = ""
    var schoolId = ""
    
    override func viewWillDisappear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            let url = globalurl + "api/channelsearch"
            let parameters = [
                "searchText": searchText
            ]
            
            Alamofire.request(.POST, url, parameters: parameters, headers: nil)
                .responseJSON { response in
                    var value = response.result.value
                    
                    self.filteredSchoolNames.removeAll(keepCapacity: true)
                    self.filteredSchoolIds.removeAll(keepCapacity: true)
                    print(value)
                    
                    if value == nil {
                        value = []
                        self.tableView.reloadData()
                    } else {
                        let json = JSON(value!)
                        for (_,subJson):(String, JSON) in json {
                            let id = subJson["_id"].string
                            let name = subJson["name"].string
                            print(name)
                            
                            if self.filteredSchoolIds.contains(id!) {
                                
                            } else {
                                self.filteredSchoolNames.append(name!)
                                self.filteredSchoolIds.append(id!)
                            }
                            
                            self.tableView.reloadData()
                        }
                    }
                    
                    
            }
 
        }
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        schoolName = filteredSchoolNames[indexPath.row]
        schoolId = filteredSchoolIds[indexPath.row]
        self.performSegueWithIdentifier("segueToUsernameFromPickSchool", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
        
        return cell
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
            usernameVC.type = "high school"
        }
    }
    

}
