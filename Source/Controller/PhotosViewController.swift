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
import Photos

class PhotosViewController: UICollectionViewController {
    var onSelect: PhotoSelection?
    var onDeselect: PhotoSelection?

    fileprivate(set) var selections = [Photo]()
    let album: Album
    let settings: Settings
    
    required init(album: Album, selections: [Photo], settings: Settings = Settings.classic()) {
        self.album = album
        self.selections = selections
        self.settings = settings
        
        super.init(collectionViewLayout: GridCollectionViewLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
}

// MARK: View life cycle
extension PhotosViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(nib: UINib(nibName: "PhotoCell", bundle: Bundle.imagePicker), for: PhotoCell.self)
        collectionView?.backgroundColor = UIColor.clear
    }
}

// MARK: Size classes
extension PhotosViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard let gridLayout = collectionViewLayout as? GridCollectionViewLayout else { return }
        let cellsPerRow = settings.cellsPerRow(traitCollection.verticalSizeClass, traitCollection.horizontalSizeClass)
        
        gridLayout.itemSpacing = CGFloat(settings.spacing)
        gridLayout.itemsPerRow = cellsPerRow
    }
}

// TODO: Move datasource to separate class.
// MARK: UICollectionViewDataSource
extension PhotosViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: PhotoCell.self, for: indexPath)

        let photo = album[(indexPath as NSIndexPath).row]
        cell.isSelected = photoSelected(at: indexPath)
        cell.preview(photo, selectionImage: settings.selectionImage)

        return cell
    }
}

// MARK: UICollectionViewDelegate
extension PhotosViewController {
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // Can we select more?
        guard canSelect(at: indexPath) else { return false }

        // Select or deselect
        if photoSelected(at: indexPath) {
            deselectPhoto(at: indexPath, in: collectionView)
        } else {
            selectPhoto(at: indexPath, in: collectionView)
        }
        
        // Return false to stop collection view of keeping track of whats selected or not.
        // The controller should be source of truth regarding selections
        return false
    }
}

// MARK: Selection
extension PhotosViewController {
    func canSelect(at indexPath: IndexPath) -> Bool {
        return selections.count < settings.maxSelections
    }

    func photoSelected(at indexPath: IndexPath) -> Bool {
        let photo = album[(indexPath as NSIndexPath).row]
        return selections.contains(photo)
    }

    func selectPhoto(at indexPath: IndexPath, in collectionView: UICollectionView) {
        // Add selection
        let photo = album[(indexPath as NSIndexPath).row]
        selections.append(photo)

        // Update cell
        collectionView.cellForItem(at: indexPath)?.isSelected = true

        // Update done button
        updateDoneButtonWithSelections(selections.count)

        // Do callback
        onSelect?(photo)

        print(navigationItem)
    }

    func deselectPhoto(at indexPath: IndexPath, in collectionView: UICollectionView) {
        // Remove selection
        let photo = album[(indexPath as NSIndexPath).row]
        if let index = selections.index(of: photo) {
            selections.remove(at: index)
        }

        // Update cell
        collectionView.cellForItem(at: indexPath)?.isSelected = false

        // Update done button
        updateDoneButtonWithSelections(selections.count)

        // Do callback
        onDeselect?(photo)
    }
}

// MARK: Misc helpers
extension PhotosViewController {
    // TODO: This should be done in ImagePicker. PhotosViewController should have no knowledge about done.
    fileprivate func updateDoneButtonWithSelections(_ numberOfSelections: Int) {
        guard let rightBarButton = navigationItem.rightBarButtonItem else { return }
        // Special case if we have selected 1 image and that is
        // the max number of allowed selections
        let title: String
        if numberOfSelections == 1 && settings.maxSelections == 1 {
            title = UIBarButtonItem.localizedDoneTitle
        } else if numberOfSelections > 0 {
            title = "\(UIBarButtonItem.localizedDoneTitle) (\(numberOfSelections))"
        } else {
            title = UIBarButtonItem.localizedDoneTitle
        }

        // Set done button title and update layout
        navigationController?.navigationBar.setBarButtonItem(rightBarButton, text: title)
        navigationController?.navigationBar.setNeedsLayout()

        // If we have selected more then minimum, done should be enabled
        rightBarButton.isEnabled = numberOfSelections >= settings.minSelections
    }
}

// MARK: Photo library change observer
extension PhotosViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Check if any selected items have been deleted
        // ...
    }
}
