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

import Foundation
import Photos

internal class AssetsModel<T: AnyEquatableObject> : Selectable {
    internal var delegate: AssetsDelegate?
    internal subscript (idx: Int) -> PHFetchResult {
        return _results[idx]
    }
    internal var count: Int {
        return _results.count
    }
    
    private var _selections = [T]()
    private var _results: [PHFetchResult]
    
    required init(fetchResult aFetchResult: [PHFetchResult]) {
        _results = aFetchResult
    }
    
    // MARK: PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(changeInstance: PHChange!) {
        for (index, fetchResult) in _results.enumerate() {
            // Check if there are changes to our fetch result
            if let collectionChanges = changeInstance.changeDetailsForFetchResult(fetchResult) {
                // Get the new fetch result
                let newResult = collectionChanges.fetchResultAfterChanges as PHFetchResult
                
                // Replace old result
                _results[index] = newResult
                
                if let removedIndexes = collectionChanges.removedIndexes, let insertedIndexes = collectionChanges.insertedIndexes, let changedIndexes = collectionChanges.changedIndexes where collectionChanges.hasIncrementalChanges == true {
                    // Incremental change, tell delegate what has been deleted, inserted and changed
                    let removedIndexPaths = indexPathsFromIndexSet(removedIndexes, inSection: index)
                    let insertedIndexPaths = indexPathsFromIndexSet(insertedIndexes, inSection: index)
                    let changedIndexPaths = indexPathsFromIndexSet(changedIndexes, inSection: index)
                    
                    // Notify delegate
                    delegate?.didUpdateAssets(self, incrementalChange: true, insert: insertedIndexPaths, delete: removedIndexPaths, change: changedIndexPaths)
                } else {
                    delegate?.didUpdateAssets(self, incrementalChange: false, insert: [], delete: [], change: [])
                }
            }
        }
    }
    
    // TODO: Extension on NSIndexSet?
    private func indexPathsFromIndexSet(indexSet: NSIndexSet, inSection section: Int) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        
        indexSet.enumerateIndexesUsingBlock { (index, _) -> Void in
            indexPaths.append(NSIndexPath(forItem: index, inSection: section))
        }
        
        return indexPaths
    }
    
    // MARK: Selectable
    func selectObjectAtIndexPath(indexPath: NSIndexPath) {
        if let object = _results[indexPath.section][indexPath.row] as? T where _selections.contains(object) == false {
            _selections.append(object)
        }
    }
    
    func deselectObjectAtIndexPath(indexPath: NSIndexPath) {
        if let object = _results[indexPath.section][indexPath.row] as? T, let index = _selections.indexOf(object) {
            _selections.removeAtIndex(index)
        }
    }
    
    func selectionCount() -> Int {
        return _selections.count
    }
    
    func selectedIndexPaths() -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        
        for object in _selections {
            for (resultIndex, fetchResult) in _results.enumerate() {
                let index = fetchResult.indexOfObject(object)
                if index != NSNotFound {
                    let indexPath = NSIndexPath(forItem: index, inSection: resultIndex)
                    indexPaths.append(indexPath)
                }
            }
        }
        
        return indexPaths
    }
    
    func selections() -> [T] {
        return _selections
    }
    
    func setSelections(newSelections: [T]) {
        _selections = newSelections
    }
    
    func removeSelections() {
        _selections.removeAll(keepCapacity: true)
    }
}
