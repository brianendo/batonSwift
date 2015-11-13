//
//  ProfileTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 11/4/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var profileSegmentedControl: UISegmentedControl!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImageView.frame = CGRectMake(0, 0, 60, 60)
        self.profileImageView.layer.borderWidth = 0.5
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
        self.profileImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
