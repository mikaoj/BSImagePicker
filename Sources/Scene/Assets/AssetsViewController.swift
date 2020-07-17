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

protocol AssetsViewControllerDelegate: class {
    func assetsViewController(_ assetsViewController: AssetsViewController, didSelectAsset asset: PHAsset)
    func assetsViewController(_ assetsViewController: AssetsViewController, didDeselectAsset asset: PHAsset)
    func assetsViewController(_ assetsViewController: AssetsViewController, didLongPressCell cell: AssetCollectionViewCell, displayingAsset asset: PHAsset)
}

class AssetsViewController: UIViewController {
    weak var delegate: AssetsViewControllerDelegate?
    var settings: Settings! {
        didSet { dataSource.settings = settings }
    }

    private let store: AssetStore
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var fetchResult: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>() {
        didSet {
            dataSource.fetchResult = fetchResult
        }
    }
    private let dataSource: AssetsCollectionViewDataSource

    private let selectionFeedback = UISelectionFeedbackGenerator()

    init(store: AssetStore) {
        self.store = store
        dataSource = AssetsCollectionViewDataSource(fetchResult: fetchResult, store: store)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        PHPhotoLibrary.shared().register(self)

        view = collectionView

        // Set an empty title to get < back button
        title = " "

        collectionView.allowsMultipleSelection = true
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = settings.theme.backgroundColor
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.prefetchDataSource = dataSource
        AssetsCollectionViewDataSource.registerCellIdentifiersForCollectionView(collectionView)

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(AssetsViewController.collectionViewLongPressed(_:)))
        longPressRecognizer.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPressRecognizer)

        syncSelections(store.assets)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCollectionViewLayout(for: traitCollection)
    }

    func showAssets(in album: PHAssetCollection) {
        fetchResult = PHAsset.fetchAssets(in: album, options: settings.fetch.assets.options)
        collectionView.reloadData()
        let selections = self.store.assets
        syncSelections(selections)
        collectionView.setContentOffset(.zero, animated: false)
    }

    private func syncSelections(_ assets: [PHAsset]) {
        collectionView.allowsMultipleSelection = true

        // Unselect all
        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        // Sync selections
        for asset in assets {
            let index = fetchResult.index(of: asset)
            guard index != NSNotFound else { continue }
            let indexPath = IndexPath(item: index, section: 0)
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            updateSelectionIndexForCell(at: indexPath)
        }
    }

    func unselect(asset: PHAsset) {
        let index = fetchResult.index(of: asset)
        guard index != NSNotFound else { return }
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.deselectItem(at:indexPath, animated: false)

        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            updateSelectionIndexForCell(at: indexPath)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateCollectionViewLayout(for: traitCollection)
    }

    @objc func collectionViewLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard settings.preview.enabled else { return }
        guard sender.state == .began else { return }

        selectionFeedback.selectionChanged()

        // Calculate which index path long press came from
        let location = sender.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location) else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? AssetCollectionViewCell else { return }
        let asset = fetchResult.object(at: indexPath.row)

        delegate?.assetsViewController(self, didLongPressCell: cell, displayingAsset: asset)
    }

    private func updateCollectionViewLayout(for traitCollection: UITraitCollection) {
        guard let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else  { return }

        let itemSpacing = settings.list.spacing
        let itemsPerRow = settings.list.cellsPerRow(traitCollection.verticalSizeClass, traitCollection.horizontalSizeClass)
        let itemWidth = (collectionView.bounds.width - CGFloat(itemsPerRow - 1) * itemSpacing) / CGFloat(itemsPerRow)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)

        collectionViewFlowLayout.minimumLineSpacing = itemSpacing
        collectionViewFlowLayout.minimumInteritemSpacing = itemSpacing
        collectionViewFlowLayout.itemSize = itemSize

        dataSource.imageSize = itemSize.resize(by: UIScreen.main.scale)
    }

    private func updateSelectionIndexForCell(at indexPath: IndexPath) {
        guard settings.theme.selectionStyle == .numbered else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? AssetCollectionViewCell else { return }
        let asset = fetchResult.object(at: indexPath.row)
        cell.selectionIndex = store.index(of: asset)
    }
}

extension AssetsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectionFeedback.selectionChanged()

        let asset = fetchResult.object(at: indexPath.row)
        store.append(asset)
        delegate?.assetsViewController(self, didSelectAsset: asset)

        updateSelectionIndexForCell(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectionFeedback.selectionChanged()
        
        let asset = fetchResult.object(at: indexPath.row)
        store.remove(asset)
        delegate?.assetsViewController(self, didDeselectAsset: asset)
        
        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            updateSelectionIndexForCell(at: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard store.count < settings.selection.max || settings.selection.unselectOnReachingMax else { return false }
        selectionFeedback.prepare()

        return true
    }
}

extension AssetsViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: fetchResult) else { return }
        // Since we are gonna update UI, make sure we are on main
        DispatchQueue.main.async {
            if changes.hasIncrementalChanges {
                self.collectionView.performBatchUpdates({
                    self.fetchResult = changes.fetchResultAfterChanges

                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, move
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        let removedItems = removed.map { IndexPath(item: $0, section:0) }
                        let removedSelections = self.collectionView.indexPathsForSelectedItems?.filter { return removedItems.contains($0) }
                        removedSelections?.forEach {
                            self.delegate?.assetsViewController(self, didDeselectAsset: changes.fetchResultBeforeChanges.object(at: $0.row))
                        }
                        self.collectionView.deleteItems(at: removedItems)
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        self.collectionView.insertItems(at: inserted.map { IndexPath(item: $0, section:0) })
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        self.collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                     to: IndexPath(item: toIndex, section: 0))
                    }
                })

                // "Use these indices to reconfigure the corresponding cells after performBatchUpdates"
                // https://developer.apple.com/documentation/photokit/phobjectchangedetails
                if let changed = changes.changedIndexes, changed.count > 0 {
                    self.collectionView.reloadItems(at: changed.map { IndexPath(item: $0, section:0) })
                }
            } else {
                self.fetchResult = changes.fetchResultAfterChanges
                self.collectionView.reloadData()
            }

            // No matter if we have incremental changes or not, sync the selections
            self.syncSelections(self.store.assets)
        }
    }
}
