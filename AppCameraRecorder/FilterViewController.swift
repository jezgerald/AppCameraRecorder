//
//  FilterViewController.swift
//  AppCameraRecorder
//
//  Created by Jessica Fitzgerald on 16/5/18.
//  Copyright © 2018 Jessica Fitzgerald. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos // to take photos
import MobileCoreServices // to access camera
import CoreImage // to create filters

class FilterViewController: FirstViewController {

    var selectedImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imagePicked.image = selectedImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBOutlet weak var photoImageView: UIImageView!
    
    // Create a place to render the filtered image
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
