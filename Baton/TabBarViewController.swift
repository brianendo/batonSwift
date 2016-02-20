//
//  TabBarViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 12/8/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import Crashlytics

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Put border between the tabBar icons
        if let items = self.tabBar.items {
            
            //Get the height of the tab bar
            let height = CGRectGetHeight(self.tabBar.bounds)
            
            //Calculate the size of the items
            let numItems = CGFloat(items.count)
            let itemSize = CGSize(
                width: tabBar.frame.width / numItems,
                height: tabBar.frame.height)
            
            for (index, _) in items.enumerate() {
                
                //We don't want a separator on the left of the first item.
                if index > 0 {
                    
                    //Xposition of the item
                    let xPosition = itemSize.width * CGFloat(index)
                    
                    /* Create UI view at the Xposition,
                    with a width of 0.5 and height equal
                    to the tab bar height, and give the
                    view a background color
                    */
                    let separator = UIView(frame: CGRect(
                        x: xPosition, y: 0, width: 0.5, height: height))
                    separator.backgroundColor = UIColor.grayColor()
                    tabBar.insertSubview(separator, atIndex: 1)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item.tag == 0 {
            Answers.logCustomEventWithName("Tab Bar",
                customAttributes: ["name":"feed"])
            print("feed")
        } else if item.tag == 1 {
            Answers.logCustomEventWithName("Tab Bar",
                customAttributes: ["name":"search"])
            print("search")
        } else if item.tag == 2 {
            Answers.logCustomEventWithName("Tab Bar",
                customAttributes: ["name":"notification"])
            print("notifications")
        } else if item.tag == 3 {
            Answers.logCustomEventWithName("Tab Bar",
                customAttributes: ["name":"profile"])
            print("profile")
        }
    }
    

}
