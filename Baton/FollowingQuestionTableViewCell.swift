//
//  FollowingQuestionTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 1/15/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

// FollowingViewController TableViewCell
class FollowingQuestionTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    // MARK: - override
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.profileImageView.layer.borderWidth = 0.5
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
        self.profileImageView.clipsToBounds = true
        
        usernameButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        usernameButton.titleLabel?.textColor = UIColor.blackColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
