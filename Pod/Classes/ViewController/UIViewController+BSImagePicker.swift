//
//  UIViewController+BSImagePicker.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-04-26.
//
//

import UIKit
import Photos

public extension UIViewController {
    func bs_presentImagePickerController(imagePicker: ImagePickerViewController, animated: Bool, select: ((asset: PHAsset) -> Void)?, deselect: ((asset: PHAsset) -> Void)?, cancel: (([PHAsset]) -> Void)?, finish: (([PHAsset]) -> Void)?, completion: (() -> Void)?) {
        // Set blocks
        imagePicker.selectionClosure = select
        imagePicker.deselectionClosure = deselect
        imagePicker.cancelClosure = cancel
        imagePicker.finishClosure = finish
        
        // Present
        presentViewController(imagePicker, animated: animated, completion: completion)
    }
}
