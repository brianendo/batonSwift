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

class TakeVideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    let keychain = KeychainSwift()
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet var switchCameraButton: UIButton!
    @IBOutlet var flashLightButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    
    var captureSession = AVCaptureSession()
    var audioCapture: AVCaptureDevice?
    var backCameraVideoCapture: AVCaptureDevice?
    var frontCameraVideoCapture: AVCaptureDevice?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var output: AVCaptureMovieFileOutput?
    var videoClips:[NSURL] = []
    var moviePlayer:MPMoviePlayerController!
    var player:AVPlayer!
    var playerController: AVPlayerViewController!
    
    var frontCamera: Bool = true
    var recordingInProgress: Bool = false
    
    var content = ""
    var id = ""
    var videoUrl: NSURL?
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touchPoint = touches.first! as UITouch
        var screenSize = cameraView.bounds.size
        var focusPoint = CGPoint(x: touchPoint.locationInView(cameraView).y / screenSize.height, y: 1.0 - touchPoint.locationInView(cameraView).x / screenSize.width)
        
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
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "restartVideoFromBeginning",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: player)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func beginSession() {
        captureSession.beginConfiguration()
        try! captureSession.addInput(AVCaptureDeviceInput(device: audioCapture!))
        try! captureSession.addInput(AVCaptureDeviceInput(device: frontCameraVideoCapture!))
        
        output = AVCaptureMovieFileOutput()
        // Allow audio and movie to be longer than 10 seconds
        output!.movieFragmentInterval = kCMTimeInvalid
        
        let maxDuration = CMTimeMakeWithSeconds(20, 30)
        output!.maxRecordedDuration = maxDuration
        captureSession.addOutput(output)
        let connection = output!.connectionWithMediaType(AVMediaTypeVideo)
        connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        captureSession.sessionPreset = AVCaptureSessionPreset640x480
        if connection!.supportsVideoMirroring {
            connection.automaticallyAdjustsVideoMirroring = false
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
//        self.cameraView.clipsToBounds = true
//        previewLayer?.frame = self.view.bounds
        cameraView.layer.addSublayer(previewLayer!)
        cameraView.bringSubviewToFront(flashLightButton)
        cameraView.bringSubviewToFront(switchCameraButton)
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if previewLayer?.frame != nil {
            previewLayer!.frame = cameraView.bounds
        } else {
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flashLightButton.hidden = true
        
        switchCameraButton.layer.shadowColor = UIColor.grayColor().CGColor
        switchCameraButton.layer.shadowOffset = CGSizeMake(0, 2.0)
        switchCameraButton.layer.shadowOpacity = 0.5
        switchCameraButton.layer.shadowRadius = 0.5
        switchCameraButton.layer.backgroundColor = UIColor.clearColor().CGColor

        flashLightButton.layer.shadowColor = UIColor.grayColor().CGColor
        flashLightButton.layer.shadowOffset = CGSizeMake(0, 2.0)
        flashLightButton.layer.shadowOpacity = 0.5
        flashLightButton.layer.shadowRadius = 0.5
        flashLightButton.layer.backgroundColor = UIColor.clearColor().CGColor
        
        self.questionTextView.text = self.content
        self.questionTextView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        self.questionTextView.textColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
        //        captureSession.sessionPreset = AVCaptureSessionPresetHigh
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

        self.doneButton.hidden = true
    }
    
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
        pathLayer.lineWidth = 8.0
        pathLayer.strokeStart = 0.0
        pathLayer.strokeEnd = 0.0
        
        gradientLayer.mask = pathLayer
        self.progressView.layer.addSublayer(gradientLayer)
        
        //Add the layer to your view's layer
        //        self.progressView.layer.addSublayer(pathLayer)
        
        //This is basic animation, quite a few other methods exist to handle animation see the reference site answers
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
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
    
    func hideProgressView() {
        progressView.layer.removeAllAnimations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        if player == nil {
            
        } else {
            player.pause()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
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
        if self.recordButton.titleLabel?.text == "Re-take" {
            print("Reach")
            self.player.pause()
            self.doneButton.hidden = true
            self.switchCameraButton.hidden = false
            self.playerController.view.removeFromSuperview()
            self.playerController.removeFromParentViewController()
            self.recordButton.titleLabel!.text = ""
            self.recordButton.setTitle("", forState: .Normal)
            self.recordButton.setImage(UIImage(named: "RecordButton"), forState: .Normal)
        } else {
            if recordingInProgress {
                output!.stopRecording()
                print("Stop")
                self.hideProgressView()
                self.progressView.hidden = true
                self.recordButton.setTitle("Re-take", forState: .Normal)
                self.recordButton.setImage(nil, forState: .Normal)
            } else {
                print("Recording")
                self.animateProgressView(20)
                self.recordButton.setTitle("", forState: .Normal)
                self.recordButton.setImage(UIImage(named: "StopButton"), forState: .Normal)
                self.switchCameraButton.hidden = true
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
                let date = NSDate()
                let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
                let outputPath = "\(documentPath)/\(formatter.stringFromDate(date)).mp4"
                let outputURL = NSURL(fileURLWithPath: outputPath)
                
                output!.startRecordingToOutputFileURL(outputURL, recordingDelegate: self)
            }
            recordingInProgress = !recordingInProgress
        }
    }
    
    @IBAction func doneButtonPressed(sender: UIButton) {
        
//        getThumbnail(videoUrl!)
        
        // Save video in S3 with the userID
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let testFileURL1 = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp"))
        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let date = NSDate()
        let key = "\(self.id)/\(userid)/\(formatter.stringFromDate(date)).mp4"
        
        uploadRequest1.bucket = S3BucketName
        uploadRequest1.key =  key
        uploadRequest1.body = videoUrl
        
        let task = transferManager.upload(uploadRequest1)
        task.continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                print("Error: \(task.error)", terminator: "")
            } else {
                print("Upload successful", terminator: "")
                
                let clip = AVURLAsset(URL: self.videoUrl!)
                let imgGenerator = AVAssetImageGenerator(asset: clip)
                let cgImage = try! imgGenerator.copyCGImageAtTime(CMTimeMake(0,1), actualTime: nil)
                var uiImage = UIImage(CGImage: cgImage)
                
//                var flip = true
//                
//                if self.frontCamera {
//                    flip = true
//                } else {
//                    flip = false
//                }
//                
//                uiImage = uiImage.imageRotatedByDegrees(0, flip: flip)
                
                // Save video in S3 with the userID
                let transferManager2 = AWSS3TransferManager.defaultS3TransferManager()
                let testFileURL2 = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp"))
                let uploadRequest2 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
                
                let data = UIImageJPEGRepresentation(uiImage, 0.5)
                data!.writeToURL(testFileURL2, atomically: true)
                
                let formatter2 = NSDateFormatter()
                formatter2.dateFormat = "yyyy-MM-dd-HH-mm-ss"
                let date2 = NSDate()
                let key2 = "\(self.id)/\(userid)/\(formatter2.stringFromDate(date2))"
                
                uploadRequest2.bucket = S3BucketName
                uploadRequest2.key =  key2
                uploadRequest2.body = testFileURL2
                
                let task2 = transferManager2.upload(uploadRequest2)
                task2.continueWithBlock { (task) -> AnyObject! in
                    if task.error != nil {
                        print("Error: \(task.error)", terminator: "")
                    } else {
                        print("Upload successful", terminator: "")
                        
                        
                        let amazonUrl = "https://s3-us-west-1.amazonaws.com/batonapp/"
                        
                        
//                        let url = globalurl + "api/answers"
//                        Alamofire.request(.POST, url, parameters: parameters as? [String: String], encoding: .JSON)
                        
                        var token = self.keychain.get("JWT")
                        print(token)
                        
                        do {
                            
                            let jwt = try decode(token!)
                            print(jwt)
                            print(jwt.body)
                            print(jwt.expiresAt)
                            print(jwt.expired)
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
                                                "thumbnail_url": amazonUrl + key2
                                            ]
                                            
                                            let url = globalurl + "api/answers"
                                            Alamofire.request(.POST, url, parameters: parameters, headers: headers)
                                                .responseJSON { response in
                                                    print(response.request)
                                                    print(response.response)
                                                    print(response.result)
                                                    print(response.response?.statusCode)
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
                                    "thumbnail_url": amazonUrl + key2
                                ]
                                
                                let url = globalurl + "api/answers"
                                Alamofire.request(.POST, url, parameters: parameters, headers: headers)
                                    .responseJSON { response in
                                        print(response.request)
                                        print(response.response)
                                        print(response.result)
                                        print(response.response?.statusCode)
                                }
                            }
                        } catch {
                            print("Failed to decode JWT: \(error)")
                        }

                    }
                    return nil
                }
                
            }
            return nil
        }
        if player.rate > 0 {
            player.pause()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: AVCaptureFileOutputRecordingDelegate
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print("Ended")
        videoClips.append(outputFileURL)
        cropVideo(outputFileURL)
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("Started")
        
    }
    
    func cropVideo(outputFileURL: NSURL) {
        
        let videoAsset: AVAsset = AVAsset(URL: outputFileURL) as AVAsset
        
        let clipVideoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo).first! as AVAssetTrack
        
        let composition = AVMutableComposition()
        composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        
        let videoComposition = AVMutableVideoComposition()
        
        videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height)
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(20, 30))
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let transform1:CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height)/2)
        let transform2 = CGAffineTransformRotate(transform1, CGFloat(M_PI_2))
        
        let finalTransform = transform2
        transformer.setTransform(finalTransform, atTime: kCMTimeZero)
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let date = NSDate()
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let outputPath = "\(documentPath)/\(formatter.stringFromDate(date))\(userid).mp4"
        let outputURL = NSURL(fileURLWithPath: outputPath)
        
        let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetMediumQuality)!
        exporter.videoComposition = videoComposition
        exporter.outputURL = outputURL
        exporter.outputFileType = AVFileTypeMPEG4
        
        exporter.exportAsynchronouslyWithCompletionHandler({ () -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if self.frontCamera {
                    self.flipVideo(exporter.outputURL!)
                } else {
                    self.handleExportCompletion(exporter)
                }
            })
        })
    }
    
    // Used to flip video horizontally if using the Front Facing Camera
    func flipVideo(outputFileURL: NSURL) {
        let videoAsset: AVAsset = AVAsset(URL: outputFileURL) as AVAsset
        
        let clipVideoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo).first! as AVAssetTrack
        
        let composition = AVMutableComposition()
        composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        
        let videoComposition = AVMutableVideoComposition()
        
        videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height)
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(20, 30))
        
        let transformer2 = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let transform1:CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height)/2)
        let transform3 = CGAffineTransformScale(transform1, -1, 1)
        
        let finalTransform2 = transform3
        transformer2.setTransform(finalTransform2, atTime: kCMTimeZero)
        
        instruction.layerInstructions = [transformer2]
        videoComposition.instructions = [instruction]
        
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let date = NSDate()
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let outputPath = "\(documentPath)/\(formatter.stringFromDate(date))\(userid)f.mp4"
        let outputURL = NSURL(fileURLWithPath: outputPath)
        
        let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetMediumQuality)!
        exporter.videoComposition = videoComposition
        exporter.outputURL = outputURL
        exporter.outputFileType = AVFileTypeMPEG4
        
        exporter.exportAsynchronouslyWithCompletionHandler({ () -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.handleExportCompletion(exporter)
            })
        })
    }
    
    func handleExportCompletion(session: AVAssetExportSession) {
        let library = ALAssetsLibrary()
        if library.videoAtPathIsCompatibleWithSavedPhotosAlbum(session.outputURL) {
            var completionBlock: ALAssetsLibraryWriteVideoCompletionBlock
            
            completionBlock = { assetUrl, error in
                if error != nil {
                    print("error writing to disk")
                } else {
                    
                }
            }
            
//            library.writeVideoAtPathToSavedPhotosAlbum(session.outputURL, completionBlock: completionBlock)
        }
        videoUrl = session.outputURL
        player = AVPlayer(URL: session.outputURL!)
        playerController = AVPlayerViewController()
        playerController.player = player
        
        playerController.view.frame = CGRectMake(self.previewLayer!.frame.origin.x, self.previewLayer!.frame.origin.x, self.previewLayer!.frame.size.width, self.previewLayer!.frame.size.height)
        
        // Mirrors video
//        if frontCamera {
//            playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
//        }
        
        playerController.showsPlaybackControls = false
        playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerController.view.hidden = false
        self.addChildViewController(playerController)
        self.cameraView.addSubview(playerController.view)
        playerController.didMoveToParentViewController(self)
        
        print(CMTimeGetSeconds((player.currentItem?.asset.duration)!))
        let time = CMTimeGetSeconds((player.currentItem?.asset.duration)!)
        
        player.play()

        self.doneButton.hidden = false
    }
    
    func restartVideoFromBeginning()  {
        print("Reached")
        //create a CMTime for zero seconds so we can go back to the beginning
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        
        player.seekToTime(seekTime)
        
//        let time = CMTimeGetSeconds((player.currentItem?.asset.duration)!)
//        self.animateProgressView(time)
        
        player.play()
        
    }
    
    func getThumbnail(outputFileURL: NSURL) {
//        let clip = AVURLAsset(URL: outputFileURL)
//        let imgGenerator = AVAssetImageGenerator(asset: clip)
//        let cgImage = try! imgGenerator.copyCGImageAtTime(CMTimeMake(0,1), actualTime: nil)
//        let uiImage = UIImage(CGImage: cgImage)
//        
//        let xPos = CGFloat((videoClips.count - 1) * 100)
//        let imageView = UIImageView(frame: CGRect(x: xPos, y: 0, width: 100, height: 100))
//        imageView.image = uiImage
//        clipsScrollView.addSubview(imageView)
//        
        let clip = AVURLAsset(URL: outputFileURL)
        let imgGenerator = AVAssetImageGenerator(asset: clip)
        let cgImage = try! imgGenerator.copyCGImageAtTime(CMTimeMake(0,1), actualTime: nil)
        var uiImage = UIImage(CGImage: cgImage)
        
        var flip = false
        if frontCamera {
            flip = true
        } else {
            flip = false
        }
        
        uiImage = uiImage.imageRotatedByDegrees(0, flip: flip)
        thumbnailImageView.image = uiImage
        
        
        // Save video in S3 with the userID
//        let transferManager2 = AWSS3TransferManager.defaultS3TransferManager()
//        let testFileURL2 = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp"))
//        let uploadRequest2 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
//        
//        let data = UIImageJPEGRepresentation(uiImage, 0.01)
//        data!.writeToURL(testFileURL2, atomically: true)
//        
//        let formatter2 = NSDateFormatter()
//        formatter2.dateFormat = "yyyy-MM-dd-HH-mm-ss"
//        let date2 = NSDate()
//        let key2 = "\(self.id)/\(formatter2.stringFromDate(date2))"
//        
//        uploadRequest2.bucket = S3BucketName
//        uploadRequest2.key =  key2
//        uploadRequest2.body = testFileURL2
//        
//        let task2 = transferManager2.upload(uploadRequest2)
//        task2.continueWithBlock { (task) -> AnyObject! in
//            if task.error != nil {
//                print("Error: \(task.error)", terminator: "")
//            } else {
//                print("Upload successful", terminator: "")
//            }
//            return nil
//        }
        
//        let xPos = CGFloat((videoClips.count - 1) * 100 + 5)
//        let imageView = UIImageView(frame: CGRect(x: xPos, y: 0, width: 100, height: 100))
//        imageView.contentMode = UIViewContentMode.ScaleAspectFill
//        imageView.image = uiImage.imageRotatedByDegrees(90, flip: false)
//        if frontCamera {
//            imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0)
//        }
//        clipsScrollView.addSubview(imageView)
    }

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
