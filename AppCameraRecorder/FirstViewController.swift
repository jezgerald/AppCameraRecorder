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

class FirstViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {

    // outlets created for on-screen buttons, views, etc.
    @IBOutlet weak var imagePicked: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var filterScrollView: UIScrollView!
    @IBOutlet weak var filterButtonView: UIView!
    
    // variables
    var currentImage : UIImage!
    var context : CIContext!
    var currentFilter : CIFilter!
    
    // array of image filters
    var CIFilters = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CIPhotoEffectMono",
        "CIColorClamp",
        "CISepiaTone",
        "CIGaussianBlur",
        "CIMotionBlur",
        "CIVibrance",
        "CICMYKHalftone"
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
            // to stop the filter showing the previous option
            filterScrollView.isHidden = true
            filterButtonView.isHidden = true
            ResetImage(sender: filterScrollView)
            
            // takes photo with camera & adds it to the UIView
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
            // to stop the filter showing the previous option
            filterScrollView.isHidden = true
            filterButtonView.isHidden = true
            ResetImage(sender: filterScrollView)
            
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

        imagePicked.image = currentImage
        filterScrollView.isHidden = false
        filterButtonView.isHidden = false
        
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 10
        let buttonWidth:CGFloat = 70
        let buttonHeight:CGFloat = 70
        let gapBetweenButtons: CGFloat = 5
        
        var itemCount = 0
        
        for i in 0..<CIFilters.count {
            itemCount = i
            
            // Button properties
            let filterButton = UIButton(type: .custom)
            filterButton.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
            filterButton.tag = itemCount
            filterButton.addTarget(self, action: #selector(FirstViewController.filterButtonTapped(sender:)), for: .touchUpInside)
            filterButton.layer.cornerRadius = 6
            filterButton.clipsToBounds = true
            
            // Create filters for each button
            let ciContext = CIContext(options: nil)
            let coreImage = CIImage(image: currentImage)
            let filter = CIFilter(name: "\(CIFilters[i])" )
            filter!.setDefaults()
            filter!.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
            let imageForButton = UIImage(cgImage: filteredImageRef!);
            
            filterButton.setBackgroundImage(imageForButton, for: .normal)
            
            // Add Buttons in the Scroll View
            xCoord += buttonWidth + gapBetweenButtons
            
//            filterScrollView.addSubview(filterButton)
            filterButtonView.addSubview(filterButton)
        }
        
        // Resize Scroll View
        var contentRect = CGRect.zero
        
        for view in filterScrollView.subviews {
            contentRect = contentRect.union(view.frame)
        }
        filterScrollView.contentSize = contentRect.size
        
    }
    
    @objc func filterButtonTapped(sender: UIButton) {
        let button = sender as UIButton
        imagePicked.image = button.backgroundImage(for: UIControlState.normal)
    }
    
    
    // reset the image
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
