//
//  FollowingAnswerTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 1/15/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class FollowingAnswerTableViewCell: UITableViewCell {

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
    
    var player: AVPlayer!
    var playerController: AVPlayerViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        likeCountTextView.layer.shadowColor = UIColor.blackColor().CGColor
//        likeCountTextView.layer.shadowOffset = CGSizeMake(0, 2.0)
//        likeCountTextView.layer.shadowOpacity = 1.0
//        likeCountTextView.layer.shadowRadius = 2.0
//        likeCountTextView.layer.backgroundColor = UIColor.clearColor().CGColor
        
        self.profileImageView.frame = CGRectMake(0, 0, 35, 35)
        self.profileImageView.layer.borderWidth = 0.5
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
        self.profileImageView.clipsToBounds = true
        
        playerController = AVPlayerViewController()
        playerController.player = player
        
        playerController.view.frame = CGRectMake(videoView.frame.origin.x, videoView.frame.origin.x, videoView.frame.size.width, videoView.frame.size.height)
        //                        playerController.view.frame = self.videoView.frame
        
        // Mirrors video
        //        playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        
        playerController.showsPlaybackControls = false
        playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerController.view.hidden = false
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
