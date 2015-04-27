//
//  ViewController.swift
//  BSImagePickerExample
//
//  Created by Joakim Gyllström on 2015-04-26.
//  Copyright (c) 2015 Joakim Gyllström. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos

class ViewController: UIViewController {
    
    @IBAction func showImagePicker(sender: UIButton) {
        let vc = ImagePickerViewController()
        
        bs_presentImagePickerController(vc, animated: true,
            select: { (asset: PHAsset) -> Void in
            
            }, deselect: { (asset: PHAsset) -> Void in
            
            }, cancel: { (assets: [PHAsset]) -> Void in
            
            }, finish: { (assets: [PHAsset]) -> Void in
            
        }, completion: nil)
    }
}

