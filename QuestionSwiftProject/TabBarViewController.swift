//
//  TabBarViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 12/8/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
//    override func viewWillLayoutSubviews() {
//        var tabFrame = self.tabBar.frame
//        // - 40 is editable , I think the default value is around 50 px, below lowers the tabbar and above increases the tab bar size
//        tabFrame.size.height = 40
//        tabFrame.origin.y = self.view.frame.size.height - 40
//        self.tabBar.frame = tabFrame
//        
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
