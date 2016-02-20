//
//  PushViewController.swift
//  Baton
//
//  Created by Brian Endo on 2/10/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class PushViewController: UIViewController {

    
    // MARK: - viewWill/viewDid
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction
    @IBAction func allowButtonPressed(sender: UIButton) {
        
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
