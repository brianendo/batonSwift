//
//  ProfileButtonsTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 1/26/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class ProfileButtonsTableViewCell: UITableViewCell {

    @IBOutlet weak var pencilButton: UIButton!
    @IBOutlet weak var recorderButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        pencilButton.setImage(UIImage(named: "pencilSelected"), forState: .Selected)
        pencilButton.setImage(UIImage(named: "grayPencilProfile"), forState: .Normal)
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
