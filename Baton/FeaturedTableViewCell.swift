//
//  FeaturedTableViewCell.swift
//  Baton
//
//  Created by Brian Endo on 3/8/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class FeaturedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var featuredImageView: UIImageView!
    @IBOutlet weak var featuredImageView2: UIImageView!
    @IBOutlet weak var featuredImageView3: UIImageView!
    @IBOutlet weak var featuredLabel: UILabel!
    @IBOutlet weak var disclosureImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        featuredLabel.layer.borderColor = UIColor.whiteColor().CGColor
        featuredLabel.layer.borderWidth = 1.0
        featuredLabel.layer.cornerRadius = 5
//        featuredLabel.shadowColor = UIColor.blackColor()
//        featuredLabel.shadowOffset = CGSizeMake(0.5, 0.5)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
