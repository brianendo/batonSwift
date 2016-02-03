//
//  QuestionTitleTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 12/4/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit

class QuestionTitleTableViewCell: UITableViewCell {

    @IBOutlet weak var likeCountTextView: UITextView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var postedByTextView: UITextView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var answerCountLabel: UILabel!
    @IBOutlet weak var postedByButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
