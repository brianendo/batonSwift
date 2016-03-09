//
//  QuestionTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 10/29/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit

// FeedViewController TableViewCell
class QuestionTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var answercountLabel: UILabel!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var channelButton: UIButton!
    @IBOutlet weak var likecountLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    // MARK: - override
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // add a pan recognizer
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
