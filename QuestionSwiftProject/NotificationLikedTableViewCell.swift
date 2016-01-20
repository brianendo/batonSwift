//
//  NotificationLikedTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 1/15/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class NotificationLikedTableViewCell: UITableViewCell {

    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
