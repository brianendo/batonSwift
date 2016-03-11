//
//  FeaturedPreviewTableViewCell.swift
//  Baton
//
//  Created by Brian Endo on 3/10/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit

class FeaturedPreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var viewImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var questionContentLabel: UILabel!
    @IBOutlet weak var usernameButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.profileImageView.layer.borderWidth = 1.0
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
        self.profileImageView.clipsToBounds = true
        
        profileImageView.layer.shadowColor = UIColor.grayColor().CGColor
        profileImageView.layer.shadowOffset = CGSizeMake(0.3, 2.0)
        profileImageView.layer.shadowOpacity = 0.5
        profileImageView.layer.shadowRadius = 0.5
        profileImageView.layer.backgroundColor = UIColor.clearColor().CGColor
        
        nameLabel.layer.shadowColor = UIColor.grayColor().CGColor
        nameLabel.layer.shadowOffset = CGSizeMake(0.3, 2.0)
        nameLabel.layer.shadowOpacity = 0.5
        nameLabel.layer.shadowRadius = 0.5
        nameLabel.layer.backgroundColor = UIColor.clearColor().CGColor
        
        viewCountLabel.layer.shadowColor = UIColor.grayColor().CGColor
        viewCountLabel.layer.shadowOffset = CGSizeMake(0.3, 2.0)
        viewCountLabel.layer.shadowOpacity = 0.5
        viewCountLabel.layer.shadowRadius = 0.5
        viewCountLabel.layer.backgroundColor = UIColor.clearColor().CGColor
        
        likeCountLabel.layer.shadowColor = UIColor.grayColor().CGColor
        likeCountLabel.layer.shadowOffset = CGSizeMake(0.3, 2.0)
        likeCountLabel.layer.shadowOpacity = 0.5
        likeCountLabel.layer.shadowRadius = 0.5
        likeCountLabel.layer.backgroundColor = UIColor.clearColor().CGColor
        
        likeImageView.layer.shadowColor = UIColor.grayColor().CGColor
        likeImageView.layer.shadowOffset = CGSizeMake(0.3, 2.0)
        likeImageView.layer.shadowOpacity = 0.5
        likeImageView.layer.shadowRadius = 0.5
        likeImageView.layer.backgroundColor = UIColor.clearColor().CGColor
        
        viewImageView.layer.shadowColor = UIColor.grayColor().CGColor
        viewImageView.layer.shadowOffset = CGSizeMake(0.3, 2.0)
        viewImageView.layer.shadowOpacity = 0.5
        viewImageView.layer.shadowRadius = 0.5
        viewImageView.layer.backgroundColor = UIColor.clearColor().CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
