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

internal class PhotosViewController : UICollectionViewController {
    internal var selectionClosure: ((asset: PHAsset) -> Void)?
    internal var deselectionClosure: ((asset: PHAsset) -> Void)?
    internal var cancelClosure: ((assets: [PHAsset]) -> Void)?
    internal var finishClosure: ((assets: [PHAsset]) -> Void)?
    
    private let photosDataSource = PhotosDataSource()
    private let albumsDataSource = AlbumsDataSource()
    private lazy var doneBarButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed:")
    }()
    
    private lazy var bundle: NSBundle? = {
        // Get path for BSImagePicker bundle
        let bundlePath = NSBundle(forClass: PhotosViewController.self).pathForResource("BSImagePicker", ofType: "bundle")
        let bundle: NSBundle?
        
        // Load bundle
        if let bundlePath = bundlePath {
            bundle = NSBundle(path: bundlePath)
        } else {
            bundle = nil
        }
        
        return bundle
    }()
    
    private lazy var albumTitleView: AlbumTitleView? = {
        let albumTitleView = self.bundle?.loadNibNamed("AlbumTitleView", owner: self, options: nil).first as? AlbumTitleView
        
        albumTitleView?.albumTitle = self.albumsDataSource.selectedAlbum.localizedTitle
        albumTitleView?.albumButton.addTarget(self, action: "albumButtonPressed:", forControlEvents: .TouchUpInside)
        
        return albumTitleView
    }()
    
    private lazy var albumsViewController: AlbumsViewController? = {
        let storyboard = UIStoryboard(name: "Albums", bundle: self.bundle)
        
        let vc = storyboard.instantiateInitialViewController() as? AlbumsViewController
        vc?.modalPresentationStyle = .Popover
        vc?.preferredContentSize = CGSize(width: 320, height: 300)
        vc?.tableView.dataSource = self.albumsDataSource
        vc?.tableView.delegate = self
        
        return vc
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
        
        // Hook up data source
        photosDataSource.album = albumsDataSource.selectedAlbum
        collectionView?.dataSource = photosDataSource
        collectionView?.delegate = self
        
        // Enable multiple selection
        collectionView?.allowsMultipleSelection = true
        
        // Add buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelButtonPressed:")
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.titleView = albumTitleView
    }
    
    func cancelButtonPressed(sender: UIBarButtonItem) {
        let array = [PHAsset]()
        cancelClosure?(assets: array)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed(sender: UIBarButtonItem) {
        let array = [PHAsset]()
        finishClosure?(assets: array)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func albumButtonPressed(sender: UIButton) {
        if let albumsViewController = albumsViewController, let popVC = albumsViewController.popoverPresentationController, albumTitleView = albumTitleView {
            popVC.permittedArrowDirections = .Up
            popVC.sourceView = sender
            let senderRect = sender.convertRect(sender.frame, fromView: sender.superview)
            let sourceRect = CGRect(x: senderRect.origin.x, y: senderRect.origin.y + (albumTitleView.frame.size.height / 2), width: senderRect.size.width, height: senderRect.size.height)
            popVC.sourceRect = sourceRect
            popVC.delegate = self
            
            presentViewController(albumsViewController, animated: true, completion: nil)
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if let collectionViewFlowLayout = collectionViewLayout as? UICollectionViewFlowLayout, let collectionViewWidth = collectionView?.bounds.size.width {
            let itemSpacing: CGFloat
            let cellsPerRow: CGFloat
            
            switch (traitCollection.verticalSizeClass, traitCollection.horizontalSizeClass) {
            case (.Compact, .Regular): // iPhone5-6 portrait
                itemSpacing = 1.0
                cellsPerRow = 3.0
            case (.Compact, .Compact): // iPhone5-6 landscape
                itemSpacing = 1.0
                cellsPerRow = 5.0
            case (.Regular, .Regular): // iPad portrait/landscape
                itemSpacing = 1.0
                cellsPerRow = 7.0
            default:
                itemSpacing = 1.0
                cellsPerRow = 3.0
            }
            
            collectionViewFlowLayout.minimumInteritemSpacing = itemSpacing
            collectionViewFlowLayout.minimumLineSpacing = itemSpacing
            
            let test = collectionView?.bounds.size.width
            let width = (collectionViewWidth / cellsPerRow) - itemSpacing
            let height = width
            let itemSize =  CGSize(width: width, height: height)
            
            collectionViewFlowLayout.itemSize = itemSize
            photosDataSource.imageSize = itemSize
        }
    }
}

extension PhotosViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        
        return true
    }
}

extension PhotosViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: Update selected album
        // TODO: Update photos
        albumsViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PhotosViewController: UICollectionViewDelegate {
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        photosDataSource.selectAsset(atIndexPath: indexPath, inCollectionView: collectionView)
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        photosDataSource.deselectAsset(atIndexPath: indexPath, inCollectionView: collectionView)
    }
}
