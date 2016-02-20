//
//  FeedSegmentedTableViewCell.swift
//  Baton
//
//  Created by Brian Endo on 2/15/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class FeedSegmentedTableViewCell: UITableViewCell {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        segmentedControl.backgroundColor = UIColor(red:0.17, green:0.18, blue:0.29, alpha:1.0)
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor(red:0.91, green:0.27, blue:0.27, alpha:1.0)], forState: UIControlState.Normal)
        segmentedControl.tintColor = UIColor(red:0.91, green:0.27, blue:0.27, alpha:1.0)
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor(red:0.17, green:0.18, blue:0.29, alpha:1.0)], forState: UIControlState.Selected)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
