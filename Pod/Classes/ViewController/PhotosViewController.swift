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

// TODO: Put in separate file
extension UIButton {
    func bs_setTitle(title: String?, forState state: UIControlState, animated: Bool) {
        // Store enabled
        let wasEnabled = self.enabled
        
        // Disable/enable animations
        UIView.setAnimationsEnabled(animated)
        
        // A little hack to set title without animation
        self.enabled = true
        self.setTitle(title, forState: state)
        self.layoutIfNeeded()
        
        // Enable animations
        UIView.setAnimationsEnabled(true)
    }
}

internal class PhotosViewController : UICollectionViewController, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UICollectionViewDelegate, AssetsDelegate {
    internal var selectionClosure: ((asset: PHAsset) -> Void)?
    internal var deselectionClosure: ((asset: PHAsset) -> Void)?
    internal var cancelClosure: ((assets: [PHAsset]) -> Void)?
    internal var finishClosure: ((assets: [PHAsset]) -> Void)?
    
    private let photosDataSource = PhotosDataSource()
    private var albumsDataSource: AlbumsDataSource?
    private lazy var doneBarButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed:")
    }()
    private var doneBarButtonTitle: String?
    
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
        
        // Setup albums data source
        albumsDataSource = AlbumsDataSource()
        albumsDataSource?.selectableFetchResult.selectResult(atIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        albumsDataSource?.delegate = self
        
        if let album = albumsDataSource?.selectableFetchResult.selectedAssets.first {
            // Update album title
            albumTitleView?.albumTitle = album.localizedTitle
            
            // Pass it on to photos data source
            photosDataSource.fetchResultsForAsset(album)
        }
        
        // Hook up data source
        photosDataSource.delegate = self
        collectionView?.dataSource = photosDataSource
        collectionView?.delegate = self
        
        // Enable multiple selection
        collectionView?.allowsMultipleSelection = true
        
        // Add buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelButtonPressed:")
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.titleView = albumTitleView
    }
    
    // MARK: Button actions
    func cancelButtonPressed(sender: UIBarButtonItem) {
        if let closure = cancelClosure {
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                closure(assets: self.photosDataSource.selectableFetchResult.selectedAssets)
            })
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed(sender: UIBarButtonItem) {
        if let closure = finishClosure {
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                closure(assets: self.photosDataSource.selectableFetchResult.selectedAssets)
            })
        }
        
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
            albumsViewController.tableView.reloadData()
            
            presentViewController(albumsViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: Traits
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
    
    // MARK: UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        
        return true
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Clear previous selection
        albumsDataSource?.selectableFetchResult.selectedAssets.removeAll(keepCapacity: true)
        
        // Update selected album
        albumsDataSource?.selectableFetchResult.selectResult(atIndexPath: indexPath)
        
        // Notify photos data source
        if let album = albumsDataSource?.selectableFetchResult.selectedAssets.first {
            // Update album title
            albumTitleView?.albumTitle = album.localizedTitle
            
            // Pass it on to photos data source
            photosDataSource.fetchResultsForAsset(album)
        }
        
        // Dismiss album selection
        albumsViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Select asset)
        photosDataSource.selectableFetchResult.selectResult(atIndexPath: indexPath)
        
        // Set selection number
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCell {
            cell.selectionNumber = photosDataSource.selectableFetchResult.selectedAssets.count
        }
        
        // Update done button
        updateDoneButton()
        
        // Call selection closure
        if let closure = selectionClosure {
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                closure(asset: self.photosDataSource.selectableFetchResult.results[indexPath.section][indexPath.row] as! PHAsset)
            })
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        // Deselect asset
        photosDataSource.selectableFetchResult.deselectResult(atIndexPath: indexPath)
        
        // Update done button
        updateDoneButton()
        
        // Reload selected cells to update their selection number
        UIView.setAnimationsEnabled(false)
        collectionView.reloadItemsAtIndexPaths(photosDataSource.selectableFetchResult.indexPathsForselectedAssets())
        syncSelectionInDataSource(photosDataSource, withCollectionView: collectionView)
        UIView.setAnimationsEnabled(true)
        
        // Call deselection closure
        if let closure = deselectionClosure {
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                closure(asset: self.photosDataSource.selectableFetchResult.results[indexPath.section][indexPath.row] as! PHAsset)
            })
        }
    }
    
    // MARK: AssetsDelegate
    func didUpdateAssets(sender: NSObject, incrementalChange: Bool, insert: [NSIndexPath], delete: [NSIndexPath], change: [NSIndexPath]) {
        // Reload table view or collection view?
        if sender == photosDataSource {
            if let collectionView = collectionView {
                if incrementalChange {
                    // Update
                    collectionView.deleteItemsAtIndexPaths(delete)
                    collectionView.insertItemsAtIndexPaths(insert)
                    collectionView.reloadItemsAtIndexPaths(change)
                } else {
                    // Reload
                    collectionView.reloadSections(NSIndexSet(index: 0))
                }
                
                // Sync selection
                syncSelectionInDataSource(photosDataSource, withCollectionView: collectionView)
            }
        } else if sender == albumsDataSource {
            if incrementalChange {
                // Update
                albumsViewController?.tableView?.deleteRowsAtIndexPaths(delete, withRowAnimation: .Automatic)
                albumsViewController?.tableView?.insertRowsAtIndexPaths(insert, withRowAnimation: .Automatic)
                albumsViewController?.tableView?.reloadRowsAtIndexPaths(change, withRowAnimation: .Automatic)
            } else {
                // Reload
                albumsViewController?.tableView?.reloadData()
            }
        }
    }
    
    // MARK: Private helper methods
    func updateDoneButton() {
        // Get selection count
        let selectedAssets = photosDataSource.selectableFetchResult.selectedAssets.count
        
        // Find right button
        if let subViews = navigationController?.navigationBar.subviews {
            for view in subViews {
                if let btn = view as? UIButton where checkIfRightButtonItem(btn) {
                    // Store original title if we havn't got it
                    if doneBarButtonTitle == nil {
                        doneBarButtonTitle = btn.titleForState(.Normal)
                    }
                    
                    // Update title
                    if selectedAssets > 0 {
                        btn.bs_setTitle("\(doneBarButtonTitle!) (\(selectedAssets))", forState: .Normal, animated: false)
                    } else {
                        btn.bs_setTitle(doneBarButtonTitle!, forState: .Normal, animated: false)
                    }
                    
                    // Stop loop
                    break
                }
            }
        }
        
        // Enabled
        if selectedAssets > 0 {
            doneBarButton.enabled = true
        } else {
            doneBarButton.enabled = false
        }
    }
    
    // Check if a give UIButton is the right UIBarButtonItem in the navigation bar
    // Somewhere along the road, our UIBarButtonItem gets transformed to an UINavigationButton
    // A private apple class that subclasses UIButton
    func checkIfRightButtonItem(btn: UIButton) -> Bool {
        var isRightButton = false
        
        if let rightButton = navigationItem.rightBarButtonItem {
            // Store previous values
            var wasRightEnabled = rightButton.enabled
            var wasButtonEnabled = btn.enabled
            
            // Set a known state for both buttons
            rightButton.enabled = false
            btn.enabled = false
            
            // Change one and see if other also changes
            rightButton.enabled = true
            isRightButton = btn.enabled
            
            // Reset
            rightButton.enabled = wasRightEnabled
            btn.enabled = wasButtonEnabled
        }
        
        return isRightButton
    }
    
    func syncSelectionInDataSource(dataSource: PhotosDataSource, withCollectionView collectionView: UICollectionView) {
        // Get indexpaths of selected assets
        let indexPaths = dataSource.selectableFetchResult.indexPathsForselectedAssets()
        
        // Loop through them and set them as selected in the collection view
        for indexPath in indexPaths {
            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
    }
}
