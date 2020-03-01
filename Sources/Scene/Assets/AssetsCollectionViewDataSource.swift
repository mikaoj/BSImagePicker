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

class AssetsCollectionViewDataSource : NSObject, UICollectionViewDataSource {
    private static let assetCellIdentifier = "AssetCell"
    private static let videoCellIdentifier = "VideoCell"
    
    var settings: Settings!

    private let fetchResult: PHFetchResult<PHAsset>
    private let imageManager = PHCachingImageManager.default()
    private let durationFormatter = DateComponentsFormatter()
    private let store: AssetStore

    private let scale: CGFloat
    private var targetSize: CGSize = .zero
    
    init(fetchResult: PHFetchResult<PHAsset>, store: AssetStore, scale: CGFloat = UIScreen.main.scale) {
        self.fetchResult = fetchResult
        self.store = store
        self.scale = scale
        durationFormatter.unitsStyle = .positional
        durationFormatter.zeroFormattingBehavior = [.pad]
        durationFormatter.allowedUnits = [.minute, .second]
        super.init()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult[indexPath.row]
        let animationsWasEnabled = UIView.areAnimationsEnabled
        let cell: AssetCollectionViewCell
        
        UIView.setAnimationsEnabled(false)
        if asset.mediaType == .video {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetsCollectionViewDataSource.videoCellIdentifier, for: indexPath) as! VideoCollectionViewCell
            let videoCell = cell as! VideoCollectionViewCell
            videoCell.durationLabel.text = durationFormatter.string(from: asset.duration)
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetsCollectionViewDataSource.assetCellIdentifier, for: indexPath) as! AssetCollectionViewCell
        }
        UIView.setAnimationsEnabled(animationsWasEnabled)

        cell.accessibilityIdentifier = "Photo \(indexPath.item + 1)"
        cell.accessibilityTraits = UIAccessibilityTraits.button
        cell.isAccessibilityElement = true
        cell.settings = settings
        
        loadImage(for: asset, in: cell)
        
        cell.selectionIndex = store.index(of: asset)
        
        return cell
    }
    
    static func registerCellIdentifiersForCollectionView(_ collectionView: UICollectionView?) {
        collectionView?.register(AssetCollectionViewCell.self, forCellWithReuseIdentifier: assetCellIdentifier)
        collectionView?.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: videoCellIdentifier)
    }
    
    private func loadImage(for asset: PHAsset, in cell: AssetCollectionViewCell?) {
        // Cancel any pending image requests
        if let cell = cell, cell.tag != 0 {
            imageManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        // Request image
        if let cell = cell {
            targetSize = cell.bounds.size.resize(by: scale)
        }

        cell?.tag = Int(imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: settings.fetch.preview.photoOptions) { (image, _) in
            guard let image = image else { return }
            cell?.imageView.image = image
        })
    }
}

extension AssetsCollectionViewDataSource: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Touching asset should trigger prefetching
        // And prefetch image for that asset
        indexPaths.forEach {
            let asset = fetchResult[$0.row]
            loadImage(for: asset, in: nil)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {

    }
}
