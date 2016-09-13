// The MIT License (MIT)
//
// Copyright (c) 2016 Joakim Gyllström
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

public class ImagePicker: UINavigationController {
    // TODO: Public access to buttons
    private let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ImagePicker.doneButtonPressed(sender:)))
    private let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ImagePicker.cancelButtonPressed(sender:)))
    
    fileprivate let folders: [Folder]
    fileprivate let settings: Settings
    
    var onSelect: PhotoSelection? {
        get { return self.photosViewController.onSelect }
        set { self.photosViewController.onSelect = newValue }
    }
    var onDeselect: PhotoSelection? {
        get { return self.photosViewController.onDeselect }
        set { self.photosViewController.onDeselect = newValue }
    }
    var onCancel: PhotosSelection?
    var onFinish: PhotosSelection?
    
    fileprivate lazy var photosViewController: PhotosViewController = {
        return PhotosViewController(album: self.folders[0][0], selections: [], settings: self.settings)
    }()
    
    private lazy var albumsViewController: AlbumsViewController = {
        let vc = AlbumsViewController(folders: self.folders)
        vc.delegate = self
        
        return vc
    }()
    
    override public var viewControllers: [UIViewController] {
        didSet {
            // Set bar button items when updating view controllers
            viewControllers.first?.navigationItem.leftBarButtonItem = cancelButton
            viewControllers.first?.navigationItem.rightBarButtonItem = doneButton
            
            let albumTitleView = Bundle.imagePicker.loadNibNamed("AlbumTitleView", owner: nil, options: nil)?.first as! AlbumTitleView
            albumTitleView.albumButton.addTarget(self, action: #selector(ImagePicker.albumButtonPressed(sender:)), for: .touchUpInside)
            albumTitleView.update(for: photosViewController.album)
            
            viewControllers.first?.navigationItem.titleView = albumTitleView
        }
    }
    
    public convenience init(folder: Folder, settings: Settings = Settings.classic()) {
        self.init(folders: [folder], settings: settings)
    }
    
    public init(folders: [Folder] = [Folder.cameraRoll(), Folder.allAlbums()], settings: Settings = Settings.classic()) {
        self.folders = folders
        self.settings = settings
        
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor.white
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        
        viewControllers = [photosViewController]
    }
}

// MARK: Button actions
extension ImagePicker {
    func cancelButtonPressed(sender: UIBarButtonItem) {
        onCancel?(photosViewController.selections)
        dismiss(animated: true, completion: nil)
    }
    
    func doneButtonPressed(sender: UIBarButtonItem) {
        onFinish?(photosViewController.selections)
        dismiss(animated: true, completion: nil)
    }
    
    func albumButtonPressed(sender: UIButton) {
        let albumsViewController = AlbumsViewController(folders: folders)
        albumsViewController.modalPresentationStyle = .popover
        albumsViewController.preferredContentSize = CGSize(width: 320, height: 300)
        
        albumsViewController.popoverPresentationController?.permittedArrowDirections = [.up]
        albumsViewController.popoverPresentationController?.sourceView = sender
        let senderRect = sender.convert(sender.frame, from: sender.superview)
        let sourceRect = CGRect(x: senderRect.origin.x, y: senderRect.origin.y + (sender.frame.size.height / 2), width: senderRect.size.width, height: senderRect.size.height)
        albumsViewController.popoverPresentationController?.sourceRect = sourceRect
        albumsViewController.popoverPresentationController?.delegate = self
        
        present(albumsViewController, animated: true, completion: nil)
    }
}

// MARK: UIPopoverPresentationControllerDelegate
extension ImagePicker: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

// MARK: AlbumsViewControllerDelegate
extension ImagePicker: AlbumsViewControllerDelegate {
    func albumsViewController(_ albumsViewController: AlbumsViewController, didSelect: Album) {
        guard let old = viewControllers.first as? PhotosViewController, old.album != didSelect else { return }
        photosViewController = PhotosViewController(album: didSelect, selections: old.selections, settings: old.settings)
        photosViewController.onDeselect = old.onDeselect
        photosViewController.onSelect = old.onSelect
        
        viewControllers = [photosViewController]
    }
    
    func albumsViewController(_ albumsViewController: AlbumsViewController, isSelected: Album) -> Bool {
        guard let photosViewController = viewControllers.first as? PhotosViewController else { return false }
        return photosViewController.album == isSelected
    }
}
