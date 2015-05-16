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

public class ImagePickerViewController : UINavigationController {
    internal var selectionClosure: ((asset: PHAsset) -> Void)? {
        set {
            photosViewController.selectionClosure = newValue
        }
        get {
            return photosViewController.selectionClosure
        }
    }
    internal var deselectionClosure: ((asset: PHAsset) -> Void)? {
        set {
            photosViewController.deselectionClosure = newValue
        }
        get {
            return photosViewController.deselectionClosure
        }
    }
    internal var cancelClosure: ((assets: [PHAsset]) -> Void)? {
        set {
            photosViewController.cancelClosure = newValue
        }
        get {
            return photosViewController.cancelClosure
        }
    }
    internal var finishClosure: ((assets: [PHAsset]) -> Void)? {
        set {
            photosViewController.finishClosure = newValue
        }
        get {
            return photosViewController.finishClosure
        }
    }
    
    internal lazy var photosViewController: PhotosViewController = {
        // Get path for BSImagePicker bundle
        let bundlePath = NSBundle(forClass: PhotosViewController.self).pathForResource("BSImagePicker", ofType: "bundle")
        let bundle: NSBundle?
        
        // Load bundle
        if let bundlePath = bundlePath {
            bundle = NSBundle(path: bundlePath)
        } else {
            bundle = nil
        }
        
        let storyboard = UIStoryboard(name: "Photos", bundle: bundle)
        
        return storyboard.instantiateInitialViewController() as! PhotosViewController
    }()
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.viewControllers = [photosViewController]
    }
}