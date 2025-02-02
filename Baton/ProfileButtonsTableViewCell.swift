//
//  ProfileButtonsTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 1/26/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

// ProfileViewController TableViewCell
class ProfileButtonsTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var pencilButton: UIButton!
    @IBOutlet weak var recorderButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var personalButton: UIButton!
    
    // MARK: - override
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        personalButton.setImage(UIImage(named: "bluePersonal"), forState: .Selected)
        personalButton.setImage(UIImage(named: "grayPersonal"), forState: .Normal)
        personalButton.layer.borderWidth = 0.5
        personalButton.layer.borderColor = UIColor(white:0.79, alpha:1.0).CGColor
        
        pencilButton.setImage(UIImage(named: "lightbulbProfileSelected"), forState: .Selected)
        pencilButton.setImage(UIImage(named: "graylightbulbProfile"), forState: .Normal)
        pencilButton.layer.borderWidth = 0.5
        pencilButton.layer.borderColor = UIColor(white:0.79, alpha:1.0).CGColor
        
        recorderButton.setImage(UIImage(named: "blueRecorderProfile"), forState: .Selected)
        recorderButton.setImage(UIImage(named: "grayRecorderProfile"), forState: .Normal)
        recorderButton.layer.borderWidth = 0.5
        recorderButton.layer.borderColor = UIColor(white:0.79, alpha:1.0).CGColor
        
        heartButton.setImage(UIImage(named: "redHeartProfile"), forState: .Selected)
        heartButton.setImage(UIImage(named: "grayHeartProfile"), forState: .Normal)
        heartButton.layer.borderWidth = 0.5
        heartButton.layer.borderColor = UIColor(white:0.79, alpha:1.0).CGColor

        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
