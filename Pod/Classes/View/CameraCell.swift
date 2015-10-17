//
//  CameraCell.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-09-26.
//
//

import UIKit

/**
*/
final class CameraCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Apply tint to image
        imageView.image = imageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    }
}
