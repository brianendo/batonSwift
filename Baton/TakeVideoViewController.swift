//
//  TakeVideoViewController.swift
//  QuestionSwiftProject
//
//  Created by Brian Endo on 11/30/15.
//  Copyright © 2015 Brian Endo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import MediaPlayer
import AssetsLibrary
import AWSS3
import Alamofire
import SwiftyJSON
import KeychainSwift
import JWTDecode
import Crashlytics

extension UIView {
    func layerGradient() {
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = self.frame.size
        layer.frame.origin = CGPointMake(0.0,0.0)
        layer.cornerRadius = CGFloat(frame.width / 20)
        
        let color0 = UIColor(red:250.0/255, green:250.0/255, blue:250.0/255, alpha:0.5).CGColor
        let color1 = UIColor(red:200.0/255, green:200.0/255, blue: 200.0/255, alpha:0.1).CGColor
        let color2 = UIColor(red:150.0/255, green:150.0/255, blue: 150.0/255, alpha:0.1).CGColor
        let color3 = UIColor(red:100.0/255, green:100.0/255, blue: 100.0/255, alpha:0.1).CGColor
        let color4 = UIColor(red:50.0/255, green:50.0/255, blue:50.0/255, alpha:0.1).CGColor
        let color5 = UIColor(red:0.0/255, green:0.0/255, blue:0.0/255, alpha:0.1).CGColor
        let color6 = UIColor(red:150.0/255, green:150.0/255, blue:150.0/255, alpha:0.1).CGColor
        
        layer.colors = [color0,color1,color2,color3,color4,color5,color6]
        self.layer.insertSublayer(layer, atIndex: 0)
    }
}

class TakeVideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet var switchCameraButton: UIButton!
    @IBOutlet var flashLightButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var uploadingLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var overlayView: UIView!
    
    // MARK: - Variables
    let keychain = KeychainSwift()
    var captureSession = AVCaptureSession()
    var audioCapture: AVCaptureDevice?
    var backCameraVideoCapture: AVCaptureDevice?
    var frontCameraVideoCapture: AVCaptureDevice?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var output: AVCaptureMovieFileOutput?
    var moviePlayer:MPMoviePlayerController!
    var player: AVPlayer!
    var playerController: AVPlayerViewController!
    var frontCamera: Bool = true
    var recordingInProgress: Bool = false
    var content = ""
    var id = ""
    var videoUrl: NSURL?
    var answerId = ""
    var fromFeatured = false
    var videoTime = 0
    var fromAddTake = false
    
    // MARK: - touchesBegan
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchPoint = touches.first! as UITouch
        let screenSize = cameraView.bounds.size
        let focusPoint = CGPoint(x: touchPoint.locationInView(cameraView).y / screenSize.height, y: 1.0 - touchPoint.locationInView(cameraView).x / screenSize.width)
        
        if let device = backCameraVideoCapture {
            if device.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) {
                do {
                    try device.lockForConfiguration()
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
        if let device = frontCameraVideoCapture {
            if device.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) {
                do {
                    try device.lockForConfiguration()
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - viewWill/viewDid
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "restartVideoFromBeginning",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: player)
    }
    
    func restartVideoFromBeginning()  {
        print("Reached")
        //create a CMTime for zero seconds so we can go back to the beginning
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        if player != nil {
            player.seekToTime(seekTime)
            player.play()
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
//        if player != nil {
//            player.removeObserver(self, forKeyPath: "status")
//        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Formatting for previewLayer
        if previewLayer?.frame != nil {
            previewLayer!.frame = cameraView.bounds
        } else {
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // switchCameraButton formatting
        switchCameraButton.layer.shadowColor = UIColor.grayColor().CGColor
        switchCameraButton.layer.shadowOffset = CGSizeMake(0, 2.0)
        switchCameraButton.layer.shadowOpacity = 0.5
        switchCameraButton.layer.shadowRadius = 0.5
        switchCameraButton.layer.backgroundColor = UIColor.clearColor().CGColor
        
        // flastLightButton formatting
        flashLightButton.layer.shadowColor = UIColor.grayColor().CGColor
        flashLightButton.layer.shadowOffset = CGSizeMake(0, 2.0)
        flashLightButton.layer.shadowOpacity = 0.5
        flashLightButton.layer.shadowRadius = 0.5
        flashLightButton.layer.backgroundColor = UIColor.clearColor().CGColor
        flashLightButton.hidden = true
        
        closeButton.layer.shadowColor = UIColor.grayColor().CGColor
        closeButton.layer.shadowOffset = CGSizeMake(0.3, 2.0)
        closeButton.layer.shadowOpacity = 0.5
        closeButton.layer.shadowRadius = 0.5
        closeButton.layer.backgroundColor = UIColor.clearColor().CGColor
        
        questionLabel.layer.shadowColor = UIColor.grayColor().CGColor
        questionLabel.layer.shadowOffset = CGSizeMake(0.3, 2.0)
        questionLabel.layer.shadowOpacity = 0.5
        questionLabel.layer.shadowRadius = 0.5
        questionLabel.layer.backgroundColor = UIColor.clearColor().CGColor
        
        overlayView.layerGradient()
        
        self.questionLabel.text = self.content
        
        // Add devices to videoCapture variables
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if device.hasMediaType(AVMediaTypeAudio) {
                audioCapture = device as? AVCaptureDevice
            }
            else if (device.hasMediaType(AVMediaTypeVideo)) {
                if (device.position == AVCaptureDevicePosition.Back) {
                    backCameraVideoCapture = device as? AVCaptureDevice
                } else {
                    frontCameraVideoCapture = device as? AVCaptureDevice
                }
            }
        }
        beginSession()
        
        // doneButton hidden until a video is recorded
        self.doneButton.hidden = true
        self.uploadingLabel.hidden = true
    }
    
    // MARK: - functions
    func beginSession() {
        captureSession.beginConfiguration()
        try! captureSession.addInput(AVCaptureDeviceInput(device: audioCapture!))
        try! captureSession.addInput(AVCaptureDeviceInput(device: frontCameraVideoCapture!))
        
        output = AVCaptureMovieFileOutput()
        
        // Allow audio and movie to be longer than 10 seconds
        output!.movieFragmentInterval = kCMTimeInvalid
        
        // Set max duration of video recorded in seconds
        let maxDuration = CMTimeMakeWithSeconds(22, 30)
        output!.maxRecordedDuration = maxDuration
        
        // Add videoOutput to captureSession
        captureSession.addOutput(output)
        let connection = output!.connectionWithMediaType(AVMediaTypeVideo)
        connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        // sessionPreset affects video quality
        captureSession.sessionPreset = AVCaptureSessionPreset640x480
        
        print(output!.connectionWithMediaType(AVMediaTypeVideo).supportsVideoMirroring)
        if connection!.supportsVideoMirroring {
            connection.automaticallyAdjustsVideoMirroring = false
        }
        
        // formattting for preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        
        cameraView.layer.addSublayer(previewLayer!)
        cameraView.bringSubviewToFront(overlayView)
        cameraView.bringSubviewToFront(closeButton)
        cameraView.bringSubviewToFront(closeButton)
        cameraView.bringSubviewToFront(progressView)
        cameraView.bringSubviewToFront(flashLightButton)
        cameraView.bringSubviewToFront(switchCameraButton)
        cameraView.bringSubviewToFront(recordButton)
        cameraView.bringSubviewToFront(doneButton)
        cameraView.bringSubviewToFront(uploadingLabel)
        cameraView.bringSubviewToFront(questionLabel)
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    
    
    // MARK: - Animation
    func animateProgressView(duration: Double) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = progressView.bounds
        
        gradientLayer.locations = [0.0, 1.0]
        
        let colorTop: AnyObject = UIColor(red: 255.0/255.0, green: 213.0/255.0, blue: 63.0/255.0, alpha: 1.0).CGColor
        let colorBottom: AnyObject = UIColor(red: 255.0/255.0, green: 198.0/255.0, blue: 5.0/255.0, alpha: 1.0).CGColor
        let arrayOfColors: [AnyObject] = [colorTop, colorBottom]
        gradientLayer.colors = arrayOfColors
        
        let path: UIBezierPath = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(CGRectGetWidth(progressView.frame), 0))
        
        //Create a CAShape Layer
        let pathLayer: CAShapeLayer = CAShapeLayer()
        pathLayer.frame = self.view.bounds
        pathLayer.path = path.CGPath
        pathLayer.backgroundColor = UIColor.clearColor().CGColor
        pathLayer.strokeColor = UIColor.blackColor().CGColor
        pathLayer.fillColor = nil
        pathLayer.lineWidth = 12.0
        pathLayer.strokeStart = 0.0
        pathLayer.strokeEnd = 0.0
        
        gradientLayer.mask = pathLayer
        self.progressView.layer.addSublayer(gradientLayer)
        
        //Add the layer to your view's layer
        //        self.progressView.layer.addSublayer(pathLayer)
        
        //This is basic animation, quite a few other methods exist to handle animation see the reference site answers
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.delegate = self
        pathAnimation.fromValue = CGFloat(0.0)
        pathAnimation.toValue = CGFloat(1.0)
        pathAnimation.duration = duration
        pathAnimation.delegate = self
        pathAnimation.removedOnCompletion = false
        pathAnimation.additive = true
        pathAnimation.fillMode = kCAFillModeForwards
        //Animation will happen right away
        pathLayer.addAnimation(pathAnimation, forKey: "strokeEnd")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        // Removes progressBar
        self.progressView.layer.sublayers?.removeAll()
        // Stops the recording delegate
        output!.stopRecording()
        self.recordButton.hidden = true
        self.recordButton.setTitle("Delete", forState: .Normal)
        self.recordButton.setImage(nil, forState: .Normal)
        
    }

    
    // MARK: - IBAction
    @IBAction func closeButtonPressed(sender: UIButton) {
        if player == nil {
        } else {
            player.pause()
        }
        
//        player.pause()
        if fromAddTake {
            self.presentingViewController?.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    // Switch between front and back Camera
    @IBAction func switchCameraButtonPressed(sender: UIButton) {
        for var i = 0; i < captureSession.inputs.count; i++ {
            let input = captureSession.inputs[i] as! AVCaptureDeviceInput
            let device = input.device as AVCaptureDevice
            
            if device.hasMediaType(AVMediaTypeVideo) {
                captureSession.removeInput(input)
            }
        }
        
        if frontCamera {
            try! captureSession.addInput(AVCaptureDeviceInput(device: backCameraVideoCapture))
            flashLightButton.hidden = false
        } else  {
            try! captureSession.addInput(AVCaptureDeviceInput(device: frontCameraVideoCapture))
            flashLightButton.hidden = true
        }
        frontCamera = !frontCamera
    }
    
    // Turn flashlight on and off, only works for backCamera
    @IBAction func toggleFlashLight() {
        for var i = 0; i < captureSession.inputs.count; i++ {
            let input = captureSession.inputs[i] as! AVCaptureDeviceInput
            let device = input.device as AVCaptureDevice
            
            if device.hasMediaType(AVMediaTypeVideo) {
                if device.isTorchModeSupported(AVCaptureTorchMode.On) {
                    try! device.lockForConfiguration()
                    if device.hasTorch && !device.torchActive {
                        device.torchMode = AVCaptureTorchMode.On
                    } else {
                        device.torchMode = AVCaptureTorchMode.Off
                    }
                    device.unlockForConfiguration()
                }
                
            }
        }
    }
    
    @IBAction func recordVideo() {
        print(self.recordButton.titleLabel?.text)
        if self.recordButton.titleLabel?.text == "Delete" {
            print("Re-take")
            
            if player != nil {
                player.pause()
            }
            self.recordButton.hidden = false
            self.doneButton.hidden = true
            self.switchCameraButton.hidden = false
            
            // Remove previous video
            self.playerController.view.removeFromSuperview()
            self.playerController.removeFromParentViewController()
            
            // Update record button
            self.recordButton.titleLabel!.text = ""
            self.recordButton.setTitle("", forState: .Normal)
            self.recordButton.setImage(UIImage(named: "RecordButton"), forState: .Normal)
        } else if self.recordButton.imageView?.image == UIImage(named: "StopButton") {
            output!.stopRecording()
            print("Stop")
            self.progressView.layer.sublayers?.removeAll()
            self.recordButton.hidden = true
            self.recordButton.setTitle("Delete", forState: .Normal)
            self.recordButton.setImage(nil, forState: .Normal)
            
//            if recordingInProgress {
//                output!.stopRecording()
//                print("Stop")
//                self.progressView.layer.sublayers?.removeAll()
//                self.recordButton.hidden = true
//                self.recordButton.setTitle("Delete", forState: .Normal)
//                self.recordButton.setImage(nil, forState: .Normal)
//
//            } else {
//                print("Recording")
//                // Starts the progress bar
//                self.progressView.hidden = false
//                self.animateProgressView(20)
//                
//                // Change record button
//                self.recordButton.setTitle("", forState: .Normal)
//                self.recordButton.setImage(UIImage(named: "StopButton"), forState: .Normal)
//                
//                // Disallow camera switching while recording
//                self.switchCameraButton.hidden = true
//                
//                let formatter = NSDateFormatter()
//                formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
//                let date = NSDate()
//                let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
//                let outputPath = "\(documentPath)/\(formatter.stringFromDate(date)).mp4"
//                let outputURL = NSURL(fileURLWithPath: outputPath)
//                
//                output!.startRecordingToOutputFileURL(outputURL, recordingDelegate: self)
//            }
//            recordingInProgress = !recordingInProgress
            
        } else {
            print("Recording")
            // Starts the progress bar
            self.progressView.hidden = false
            self.animateProgressView(20)
            
            // Change record button
            self.recordButton.setTitle("", forState: .Normal)
            self.recordButton.setImage(UIImage(named: "StopButton"), forState: .Normal)
            
            // Disallow camera switching while recording
            self.switchCameraButton.hidden = true
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
            let date = NSDate()
            let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
            let outputPath = "\(documentPath)/\(formatter.stringFromDate(date)).mp4"
            let outputURL = NSURL(fileURLWithPath: outputPath)
            
            do {
                try outputURL.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
            } catch _{
                print("Failed")
            }
            
            output!.startRecordingToOutputFileURL(outputURL, recordingDelegate: self)
        }
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        
        if player != nil {
            player.pause()
        }
        self.uploadingLabel.hidden = false
        self.doneButton.hidden = true
        self.recordButton.hidden = true
        
        let amazonUrl = "https://s3-us-west-1.amazonaws.com/" + S3BucketName + "/"
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let testFileURL1 = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp"))
        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let date = NSDate()
        let key = "videos/\(self.id)/\(userid)/\(formatter.stringFromDate(date)).mp4"
        uploadRequest1.bucket = S3BucketName
        uploadRequest1.key =  key
        uploadRequest1.body = videoUrl
        
        let task = transferManager.upload(uploadRequest1)
        task.continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                print("Error: \(task.error)", terminator: "")
            } else {
                print("Upload successful", terminator: "")
                NSNotificationCenter.defaultCenter().postNotificationName("madeVideo", object: self)
            }
            return nil
        }
        
        
        let clip = AVURLAsset(URL: self.videoUrl!)
        let imgGenerator = AVAssetImageGenerator(asset: clip)
        let cgImage = try! imgGenerator.copyCGImageAtTime(CMTimeMake(0,1), actualTime: nil)
        let uiImage = UIImage(CGImage: cgImage)
        
        // Save video in S3 with the userID
        let transferManager2 = AWSS3TransferManager.defaultS3TransferManager()
        let testFileURL2 = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp"))
        let uploadRequest2 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        // Image is 0.5 resolution
        let data = UIImageJPEGRepresentation(uiImage, 0.5)
        data!.writeToURL(testFileURL2, atomically: true)
        let formatter2 = NSDateFormatter()
        formatter2.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let date2 = NSDate()
        
        let key2 = "thumbnails/\(self.id)/\(userid)/\(formatter2.stringFromDate(date2))"
        uploadRequest2.bucket = S3BucketName
        uploadRequest2.key =  key2
        uploadRequest2.body = testFileURL2
        
        let task2 = transferManager2.upload(uploadRequest2)
        task2.continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                print("Error: \(task.error)", terminator: "")
            } else {
                print("Upload successful", terminator: "")
            }
            return nil
        }

        var token = self.keychain.get("JWT")
        
        do {
            if token == nil {
                var refresh_token = self.keychain.get("refresh_token")
                
                if refresh_token == nil {
                    refresh_token = ""
                }
                let url = globalurl + "api/changetoken/"
                let parameters = [
                    "refresh_token": refresh_token! as String
                ]
                Alamofire.request(.POST, url, parameters: parameters)
                    .responseJSON { response in
                        var value = response.result.value
                        
                        if value == nil {
                            value = []
                        } else {
                            let json = JSON(value!)
                            print("JSON: \(json)")
                            print(json["token"].string)
                            let newtoken = json["token"].string
                            self.keychain.set(newtoken!, forKey: "JWT")
                            token = newtoken
                            
                            let headers = [
                                "Authorization": "\(token!)"
                            ]
                            let parameters = [
                                "question_id": self.id,
                                "creator": userid,
                                "creatorname": myUsername,
                                "video_url": amazonUrl + key,
                                "thumbnail_url": amazonUrl + key2,
                                "featuredQuestion": self.fromFeatured,
                                "vertical_screen": true
                            ]
                            let url = globalurl + "api/answers"
                            Alamofire.request(.POST, url, parameters: parameters as? [String:AnyObject], headers: headers)
                                .responseJSON { response in
                                    print(response.request)
                                    print(response.response)
                                    print(response.result)
                                    print(response.response?.statusCode)
                                    var value = response.result.value
                                    
                                    if value == nil {
                                        value = []
                                    }
                                    let json = JSON(value!)
                                    print("JSON: \(json)")
                                    print(json["_id"].string)
                                    let answerId = json["_id"].string
                                    
                                    Answers.logCustomEventWithName("Video Submitted",
                                        customAttributes: ["length": self.videoTime, "username": myUsername])
                                    
                                    self.answerId = answerId!
                                    self.performSegueWithIdentifier("segueToShareVideo", sender: self)
                                    
                            }
                        }
                        
                        
                }
            } else {
                let jwt = try decode(token!)
                if jwt.expired == true {
                    var refresh_token = self.keychain.get("refresh_token")
                    
                    if refresh_token == nil {
                        refresh_token = ""
                    }
                    let url = globalurl + "api/changetoken/"
                    let parameters = [
                        "refresh_token": refresh_token! as String
                    ]
                    Alamofire.request(.POST, url, parameters: parameters)
                        .responseJSON { response in
                            var value = response.result.value
                            
                            if value == nil {
                                value = []
                            } else {
                                let json = JSON(value!)
                                print("JSON: \(json)")
                                print(json["token"].string)
                                let newtoken = json["token"].string
                                self.keychain.set(newtoken!, forKey: "JWT")
                                token = newtoken
                                
                                let headers = [
                                    "Authorization": "\(token!)"
                                ]
                                let parameters = [
                                    "question_id": self.id,
                                    "creator": userid,
                                    "creatorname": myUsername,
                                    "video_url": amazonUrl + key,
                                    "thumbnail_url": amazonUrl + key2,
                                    "featuredQuestion": self.fromFeatured,
                                    "vertical_screen": true
                                ]
                                let url = globalurl + "api/answers"
                                Alamofire.request(.POST, url, parameters: parameters as? [String:AnyObject], headers: headers)
                                    .responseJSON { response in
                                        print(response.request)
                                        print(response.response)
                                        print(response.result)
                                        print(response.response?.statusCode)
                                        var value = response.result.value
                                        
                                        if value == nil {
                                            value = []
                                        }
                                        let json = JSON(value!)
                                        print("JSON: \(json)")
                                        print(json["_id"].string)
                                        let answerId = json["_id"].string
                                        
                                        Answers.logCustomEventWithName("Video Submitted",
                                            customAttributes: ["length": self.videoTime, "username": myUsername])
                                        
                                        
                                        self.answerId = answerId!
                                        self.performSegueWithIdentifier("segueToShareVideo", sender: self)
                                        
                                }
                            }
                            
                            
                    }
                } else {
                    let headers = [
                        "Authorization": "\(token!)"
                    ]
                    
                    let parameters = [
                        "question_id": self.id,
                        "creator": userid,
                        "creatorname": myUsername,
                        "video_url": amazonUrl + key,
                        "thumbnail_url": amazonUrl + key2,
                        "featuredQuestion": self.fromFeatured,
                        "vertical_screen": true
                    ]
                    let url = globalurl + "api/answers"
                    Alamofire.request(.POST, url, parameters: parameters as? [String:AnyObject], headers: headers)
                        .responseJSON { response in
                            print(response.request)
                            print(response.response)
                            print(response.result)
                            print(response.response?.statusCode)
                            var value = response.result.value
                            
                            if value == nil {
                                value = []
                            }
                            let json = JSON(value!)
                            print("JSON: \(json)")
                            print(json["_id"].string)
                            let answerId = json["_id"].string
                            
                            Answers.logCustomEventWithName("Video Submitted",
                                customAttributes: ["length": self.videoTime, "username": myUsername])
                            
                            self.answerId = answerId!
                            self.performSegueWithIdentifier("segueToShareVideo", sender: self)
                    }
                }
            }
            
        } catch {
            print("Failed to decode JWT: \(error)")
        }
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToShareVideo" {
            NSNotificationCenter.defaultCenter().postNotificationName("postedVideo", object: self)
            let shareVideoVC: ShareVideoViewController = segue.destinationViewController as! ShareVideoViewController
            shareVideoVC.answerId = self.answerId
            shareVideoVC.questionContent = self.content
            shareVideoVC.fromAddTake = self.fromAddTake
        }
    }
    
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print("Ended")
        cropVideo(outputFileURL)
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("Started")
    }
    
    // MARK: Edit Video
    func cropVideo(outputFileURL: NSURL) {
        
        let videoAsset: AVAsset = AVAsset(URL: outputFileURL) as AVAsset
        
        // Code used for videoComposition
        let clipVideoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo).first! as AVAssetTrack
        
        let composition = AVMutableComposition()
        composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        
        let videoComposition = AVMutableVideoComposition()
        
        
        videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.width)
