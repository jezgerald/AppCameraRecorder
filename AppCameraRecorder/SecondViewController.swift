//
//  SecondViewController.swift
//  AppCameraRecorder
//
//  Created by Jessica Fitzgerald on 12/5/18.
//  Copyright © 2018 Jessica Fitzgerald. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AVKit
import MobileCoreServices // to access camera

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    // image viewer to show preview of video after taken
    @IBOutlet weak var videoPicked: UIImageView!
    
    var soundRecorder = AVAudioRecorder()
    var soundPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // button to record video
    @IBAction func recordButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let mediaUI = UIImagePickerController()
            mediaUI.delegate = self
            mediaUI.sourceType = UIImagePickerControllerSourceType.camera
            mediaUI.mediaTypes = [kUTTypeMovie as String]
            mediaUI.allowsEditing = true
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
    
    // save video to library - working without code???
    // TO FIX
    @IBAction func saveButton(_ sender: UIButton) {
        
        saveNotice()
    }
    
    // finish and close the video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        guard
            let mediaType = info[UIImagePickerControllerMediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerControllerMediaURL] as? URL,
            UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
            else {
                return
        }
        
       videoPicked.image = getThumbnailFrom(path: url)
        
        // Save video to photo library
        // Possible to transfer to Save button????? - needs url, info, etc.
        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
        
        picker.presentingViewController?.dismiss(animated: true)

    }
    
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
    
    // error alert if video doesn't work
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    // currently saving without pressing save
    // TO FIX
    func saveNotice() {
        let alertController = UIAlertController(title: "Video saved!", message: "Your video was successfully saved", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    // TO DO
    @IBAction func filterButton(_ sender: UIButton) {
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
 
