//
//  PushViewController.swift
//  Baton
//
//  Created by Brian Endo on 2/10/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PushViewController: UIViewController {

    
    @IBOutlet weak var relaySwitch: UISwitch!
    @IBOutlet weak var likeSwitch: UISwitch!
    @IBOutlet weak var followSwitch: UISwitch!
    
    var relayState = true
    var likeState = true
    var followState = true
    
    // MARK: - viewWill/viewDid
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        relaySwitch.addTarget(self, action: Selector("relayStateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        likeSwitch.addTarget(self, action: Selector("likeStateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        followSwitch.addTarget(self, action: Selector("followStateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    func relayStateChanged(switchState: UISwitch) {
        if switchState.on {
            relayState = true
            print(relayState)
        } else {
            relayState = false
            print(relayState)
        }
    }
    
    func likeStateChanged(switchState: UISwitch) {
        if switchState.on {
            likeState = true
            print(likeState)
        } else {
            likeState = false
            print(likeState)
        }
    }
    
    func followStateChanged(switchState: UISwitch) {
        if switchState.on {
            followState = true
            print(followState)
        } else {
            followState = false
            print(followState)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction
    @IBAction func allowButtonPressed(sender: UIButton) {
        
        let url = globalurl + "api/userpushsettings"
        let parameters = [
            "id": userid,
            "relayPush": relayState,
            "likePush": likeState,
            "followPush": followState
        ]
        
        
        Alamofire.request(.PUT, url, parameters: parameters as? [String:AnyObject])
            .responseJSON { response in
                let result = response.result.value
                print(result)
                if result == nil {
                    
                } else {
                    let json = JSON(response.result.value!)
                    print("JSON: \(json)")
                    
                }
        }

        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateInitialViewController()
        self.presentViewController(mainVC!, animated: true, completion: nil)
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
            let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            
            // This is an asynchronous method to retrieve a Device Token
            // Callbacks are in AppDelegate.swift
            // Success = didRegisterForRemoteNotificationsWithDeviceToken
            // Fail = didFailToRegisterForRemoteNotificationsWithError
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
    }
    
    @IBAction func doNotAllowButtonPressed(sender: UIButton) {
        
        let url = globalurl + "api/userpushsettings"
        let parameters = [
            "id": userid,
            "relayPush": relayState,
            "likePush": likeState,
            "followPush": followState
        ]
        
        
        Alamofire.request(.PUT, url, parameters: parameters as? [String:AnyObject])
            .responseJSON { response in
                let result = response.result.value
                print(result)
                if result == nil {
                    
                } else {
                    let json = JSON(response.result.value!)
                    print("JSON: \(json)")
                    
                }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateInitialViewController()
        self.presentViewController(mainVC!, animated: true, completion: nil)
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
            let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            
            // This is an asynchronous method to retrieve a Device Token
            // Callbacks are in AppDelegate.swift
            // Success = didRegisterForRemoteNotificationsWithDeviceToken
            // Fail = didFailToRegisterForRemoteNotificationsWithError
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
    }
    
    

}
