//
//  SettingsTableViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 1/29/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift

class SettingsTableViewController: UITableViewController {

    // MARK: - Variables
    let keychain = KeychainSwift()
    
    // MARK: - viewDid/viewWill
    override func viewDidAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - functions
    func configurationTextField(textField: UITextField!)
    {
        if let _ = textField {
            textField.text = ""
        }
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let alert = UIAlertController(title: "Provide Feedback", message: "Let us know about any problems so we can continue to improve Baton.", preferredStyle:
                UIAlertControllerStyle.Alert)
            
            alert.addTextFieldWithConfigurationHandler(configurationTextField)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
                print("User click Ok button")
                let alertText = alert.textFields![0].text! as String
//                print(alert.textFields![0].text)
                print(alertText)
                if alertText == "" {
                    
                } else {
                    let parameters = [
                        "creator": userid,
                        "content": alertText
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
                
            }))
            
            self.presentViewController(alert, animated: true, completion: {
                print("completion block")
            })
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                self.performSegueWithIdentifier("segueToChangeEmail", sender: self)
            }
            
            if indexPath.row == 1 {
                self.performSegueWithIdentifier("segueToChangePassword", sender: self)
            }
        }
        
        if indexPath.section == 2 {
            // Clear all contents of keychain
            keychain.clear()
            let login = UIStoryboard(name: "LogIn", bundle: nil)
            let loginVC = login.instantiateInitialViewController()
            self.presentViewController(loginVC!, animated: true, completion: nil)
        }
    }



}
