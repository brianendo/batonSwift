//
//  Onboarding2ViewController.swift
//  Baton
//
//  Created by Brian Endo on 2/10/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import AWSS3
import AVFoundation
import AVKit

class Onboarding2ViewController: UIViewController {
    
    // MARK: - Variables
    var player: AVPlayer!
    var playerController: AVPlayerViewController!
    
    // MARK: - IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    
    // MARK: - viewWill/viewDid
    override func viewWillAppear(animated: Bool) {
        
        // Sets notification to restart video when it ends
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "restartVideoFromBeginning",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: nil)
        
        // Play player when view appears
        if player.rate > 0 {
            
        } else {
            player.play()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Remove notification
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        // Pause player when leaving view
        if player.rate > 0 {
            player.pause()
        } else {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Layout playerController view and add url to player
        videoView.layoutIfNeeded()
        playerController = AVPlayerViewController()
        playerController.view.frame = videoView.bounds
        playerController.showsPlaybackControls = false
        playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerController.view.hidden = false
        let videoUrl = "https://s3-us-west-1.amazonaws.com/batonapp/Onboarding2Flipped.mp4"
        let newURL = NSURL(string: videoUrl)
        player = AVPlayer(URL: newURL!)
        playerController.player = player
        playerController.player?.volume = 0
        videoView.addSubview(playerController.view)
        player.play()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Functions
    func restartVideoFromBeginning()  {
        //create a CMTime for zero seconds so we can go back to the beginning
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        // Bring player to time zero
        player.seekToTime(seekTime)
        player.play()
    }
    
}
