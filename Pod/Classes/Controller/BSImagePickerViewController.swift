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

public final class BSImagePickerViewController : UINavigationController, BSImagePickerSettings {
    private let settings = Settings()
    
    lazy var photosViewController: PhotosViewController = {
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
        
        let controller = storyboard.instantiateInitialViewController() as! PhotosViewController
        controller.settings = self.settings
        
        return controller
    }()
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor.whiteColor()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViewControllerToStatus(PHPhotoLibrary.authorizationStatus())
    }
    
    func updateViewControllerToStatus(status: PHAuthorizationStatus) {
        switch status {
        case .Authorized:
            // We are authorized. Push photos view controller
            viewControllers = []
            pushViewController(self.photosViewController, animated: false)
            
        case .NotDetermined:
            // Ask user for permission
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.updateViewControllerToStatus(status)
                })
            })
        default: ()
        }
    }
    
    // MARK: ImagePickerSettings proxy
    public var maxNumberOfSelections: Int {
        get {
            return settings.maxNumberOfSelections
        }
        set {
            settings.maxNumberOfSelections = newValue
        }
    }
    
    public var selectionCharacter: Character? {
        get {
            return settings.selectionCharacter
        }
        set {
            settings.selectionCharacter = newValue
        }
    }
    
    public var selectionFillColor: UIColor {
        get {
            return settings.selectionFillColor
        }
        set {
            settings.selectionFillColor = newValue
        }
    }
    public var selectionStrokeColor: UIColor {
        get {
            return settings.selectionStrokeColor
        }
        set {
            settings.selectionStrokeColor = newValue
        }
    }
    public var selectionShadowColor: UIColor {
        get {
            return settings.selectionShadowColor
        }
        set {
            settings.selectionShadowColor = newValue
        }
    }
    public var selectionTextAttributes: [NSObject: AnyObject] {
        get {
            return settings.selectionTextAttributes
        }
        set {
            settings.selectionTextAttributes = newValue
        }
    }
    public var cellsPerRow: (verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int {
        get {
            return settings.cellsPerRow
        }
        set {
            settings.cellsPerRow = newValue
        }
    }
    
    // MARK: Buttons
    public var cancelButton: UIBarButtonItem {
        get {
            return photosViewController.cancelBarButton
        }
    }
    
    public var doneButton: UIBarButtonItem {
        get {
            return photosViewController.doneBarButton
        }
    }
    
    public var albumButton: UIButton {
        get {
            return photosViewController.albumTitleView.albumButton
        }
    }
    
    // MARK: Closures
    var selectionClosure: ((asset: PHAsset) -> Void)? {
        get {
            return photosViewController.selectionClosure
        }
        set {
            photosViewController.selectionClosure = newValue
        }
    }
    var deselectionClosure: ((asset: PHAsset) -> Void)? {
        get {
            return photosViewController.deselectionClosure
        }
        set {
            photosViewController.deselectionClosure = newValue
        }
    }
    var cancelClosure: ((assets: [PHAsset]) -> Void)? {
        get {
            return photosViewController.cancelClosure
        }
        set {
            photosViewController.cancelClosure = newValue
        }
    }
    var finishClosure: ((assets: [PHAsset]) -> Void)? {
        get {
            return photosViewController.finishClosure
        }
        set {
            photosViewController.finishClosure = newValue
        }
    }
}
