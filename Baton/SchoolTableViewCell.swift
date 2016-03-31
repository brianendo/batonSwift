//
//  SchoolTableViewCell.swift
//  Baton
//
//  Created by Brian Endo on 3/30/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class SchoolTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
