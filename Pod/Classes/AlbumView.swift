//
//  AlbumView.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-05-08.
//
//

import UIKit

internal class AlbumView: UIView {
    @IBOutlet weak var albumButton: UIButton!
    
    internal var albumTitle = "" {
        didSet {
            albumButton.setTitle(self.albumTitle, forState: .Normal)
            albumButton.setImage(arrowDownImage, forState: .Normal)
            
            // Place image to the right
            if let imageView = albumButton.imageView, let titleLabel = albumButton.titleLabel {
                albumButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageView.frame.size.width, bottom: 0, right: imageView.frame.size.width)
                albumButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: titleLabel.frame.size.width, bottom: 0, right: -titleLabel.frame.size.width - 8)
            }
        }
    }
    
    internal lazy var arrowDownImage: UIImage? = {
        // Get path for BSImagePicker bundle
        let bundlePath = NSBundle(forClass: PhotosViewController.self).pathForResource("BSImagePicker", ofType: "bundle")
        let bundle: NSBundle?
        
        // Load bundle
        if let bundlePath = bundlePath {
            bundle = NSBundle(path: bundlePath)
        } else {
            bundle = nil
        }
        
        return UIImage(named: "arrow_down", inBundle: bundle, compatibleWithTraitCollection: nil)
    }()
}
