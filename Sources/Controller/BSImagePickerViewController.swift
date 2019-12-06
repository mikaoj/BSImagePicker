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
BSImagePickerViewController.
Use settings or buttons to customize it to your needs.
*/
open class BSImagePickerViewController : UINavigationController {
    /**
     Object that keeps settings for the picker.
     */
    open var settings: BSImagePickerSettings = Settings()
    
    /**
     Done button.
     */
    @objc open var doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    
    /**
     Cancel button
     */
    @objc open var cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    
    /**
     Default selections
     */
    @objc open var defaultSelections: PHFetchResult<PHAsset>?
    
    /**
     Fetch results.
     */
    
    @objc open lazy var fetchResults: [PHFetchResult] = { () -> [PHFetchResult<PHAssetCollection>] in
        let fetchOptions = PHFetchOptions()
        
        // Camera roll fetch result
        let cameraRollResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: fetchOptions)
        
        // Smart Albums result
        let customFetchOptions = PHFetchOptions()
        customFetchOptions.includeHiddenAssets = false
        customFetchOptions.includeAllBurstAssets = false
        let cameraAlbumsResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: customFetchOptions)
        
        // Albums fetch result
        let albumResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        return [cameraRollResult, cameraAlbumsResult, albumResult]
    }()
    
    @objc var albumTitleView: UIButton = {

        // .custom type used to avoid sizing animation uglyness when changing the title
        let btn = UIButton(type: .custom)

        // Positions the image to the right
        btn.semanticContentAttribute = .forceRightToLeft

        // Padding between the title and image
        let titleImageGap: CGFloat = 6.0
        btn.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -titleImageGap, bottom: 0.0, right: titleImageGap)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: titleImageGap, bottom: 0.0, right: 0.0)

        let image = UIImage(named: "arrow_down", in: BSImagePickerViewController.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)

        btn.setTitleColor(btn.tintColor, for: .normal)

        // Font size specified to match the default font size for a UIButton with .system type
        btn.titleLabel?.font = .systemFont(ofSize: 15.0)
        return btn
    }()
    
    static var bundle: Bundle {
        if let path = Bundle(for: PhotosViewController.self).path(forResource: "BSImagePicker", ofType: "bundle"), let b = Bundle(path: path) {
            return b
        } else {
            return Bundle(for: PhotosViewController.self)
        }
    }
    
    @objc lazy var photosViewController: PhotosViewController = {
        var selections: [PHAsset] = []
        defaultSelections?.enumerateObjects({ (asset, idx, stop) in
            selections.append(asset)
        })

        let assetStore = AssetStore(assets: selections)
        let vc = PhotosViewController(fetchResults: self.fetchResults,
                                      assetStore: assetStore,
                                      settings: self.settings)
        
        vc.doneBarButton = self.doneButton
        vc.cancelBarButton = self.cancelButton
        vc.albumTitleView = self.albumTitleView
        
        return vc
    }()
    
    @objc class func authorize(_ status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(), fromViewController: UIViewController, completion: @escaping (_ authorized: Bool) -> Void) {
        switch status {
        case .authorized:
            // We are authorized. Run block
            completion(true)
        case .notDetermined:
            // Ask user for permission
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.authorize(status, fromViewController: fromViewController, completion: completion)
                })
            })
        default: ()
            DispatchQueue.main.async(execute: { () -> Void in
                completion(false)
            })
        }
    }
    
    /**
    Sets up an classic image picker with results from camera roll and albums
    */
    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    /**
    https://www.youtube.com/watch?v=dQw4w9WgXcQ
    */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
    Load view. See apple documentation
    */
    open override func loadView() {
        super.loadView()
        
        // TODO: Settings
        view.backgroundColor = UIColor.white
        
        // Make sure we really are authorized
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            setViewControllers([photosViewController], animated: false)
        }
    }
}

// MARK: ImagePickerSettings proxy
extension BSImagePickerViewController: BSImagePickerSettings {


    /**
     See BSImagePicketSettings for documentation
     */
    @objc public var maxNumberOfSelections: Int {
        get {
            return settings.maxNumberOfSelections
        }
        set {
            settings.maxNumberOfSelections = newValue
        }
    }
    
    /**
     See BSImagePicketSettings for documentation
     */
    public var selectionCharacter: Character? {
        get {
            return settings.selectionCharacter
        }
        set {
            settings.selectionCharacter = newValue
        }
    }
    
    /**
     See BSImagePicketSettings for documentation
     */
    @objc public var selectionFillColor: UIColor {
        get {
            return settings.selectionFillColor
        }
        set {
            settings.selectionFillColor = newValue
        }
    }
    
    /**
     See BSImagePicketSettings for documentation
     */
    @objc public var selectionStrokeColor: UIColor {
        get {
            return settings.selectionStrokeColor
        }
        set {
            settings.selectionStrokeColor = newValue
        }
    }
    
    /**
     See BSImagePicketSettings for documentation
     */
    @objc public var selectionShadowColor: UIColor {
        get {
            return settings.selectionShadowColor
        }
        set {
            settings.selectionShadowColor = newValue
        }
    }
    
    /**
     See BSImagePicketSettings for documentation
     */
    @objc public var selectionTextAttributes: [NSAttributedString.Key: AnyObject] {
        get {
            return settings.selectionTextAttributes
        }
        set {
            settings.selectionTextAttributes = newValue
        }
    }
    
    /**
     BackgroundColor
     */
    @objc public var backgroundColor: UIColor {
        get {
            return settings.backgroundColor
        }
        set {
            settings.backgroundColor = newValue
        }
    }
    
    /**
     See BSImagePicketSettings for documentation
     */
    @objc public var cellsPerRow: (_ verticalSize: UIUserInterfaceSizeClass, _ horizontalSize: UIUserInterfaceSizeClass) -> Int {
        get {
            return settings.cellsPerRow
        }
        set {
            settings.cellsPerRow = newValue
        }
    }
    
    /**
     See BSImagePicketSettings for documentation
     */
    @objc public var takePhotos: Bool {
        get {
            return settings.takePhotos
        }
        set {
            settings.takePhotos = newValue
        }
    }
    
    /**
     Toggle select videos
     */
    @objc public var enableVideos: Bool {
        get {
            return settings.enableVideos
        }
        set {
            settings.enableVideos = newValue
        }
    }
    
    /**
     Maximum allowed video duration
     */
    @objc public var maxDuration: Double {
        get {
            return settings.maxDuration
        }
        set {
            settings.maxDuration = newValue
        }
    }
    
    @objc public var takePhotoIcon: UIImage? {
        get {
            return settings.takePhotoIcon
        }
        set {
            settings.takePhotoIcon = newValue
        }
    }
}

// MARK: Album button
extension BSImagePickerViewController {
    /**
     Album button in title view
     */
    @objc public var albumButton: UIButton {
        get {
            return albumTitleView
        }
        set {
            albumTitleView = newValue
        }
    }
}
