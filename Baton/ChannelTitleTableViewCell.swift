//
//  ChannelTitleTableViewCell.swift
//  Baton
//
//  Created by Brian Endo on 2/15/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class ChannelTitleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggleChannelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        toggleChannelButton.setTitle("-", forState: .Selected)
        toggleChannelButton.setTitle("+", forState: .Normal)
//        toggleChannelButton.setTitleColor(UIColor.blueColor(), forState: .Highlighted)
        toggleChannelButton.backgroundColor = UIColor.whiteColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
