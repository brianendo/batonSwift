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

class StartViewController: UIViewController {

    let keychain = KeychainSwift()
    
    @IBOutlet weak var twitterLoginButton: UIButton!
    
    var firstname = ""
    var lastname = ""
    var profileImageUrl = ""
    var username = ""
    var twitterId = ""
    var twitterUsername = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        twitterLoginButton.titleEdgeInsets = UIEdgeInsetsMake(0, -twitterLoginButton.imageView!.frame.size.width, 0, twitterLoginButton.imageView!.frame.size.width);
        twitterLoginButton.imageEdgeInsets = UIEdgeInsetsMake(0, twitterLoginButton.titleLabel!.frame.size.width, 0, -twitterLoginButton.titleLabel!.frame.size.width)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func twitterLoginPressed(sender: UIButton) {
        Twitter.sharedInstance().logInWithCompletion { session, error in
            if (session != nil) {
                print(session?.userID)
                
                let twitterId = (session?.userID)! as String
                
                let url = globalurl + "api/findtwitteruser/" + twitterId
                
                Alamofire.request(.GET, url, parameters: nil)
                    .responseJSON { response in
                        print(response.request)
                        print(response.response)
                        print(response.result)
                        print(response.response?.statusCode)
                        
                        let statuscode = response.response?.statusCode
                        if statuscode == 200 {
                            print("Log In successful")
                            let json = JSON(response.result.value!)
                            print("JSON: \(json)")
                            print(json["data"]["_id"].string)
                            print(json["token"].string)
                            let id = json["data"]["_id"].string
                            let token = json["token"].string
                            var refresh_token = json["data"]["token"].string
                            if token == nil {
                                
                            } else {
                                do {
                                    let jwt = try decode(token!)
                                    print(jwt)
                                    print(jwt.body)
                                    print(jwt.expiresAt)
                                } catch {
                                    print("Failed to decode JWT: \(error)")
                                }
                                
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
                                            self.keychain.set(token!, forKey: "refresh_token")
                                        }
                                }
                            } else {
                                self.keychain.set(refresh_token!, forKey: "refresh_token")
                            }
                            
                            self.keychain.set(id!, forKey: "ID")
                            self.keychain.set("1", forKey: "ISLOGGEDIN")
                            self.keychain.set(token!, forKey: "JWT")
                            
//                            let id = json["_id"].string
//                            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//                            prefs.setObject(id, forKey: "ID")
//                            prefs.setInteger(1, forKey: "ISLOGGEDIN")
//                            prefs.synchronize()
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let mainVC = storyboard.instantiateInitialViewController()
                            self.presentViewController(mainVC!, animated: true, completion: nil)
                        } else if statuscode == 400 {
                            print("signed in as \(session!.userName)")
                            let userID = (session?.userID)!
                            let client = TWTRAPIClient()
                            client.loadUserWithID(userID) { (user, error) -> Void in
                                // handle the response or error
                                print(user?.name)
                                print(user?.profileImageURL)
                                print(user?.profileImageLargeURL)
                                let fullName = (user?.name)! as String
                                let fullNameArr = fullName.characters.split{$0 == " "}.map(String.init)
                                
                                self.firstname = fullNameArr[0]
                                self.lastname = fullNameArr[1]
                                self.profileImageUrl = (user?.profileImageLargeURL)! as String
                                self.username = session!.userName as String
                                self.twitterId = userID
                                self.twitterUsername = session!.userName as String
                                
                                let url = "http://twitter.com/" + session!.userName
                                self.performSegueWithIdentifier("segueToTwitterSignup", sender: self)
                            }
                        } else if statuscode == 404 {
                            var alertView:UIAlertView = UIAlertView()
                            alertView.title = "Sign in Failed!"
                            alertView.message = "Connection Failed"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        } else {
                            var alertView:UIAlertView = UIAlertView()
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
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToTwitterSignup" {
            let twitterVC: TwitterSignupViewController = segue.destinationViewController as! TwitterSignupViewController
            twitterVC.firstName = firstname
            twitterVC.lastName = lastname
            twitterVC.profileImageUrl = profileImageUrl
            twitterVC.username = username
            twitterVC.twitterId = twitterId
            twitterVC.twitterUsername = twitterUsername
        }
    }
}
