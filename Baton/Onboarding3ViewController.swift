//
//  Onboarding3ViewController.swift
//  Baton
//
//  Created by Brian Endo on 2/10/16.
//  Copyright © 2016 Brian Endo. All rights reserved.
//

import UIKit
import AWSS3
import AVFoundation
import AVKit

class Onboarding3ViewController: UIViewController {
    
    var player: AVPlayer!
    var playerController: AVPlayerViewController!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "restartVideoFromBeginning",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: nil)
        
        if player.rate > 0 {
            
        } else {
            player.play()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        if player.rate > 0 {
            player.pause()
        } else {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoView.layoutIfNeeded()
        playerController = AVPlayerViewController()
        playerController.view.frame = videoView.bounds
        
        playerController.showsPlaybackControls = false
        playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerController.view.hidden = false
        
        let videoUrl = "https://s3-us-west-1.amazonaws.com/batonapp/Onboarding3Flipped.mp4"
        
        let newURL = NSURL(string: videoUrl)
        
        player = AVPlayer(URL: newURL!)
        playerController.player = player
        
        videoView.addSubview(playerController.view)
        
        player.play()
        
    }
    
    func restartVideoFromBeginning()  {
        print("Reached")
        //create a CMTime for zero seconds so we can go back to the beginning
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        
        player.seekToTime(seekTime)
        
        player.play()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
