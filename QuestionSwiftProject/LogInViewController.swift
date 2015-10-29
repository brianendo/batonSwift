//
//  LogInViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 10/29/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class LogInViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logInButtonPressed(sender: UIButton) {
//        let username = self.usernameTextField.text!
//        let password = self.passwordTextField.text!
//        let url = "http://localhost:3000/api/login"
//        let parameters = [
//            "username": username,
//            "password": password
//        ]
//        
//        Alamofire.request(.POST, url, parameters: parameters)
//            .responseJSON { response in
//                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
//                
//                if let JSON = response.result.value {
//                    print("JSON: \(JSON)")
//                }
//        }
        ref.authUser(emailTextField.text, password: passwordTextField.text,
            withCompletionBlock: { error, authData in
                if error != nil {
                    // There was an error logging in to this account
                } else {
                    // We are now logged in
                    print(authData.uid)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainVC = storyboard.instantiateInitialViewController()
                    self.presentViewController(mainVC!, animated: true, completion: nil)
                }
        })
        
    }
    

}
