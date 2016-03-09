//
//  ProfileQuestionTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 11/3/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit

// ProfileViewController TableViewCell
class ProfileQuestionTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var answercountLabel: UILabel!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var channelButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    // MARK: - overrid
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