//        videoComposition.renderSize = CGSizeMake((previewLayer?.frame.width)!, (previewLayer?.frame.height)!)
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(22, 30))
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        
        
        let transform1:CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, 0)
        let transform2 = CGAffineTransformRotate(transform1, CGFloat(M_PI_2))
        if frontCamera {
            let transform4:CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, 0)
            let transform3 = CGAffineTransformScale(transform4, -1, 1)
            let finalTransform = CGAffineTransformConcat(transform2, transform3)
            transformer.setTransform(finalTransform, atTime: kCMTimeZero)
        } else {
            let finalTransform = transform2
            transformer.setTransform(finalTransform, atTime: kCMTimeZero)
        }
        
        
        
//        videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height)
//        videoComposition.frameDuration = CMTimeMake(1, 30)
//
//        let instruction = AVMutableVideoCompositionInstruction()
//        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(22, 30))
//
//        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
//        let transform1:CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height)/2)
//        let transform2 = CGAffineTransformRotate(transform1, CGFloat(M_PI_2))
//        
//        
//        if frontCamera {
//            let transform4:CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, 0)
//            let transform3 = CGAffineTransformScale(transform4, -1, 1)
//            let finalTransform = CGAffineTransformConcat(transform2, transform3)
//            transformer.setTransform(finalTransform, atTime: kCMTimeZero)
//        } else {
//            let finalTransform = transform2
//            transformer.setTransform(finalTransform, atTime: kCMTimeZero)
//        }
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let date = NSDate()
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let outputPath = "\(documentPath)/\(formatter.stringFromDate(date))\(userid).mp4"
        let outputURL = NSURL(fileURLWithPath: outputPath)
        
        do {
            try outputURL.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
        } catch _{
            print("Failed")
        }
        
        // Exporting with Medium Quality
        let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetMediumQuality)!
