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

final class PhotosViewController : UICollectionViewController, SelectableDataDelegate {
    var selectionClosure: ((asset: PHAsset) -> Void)?
    var deselectionClosure: ((asset: PHAsset) -> Void)?
    var cancelClosure: ((assets: [PHAsset]) -> Void)?
    var finishClosure: ((assets: [PHAsset]) -> Void)?
    
    var doneBarButton: UIBarButtonItem?
    var cancelBarButton: UIBarButtonItem?
    var albumTitleView: AlbumTitleView?
    
    let expandAnimator = ZoomAnimator()
    let shrinkAnimator = ZoomAnimator()
    
    private var photosDataSource: PhotoCollectionViewDataSource?
    private var albumsDataSource: AlbumTableViewDataSource
    private let cameraDataSource = CameraCollectionViewDataSource()
    private var composedDataSource: ComposedCollectionViewDataSource?
    
    let settings: BSImagePickerSettings
    
    private var doneBarButtonTitle: String?
    
    lazy var albumsViewController: AlbumsViewController = {
        let storyboard = UIStoryboard(name: "Albums", bundle: BSImagePickerViewController.bundle)
        let vc = storyboard.instantiateInitialViewController() as! AlbumsViewController
        vc.tableView.dataSource = self.albumsDataSource
        vc.tableView.delegate = self
        
        return vc
    }()
    
    private lazy var previewViewContoller: PreviewViewController? = {
        return PreviewViewController(nibName: nil, bundle: nil)
    }()
    
    required init(dataSource: SelectableDataSource, settings aSettings: BSImagePickerSettings, selections: [PHAsset] = []) {
        albumsDataSource = AlbumTableViewDataSource(dataSource: dataSource)
        settings = aSettings
        
        super.init(collectionViewLayout: NoSectionBreakCollectionViewLayout())
        
        albumsDataSource.data.delegate = self
        
        // Default is to have first album selected
        albumsDataSource.data.selectObjectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        
        if let album = albumsDataSource.data.selections.first as? PHAssetCollection {
            initializePhotosDataSource(album)
            photosDataSource?.data.selections = selections
        }
    }

    required init?(coder aDecoder: NSCoder) {
        albumsDataSource = AlbumTableViewDataSource(dataSource: FetchResultsSelectableDataSource(fetchResults: []))
        albumsDataSource.data.allowsMultipleSelection = false
        settings = Settings()
        
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
        
        // Setup collection view
        // TODO: Settings
        collectionView?.backgroundColor = UIColor.whiteColor()
        photosDataSource?.registerCellIdentifiersForCollectionView(collectionView)
        cameraDataSource.registerCellIdentifiersForCollectionView(collectionView)
        
        // Set an empty title to get < back button
        title = " "
        
        // Set button actions and add them to navigation item
        doneBarButton?.target = self
        doneBarButton?.action = Selector("doneButtonPressed:")
        cancelBarButton?.target = self
        cancelBarButton?.action = Selector("cancelButtonPressed:")
        albumTitleView?.albumButton.addTarget(self, action: Selector("albumButtonPressed:"), forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.titleView = albumTitleView

        if let album = albumsDataSource.data.selections.first as? PHAssetCollection {
            updateAlbumTitle(album)
            synchronizeCollectionView()
        }
        
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
    
    // MARK: Button actions
    func cancelButtonPressed(sender: UIBarButtonItem) {
        guard let closure = cancelClosure, let assets = photosDataSource?.data.selections as? [PHAsset] else {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
            closure(assets: assets)
        })
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneButtonPressed(sender: UIBarButtonItem) {
        guard let closure = finishClosure, let assets = photosDataSource?.data.selections as? [PHAsset] else {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
            closure(assets: assets)
        })
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func albumButtonPressed(sender: UIButton) {
        guard let popVC = albumsViewController.popoverPresentationController else {
            return
        }
        
        popVC.permittedArrowDirections = .Up
        popVC.sourceView = sender
        let senderRect = sender.convertRect(sender.frame, fromView: sender.superview)
        let sourceRect = CGRect(x: senderRect.origin.x, y: senderRect.origin.y + (sender.frame.size.height / 2), width: senderRect.size.width, height: senderRect.size.height)
        popVC.sourceRect = sourceRect
        popVC.delegate = self
        albumsViewController.tableView.reloadData()
        
        presentViewController(albumsViewController, animated: true, completion: nil)
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
    
    // MARK: Selectable data delegate
    func didUpdateData(sender: SelectableDataSource, incrementalChange: Bool, insertions insert: [NSIndexPath], deletions delete: [NSIndexPath], changes change: [NSIndexPath]) {
        // May come on a background thread, so dispatch to main
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            // Reload table view or collection view?
            if sender.isEqual(self.photosDataSource?.data)  {
                guard let collectionView = self.collectionView else {
                    return
                }
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
                    self.syncSelectionInDataSource(photosDataSource.data, withCollectionView: collectionView)
                }
            } else if sender.isEqual(self.albumsDataSource.data) {
                if incrementalChange {
                    // Update
                    self.albumsViewController.tableView?.deleteRowsAtIndexPaths(delete, withRowAnimation: .Automatic)
                    self.albumsViewController.tableView?.insertRowsAtIndexPaths(insert, withRowAnimation: .Automatic)
                    self.albumsViewController.tableView?.reloadRowsAtIndexPaths(change, withRowAnimation: .Automatic)
                } else {
                    // Reload
                    self.albumsViewController.tableView?.reloadData()
                }
            }
        })
    }
    
