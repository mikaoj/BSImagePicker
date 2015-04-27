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
    
    private let photosModel: PhotosModel
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        photosModel = PhotosModel()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        photosModel = PhotosModel()
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
        collectionView?.dataSource = photosModel
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelButtonPressed:")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed:")
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
}