//        let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)!
        // videoCompositon uses the instructions from transformer
        exporter.videoComposition = videoComposition
        exporter.outputURL = outputURL
        exporter.outputFileType = AVFileTypeMPEG4
        
        exporter.exportAsynchronouslyWithCompletionHandler({ () -> Void in
            dispatch_async(dispatch_get_main_queue(), {
//                self.flipVideo(exporter.outputURL!)
                self.handleExportCompletion(exporter)
            })
        })
    }
    
    func handleExportCompletion(session: AVAssetExportSession) {
//        let library = ALAssetsLibrary()
//        if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(session.outputURL) {
//            var completionBlock: ALAssetsLibraryWriteVideoCompletionBlock
//            
//            completionBlock = { assetUrl, error in
//                if error != nil {
//                    print("error writing to disk")
//                } else {
//                    
//                }
//            }
            // Uncomment to save Video to own Phone
//            library.writeVideoAtPathToSavedPhotosAlbum(session.outputURL, completionBlock: completionBlock)
//        }
        
        // Set up video in playerController
        videoUrl = session.outputURL
//        getThumbnail(videoUrl!)
        player = AVPlayer(URL: session.outputURL!)
        playerController = AVPlayerViewController()
        playerController.player = player
        playerController.view.frame = CGRectMake(self.previewLayer!.frame.origin.x, self.previewLayer!.frame.origin.x, self.previewLayer!.frame.size.width, self.previewLayer!.frame.size.height)
        playerController.showsPlaybackControls = false
        playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerController.view.hidden = false
        self.addChildViewController(playerController)
        self.cameraView.addSubview(playerController.view)
        playerController.didMoveToParentViewController(self)
//        player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
        player.play()
        print(self.player.currentItem?.asset.duration)
        let time = CMTimeGetSeconds((self.player.currentItem?.asset.duration)!)
        print(time)
        let intTime = Int(round(time))
        print(intTime)
        self.videoTime = intTime
        cameraView.bringSubviewToFront(overlayView)
        cameraView.bringSubviewToFront(closeButton)
        cameraView.bringSubviewToFront(progressView)
        cameraView.bringSubviewToFront(recordButton)
        cameraView.bringSubviewToFront(doneButton)
        cameraView.bringSubviewToFront(uploadingLabel)
        cameraView.bringSubviewToFront(questionLabel)
        self.recordButton.hidden = false
        self.doneButton.hidden = false
    }
    
