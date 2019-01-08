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
import BSGridCollectionViewLayout

final class PhotosViewController : UICollectionViewController {    
    var selectionClosure: ((_ asset: PHAsset) -> Void)?
    var deselectionClosure: ((_ asset: PHAsset) -> Void)?
    var cancelClosure: ((_ assets: [PHAsset]) -> Void)?
    var finishClosure: ((_ assets: [PHAsset]) -> Void)?
    var selectLimitReachedClosure: ((_ selectionLimit: Int) -> Void)?
    
    var doneBarButton: UIBarButtonItem?
    var cancelBarButton: UIBarButtonItem?
    var albumTitleView: UIButton?
    
    let expandAnimator = ZoomAnimator()
    let shrinkAnimator = ZoomAnimator()
    
    private var photosDataSource: PhotoCollectionViewDataSource?
    private var albumsDataSource: AlbumTableViewDataSource
    private let cameraDataSource: CameraCollectionViewDataSource
    private var composedDataSource: ComposedCollectionViewDataSource?
    private var assetStore: AssetStore
    
    let settings: BSImagePickerSettings
    
    private let doneBarButtonTitle: String = NSLocalizedString("Done", comment: "Done")
    
    lazy var albumsViewController: AlbumsViewController = {
        let vc = AlbumsViewController()
        vc.tableView.dataSource = self.albumsDataSource
        vc.tableView.delegate = self
        
        return vc
    }()
    
    private lazy var previewViewContoller: PreviewViewController? = {
        return PreviewViewController(nibName: nil, bundle: nil)
    }()
    
    required init(fetchResults: [PHFetchResult<PHAssetCollection>], assetStore: AssetStore, settings aSettings: BSImagePickerSettings) {
        albumsDataSource = AlbumTableViewDataSource(fetchResults: fetchResults)
        cameraDataSource = CameraCollectionViewDataSource(settings: aSettings, cameraAvailable: UIImagePickerController.isSourceTypeAvailable(.camera))
        settings = aSettings
        self.assetStore = assetStore
        
        super.init(collectionViewLayout: GridCollectionViewLayout())
        
        PHPhotoLibrary.shared().register(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("b0rk: initWithCoder not implemented")
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func loadView() {
        super.loadView()
        
        // Setup collection view
        collectionView?.backgroundColor = settings.backgroundColor
        collectionView?.allowsMultipleSelection = true
        
        // Set an empty title to get < back button
        title = " "
        
        // Set button actions and add them to navigation item
        doneBarButton?.target = self
        doneBarButton?.action = #selector(PhotosViewController.doneButtonPressed(_:))
        cancelBarButton?.target = self
        cancelBarButton?.action = #selector(PhotosViewController.cancelButtonPressed(_:))
        albumTitleView?.addTarget(self, action: #selector(PhotosViewController.albumButtonPressed(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.titleView = albumTitleView

        if let album = albumsDataSource.fetchResults.first?.firstObject {
            initializePhotosDataSource(album)
            updateAlbumTitle(album)
            collectionView?.reloadData()
        }
        
        // Add long press recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(PhotosViewController.collectionViewLongPressed(_:)))
        longPressRecognizer.minimumPressDuration = 0.5
        collectionView?.addGestureRecognizer(longPressRecognizer)
        
        // Set navigation controller delegate
        navigationController?.delegate = self
        
        // Register cells
        photosDataSource?.registerCellIdentifiersForCollectionView(collectionView)
        cameraDataSource.registerCellIdentifiersForCollectionView(collectionView)
    }
    
    // MARK: Appear/Disappear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDoneButton()
    }
    
    // MARK: Button actions
    @objc func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        cancelClosure?(assetStore.assets)
    }
    
    @objc func doneButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        finishClosure?(assetStore.assets)
    }
    
    @objc func albumButtonPressed(_ sender: UIButton) {
        guard let popVC = albumsViewController.popoverPresentationController else {
            return
        }
        
        popVC.permittedArrowDirections = .up
        popVC.sourceView = sender
        let senderRect = sender.convert(sender.frame, from: sender.superview)
        let sourceRect = CGRect(x: senderRect.origin.x, y: senderRect.origin.y + (sender.frame.size.height / 2), width: senderRect.size.width, height: senderRect.size.height)
        popVC.sourceRect = sourceRect
        popVC.delegate = self
        albumsViewController.tableView.reloadData()
        
        present(albumsViewController, animated: true, completion: nil)
    }
    
