//
//  ViewController.swift
//  BSImagePickerExample
//
//  Created by Joakim Gyllström on 2015-04-26.
//  Copyright (c) 2015 Joakim Gyllström. All rights reserved.
//

import UIKit
import BSImagePicker

class ViewController: UIViewController {
    
    @IBAction func showImagePicker(sender: UIButton) {
        let vc = ImagePickerViewController()
        
        presentViewController(vc, animated: true, completion: nil)
    }
}

