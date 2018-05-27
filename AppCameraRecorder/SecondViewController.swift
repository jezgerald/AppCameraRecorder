//
//  SecondViewController.swift
//  AppCameraRecorder
//
//  Created by Jessica Fitzgerald on 12/5/18.
//  Copyright © 2018 Jessica Fitzgerald. All rights reserved.
//

import AVFoundation
import UIKit
import AVKit
import Photos // to take photos
import MobileCoreServices // to access camera
import CoreImage // to create filters
import CoreMedia // to create & apply video filters

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // image viewer to show preview of video after taken
    @IBOutlet weak var videoPicked: UIImageView!
    
    // variables
    var captureSession : AVCaptureSession!
    var videoURL: URL?
    let playerController = AVPlayerViewController()
    var playerLayer = AVPlayerLayer()
    var assetWriter:AVAssetWriter?
    var outputURL: URL?
    
    // array of filters
    var CIFilters = [
        "CISepiaTone",
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CIPhotoEffectMono",
        "CIGaussianBlur"
    ]
    
    
    // button to record video
    @IBAction func recordButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let mediaUI = UIImagePickerController()
            mediaUI.delegate = self
            mediaUI.sourceType = UIImagePickerControllerSourceType.camera
            mediaUI.mediaTypes = [kUTTypeMovie as String]
            mediaUI.allowsEditing = true
            mediaUI.showsCameraControls = true
            self.present(mediaUI, animated: true, completion: nil)
        }
    }
    
    // access photo library
    @IBAction func photoLibrary(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let mediaUI = UIImagePickerController()
            mediaUI.delegate = self
            mediaUI.sourceType = UIImagePickerControllerSourceType.photoLibrary
            mediaUI.mediaTypes = [kUTTypeMovie as String]
            mediaUI.allowsEditing = true
            self.present(mediaUI, animated: true, completion: nil)
        }
    }
    
    
    // finish recording and close the video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        // video URL
        videoURL = info[UIImagePickerControllerMediaURL] as! URL?
        
        // export video as movie type, update URL, and ensure compatibility with user's Photo Library
        guard
            let mediaType = info[UIImagePickerControllerMediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            UIVideoAtPathIsCompatibleWithSavedPhotosAlbum((videoURL?.path)!)
            else { return }
        
        // dismisses view controller
        picker.presentingViewController?.dismiss(animated: true)
        
        // alert to say video has recorded & how to view
        let alert = UIAlertController(title: "Video recorded", message: "If you like the video, save or share! \nIf not, re-shoot!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
        // play video in sublayer
        let player = AVPlayer(url: videoURL!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoPicked.frame
        self.view.layer.addSublayer(playerLayer)
        player.play()
    }
    
    
    // save video to library
    @IBAction func saveButton(_ sender: UIButton) {
        // saves video to Photo Library - includes alert message
        UISaveVideoAtPathToSavedPhotosAlbum((videoURL?.path)!, self, #selector(self.video(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    
    // video function - required to save video
    // provides alert to success or failure of saving video
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    // alert to inform user that their video has saved to their photo library
    func saveNotice() {
        let alertController = UIAlertController(title: "Video saved!", message: "Your video was successfully saved", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }

    
    // error message to prompt the user to choose or take a video
    func errorNotice() {
        
        let alertController = UIAlertController(title: "No video selected", message: "Choose or take a video", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    // filter options to apply to video
    @IBAction func filterButton(_ sender: UIButton) {
        let filter = CIFilter(name: "CIPhotoEffectNoir")!
        
        // alert user if there's no video
        if videoURL == nil { errorNotice()
            return }
        
        let asset = AVAsset(url: videoURL!)
        
        let composition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
            let source = request.sourceImage
            filter.setValue(source, forKey: kCIInputImageKey)
            let output = filter.outputImage
            request.finish(with: output!, context: nil)
        })
        
        let item = AVPlayerItem(asset: asset)
        item.videoComposition = composition
        let player = AVPlayer(playerItem: item)
        let newLayer = AVPlayerLayer(player: player)
        newLayer.frame = videoPicked.frame
        self.view.layer.addSublayer(newLayer)
        player.play()
    
        print("FilteredURL: ", videoURL!)
        
        outputURL = videoURL
        assetWriter = try? AVAssetWriter(outputURL: outputURL!, fileType: AVFileType.mp4)
        assetWriter?.startWriting()
        assetWriter?.finishWriting {
            print("outputURL: ", self.outputURL!)
            self.videoURL = self.outputURL
        }
        
        videoURL = (player.currentItem?.asset as? AVURLAsset?)!?.url
        print("NewFilterURL: ", videoURL!)
        
    }
    
    
    @IBAction func filter(_ sender: UIButton) {
        let filter = CIFilter(name: "CISepiaTone")!
        
        // alert user if there's no video
        if videoURL == nil { errorNotice()
            return }
        
        let asset = AVAsset(url: videoURL!)
        
        let composition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
            let source = request.sourceImage
            filter.setValue(source, forKey: kCIInputImageKey)
            let output = filter.outputImage
            request.finish(with: output!, context: nil)
        })
        
        let item = AVPlayerItem(asset: asset)
        item.videoComposition = composition
        let player = AVPlayer(playerItem: item)
        let newLayer = AVPlayerLayer(player: player)
        newLayer.frame = videoPicked.frame
        self.view.layer.addSublayer(newLayer)
        player.play()
        
        print("FilteredURL: ", videoURL!)
        
        outputURL = videoURL
        assetWriter = try? AVAssetWriter(outputURL: outputURL!, fileType: AVFileType.mp4)
        assetWriter?.startWriting()
        assetWriter?.finishWriting {
            print("outputURL: ", self.outputURL!)
            self.videoURL = self.outputURL
        }
        
        videoURL = (player.currentItem?.asset as? AVURLAsset?)!?.url
        print("NewFilterURL: ", videoURL!)
    }
    
    
    @IBAction func filterFade(_ sender: UIButton) {
        
        let filter = CIFilter(name: "CIPhotoEffectProcess")!
        
        // alert user if there's no video
        if videoURL == nil { errorNotice()
            return }
        
        let asset = AVAsset(url: videoURL!)
        
        let composition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
            let source = request.sourceImage
            filter.setValue(source, forKey: kCIInputImageKey)
            let output = filter.outputImage
            request.finish(with: output!, context: nil)
        })
        
        let item = AVPlayerItem(asset: asset)
        item.videoComposition = composition
        let player = AVPlayer(playerItem: item)
        let newLayer = AVPlayerLayer(player: player)
        newLayer.frame = videoPicked.frame
        self.view.layer.addSublayer(newLayer)
        player.play()
        
        print("FilteredURL: ", videoURL!)
        
        outputURL = videoURL
        assetWriter = try? AVAssetWriter(outputURL: outputURL!, fileType: AVFileType.mp4)
        assetWriter?.startWriting()
        assetWriter?.finishWriting {
            print("outputURL: ", self.outputURL!)
            self.videoURL = self.outputURL
        }
        
        videoURL = (player.currentItem?.asset as? AVURLAsset?)!?.url
        print("NewFilterURL: ", videoURL!)
    }
    
    // share video
    @IBAction func share(_ sender: UIButton) {
        
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
        
        // share options only show if a video has been chosen/taken
        if videoURL != nil {
            
            // Compress video so it shares faster
            // Encode to mp4
            
    // doesn't work with filtered video?
            
            compressVideo(inputURL: videoURL! as URL, outputURL: compressedURL) { (exportSession) in
                guard let session = exportSession
                else { return }

                // switch statement detailing the session's status
                switch session.status {
                case .unknown:
                    break
                case .waiting:
                    break
                case .exporting:
                    break
                case .completed:
                    guard NSData(contentsOf: compressedURL) != nil
                    else { return }
                case .failed:
                    break
                case .cancelled:
                    break
                }
            }
            
            // use UIActivityViewController to export the new compressed video URL
            let activityVC = UIActivityViewController(activityItems: [videoURL as Any], applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.sourceRect = self.view.frame
            
            self.present(activityVC, animated: true, completion: nil)
        }
        // error message to prompt the user to choose or take a photo
        else {
            errorNotice()
        }
        
        videoURL = compressedURL
    }
    
    
    // Video compression function
    // Uses input and output URLs to export the session - used in the share function above
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: videoURL!, options: nil)
        
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality)
        else {
            handler(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously() {
            DispatchQueue.main.async {
                self.exportDidFinish(exportSession)
                self.videoURL = exportSession.outputURL
            }
        }
    }
    
    // export finished
    func exportDidFinish(_ session: AVAssetExportSession) {
        
        guard
            session.status == AVAssetExportSessionStatus.completed,
            let outputURL = session.outputURL
            else { return }
        
        let saveVideoToPhotos = {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
            }) { saved, error in
                let success = saved && (error == nil)
                let title = success ? "Success" : "Error"
                let message = success ? "Video saved" : "Failed to save video"
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        // Ensure permission to access Photo Library
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    saveVideoToPhotos()
                }
            }
        } else { saveVideoToPhotos() }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
}


