//
//  PhotosViewController.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-04-26.
//
//

import UIKit
import Photos

class PhotosViewController : UICollectionViewController, UIPopoverPresentationControllerDelegate {
    internal var selectionClosure: ((asset: PHAsset) -> Void)?
    internal var deselectionClosure: ((asset: PHAsset) -> Void)?
    internal var cancelClosure: ((assets: [PHAsset]) -> Void)?
    internal var finishClosure: ((assets: [PHAsset]) -> Void)?
    
    private let photosDataSource = PhotosDataSource()
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
        return self.bundle?.loadNibNamed("AlbumTitleView", owner: self, options: nil).first as? AlbumTitleView
    }()
    
    private lazy var albumsViewController: AlbumsViewController? = {
        let storyboard = UIStoryboard(name: "Albums", bundle: self.bundle)
        
        let vc = storyboard.instantiateInitialViewController() as? AlbumsViewController
        vc?.modalPresentationStyle = .Popover
        vc?.preferredContentSize = CGSize(width: 300, height: 300)
        
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
        collectionView?.dataSource = photosDataSource
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelButtonPressed:")
        navigationItem.rightBarButtonItem = doneBarButton
        
        albumTitleView?.albumTitle = "Hejsan"
        albumTitleView?.albumButton.addTarget(self, action: "albumButtonPressed:", forControlEvents: .TouchUpInside)
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
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
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
