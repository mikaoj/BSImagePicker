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

final class PhotosViewController : UICollectionViewController, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UICollectionViewDelegate, AssetsDelegate, UINavigationControllerDelegate {
    var selectionClosure: ((asset: PHAsset) -> Void)?
    var deselectionClosure: ((asset: PHAsset) -> Void)?
    var cancelClosure: ((assets: [PHAsset]) -> Void)?
    var finishClosure: ((assets: [PHAsset]) -> Void)?
    
    var settings: BSImagePickerSettings = Settings()
    
    lazy var doneBarButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed:")
    }()
    lazy var cancelBarButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelButtonPressed:")
    }()
    lazy var albumTitleView: AlbumTitleView = {
        let albumTitleView = self.bundle.loadNibNamed("AlbumTitleView", owner: self, options: nil).first as! AlbumTitleView
        
        albumTitleView.albumButton.addTarget(self, action: "albumButtonPressed:", forControlEvents: .TouchUpInside)
        
        return albumTitleView
    }()
    
    private let expandAnimator = ZoomAnimator()
    private let shrinkAnimator = ZoomAnimator()
    private var photosDataSource: PhotosDataSource?
    private var albumsDataSource: AlbumsDataSource?
    private var doneBarButtonTitle: String?
    private var isVisible = true
    
    private lazy var bundle: NSBundle = {
        // Get path for BSImagePicker bundle
        // Forcefull unwraps on purpose, if these aren't present the code wouldn't work as it should anyways
        // So I'll accept the crash in that case :)
        let bundlePath = NSBundle(forClass: PhotosViewController.self).pathForResource("BSImagePicker", ofType: "bundle")!
        return NSBundle(path: bundlePath)!
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
    
    private lazy var previewViewContoller: PreviewViewController? = {
        return PreviewViewController(nibName: nil, bundle: nil)
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
        
        // Set an empty title to get < back button
        title = " "
        
        // Setup albums data source
        albumsDataSource = AlbumsDataSource()
        albumsDataSource?.selectObjectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        albumsDataSource?.delegate = self
        
        photosDataSource = PhotosDataSource(settings: settings)
        
        // TODO: Break out into method. Is duplicated in didSelectTableView
        if let album = albumsDataSource?.selections().first {
            // Update album title
            albumTitleView.albumTitle = album.localizedTitle
            
            // Pass it on to photos data source
            photosDataSource?.fetchResultsForAsset(album)
        }
        
        // Hook up data source
        photosDataSource?.delegate = self
        collectionView?.dataSource = photosDataSource
        collectionView?.delegate = self
        
        // Enable multiple selection
        collectionView?.allowsMultipleSelection = true
        
        // Add buttons
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.titleView = albumTitleView
        
        // Add long press recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "collectionViewLongPressed:")
        longPressRecognizer.minimumPressDuration = 0.5
        collectionView?.addGestureRecognizer(longPressRecognizer)
        
        // Set navigation controller delegate
        navigationController?.delegate = self
    }
    
    // MARK: Appear/Disappear
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDoneButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        isVisible = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        isVisible = false
    }
    
    // MARK: Button actions
    func cancelButtonPressed(sender: UIBarButtonItem) {
        if let closure = cancelClosure, let assets = photosDataSource?.selections() {
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                closure(assets: assets)
            })
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed(sender: UIBarButtonItem) {
        if let closure = finishClosure, let assets = photosDataSource?.selections() {
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                closure(assets: assets)
            })
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func albumButtonPressed(sender: UIButton) {
        if let albumsViewController = albumsViewController, let popVC = albumsViewController.popoverPresentationController {
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
    
    func collectionViewLongPressed(sender: UIGestureRecognizer) {
        if sender.state == .Began {
            // Disable recognizer while we are figuring out location and pushing preview
            sender.enabled = false
            collectionView?.userInteractionEnabled = false
            
            // Calculate which index path long press came from
            let location = sender.locationInView(collectionView)
            let indexPath = collectionView?.indexPathForItemAtPoint(location)
            
            if let vc = previewViewContoller, let indexPath = indexPath, let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? PhotoCell, let asset = cell.asset {
                // Setup fetch options to be synchronous
                let options = PHImageRequestOptions()
                options.synchronous = true
                
                // Load image for preview
                if let imageView = vc.imageView {
                    PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize:imageView.frame.size, contentMode: .AspectFit, options: options) { (result, _) in
                        imageView.image = result
                    }
                }
                
                // Setup animation
                expandAnimator.sourceImageView = cell.imageView
                expandAnimator.destinationImageView = vc.imageView
                shrinkAnimator.sourceImageView = vc.imageView
                shrinkAnimator.destinationImageView = cell.imageView
                
                navigationController?.pushViewController(vc, animated: true)
            }
            
            // Re-enable recognizer
            sender.enabled = true
            collectionView?.userInteractionEnabled = true
        }
    }
    
    // MARK: Traits
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if let collectionViewFlowLayout = collectionViewLayout as? UICollectionViewFlowLayout, let collectionViewWidth = collectionView?.bounds.size.width, photosDataSource = photosDataSource {
            let itemSpacing: CGFloat = 1.0
            let cellsPerRow = settings.cellsPerRow(verticalSize: traitCollection.verticalSizeClass, horizontalSize: traitCollection.horizontalSizeClass)
            
            collectionViewFlowLayout.minimumInteritemSpacing = itemSpacing
            collectionViewFlowLayout.minimumLineSpacing = itemSpacing
            
            let width = (collectionViewWidth / CGFloat(cellsPerRow)) - itemSpacing
            let itemSize =  CGSize(width: width, height: width)
            
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
        // Update selected album
        albumsDataSource?.selectObjectAtIndexPath(indexPath)
        
        // Notify photos data source
        if let album = albumsDataSource?.selections().first {
            // Update album title
            albumTitleView.albumTitle = album.localizedTitle
            
            // Pass it on to photos data source
            photosDataSource?.fetchResultsForAsset(album)
        }
        
        // Dismiss album selection
        albumsViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return isVisible && photosDataSource?.selectionCount() < settings.maxNumberOfSelections
    }
    
    override func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return isVisible
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Select asset)
        photosDataSource?.selectObjectAtIndexPath(indexPath)
        
        // Set selection number
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCell, let count = photosDataSource?.selectionCount() {
            if let selectionCharacter = settings.selectionCharacter {
                cell.selectionString = String(selectionCharacter)
            } else {
                cell.selectionString = String(count)
            }
        }
        
        // Update done button
        updateDoneButton()
        
        // Call selection closure
        if let closure = selectionClosure, let asset = photosDataSource?[indexPath.section][indexPath.row] as? PHAsset {
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                closure(asset: asset)
            })
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        // Deselect asset
        photosDataSource?.deselectObjectAtIndexPath(indexPath)
        
        // Update done button
        updateDoneButton()
        
        // Reload selected cells to update their selection number
        if let photosDataSource = photosDataSource {
            UIView.setAnimationsEnabled(false)
            collectionView.reloadItemsAtIndexPaths(photosDataSource.selectedIndexPaths())
            syncSelectionInDataSource(photosDataSource, withCollectionView: collectionView)
            UIView.setAnimationsEnabled(true)
        }
        
        // Call deselection closure
        if let closure = deselectionClosure, let asset = photosDataSource?[indexPath.section][indexPath.row] as? PHAsset {
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                closure(asset: asset)
            })
        }
    }
    
    // MARK: AssetsDelegate
    func didUpdateAssets(sender: AnyObject, incrementalChange: Bool, insert: [NSIndexPath], delete: [NSIndexPath], change: [NSIndexPath]) {
        // May come on a background thread, so dispatch to main
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            // Reload table view or collection view?
            if let sender = sender as? PhotosDataSource {
                if let collectionView = self.collectionView {
                    if incrementalChange {
                        // Update
                        collectionView.deleteItemsAtIndexPaths(delete)
                        collectionView.insertItemsAtIndexPaths(insert)
                        collectionView.reloadItemsAtIndexPaths(change)
                    } else {
                        // Reload & scroll to top if significant change
                        collectionView.reloadData()
                        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: .None, animated: false)
                    }
                    
                    // Sync selection
                    if let photosDataSource = self.photosDataSource {
                        self.syncSelectionInDataSource(photosDataSource, withCollectionView: collectionView)
                    }
                }
            } else if let sender = sender as? AlbumsDataSource {
                if incrementalChange {
                    // Update
                    self.albumsViewController?.tableView?.deleteRowsAtIndexPaths(delete, withRowAnimation: .Automatic)
                    self.albumsViewController?.tableView?.insertRowsAtIndexPaths(insert, withRowAnimation: .Automatic)
                    self.albumsViewController?.tableView?.reloadRowsAtIndexPaths(change, withRowAnimation: .Automatic)
                } else {
                    // Reload
                    self.albumsViewController?.tableView?.reloadData()
                }
            }
        })
    }
    
    // MARK: Private helper methods
    func updateDoneButton() {
        // Get selection count
        if let numberOfSelectedAssets = photosDataSource?.selectionCount() {
            // Find right button
            if let subViews = navigationController?.navigationBar.subviews {
                for view in subViews {
                    if let btn = view as? UIButton where checkIfRightButtonItem(btn) {
                        // Store original title if we havn't got it
                        if doneBarButtonTitle == nil {
                            doneBarButtonTitle = btn.titleForState(.Normal)
                        }
                        
                        // Update title
                        if numberOfSelectedAssets > 0 {
                            btn.bs_setTitleWithoutAnimation("\(doneBarButtonTitle!) (\(numberOfSelectedAssets))", forState: .Normal)
                        } else {
                            btn.bs_setTitleWithoutAnimation(doneBarButtonTitle!, forState: .Normal)
                        }
                        
                        // Stop loop
                        break
                    }
                }
            }
            
            // Enabled
            if numberOfSelectedAssets > 0 {
                doneBarButton.enabled = true
            } else {
                doneBarButton.enabled = false
            }
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
        let indexPaths = dataSource.selectedIndexPaths()
        
        // Loop through them and set them as selected in the collection view
        for indexPath in indexPaths {
            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
    }
    
    // MARK: UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .Push {
            return expandAnimator
        } else {
            return shrinkAnimator
        }
    }
}
