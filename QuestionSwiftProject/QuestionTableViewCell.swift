//
//  QuestionTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 10/29/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var answercountLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var bottomMarginImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImageView.frame = CGRectMake(0, 0, 30, 30)
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