    @objc func collectionViewLongPressed(_ sender: UIGestureRecognizer) {
        if sender.state == .began {
            // Disable recognizer while we are figuring out location and pushing preview
            sender.isEnabled = false
            collectionView?.isUserInteractionEnabled = false
            
            // Calculate which index path long press came from
            let location = sender.location(in: collectionView)
            let indexPath = collectionView?.indexPathForItem(at: location)
            
            if let vc = previewViewContoller, let indexPath = indexPath, let cell = collectionView?.cellForItem(at: indexPath) as? PhotoCell, let asset = cell.asset {
                // Setup fetch options to be synchronous
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                // Load image for preview
                if let imageView = vc.imageView {
                    PHCachingImageManager.default().requestImage(for: asset, targetSize:imageView.frame.size, contentMode: .aspectFit, options: options) { (result, _) in
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
            
            // Re-enable recognizer, after animation is done
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(expandAnimator.transitionDuration(using: nil) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { () -> Void in
                sender.isEnabled = true
                self.collectionView?.isUserInteractionEnabled = true
            })
        }
    }
    
    // MARK: Private helper methods
    func updateDoneButton() {
        if assetStore.assets.count > 0 {
            doneBarButton = UIBarButtonItem(title: "\(doneBarButtonTitle) (\(assetStore.count))", style: .done, target: doneBarButton?.target, action: doneBarButton?.action)
        } else {
            doneBarButton = UIBarButtonItem(title: doneBarButtonTitle, style: .done, target: doneBarButton?.target, action: doneBarButton?.action)
        }

        // Enabled?
        doneBarButton?.isEnabled = assetStore.assets.count > 0

        navigationItem.rightBarButtonItem = doneBarButton
    }

    func updateAlbumTitle(_ album: PHAssetCollection) {
        guard let title = album.localizedTitle else { return }
        // Update album title
        albumTitleView?.setAlbumTitle(title)
    }
    
  func initializePhotosDataSource(_ album: PHAssetCollection) {
        // Set up a photo data source with album
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        initializePhotosDataSourceWithFetchResult(PHAsset.fetchAssets(in: album, options: fetchOptions))
    }
    
    func initializePhotosDataSourceWithFetchResult(_ fetchResult: PHFetchResult<PHAsset>) {
        let newDataSource = PhotoCollectionViewDataSource(fetchResult: fetchResult, assetStore: assetStore, settings: settings)
        
        // Transfer image size
        // TODO: Move image size to settings
        if let photosDataSource = photosDataSource {
            newDataSource.imageSize = photosDataSource.imageSize
        }
        
        photosDataSource = newDataSource
        
        // Hook up data source
        composedDataSource = ComposedCollectionViewDataSource(dataSources: [cameraDataSource, newDataSource])
        collectionView?.dataSource = composedDataSource
        collectionView?.delegate = self
    }
}

// MARK: UICollectionViewDelegate
extension PhotosViewController {
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // NOTE: ALWAYS return false. We don't want the collectionView to be the source of thruth regarding selections
        // We can manage it ourself.

        // Camera shouldn't be selected, but pop the UIImagePickerController!
        if let composedDataSource = composedDataSource , composedDataSource.dataSources[indexPath.section].isEqual(cameraDataSource) {
            let cameraController = UIImagePickerController()
            cameraController.allowsEditing = false
            cameraController.sourceType = .camera
            cameraController.delegate = self
            
            self.present(cameraController, animated: true, completion: nil)
            
            return false
        }

        // Make sure we have a data source and that we can make selections
        guard let photosDataSource = photosDataSource, collectionView.isUserInteractionEnabled else { return false }

        // We need a cell
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell else { return false }
        let asset = photosDataSource.fetchResult.object(at: indexPath.row)

        // Select or deselect?
        if assetStore.contains(asset) { // Deselect
            // Deselect asset
            assetStore.remove(asset)

            // Update done button
            updateDoneButton()

            // Get indexPaths of selected items
            let selectedIndexPaths = assetStore.assets.compactMap({ (asset) -> IndexPath? in
                let index = photosDataSource.fetchResult.index(of: asset)
                guard index != NSNotFound else { return nil }
                return IndexPath(item: index, section: 1)
            })

            // Reload selected cells to update their selection number
            UIView.setAnimationsEnabled(false)
            collectionView.reloadItems(at: selectedIndexPaths)
            UIView.setAnimationsEnabled(true)

            cell.photoSelected = false

            // Call deselection closure
            deselectionClosure?(asset)
        } else if assetStore.count < settings.maxNumberOfSelections { // Select
            // Select asset if not already selected
            assetStore.append(asset)

            // Set selection number
            if let selectionCharacter = settings.selectionCharacter {
                cell.selectionString = String(selectionCharacter)
            } else {
                cell.selectionString = String(assetStore.count)
            }

            cell.photoSelected = true

            // Update done button
            updateDoneButton()

            // Call selection closure
            selectionClosure?(asset)
        } else if assetStore.count >= settings.maxNumberOfSelections {
            selectLimitReachedClosure?(assetStore.count)
        }

        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CameraCell else {
            return
        }
        
        cell.startLiveBackground() // Start live background
    }
}

// MARK: UIPopoverPresentationControllerDelegate
extension PhotosViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}
// MARK: UINavigationControllerDelegate
extension PhotosViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return expandAnimator
        } else {
            return shrinkAnimator
        }
    }
}

