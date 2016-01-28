//
//  ProfileRelayTableViewCell.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 12/8/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ProfileRelayTableViewCell: UITableViewCell {

    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountTextView: UITextView!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var questionContentButton: UIButton!
    
    
    var player: AVPlayer!
    var playerController: AVPlayerViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
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
