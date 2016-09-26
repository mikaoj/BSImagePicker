// The MIT License (MIT)
//
// Copyright (c) 2016 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

class AlbumCell: UITableViewCell {
    @IBOutlet var firstImageView: UIImageView!
    @IBOutlet var secondImageView: UIImageView!
    @IBOutlet var thirdImageView: UIImageView!
    @IBOutlet var albumTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Add a little shadow to images views
        for imageView in [firstImageView, secondImageView, thirdImageView] {
            imageView?.layer.shadowColor = UIColor.white.cgColor
            imageView?.layer.shadowRadius = 1.0
            imageView?.layer.shadowOffset = CGSize(width: 0.5, height: -0.5)
            imageView?.layer.shadowOpacity = 1.0
        }
    }
    
    override var isSelected: Bool {
        didSet {
            // Selection checkmark
            if isSelected == true {
                accessoryType = .checkmark
            } else {
                accessoryType = .none
            }
        }
    }
    
    func update(for album: Album) {
        albumTitleLabel.text = album.title
        
        let imageViews = [firstImageView, secondImageView, thirdImageView]
        for (index, imageView) in imageViews.enumerated() {
            let photo = album[index]
            photo.thumbnail(size: firstImageView.bounds.size, contentMode: .aspectFill, result: { (image) in
                imageView?.image = image
            })
        }
    }
}
