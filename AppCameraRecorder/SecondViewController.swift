//
//  SecondViewController.swift
//  AppCameraRecorder
//
//  Created by Jessica Fitzgerald on 12/5/18.
//  Copyright © 2018 Jessica Fitzgerald. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos // to take photos
import MobileCoreServices // to access camera
import CoreImage // to create filters
import CoreMedia // to create & apply video filters

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession : AVCaptureSession!
    
    // image viewer to show preview of video after taken
    @IBOutlet weak var videoPicked: UIImageView!
    
    var soundRecorder = AVAudioRecorder()
    var soundPlayer = AVAudioPlayer()
    var videoURL: NSURL?
    let playerController = AVPlayerViewController()
    
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
    
    // save video to library
    @IBAction func saveButton(_ sender: UIButton) {
        
    }
    
    
    // finish and close the video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        guard
            let mediaType = info[UIImagePickerControllerMediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerControllerMediaURL] as? URL,
            UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
            else { return }
        
        // trying to extract URL to be used elsewhere
//        self.videoURL = url as NSURL
        
        // dismisses view controller
        picker.presentingViewController?.dismiss(animated: true)
        
        //playVideo()
        
        let player = AVPlayer(url: url)
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = videoPicked.frame
//        self.view.layer.addSublayer(playerLayer)
//        player.play()

        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        
//        let vcPlayer = AVPlayerViewController()
//        vcPlayer.player = player
//        vcPlayer.showsPlaybackControls = true
//        self.present(vcPlayer, animated: true, completion: nil)
        
        
        // saves video to Photo Library - includes alert message
//        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    // trying to create a way to view the video on the main screen before saving
    func playVideo() {

//        UIVideoEditorController

    }
    
    // trying to add code to play the video
    @IBAction func playButton(_ sender: UIButton) {
        
        performSegue(withIdentifier: "videoPlaySegue", sender: self)
//
////        if let videoURL = videoURL {
//        let player = AVPlayer(url: videoURL! as URL)
//        let vcPlayer = AVPlayerViewController()
//        vcPlayer.player = player
//        self.present(vcPlayer, animated: true, completion: nil)
//        }
//        else {
//            let alertController = UIAlertController(title: "No video selected", message: "Choose or take a video", preferredStyle: .alert)
//            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alertController.addAction(defaultAction)
//            present(alertController, animated: true, completion: nil)
//        }
    }

    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destination as!
        AVPlayerViewController
        let url = self.videoURL
        destination.player = AVPlayer(url: url! as URL)
    }
    
    // video function - required to save video
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // get thumbnail of video to show on main screen
    func getThumbnailFrom(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
        }
        catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
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
        
    }
    
    
    // share video
    @IBAction func share(_ sender: UIButton) {
        
        // to choose the image already showing
        //let video = videoPicked.image
        let video = playerController.player
        
        // share options only show if an image has been chosen/taken
        if video != nil {
            let activityVC = UIActivityViewController(activityItems: [video as Any], applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = sender
            
            self.present(activityVC, animated: true, completion: nil)
        }
            // error message to prompt the user to choose or take a photo
        else {
            let alertController = UIAlertController(title: "No video selected", message: "Choose or take a video", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
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

 
 */
 