// MARK: UITableViewDelegate
extension PhotosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Update photos data source
        let album = albumsDataSource.fetchResults[indexPath.section][indexPath.row]
        initializePhotosDataSource(album)
        updateAlbumTitle(album)
        collectionView?.reloadData()
        
        // Dismiss album selection
        albumsViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: Traits
extension PhotosViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if let collectionViewFlowLayout = collectionViewLayout as? GridCollectionViewLayout {
            let itemSpacing: CGFloat = 2.0
            let cellsPerRow = settings.cellsPerRow(traitCollection.verticalSizeClass, traitCollection.horizontalSizeClass)
            
            collectionViewFlowLayout.itemSpacing = itemSpacing
            collectionViewFlowLayout.itemsPerRow = cellsPerRow
            
            photosDataSource?.imageSize = collectionViewFlowLayout.itemSize
            
            updateDoneButton()
        }
    }
}

// MARK: UIImagePickerControllerDelegate
extension PhotosViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            placeholder = request.placeholderForCreatedAsset
            }, completionHandler: { success, error in
                guard let placeholder = placeholder, let asset = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil).firstObject, success == true else {
                    picker.dismiss(animated: true, completion: nil)
                    return
                }
                
                DispatchQueue.main.async {
                    // TODO: move to a function. this is duplicated in didSelect
                    self.assetStore.append(asset)
                    self.updateDoneButton()
                    
                    // Call selection closure
                    self.selectionClosure?(asset)
                    
                    picker.dismiss(animated: true, completion: nil)
                }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension PhotosViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let photosDataSource = photosDataSource, let collectionView = collectionView else {
            return
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            if let photosChanges = changeInstance.changeDetails(for: photosDataSource.fetchResult as! PHFetchResult<PHObject>) {
                // Update collection view
                // Alright...we get spammed with change notifications, even when there are none. So guard against it
                let removedCount = photosChanges.removedIndexes?.count ?? 0
                let insertedCount = photosChanges.insertedIndexes?.count ?? 0
                let changedCount = photosChanges.changedIndexes?.count ?? 0
                if photosChanges.hasIncrementalChanges && (removedCount > 0 || insertedCount > 0 || changedCount > 0) {
                    // Update fetch result
                    photosDataSource.fetchResult = photosChanges.fetchResultAfterChanges as! PHFetchResult<PHAsset>
                    
                    collectionView.performBatchUpdates({
                        if let removed = photosChanges.removedIndexes {
                            collectionView.deleteItems(at: removed.bs_indexPathsForSection(1))
                        }
                        
                        if let inserted = photosChanges.insertedIndexes {
                            collectionView.insertItems(at: inserted.bs_indexPathsForSection(1))
                        }
                        
                        if let changed = photosChanges.changedIndexes {
                            collectionView.reloadItems(at: changed.bs_indexPathsForSection(1))
                        }
                    })
                    
                    // Changes is causing issues right now...fix me later
                    // Example of issue:
                    // 1. Take a new photo
                    // 2. We will get a change telling to insert that asset
                    // 3. While it's being inserted we get a bunch of change request for that same asset
                    // 4. It flickers when reloading it while being inserted
                    // TODO: FIX
                    //                    if let changed = photosChanges.changedIndexes {
                    //                        print("changed")
                    //                        collectionView.reloadItemsAtIndexPaths(changed.bs_indexPathsForSection(1))
                    //                    }
                } else if photosChanges.hasIncrementalChanges == false {
                    // Update fetch result
                    photosDataSource.fetchResult = photosChanges.fetchResultAfterChanges as! PHFetchResult<PHAsset>
                    
                    // Reload view
                    collectionView.reloadData()
                }
            }
        })
        
        
        // TODO: Changes in albums
    }
}
