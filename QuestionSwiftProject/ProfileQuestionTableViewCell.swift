//
//  ProfileQuestionTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 11/3/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit

class ProfileQuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var answercountLabel: UILabel!
    
    @IBOutlet weak var questionTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
