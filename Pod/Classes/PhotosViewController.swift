//
//  PhotosViewController.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-04-26.
//
//

import UIKit
import Photos

class PhotosViewController : UICollectionViewController {
    internal var selectionClosure: ((asset: PHAsset) -> Void)?
    internal var deselectionClosure: ((asset: PHAsset) -> Void)?
    internal var cancelClosure: ((assets: [PHAsset]) -> Void)?
    internal var finishClosure: ((assets: [PHAsset]) -> Void)?
    
    private let photosDataSource = PhotosDataSource()
    private lazy var doneBarButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed:")
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
