//
//  PushViewController.swift
//  Baton
//
//  Created by Brian Endo on 2/10/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class PushViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func allowButtonPressed(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateInitialViewController()
        self.presentViewController(mainVC!, animated: true, completion: nil)
    }
    
    @IBAction func doNotAllowButtonPressed(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateInitialViewController()
        self.presentViewController(mainVC!, animated: true, completion: nil)
    }
    
    

}
