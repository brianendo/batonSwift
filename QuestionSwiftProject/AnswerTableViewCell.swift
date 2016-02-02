//
//  AnswerTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 12/3/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class AnswerTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeCountTextView: UITextView!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var nameButton: UIButton!
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
        
//        likeCountTextView.layer.shadowColor = UIColor.blackColor().CGColor
//        likeCountTextView.layer.shadowOffset = CGSizeMake(0, 2.0)
//        likeCountTextView.layer.shadowOpacity = 1.0
//        likeCountTextView.layer.shadowRadius = 2.0
//        likeCountTextView.layer.backgroundColor = UIColor.clearColor().CGColor
        
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
