//
//  EditPushViewController.swift
//  Baton
//
//  Created by Brian Endo on 3/12/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import JWTDecode
import KeychainSwift

class EditPushViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var relaySwitch: UISwitch!
    @IBOutlet weak var likeSwitch: UISwitch!
    @IBOutlet weak var followSwitch: UISwitch!
    
    let keychain = KeychainSwift()
    var myRelayPush = true
    var myLikePush = true
    var myFollowPush = true
    
    func loadUserInfo() {
        
        // Grab JWT token and then verify if token is expired!
        var token = keychain.get("JWT")
        
        do {
            
            if token == nil {
                var refresh_token = keychain.get("refresh_token")
                
                if refresh_token == nil {
                    refresh_token = ""
                }
                
                // Use refresh token to get new JWT
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
                            let newtoken = json["token"].string
                            self.keychain.set(newtoken!, forKey: "JWT")
                            token = newtoken
                            
                            // Use JWT to access users route
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
                                        
                                        
                                        var relayPush = json["relayPush"].bool
                                        var likePush = json["likePush"].bool
                                        var followPush = json["followPush"].bool
                                        
                                        if relayPush == nil {
                                            relayPush = true
                                        }
                                        if likePush == nil {
                                            likePush = true
                                        }
                                        
                                        if followPush == nil {
                                            followPush = true
                                        }
                                        
                                        self.myRelayPush = relayPush!
                                        self.myLikePush = likePush!
                                        self.myFollowPush = followPush!
                                        
                                        self.relaySwitch.setOn(relayPush!, animated: true)
                                        self.likeSwitch.setOn(likePush!, animated: true)
                                        self.followSwitch.setOn(followPush!, animated: true)
                                        
                                    }
                            }
                        }
                        
                        
                }
            } else {
                let jwt = try decode(token!)
                
                // Check if JWT expired
                if jwt.expired == true {
                    var refresh_token = keychain.get("refresh_token")
                    
                    if refresh_token == nil {
                        refresh_token = ""
                    }
                    
                    // Use refresh token to get new JWT
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
                                //                            print("JSON: \(json)")
                                //                            print(json["token"].string)
                                let newtoken = json["token"].string
                                self.keychain.set(newtoken!, forKey: "JWT")
                                token = newtoken
                                
                                // Use JWT to access users route
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
                                            
                                            var relayPush = json["relayPush"].bool
                                            var likePush = json["likePush"].bool
                                            var followPush = json["followPush"].bool
                                            
                                            if relayPush == nil {
                                                relayPush = true
                                            }
                                            if likePush == nil {
                                                likePush = true
                                            }
                                            
                                            if followPush == nil {
                                                followPush = true
                                            }
                                            
                                            self.myRelayPush = relayPush!
                                            self.myLikePush = likePush!
                                            self.myFollowPush = followPush!
                                            
                                            self.relaySwitch.setOn(relayPush!, animated: true)
                                            self.likeSwitch.setOn(likePush!, animated: true)
                                            self.followSwitch.setOn(followPush!, animated: true)
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
                                
                                
                                var relayPush = json["relayPush"].bool
                                var likePush = json["likePush"].bool
                                var followPush = json["followPush"].bool
                                
                                if relayPush == nil {
                                    relayPush = true
                                }
                                if likePush == nil {
                                    likePush = true
                                }
                                
                                if followPush == nil {
                                    followPush = true
                                }
                                
                                self.myRelayPush = relayPush!
                                
                                self.myLikePush = likePush!
                                self.myFollowPush = followPush!
                                
                                self.relaySwitch.setOn(relayPush!, animated: true)
                                self.likeSwitch.setOn(likePush!, animated: true)
                                self.followSwitch.setOn(followPush!, animated: true)
                            }
                    }
                }
            }
            
        } catch {
            print("Failed to decode JWT: \(error)")
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadUserInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        relaySwitch.addTarget(self, action: Selector("relayStateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        likeSwitch.addTarget(self, action: Selector("likeStateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        followSwitch.addTarget(self, action: Selector("followStateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
    }

    func relayStateChanged(switchState: UISwitch) {
        if switchState.on {
            myRelayPush = true
        } else {
            myRelayPush = false
        }
    }
    
    func likeStateChanged(switchState: UISwitch) {
        if switchState.on {
            myLikePush = true
        } else {
            myLikePush = false
        }
    }
    
    func followStateChanged(switchState: UISwitch) {
        if switchState.on {
            myFollowPush = true
        } else {
            myFollowPush = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        let url = globalurl + "api/userpushsettings"
        let parameters = [
            "id": userid,
            "relayPush": myRelayPush,
            "likePush": myLikePush,
            "followPush": myFollowPush
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
