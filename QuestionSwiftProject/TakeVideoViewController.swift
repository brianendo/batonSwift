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

class TakeVideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet var switchCameraButton: UIButton!
    @IBOutlet var flashLightButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet weak var clipsScrollView: UIScrollView!
    
    
    var captureSession = AVCaptureSession()
    var audioCapture: AVCaptureDevice?
    var backCameraVideoCapture: AVCaptureDevice?
    var frontCameraVideoCapture: AVCaptureDevice?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var output: AVCaptureMovieFileOutput?
    var videoClips:[NSURL] = []
    var moviePlayer:MPMoviePlayerController!
    var player: AVPlayer!
    var playerController: AVPlayerViewController!
    
    var frontCamera: Bool = true
    var recordingInProgress: Bool = false
    
    var content = ""
    var id = ""
    var videoUrl: NSURL?
    
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
        try! captureSession.addInput(AVCaptureDeviceInput(device: audioCapture!))
        try! captureSession.addInput(AVCaptureDeviceInput(device: frontCameraVideoCapture!))
        
        output = AVCaptureMovieFileOutput()
        let maxDuration = CMTimeMakeWithSeconds(40, 30)
        output!.maxRecordedDuration = maxDuration
        captureSession.addOutput(output)
        let connection = output!.connectionWithMediaType(AVMediaTypeVideo)
        connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        captureSession.sessionPreset = AVCaptureSessionPreset640x480
//        if connection!.supportsVideoMirroring {
//            connection.automaticallyAdjustsVideoMirroring = false
//            connection!.videoMirrored = true
//        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
//        self.cameraView.clipsToBounds = true
//        previewLayer?.frame = self.view.bounds
        cameraView.layer.addSublayer(previewLayer!)
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
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
        } else  {
            try! captureSession.addInput(AVCaptureDeviceInput(device: frontCameraVideoCapture))
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
        if self.recordButton.titleLabel?.text == "Re-take" {
            self.player.pause()
            self.playerController.view.removeFromSuperview()
            self.playerController.removeFromParentViewController()
            self.recordButton.setTitle("Record", forState: .Normal)
        } else {
            if recordingInProgress {
                output!.stopRecording()
                print("Stop")
                self.recordButton.setTitle("Re-take", forState: .Normal)
            } else {
                print("Recording")
                self.recordButton.setTitle("Stop", forState: .Normal)
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
        
        // Save video in S3 with the userID
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let testFileURL1 = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp"))
        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let date = NSDate()
        let key = "\(self.id)/\(formatter.stringFromDate(date)).mp4"
        
        uploadRequest1.bucket = S3BucketName
        uploadRequest1.key =  key
        uploadRequest1.body = videoUrl
        
        let task = transferManager.upload(uploadRequest1)
        task.continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                print("Error: \(task.error)", terminator: "")
            } else {
                print("Upload successful", terminator: "")
                let url = globalurl + "api/answers"
                
                let amazonUrl = "https://s3-us-west-1.amazonaws.com/batonapp/"
                
                let parameters = [
                    "question_id": self.id,
                    "creator": userid,
                    "creatorname": name,
                    "video_url": amazonUrl + key,
                    "frontCamera": self.frontCamera
                ]
                Alamofire.request(.POST, url, parameters: parameters as? [String: AnyObject], encoding: .JSON)
                
            }
            return nil
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: AVCaptureFileOutputRecordingDelegate
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print("Ended")
        videoClips.append(outputFileURL)
        cropVideo(outputFileURL)
        getThumbnail(outputFileURL)
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
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(40, 30))
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        var transform1:CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height)/2)
        //        transform1 = CGAffineTransformMakeScale(-1.0, 1.0)
        let transform2 = CGAffineTransformRotate(transform1, CGFloat(M_PI_2))
        let finalTransform = transform2
        transformer.setTransform(finalTransform, atTime: kCMTimeZero)
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let date = NSDate()
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let outputPath = "\(documentPath)/\(formatter.stringFromDate(date)).mp4"
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
        if frontCamera {
            playerController.view.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        }
        
        playerController.showsPlaybackControls = false
        playerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerController.view.hidden = false
        self.addChildViewController(playerController)
        self.cameraView.addSubview(playerController.view)
        playerController.didMoveToParentViewController(self)
        player.play()

        self.doneButton.hidden = false
    }
    
    func restartVideoFromBeginning()  {
        
        //create a CMTime for zero seconds so we can go back to the beginning
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        
        player.seekToTime(seekTime)
        
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
        let uiImage = UIImage(CGImage: cgImage)
        let xPos = CGFloat((videoClips.count - 1) * 100 + 5)
        let imageView = UIImageView(frame: CGRect(x: xPos, y: 0, width: 100, height: 100))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.image = uiImage.imageRotatedByDegrees(90, flip: false)
        if frontCamera {
            imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        }
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
