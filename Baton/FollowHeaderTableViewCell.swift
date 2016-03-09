//
//  FollowHeaderTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 1/22/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

// FollowingViewController TableViewCell
class FollowHeaderTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var relayButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    
    // MARK: - override
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        relayButton.setImage(UIImage(named: "blueVideo"), forState: .Selected)
        relayButton.setImage(UIImage(named: "grayVideo"), forState: .Normal)
        relayButton.setTitleColor(UIColor(white:0.74, alpha:1.0), forState: .Normal)
        relayButton.setTitleColor(UIColor(red:0.17, green:0.18, blue:0.29, alpha:1.0), forState: .Selected)
        relayButton.backgroundColor = UIColor.whiteColor()
        relayButton.tag = 0
        
        postButton.setImage(UIImage(named: "bluelightbulb"), forState: .Selected)
        postButton.setImage(UIImage(named: "graylightbulb"), forState: .Normal)
        postButton.setTitleColor(UIColor(white:0.74, alpha:1.0), forState: .Normal)
        postButton.setTitleColor(UIColor(red:0.17, green:0.18, blue:0.29, alpha:1.0), forState: .Selected)
        postButton.backgroundColor = UIColor.whiteColor()
        postButton.tag = 1
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
