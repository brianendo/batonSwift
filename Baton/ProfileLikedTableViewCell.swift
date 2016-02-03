//
//  ProfileLikedTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 1/18/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ProfileLikedTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var questionContentButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var questionContentHeight: NSLayoutConstraint!
    @IBOutlet weak var likeCountTextView: UITextView!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var questionContentTextView: UITextView!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var extraButton: UIButton!
    
    var player: AVPlayer!
    var playerController: AVPlayerViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.profileImageView.frame = CGRectMake(0, 0, 35, 35)
        self.profileImageView.layer.borderWidth = 0.5
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
        self.profileImageView.clipsToBounds = true
        
        playerController = AVPlayerViewController()
        playerController.player = player
        
        playerController.view.frame = CGRectMake(videoView.frame.origin.x, videoView.frame.origin.x, videoView.frame.size.width, videoView.frame.size.height)
        
        playerController.showsPlaybackControls = false
        playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerController.view.hidden = false
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
