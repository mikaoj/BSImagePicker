//
//  PhotoCell.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-05-07.
//
//

import UIKit

internal class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectionOverlayView: UIView!
    @IBOutlet weak var numberedSelectionView: NumberedSelectionView!
}
