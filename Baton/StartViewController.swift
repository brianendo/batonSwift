//
//  StartViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 10/29/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import TwitterKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import JWTDecode
import Crashlytics
import FBSDKCoreKit
import FBSDKLoginKit

class StartViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var twitterLoginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    
    // MARK: - Variables
    let keychain = KeychainSwift()
    var firstname = ""
    var lastname = ""
    var profileImageUrl = ""
    var username = ""
    var twitterId = ""
    var twitterUsername = ""
    var highschoolName = ""
    var facebookId = ""
    var email = ""
    
    // MARK: - viewWill/viewDid
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Format text and image on Twitter Button
//        twitterLoginButton.titleEdgeInsets = UIEdgeInsetsMake(0, -twitterLoginButton.imageView!.frame.size.width, 0, twitterLoginButton.imageView!.frame.size.width);
//        twitterLoginButton.imageEdgeInsets = UIEdgeInsetsMake(0, twitterLoginButton.titleLabel!.frame.size.width, 0, -twitterLoginButton.titleLabel!.frame.size.width)
        
        facebookLoginButton.titleEdgeInsets = UIEdgeInsetsMake(0, -facebookLoginButton.imageView!.frame.size.width, 0, facebookLoginButton.imageView!.frame.size.width)
        facebookLoginButton.imageEdgeInsets = UIEdgeInsetsMake(0, facebookLoginButton.titleLabel!.frame.size.width, 0, -facebookLoginButton.titleLabel!.frame.size.width)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - IBAction
    @IBAction func twitterLoginPressed(sender: UIButton) {
        // Twitter Login
        Answers.logCustomEventWithName("StartVC Taps",
            customAttributes: ["button":"Twitter"])
        Twitter.sharedInstance().logInWithCompletion { session, error in
            if (session != nil) {
                print(session?.userID)
                
                // Unique Twitter id
                let twitterId = (session?.userID)! as String
                
                // Check if user with Twitter id exists
                let url = globalurl + "api/findtwitteruser/" + twitterId
                Alamofire.request(.GET, url, parameters: nil)
                    .responseJSON { response in
                        print(response.request)
                        print(response.response)
                        print(response.result)
                        print(response.response?.statusCode)
                        
                        let statuscode = response.response?.statusCode
                        
                        // Able to find a user with that Twitter ID
                        if statuscode == 200 {
                            print("Log In successful")
                            let json = JSON(response.result.value!)
                            print("JSON: \(json)")
                            print(json["data"]["_id"].string)
                            print(json["token"].string)
                            let id = json["data"]["_id"].string
                            let token = json["token"].string
                            let refresh_token = json["data"]["token"].string
                            
                            if refresh_token == nil {
                                // Generate refresh token if user does not have one
                                let url = globalurl + "api/users/" + id! + "/addtoken/"
                                
                                Alamofire.request(.PUT, url, parameters: nil)
                                    .responseJSON { response in
                                        let result = response.result.value
                                        print(result)
                                        if result == nil {
                                            
                                        } else {
                                            let json = JSON(response.result.value!)
                                            print("JSON: \(json)")
                                            let token = json["token"].string
                                            
                                            // Set refresh token in Keychain
                                            self.keychain.set(token!, forKey: "refresh_token")
                                        }
                                }
                            } else {
                                // Set refresh token in Keychain
                                self.keychain.set(refresh_token!, forKey: "refresh_token")
                            }
                            
                            self.keychain.set(id!, forKey: "ID")
                            self.keychain.set("1", forKey: "ISLOGGEDIN")
                            self.keychain.set(token!, forKey: "JWT")
                            
                            Answers.logLoginWithMethod("Twitter",
                                success: true,
                                customAttributes: [:])
                            
                            // Go to main storyboard
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let mainVC = storyboard.instantiateInitialViewController()
                            self.presentViewController(mainVC!, animated: true, completion: nil)
                        }
                        // Unable to find user with that Twitter ID, Set up sign up process
                        else if statuscode == 400 {
                            print("signed in as \(session!.userName)")
                            let userID = (session?.userID)!
                            let client = TWTRAPIClient()
                            client.loadUserWithID(userID) { (user, error) -> Void in
                                print(user?.name)
                                print(user?.profileImageURL)
                                print(user?.profileImageLargeURL)
                                var profileImageUrl = (user?.profileImageLargeURL)
                                if profileImageUrl == nil {
                                    profileImageUrl = ""
                                }
                                
                                let fullName = (user?.name)
                                if fullName == nil {
                                    
                                } else {
                                    // Split first name and last name by finding a space, not going to be fully accurate
                                    let fullNameArr = fullName!.characters.split{$0 == " "}.map(String.init)
                                    if fullNameArr.count > 1 {
                                        self.firstname = fullNameArr[0]
                                        self.lastname = fullNameArr[1]
                                    } else if fullNameArr.count == 1 {
                                        self.firstname = fullNameArr[0]
                                    } else {
                                        
                                    }
                                }
                                
                                
                                self.profileImageUrl = profileImageUrl! as String
                                self.username = session!.userName as String
                                self.twitterId = userID
                                self.twitterUsername = session!.userName as String
                                
                                self.performSegueWithIdentifier("segueToTwitterSignup", sender: self)
                            }
                        } else if statuscode == 404 {
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Sign in Failed!"
                            alertView.message = "Connection Failed"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        } else {
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Sign in Failed!"
                            alertView.message = "Connection Failed"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        }
                }
            } else {
                print("error: \(error!.localizedDescription)")
                let alert = UIAlertController(title: "Could not log in",
                    message: "Unable to access Twitter",
                    preferredStyle: UIAlertControllerStyle.Alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func logInButtonPressed(sender: UIButton) {
        Answers.logCustomEventWithName("StartVC Taps",
            customAttributes: ["button":"Log In"])
    }
    
    @IBAction func signUpButtonPressed(sender: UIButton) {
        Answers.logCustomEventWithName("StartVC Taps",
            customAttributes: ["button":"Sign Up"])
    }
    
    
    @IBAction func facebookButtonPressed(sender: UIButton) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["email", "public_profile"], fromViewController: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result
                if((FBSDKAccessToken.currentAccessToken()) != nil) {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                        fbLoginManager.logOut()
                        
                    }
                } else {
                    
                }
            }
        }
        
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email, gender, age_range"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    print(result)
                    
                    let json = JSON(result)
                    print("JSON: \(json)")
                    print(json["id"].string)
                    print(json["email"].string)
                    let first_name = json["first_name"].string
                    let last_name = json["last_name"].string
                    let email = json["email"].string
                    let facebook_id = json["id"].string
                    let pictureUrl = json["picture"]["data"]["url"].string
                    
                    self.firstname = first_name!
                    self.lastname = last_name!
                    self.email = email!
                    self.facebookId = facebook_id!
                    self.profileImageUrl = pictureUrl!
                    
//                    let schools = json["education"]
//                    
//                    if schools != nil {
//                        for (_,subJson):(String, JSON) in schools {
//                            let schoolname = subJson["school"]["name"].string
//                            let schoolid = subJson["school"]["id"].string
//                            let schooltype = subJson["type"].string
//                            
//                            print(schoolname)
//                            print(schoolid)
//                            print(schooltype)
//                            
//                            if schooltype == "High School" {
//                                print("recorded")
//                                self.highschoolName = schoolname!
//                            }
//                        }
//                    }
                    
                    let url = globalurl + "api/findfacebookuser/" + facebook_id!
                    Alamofire.request(.GET, url, parameters: nil)
                        .responseJSON { response in
                            print(response.request)
                            print(response.response)
                            print(response.result)
                            print(response.response?.statusCode)
                            
                            let statuscode = response.response?.statusCode
                            
                            // Able to find a user with that Twitter ID
                            if statuscode == 200 {
                                print("Log In successful")
                                let json = JSON(response.result.value!)
                                print("JSON: \(json)")
                                print(json["data"]["_id"].string)
                                print(json["token"].string)
                                let id = json["data"]["_id"].string
                                let token = json["token"].string
                                let refresh_token = json["data"]["token"].string
                                var schoolId = json["data"]["currentSchoolId"].string
                                var schoolName = json["data"]["currentSchoolName"].string
                                var shortenedName = json["data"]["currentSchoolShortenedName"].string
                                print(schoolId)
                                
                                if shortenedName == nil {
                                    shortenedName = schoolName
                                }
                                
                                if schoolId == nil {
                                    schoolId = ""
                                }
                                
                                if refresh_token == nil {
                                    // Generate refresh token if user does not have one
                                    let url = globalurl + "api/users/" + id! + "/addtoken/"
                                    
                                    Alamofire.request(.PUT, url, parameters: nil)
                                        .responseJSON { response in
                                            let result = response.result.value
                                            print(result)
                                            if result == nil {
                                                
                                            } else {
                                                let json = JSON(response.result.value!)
                                                print("JSON: \(json)")
                                                let token = json["token"].string
                                                
                                                // Set refresh token in Keychain
                                                self.keychain.set(token!, forKey: "refresh_token")
                                            }
                                    }
                                } else {
                                    // Set refresh token in Keychain
                                    self.keychain.set(refresh_token!, forKey: "refresh_token")
                                }
                                
                                self.keychain.set(id!, forKey: "ID")
                                self.keychain.set("1", forKey: "ISLOGGEDIN")
                                self.keychain.set(token!, forKey: "JWT")
                                self.keychain.set(schoolId!, forKey: "schoolID")
                                self.keychain.set(schoolName!, forKey: "mySchoolName")
                                self.keychain.set(shortenedName!, forKey: "shortenedName")
                                
                                
                                // Go to main storyboard
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let mainVC = storyboard.instantiateInitialViewController()
                                self.presentViewController(mainVC!, animated: true, completion: nil)
                            }
                            // Unable to find user with that Twitter ID, Set up sign up process
                            else if statuscode == 400 {
//                                print("signed in as \(session!.userName)")
//                                let userID = (session?.userID)!
//                                let client = TWTRAPIClient()
//                                client.loadUserWithID(userID) { (user, error) -> Void in
//                                    print(user?.name)
//                                    print(user?.profileImageURL)
//                                    print(user?.profileImageLargeURL)
//                                    var profileImageUrl = (user?.profileImageLargeURL)
//                                    if profileImageUrl == nil {
//                                        profileImageUrl = ""
//                                    }
//                                    
//                                    let fullName = (user?.name)
//                                    if fullName == nil {
//                                        
//                                    } else {
//                                        // Split first name and last name by finding a space, not going to be fully accurate
//                                        let fullNameArr = fullName!.characters.split{$0 == " "}.map(String.init)
//                                        if fullNameArr.count > 1 {
//                                            self.firstname = fullNameArr[0]
//                                            self.lastname = fullNameArr[1]
//                                        } else if fullNameArr.count == 1 {
//                                            self.firstname = fullNameArr[0]
//                                        } else {
//                                            
//                                        }
//                                    }
//                                    
//                                    
//                                    self.profileImageUrl = profileImageUrl! as String
//                                    self.username = session!.userName as String
//                                    self.twitterId = userID
//                                    self.twitterUsername = session!.userName as String
//                                    
//                                    self.performSegueWithIdentifier("segueToTwitterSignup", sender: self)
//                                }
                                self.performSegueWithIdentifier("segueToPickSchoolType", sender: self)
                            } else if statuscode == 404 {
                                let alertView:UIAlertView = UIAlertView()
                                alertView.title = "Sign in Failed!"
                                alertView.message = "Connection Failed"
                                alertView.delegate = self
                                alertView.addButtonWithTitle("OK")
                                alertView.show()
                            } else {
                                let alertView:UIAlertView = UIAlertView()
                                alertView.title = "Sign in Failed!"
                                alertView.message = "Connection Failed"
                                alertView.delegate = self
                                alertView.addButtonWithTitle("OK")
                                alertView.show()
                            }
                    }

                    
                }
            })
        }
    }
    
    
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToTwitterSignup" {
            let twitterVC: TwitterSignupViewController = segue.destinationViewController as! TwitterSignupViewController
            twitterVC.firstName = firstname
            twitterVC.lastName = lastname
            twitterVC.profileImageUrl = profileImageUrl
            twitterVC.username = username
            twitterVC.twitterId = twitterId
            twitterVC.twitterUsername = twitterUsername
        } else if segue.identifier == "segueToPickSchoolType" {
            let pickTypeVC: PickSchoolTypeViewController = segue.destinationViewController as! PickSchoolTypeViewController
            pickTypeVC.firstName = firstname
            pickTypeVC.lastName = lastname
            pickTypeVC.profileImageUrl = profileImageUrl
            pickTypeVC.facebookId = facebookId
            pickTypeVC.email = email
        }
    }
    
//    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
//        if error == nil {
//            print("Login Complete")
//        } else {
//            print(error.localizedDescription)
//        }
//    }
//    
//    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
//        print("User logged out")
//    }
}
