//
//  AppDelegate.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 10/29/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognito
import AWSS3
import Fabric
import TwitterKit
import COSTouchVisualizer
import Crashlytics
import Alamofire
import SwiftyJSON


// Global currentuser variable
var currentUser = ""
var name = ""
var userid = ""

var myUsername = ""
var myfirstname = ""
var mylastname = ""
var mybio = ""
var myemail = ""

let herokuUrl = "https://arcane-savannah-8802.herokuapp.com/"
let batonUrl = "http://batonapp.io/"
let localUrl = "http://localhost:5000/"
let globalurl = herokuUrl

let cloudfrontUrl = "https://d1uji1hs8rdjoi.cloudfront.net/"


// Constants for Amazon Web Services
let CognitoRegionType = AWSRegionType.USEast1  // e.g. AWSRegionType.USEast1
let DefaultServiceRegionType = AWSRegionType.USWest1 // e.g. AWSRegionType.USWest2
let CognitoIdentityPoolId = "us-east-1:cd887d49-c047-4889-bf49-215cd886036d"
let S3BucketName = "batonapp"

var imageCache: Dictionary<String, NSData?> = Dictionary<String, NSData>()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, COSTouchVisualizerWindowDelegate {

    var window: UIWindow?
    
    // Uncomment to use COSTouchVisualizerWindowDelegate for presentations
//    lazy var window: UIWindow? = {
//        var customWindow = COSTouchVisualizerWindow(frame: UIScreen.mainScreen().bounds)
//        customWindow.touchVisualizerWindowDelegate = self
//        return customWindow
//    }()
//
//    func touchVisualizerWindowShouldAlwaysShowFingertip(window: COSTouchVisualizerWindow!) -> Bool {
//        return true
//    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Update colors for NavBar and StatusBar
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().barTintColor = UIColor(red:0.17, green:0.18, blue:0.29, alpha:1.0)
        UINavigationBar.appearance().tintColor = UIColor(red:0.91, green:0.27, blue:0.27, alpha:1.0)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor(red:0.91, green:0.27, blue:0.27, alpha:1.0), NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 20)!]
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        let statusbar = UIView.init(frame: CGRectMake(0, 0, self.window!.frame.size.width, 20))
        statusbar.backgroundColor = UIColor(red:0.17, green:0.18, blue:0.29, alpha:1.0)
        self.window?.rootViewController?.view.addSubview(statusbar)
        
        // Update colors for TabBar
        UITabBar.appearance().barTintColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        UITabBar.appearance().tintColor = UIColor(red:0.91, green:0.27, blue:0.27, alpha:1.0)
        
        // Check credentials for AWS
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: AWSRegionType.USEast1, identityPoolId: CognitoIdentityPoolId)
        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: AWSRegionType.USWest1, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
        
//        initializeNotificationServices()
//        // Register for Push Notitications
//        if application.applicationState != UIApplicationState.Background {
//            // Track an app open here if we launch with a push, unless
//            // "content_available" was used to trigger a background push (introduced in iOS 7).
//            // In that case, we skip tracking here to avoid double counting the app-open.
//            
//            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
//            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
//            var pushPayload = false
//            if let options = launchOptions {
//                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
//            }
////            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
////                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
////            }
//        }
//        if application.respondsToSelector("registerUserNotificationSettings:") {
//            let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
//            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
//            application.registerUserNotificationSettings(settings)
//            application.registerForRemoteNotifications()
//        } else {
//            //            let types: UIRemoteNotificationType = [UIRemoteNotificationType.Badge, UIRemoteNotificationType.Alert, UIRemoteNotificationType.Sound]
//            let types: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
//            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
//            //            application.registerForRemoteNotificationTypes(types)
//            application.registerUserNotificationSettings(settings)
//            application.registerForRemoteNotifications()
//        }
        
        
        
        // Used for Twitter Login and Compose Tweet
        Fabric.with([Twitter.self, AWSCognito.self, Crashlytics.self])


        return true
    }

    func initializeNotificationServices() -> Void {
        let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        // This is an asynchronous method to retrieve a Device Token
        // Callbacks are in AppDelegate.swift
        // Success = didRegisterForRemoteNotificationsWithDeviceToken
        // Fail = didFailToRegisterForRemoteNotificationsWithError
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let deviceTokenStr = convertDeviceTokenToString(deviceToken)
        // ...register device token with our Time Entry API server via REST
        print(deviceTokenStr)
        
        if userid == "" {
            
        } else {
            let url = globalurl + "api/users/" + userid + "/adddevicetoken/" + deviceTokenStr
            Alamofire.request(.PUT, url, parameters: nil)
                .responseJSON { response in
                    print(response.response?.statusCode)
                    
                    let statuscode = response.response?.statusCode
                    if statuscode == 200 {
                        print("user updated")
                        
                    } else if statuscode == 400 {
                        print("user not updated")
                        
                    } else if statuscode == 404 {
                        print("user not updated")

                    } else {
                        print("user not updated")

                    }
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Device token for push notifications: FAIL -- ")
        print(error.description)
    }
    
    private func convertDeviceTokenToString(deviceToken:NSData) -> String {
        //  Convert binary Device Token to a String (and remove the <,> and white space charaters).
        var deviceTokenStr = deviceToken.description.stringByReplacingOccurrencesOfString(">", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString("<", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
        
        // Our API returns token in all uppercase, regardless how it was originally sent.
        // To make the two consistent, I am uppercasing the token string here.
        deviceTokenStr = deviceTokenStr.lowercaseString
        return deviceTokenStr
    }
    
    // Called when a notification is received and the app is in the
    // foreground (or if the app was in the background and the user clicks on the notification).
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]
//        , fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        // display the userInfo
//        if let notification = userInfo["aps"] as? NSDictionary,
//            let alert = notification["alert"] as? String {
//                var alertCtrl = UIAlertController(title: "Time Entry", message: alert as String, preferredStyle: UIAlertControllerStyle.Alert)
//                alertCtrl.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//                // Find the presented VC...
//                var presentedVC = self.window?.rootViewController
//                while (presentedVC!.presentedViewController != nil)  {
//                    presentedVC = presentedVC!.presentedViewController
//                }
//                presentedVC!.presentViewController(alertCtrl, animated: true, completion: nil)
//                
//                // call the completion handler
//                // -- pass in NoData, since no new data was fetched from the server.
//                completionHandler(UIBackgroundFetchResult.NoData)
//        }
//    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if (application.applicationState == UIApplicationState.Background || application.applicationState == UIApplicationState.Inactive) {
            print(userInfo)
            let type = userInfo["type"] as! String
            if type == "answeredQuestion" {
                let answerId = userInfo["answerId"] as! String
                let questionId = userInfo["questionId"] as! String
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = self.window?.rootViewController as! TabBarViewController
                
                tabBarController.selectedIndex = 2
                let navController = tabBarController.viewControllers![2] as! UINavigationController
                let destinationViewController = storyboard.instantiateViewControllerWithIdentifier("AnsweredQuestionViewController") as! AnsweredQuestionViewController
                destinationViewController.answerId = answerId
                destinationViewController.questionId = questionId
                navController.pushViewController(destinationViewController, animated: true)
            }
            
        }
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

