//
//  FirstViewController.swift
//  AppCameraRecorder
//
//  Created by Jessica Fitzgerald on 12/5/18.
//  Copyright © 2018 Jessica Fitzgerald. All rights reserved.
//

import UIKit
import AVFoundation
import Photos // to take photos
import AVKit
import MobileCoreServices // to access camera
import CoreImage // to apply filters

class FirstViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imagePicked: UIImageView!
    @IBOutlet weak var slider: UISlider!
    
    var currentImage : UIImage!
    var context : CIContext!
    var currentFilter : CIFilter!
    
    // filter array
    var CIFilters = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        context = CIContext()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // take photo
    @IBAction func recordButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // open photo library
    @IBAction func photoLibrary(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // save photo to library
    @IBAction func saveButton(_ sender: UIButton) {
        let imageData = UIImageJPEGRepresentation(imagePicked.image!, 0)
        let compressedJPEGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedJPEGImage!, nil, nil, nil)
        
        saveNotice()
    }
    
    // filter options
    @IBAction func filter(_ sender: UIButton) {

        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIPhotoEffectChrome", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPhotoEffectFade", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPhotoEffectInstant", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPhotoEffectNoir", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: ResetImage))
        present(ac, animated: true)
        
    }
    
    func setFilter(action: UIAlertAction) {
        // make sure we have a valid image before continuing!
        guard currentImage != nil else { return }
        
        currentFilter = CIFilter(name: action.title!)
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    func ResetImage (sender: AnyObject) {
        if let image = self.currentImage {
            self.imagePicked.image = image
        }
        
    }
    
    // show photo on main page after taken
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = (info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as? UIImage
        {
            imagePicked.image = image
            currentImage = image
        }
        picker.presentingViewController?.dismiss(animated: true, completion: nil);
    }
    
    // change filter intensity where applicable
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    // process picture with applied filter
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        let intensity = Int(slider.value)
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity, forKey: kCIInputIntensityKey)
            slider.isHidden = false
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(intensity * 200, forKey: kCIInputRadiusKey)
            slider.isHidden = false
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity * 100, forKey: kCIInputScaleKey)
            slider.isHidden = false
        }
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
            slider.isHidden = false
        }
        else {
            slider.isHidden = true
        }
        
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            self.imagePicked.image = processedImage
        }
    }
    
    // alert stating photo has saved
    func saveNotice() {
        let alertController = UIAlertController(title: "Photo saved!", message: "Your photo was saved  successfully", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    // share image to social media or other applications
    @IBAction func share(_ sender: UIButton) {

        // to choose the image already showing
        let image = imagePicked.image

        // share options only show if an image has been chosen/taken
        if image != nil {
            let activityVC = UIActivityViewController(activityItems: [image as Any], applicationActivities: nil)

            activityVC.popoverPresentationController?.sourceView = sender

            self.present(activityVC, animated: true, completion: nil)
        }
        // error message to prompt the user to choose or take a photo
        else {
            let alertController = UIAlertController(title: "No photo selected", message: "Choose or take a photo", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    
}


// Old code
//    @IBAction func applyFilter(sender: AnyObject) {
//
//        // Create an image to filter
//        let inputImage = CIImage(image: imagePicked.image!)
//
//        // Create a random color to pass to a filter
//        let randomColor = [kCIInputAngleKey: (Double(arc4random_uniform(314)) / 100)]
//
//        // Apply a filter to the image
//        let filteredImage = inputImage?.applyingFilter("CIHueAdjust", parameters: randomColor)
//
//        // Render the filtered image
////        let renderedImage = context.createCGImage(filteredImage!, fromRect: filteredImage!.extent())
//
//        // Reflect the change back in the interface
////        imagePicked.image = UIImage(cgImage: renderedImage)
//
//    }

//        performSegue(withIdentifier: "photoSegue", sender: self)

// no longer using below as created new View instead of tab
////FILTER IMAGE TO NEW SEGUE CONTROLLER THING: https://stackoverflow.com/questions/35020242/how-do-i-segue-an-image-to-another-viewcontroller-and-display-it-within-an-image
//override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    guard let filterVC = segue.destination as? FilterViewController
//        else { return }
//
//    if segue.identifier == "photoSegue" {
//        filterVC.selectedImage = imagePicked.image!
//        //            imagePicked.image = CIImage.applyingFilter(imagePicked)
//    }
//}
