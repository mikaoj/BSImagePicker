//
//  AlbumCell.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-05-09.
//
//

import UIKit

internal class AlbumCell: UITableViewCell {
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Add a little shadow to images views
        for imageView in [firstImageView, secondImageView, thirdImageView] {
            imageView.layer.shadowColor = UIColor.whiteColor().CGColor
            imageView.layer.shadowRadius = 1.0
            imageView.layer.shadowOffset = CGSize(width: 0.5, height: -0.5)
            imageView.layer.shadowOpacity = 1.0
        }
    }
}