/* old code

 --- ImagePickerController function
 //        let videoType = info[UIImagePickerControllerMediaType] as? String
 //        videoType == (kUTTypeMovie as String)
 //        let videoData = AVCaptureFileOutputRecordingDelegate
 //        let url = info[UIImagePickerControllerMediaURL] as? URL
 //
 //        let player = AVPlayer(url: url?)?
 //        let vcPlayer = AVPlayerViewController()
 //        vcPlayer.player = player
 //        self.present(vcPlayer, animated: true, completion: nil)
 
 
 //    func fileOutput(AVCaptureOutput, didStartRecordingTo: URL, from: [AVCaptureConnection])
 //    {
 //    }

 --- Save button
 //        let compressedJPEGImage = UIImage(data: imageData!)
 //        UIImageWriteToSavedPhotosAlbum(compressedJPEGImage!, nil, nil, nil)

 
 // (class) AVCaptureFileOutputRecordingDelegate
 // required for AVCaptureFileOutput:
 //    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
 //    }

 
 --- AVPlayerViewController
 //        let vcPlayer = AVPlayerViewController()
 //        vcPlayer.player = player
 //        vcPlayer.showsPlaybackControls = true
 //        self.present(vcPlayer, animated: true, completion: nil)
 
 
 //        let playerViewController = AVPlayerViewController()
 //        playerViewController.player = player
 //        self.present(playerViewController, animated: true) {
 //            playerViewController.player!.play()
 //        }
 
 
--- generate thumbnail
 func generateThumbnail(url: URL) -> UIImage? {
 let asset = AVAsset(url: videoURL!)
 
 do {
 let imageGenerator = AVAssetImageGenerator(asset: asset)
 imageGenerator.appliesPreferredTrackTransform = true
 let cgImage = try imageGenerator.copyCGImage(at: kCMTimeZero, actualTime: nil)
 return UIImage(cgImage: cgImage)
 } catch {
 print(error.localizedDescription)
 
 return nil
 }
 }


 
 // previously tried code - works to compress the video, but still doesn't work with sharing a filtered video
 //            compressVideo(inputURL: videoURL!, outputURL: compressedURL, handler: { (_ exportSession: AVAssetExportSession?) -> Void in
 //
 //                switch exportSession!.status {
 //                case .completed:
 //                    print("Video compressed successfully")
 //                    do {
 //                        compressedFileData = try Data(contentsOf: exportSession!.outputURL!)
 //                        compressedURL = compressedFileData!.url
 //                    } catch _ {
 //                        print ("Error converting compressed file to Data")
 //                    }
 //                default:
 //                    print("Could not compress video")
 //                }
 //            } )

 
 
 ------- don't even know anymore
 //        guard let outputURL = exportSession.outputURL else { return }
 //
 //        PHPhotoLibrary.requestAuthorization { status in
 //            if status == .authorized {
 //
 //                // Save the movie file to the photo library and cleanup.
 //                PHPhotoLibrary.shared().performChanges({
 //                    let options = PHAssetResourceCreationOptions()
 //                    options.shouldMoveFile = true
 //                    let creationRequest = PHAssetCreationRequest.forAsset()
 //                    creationRequest.addResource(with: .video, fileURL: outputURL, options: options)
 //                }, completionHandler: { success, error in
 //                    if !success {
 //                        guard let theError = error else { return }
 //                        print("An export error occurred: \(theError.localizedDescription)")
 //                        return
 //                    }
 //                })
 //            }
 //            else {
 //                print("Not authorized to save movie to the camera roll.")
 //                return
 //            }
 //        }
 
 */
 
