//
//  MyQuestionAnswerTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 11/2/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit

class MyQuestionAnswerTableViewCell: UITableViewCell {

    @IBOutlet weak var thankButton: UIButton!
    
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
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