//    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//        if keyPath == "status" {
//            if (self.player.status == AVPlayerStatus.ReadyToPlay) {
//                print("reached")
//            }
//            
//        }
//    }
    
    
    func getThumbnail(outputFileURL: NSURL) {
        let clip = AVURLAsset(URL: outputFileURL)
        let imgGenerator = AVAssetImageGenerator(asset: clip)
        let cgImage = try! imgGenerator.copyCGImageAtTime(CMTimeMake(0,1), actualTime: nil)
        var uiImage = UIImage(CGImage: cgImage)
//        uiImage.imageRotatedByDegrees(180, flip: false)
//        thumbnailImageView.contentMode = UIViewContentMode.ScaleAspectFill
        thumbnailImageView.image = uiImage
//        thumbnailImageView.transform = CGAffineTransformMakeRotation((90 * CGFloat(M_PI)) / 180)
//        thumbnailImageView.transform = CGAffineTransformMakeScale(-1, 1)
        
    }
    
     //Used to flip video horizontally if using the Front Facing Camera
//        func flipVideo(outputFileURL: NSURL) {
//            let videoAsset: AVAsset = AVAsset(URL: outputFileURL) as AVAsset
//    
//            let clipVideoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo).first! as AVAssetTrack
//    
//            let composition = AVMutableComposition()
//            composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
//    
//            let videoComposition = AVMutableVideoComposition()
//    
//            videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height)
//            videoComposition.frameDuration = CMTimeMake(1, 30)
//    
//            let instruction = AVMutableVideoCompositionInstruction()
//            instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(20, 30))
//    
//            let transformer2 = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
//            let transform1:CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height)/2)
//            let transform3 = CGAffineTransformScale(transform1, -1, 1)
//    
//            let finalTransform2 = transform3
//            transformer2.setTransform(finalTransform2, atTime: kCMTimeZero)
//    
//            instruction.layerInstructions = [transformer2]
//            videoComposition.instructions = [instruction]
//    
//    
//            let formatter = NSDateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
//            let date = NSDate()
//            let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
//            let outputPath = "\(documentPath)/\(formatter.stringFromDate(date))\(userid)f.mp4"
//            let outputURL = NSURL(fileURLWithPath: outputPath)
//    
//            let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetMediumQuality)!
//            exporter.videoComposition = videoComposition
//            exporter.outputURL = outputURL
//            exporter.outputFileType = AVFileTypeMPEG4
//    
//            exporter.exportAsynchronouslyWithCompletionHandler({ () -> Void in
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.handleExportCompletion(exporter)
//                })
//            })
//        }

}

extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
        let t = CGAffineTransformMakeRotation(degreesToRadians(degrees))
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        CGContextScaleCTM(bitmap, yFlip, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
