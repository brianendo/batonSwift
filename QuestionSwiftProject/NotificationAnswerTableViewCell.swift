//
//  NotificationAnswerTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 11/3/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit

class NotificationAnswerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerTextView: UITextView!
    @IBOutlet weak var contentTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
