// The MIT License (MIT)
//
// Copyright (c) 2015 Joakim Gyllström
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

/**
Cell for photo albums in the albums drop down menu
*/
final class AlbumCell: UITableViewCell {
    static let cellIdentifier = "albumCell"

    let firstImageView: UIImageView = UIImageView(frame: .zero)
    let secondImageView: UIImageView = UIImageView(frame: .zero)
    let thirdImageView: UIImageView = UIImageView(frame: .zero)
    let albumTitleLabel: UILabel = UILabel(frame: .zero)

    private let imageContainerView: UIView = UIView(frame: .zero)

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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        selectionStyle = .none

        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageContainerView)
        albumTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(albumTitleLabel)

        NSLayoutConstraint.activate([
            imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            imageContainerView.heightAnchor.constraint(equalToConstant: 84),
            imageContainerView.widthAnchor.constraint(equalToConstant: 84),
            imageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            albumTitleLabel.leadingAnchor.constraint(equalTo: imageContainerView.trailingAnchor, constant: 8),
            albumTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            albumTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            albumTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        // Image views
        [thirdImageView, secondImageView, firstImageView].forEach {
            imageContainerView.addSubview($0)
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: 79),
                $0.widthAnchor.constraint(equalToConstant: 79)
            ])

            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.shadowColor = UIColor.white.cgColor
            $0.layer.shadowRadius = 1.0
            $0.layer.shadowOffset = CGSize(width: 0.5, height: -0.5)
            $0.layer.shadowOpacity = 1.0
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
        }

        NSLayoutConstraint.activate([
            thirdImageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            thirdImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            secondImageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            secondImageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            firstImageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            firstImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        firstImageView.image = nil
        secondImageView.image = nil
        thirdImageView.image = nil
        albumTitleLabel.text = nil
    }
}
