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
import Photos

/**
Implements the UITableViewDataSource protocol with a data source and cell factory
*/
final class AlbumsTableViewDataSource : NSObject, UITableViewDataSource {
    var settings: Settings!
    
    private let albums: [PHAssetCollection]
    private let scale: CGFloat
    private let imageManager = PHCachingImageManager.default()
    
    init(albums: [PHAssetCollection], scale: CGFloat = UIScreen.main.scale) {
        self.albums = albums
        self.scale = scale
        super.init()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return albums.count > 0 ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumCell.identifier, for: indexPath) as! AlbumCell
        
        // Fetch album
        let album = albums[indexPath.row]
        
        // Title
        cell.albumTitleLabel.attributedText = titleForAlbum(album)

        let fetchOptions = settings.fetch.assets.options.copy() as! PHFetchOptions
        fetchOptions.fetchLimit = 1
        
        let imageSize = CGSize(width: 84, height: 84).resize(by: scale)
        let imageContentMode: PHImageContentMode = .aspectFill
        if let asset = PHAsset.fetchAssets(in: album, options: fetchOptions).firstObject {
            imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: imageContentMode, options: settings.fetch.preview.photoOptions) { (image, _) in
                guard let image = image else { return }
                cell.albumImageView.image = image
            }
        }
        
        return cell
    }

    func registerCells(in tableView: UITableView) {
        tableView.register(AlbumCell.self, forCellReuseIdentifier: AlbumCell.identifier)
    }

    private func titleForAlbum(_ album: PHAssetCollection) -> NSAttributedString {
        let text = NSMutableAttributedString()

        text.append(NSAttributedString(string: album.localizedTitle ?? "", attributes: settings.theme.albumTitleAttributes))

        return text
    }
}
