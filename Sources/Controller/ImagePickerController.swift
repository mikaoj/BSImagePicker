// The MIT License (MIT)
//
// Copyright (c) 2019 Joakim Gyllström
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

// MARK: ImagePickerController
public class ImagePickerController: UINavigationController {
    // MARK: Public properties
    public weak var imagePickerDelegate: ImagePickerControllerDelegate?
    public var settings: Settings = Settings()
    public var doneButton: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("BSImagePicker.Done", comment: "Done button title"), style: .done, target: nil, action: nil)
    public var cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    public var albumButton: UIButton = UIButton(type: .custom)
    public var assetStore: AssetStore = AssetStore(assets: [])

    // MARK: Internal properties
    var onSelection: ((_ asset: PHAsset) -> Void)?
    var onDeselection: ((_ asset: PHAsset) -> Void)?
    var onCancel: ((_ assets: [PHAsset]) -> Void)?
    var onFinish: ((_ assets: [PHAsset]) -> Void)?
    
    let assetsViewController = AssetsViewController()
    let albumsViewController = AlbumsViewController()
    let dropdownTransitionDelegate = DropdownTransitionDelegate()
    let zoomTransitionDelegate = ZoomTransitionDelegate()

    public init() {
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        // TODO: It would be nice to not have to do this and use the default iOS 13 behavior.
        // Right now there are some bugs with animations for preview and album view that needs to be fixed.
        modalPresentationStyle = .fullScreen
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            // Disables iOS 13 swipe to dismiss - to force user to press cancel or done.
            // But it is kind of nice to have the swipe to dismiss. Perhaps remove cancel/done callbacks and only use dismissed callback.
            // And let the users of this framework decide to do with it...hmm
            // TODO:
            isModalInPresentation = true
        }
        
        // Sync settings
        albumsViewController.settings = settings
        assetsViewController.settings = settings
        
        // Setup view controllers
        albumsViewController.delegate = self
        assetsViewController.delegate = self
        
        viewControllers = [assetsViewController]
        view.backgroundColor = settings.theme.backgroundColor
        delegate = zoomTransitionDelegate
        
        // Setup buttons
        let firstViewController = viewControllers.first
        albumButton.setTitleColor(albumButton.tintColor, for: .normal)
        albumButton.titleLabel?.font = .systemFont(ofSize: 16)
        albumButton.titleLabel?.adjustsFontSizeToFitWidth = true

        let arrowView = ArrowView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
        arrowView.backgroundColor = .clear
        let image = arrowView.asImage

        albumButton.setImage(image, for: .normal)
        albumButton.semanticContentAttribute = .forceRightToLeft // To set image to the right without having to calculate insets/constraints.
        albumButton.addTarget(self, action: #selector(ImagePickerController.albumsButtonPressed(_:)), for: .touchUpInside)
        firstViewController?.navigationItem.titleView = albumButton

        doneButton.target = self
        doneButton.action = #selector(doneButtonPressed(_:))
        firstViewController?.navigationItem.rightBarButtonItem = doneButton

        cancelButton.target = self
        cancelButton.action = #selector(cancelButtonPressed(_:))
        firstViewController?.navigationItem.leftBarButtonItem = cancelButton
        
        updatedDoneButton()
        updateAlbumButton()

        if let firstAlbum = settings.fetch.album.fetchResults.first?.object(at: 0) {
            select(album: firstAlbum)
        } else {
            // TODO: Handle no collections?
        }
    }

    func updatedDoneButton() {
        doneButton.title = assetStore.count > 0 ? "\(NSLocalizedString("BSImagePicker.Done", comment: "Done button title")) (\(assetStore.count))" : NSLocalizedString("BSImagePicker.Done", comment: "Done button title")
        doneButton.isEnabled = assetStore.count >= settings.selection.min
    }

    func updateAlbumButton() {
        albumButton.isHidden = settings.fetch.album.fetchResults.count == 0
    }
}
