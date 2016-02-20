//
//  WebViewController.swift
//  Baton
//
//  Created by Brian Endo on 2/3/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    // MARK: - IBOutelts
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: - Variables
    var urlToLoad: NSURL?
    
    // MARK: - viewWill/viewDid
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = NSURLRequest(URL: urlToLoad!)
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction
    @IBAction func exitButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}
