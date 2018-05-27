//
//  FirstViewController.swift
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
import CoreImage // to apply filters

class FirstViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {

    // outlets created for on-screen views
    @IBOutlet weak var imagePicked: UIImageView!
    @IBOutlet weak var filterButtonScroll: UIScrollView!
    
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
        "CICMYKHalftone",
        "CIGaussianBlur",
        "CIMotionBlur"
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
            filterButtonScroll.isHidden = true
            ResetImage(sender: filterButtonScroll)
            
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
            filterButtonScroll.isHidden = true
            ResetImage(sender: filterButtonScroll)
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // save photo to library
    @IBAction func saveButton(_ sender: UIButton) {
        if imagePicked.image != nil {
            let imageData = UIImageJPEGRepresentation(imagePicked.image!, 0)
            let compressedJPEGImage = UIImage(data: imageData!)
            UIImageWriteToSavedPhotosAlbum(compressedJPEGImage!, nil, nil, nil)
            
            saveNotice()
        }
        else { errorMessage() }
    }
    

    // filter options
    @IBAction func filter(_ sender: UIButton) {

        imagePicked.image = currentImage
        filterButtonScroll.isHidden = false
        filterButtonScroll.isScrollEnabled = true
        filterButtonScroll.delegate = self
//        filterButtonScroll.contentSize = CGSize(width: self.view.frame.size.width, height: 50)

        filterButtonScroll.contentSize.height = CGFloat(45*CIFilters.count)
        filterButtonScroll.contentSize.width = self.view.bounds.width
        filterButtonScroll.translatesAutoresizingMaskIntoConstraints = false
        
        var xCoord: CGFloat = 10
        let yCoord: CGFloat = 10
        let buttonWidth:CGFloat = 65
        let buttonHeight:CGFloat = 65
        let gapBetweenButtons: CGFloat = 5
        
        var itemCount = 0
        
        if imagePicked.image != nil {
            for i in 0..<CIFilters.count {
                itemCount = i
                
                // Button properties
                let filterButton = UIButton(type: .custom)
                filterButton.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
                filterButton.tag = itemCount
                filterButton.addTarget(self, action: #selector(FirstViewController.filterButtonTapped(sender:)), for: .touchUpInside)
                filterButton.layer.cornerRadius = 6
                filterButton.clipsToBounds = true
                
                // Create buttons for filters
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
                
                filterButtonScroll.addSubview(filterButton)
            }
        }
        else {
            errorMessage()
        }
        
        // Resize Scroll View
        var contentRect = CGRect.zero
        
        for view in filterButtonScroll.subviews {
            contentRect = contentRect.union(view.frame)
        }

        // change content size to scroll horizontally, and adjust behaviour so it won't automatically scroll up and down
        filterButtonScroll.contentSize = CGSize(width: xCoord, height: filterButtonScroll.frame.height)
        filterButtonScroll.contentInsetAdjustmentBehavior = .never

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
    
    
    // alert stating photo has saved
    func saveNotice() {
        if imagePicked.image != nil {
            let alertController = UIAlertController(title: "Photo saved!", message: "Your photo was saved  successfully", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
        else { errorMessage() }
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
            errorMessage()
        }
    }
    
    // error message to alert user no photo selected
    func errorMessage() {
        let alertController = UIAlertController(title: "No photo selected", message: "Choose or take a photo", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
