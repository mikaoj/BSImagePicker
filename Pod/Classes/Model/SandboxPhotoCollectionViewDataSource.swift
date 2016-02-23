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
 Gives UICollectionViewDataSource functionality with a given data source and cell factory
 */
final class SandboxPhotoCollectionViewDataSource : NSObject, UICollectionViewDataSource {

    var selectionsImage = [UIImage]()
    var sandboxImage = [UIImage]()
    
    private let photoCellIdentifier = "photoCellIdentifier"
    
    let settings: BSImagePickerSettings?
    
    let matchingImage : ((obj:AnyObject, image:UIImage) -> Bool) = { obj, image in
        if let obj = obj as? UIImage where obj == image {
            return true
        }
        return false
    }
    
    init(settings: BSImagePickerSettings?) {
        self.settings = settings
        super.init()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sandboxImage.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        UIView.setAnimationsEnabled(false)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoCellIdentifier, forIndexPath: indexPath) as! PhotoCell
        if let settings = settings {
            cell.settings = settings
        }

        let img = sandboxImage[indexPath.row]
        
        cell.image = img
        cell.imageView.image = img
        
        // Set selection number
        if let index = bs_selectedObjects.indexOf({matchingImage(obj: $0, image: img)}) {
            if let character = settings?.selectionCharacter {
                cell.selectionString = String(character)
            } else {
                cell.selectionString = String(index+1)
            }
            
            cell.selected = true
        } else {
            cell.selected = false
        }
        
        UIView.setAnimationsEnabled(true)
        
        return cell
    }
    
    func registerCellIdentifiersForCollectionView(collectionView: UICollectionView?) {
        collectionView?.registerNib(UINib(nibName: "PhotoCell", bundle: BSImagePickerViewController.bundle), forCellWithReuseIdentifier: photoCellIdentifier)
    }
}