//
//  AppDelegate.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 10/29/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase
import AWSCore
import AWSCognito
import AWSS3

// Firebase url
let ref = Firebase(url: "https://questionproject.firebaseio.com/")

// Global currentuser variable
var currentUser = ""
var name = ""
var userid = ""

let herokuUrl = "https://arcane-savannah-8802.herokuapp.com/"
let localUrl = "http://localhost:5000/"
let globalurl = localUrl

let cloudfrontUrl = "https://d1uji1hs8rdjoi.cloudfront.net/"


// Constants for Amazon Web Services
let CognitoRegionType = AWSRegionType.USEast1  // e.g. AWSRegionType.USEast1
let DefaultServiceRegionType = AWSRegionType.USWest1 // e.g. AWSRegionType.USWest2
let CognitoIdentityPoolId = "us-east-1:cd887d49-c047-4889-bf49-215cd886036d"
let S3BucketName = "batonapp"

var imageCache: Dictionary<String, NSData?> = Dictionary<String, NSData>()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().barTintColor = UIColor(red:0.17, green:0.18, blue:0.29, alpha:1.0)
        UINavigationBar.appearance().tintColor = UIColor(red:0.91, green:0.27, blue:0.27, alpha:1.0)
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor(red:0.17, green:0.18, blue:0.29, alpha:1.0), NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 20)!]
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        UITabBar.appearance().barTintColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        UITabBar.appearance().tintColor = UIColor(red:0.91, green:0.27, blue:0.27, alpha:1.0)
        
        // Check credentials for AWS
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: AWSRegionType.USEast1, identityPoolId: CognitoIdentityPoolId)
        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: AWSRegionType.USWest1, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
        
        return true
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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