    // MARK: Private helper methods
    func updateDoneButton() {
        // Get selection count
        if let numberOfSelectedAssets = photosDataSource?.data.selections.count {
            // Find right button
            if let subViews = navigationController?.navigationBar.subviews {
                for view in subViews {
                    if let btn = view as? UIButton where checkIfRightButtonItem(btn) {
                        // Store original title if we havn't got it
                        if doneBarButtonTitle == nil {
                            doneBarButtonTitle = btn.titleForState(.Normal)
                        }
                        
                        if let doneBarButtonTitle = doneBarButtonTitle {
                            // Update title
                            if numberOfSelectedAssets > 0 {
                                btn.bs_setTitleWithoutAnimation("\(doneBarButtonTitle) (\(numberOfSelectedAssets))", forState: .Normal)
                            } else {
                                btn.bs_setTitleWithoutAnimation(doneBarButtonTitle, forState: .Normal)
                            }
                        }
                        
                        // Stop loop
                        break
                    }
                }
            }
            
            // Enabled
            if numberOfSelectedAssets > 0 {
                doneBarButton?.enabled = true
            } else {
                doneBarButton?.enabled = false
            }
        }
    }
    
    // Check if a give UIButton is the right UIBarButtonItem in the navigation bar
    // Somewhere along the road, our UIBarButtonItem gets transformed to an UINavigationButton
    func checkIfRightButtonItem(btn: UIButton) -> Bool {
        guard let rightButton = navigationItem.rightBarButtonItem else {
            return false
        }
        
        // Store previous values
        let wasRightEnabled = rightButton.enabled
        let wasButtonEnabled = btn.enabled
        
        // Set a known state for both buttons
        rightButton.enabled = false
        btn.enabled = false
        
        // Change one and see if other also changes
        rightButton.enabled = true
        let isRightButton = btn.enabled
        
        // Reset
        rightButton.enabled = wasRightEnabled
        btn.enabled = wasButtonEnabled
        
        return isRightButton
    }
    
    func syncSelectionInDataSource(dataSource: SelectableDataSource, withCollectionView collectionView: UICollectionView) {
        // Get indexpaths of selected assets
        let indexPaths = dataSource.selectedIndexPaths
        
        // Loop through them and set them as selected in the collection view
        for indexPath in indexPaths {
            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
    }
    
    func updateAlbumTitle(album: PHAssetCollection) {
        if let title = album.localizedTitle {
            // Update album title
            albumTitleView?.albumTitle = title
        }
    }
    
    func initializePhotosDataSource(album: PHAssetCollection) {
        // Set up a photo data source with album
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
        let dataSource = FetchResultsSelectableDataSource(fetchResult: PHAsset.fetchAssetsInAssetCollection(album, options: fetchOptions))
        let newDataSource = PhotoCollectionViewDataSource(dataSource: dataSource, settings: settings)
        
        // Keep selection
        if let photosDataSource = photosDataSource {
            newDataSource.data.selections = photosDataSource.data.selections
        }
        
        photosDataSource = newDataSource
    }
    
    func synchronizeCollectionView() {
        guard let photosDataSource = photosDataSource else {
            return
        }
        
        // Hook up data source
        composedDataSource = ComposedCollectionViewDataSource(dataSources: [cameraDataSource, photosDataSource])
        collectionView?.dataSource = composedDataSource
        collectionView?.delegate = self
        photosDataSource.data.delegate = self
        
        // Enable multiple selection
        photosDataSource.data.allowsMultipleSelection = true
        collectionView?.allowsMultipleSelection = true
        
        // Reload and sync selections
        collectionView?.reloadData()
        syncSelectionInDataSource(photosDataSource.data, withCollectionView: collectionView!)
    }
}

// MARK: UICollectionViewDelegate
extension PhotosViewController {
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard let composedDataSource = composedDataSource where composedDataSource.dataSources[indexPath.section].isEqual(photosDataSource) else {
            return true
        }
        
        return photosDataSource?.data.selections.count < settings.maxNumberOfSelections
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCell, let count = photosDataSource?.data.selections.count else {
            return
        }
        
        // Select asset)
        let correctedIndexPath = NSIndexPath(forItem: indexPath.row, inSection: 0)
        photosDataSource?.data.selectObjectAtIndexPath(correctedIndexPath)
        
        // Set selection number
        if let selectionCharacter = settings.selectionCharacter {
            cell.selectionString = String(selectionCharacter)
        } else {
            cell.selectionString = String(count+1)
        }
        
        // Update done button
        updateDoneButton()
        
        // Call selection closure
        if let closure = selectionClosure, let asset = photosDataSource?.data.objectAtIndexPath(correctedIndexPath) as? PHAsset {
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                closure(asset: asset)
            })
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let correctedIndexPath = NSIndexPath(forItem: indexPath.row, inSection: 0)
        
        // Deselect asset
        photosDataSource?.data.deselectObjectAtIndexPath(correctedIndexPath)
        
        // Update done button
        updateDoneButton()
        
        // Reload selected cells to update their selection number
        if let photosDataSource = photosDataSource {
            UIView.setAnimationsEnabled(false)
            collectionView.reloadItemsAtIndexPaths(photosDataSource.data.selectedIndexPaths)
            syncSelectionInDataSource(photosDataSource.data, withCollectionView: collectionView)
            UIView.setAnimationsEnabled(true)
        }
        
        // Call deselection closure
        if let closure = deselectionClosure, let asset = photosDataSource?.data.objectAtIndexPath(correctedIndexPath) as? PHAsset {
            dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
                closure(asset: asset)
            })
        }
    }
}

// MARK: UIPopoverPresentationControllerDelegate
extension PhotosViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

// MARK: UINavigationControllerDelegate
extension PhotosViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .Push {
            return expandAnimator
        } else {
            return shrinkAnimator
        }
    }
}

// MARK: UITableViewDelegate
extension PhotosViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Update selected album
        albumsDataSource.data.selectObjectAtIndexPath(indexPath)
        
        // Notify photos data source
        if let album = albumsDataSource.data.selections.first as? PHAssetCollection {
            initializePhotosDataSource(album)
            updateAlbumTitle(album)
            synchronizeCollectionView()
        }
        
        // Dismiss album selection
        albumsViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: Traits
extension PhotosViewController {
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if let collectionViewFlowLayout = collectionViewLayout as? NoSectionBreakCollectionViewLayout, let collectionViewWidth = collectionView?.bounds.size.width {
            let itemSpacing: CGFloat = 1.0
            let cellsPerRow = settings.cellsPerRow(verticalSize: traitCollection.verticalSizeClass, horizontalSize: traitCollection.horizontalSizeClass)
            
            collectionViewFlowLayout.minimumInteritemSpacing = itemSpacing
            collectionViewFlowLayout.minimumLineSpacing = itemSpacing
            collectionViewFlowLayout.cellsPerRow = cellsPerRow
            
            let width = (collectionViewWidth / CGFloat(cellsPerRow)) - itemSpacing
            let itemSize =  CGSize(width: width, height: width)
            
            collectionViewFlowLayout.itemSize = itemSize
            photosDataSource?.imageSize = itemSize
        }
    }
}

// MARK: UIImagePickerControllerDelegate
extension PhotosViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
