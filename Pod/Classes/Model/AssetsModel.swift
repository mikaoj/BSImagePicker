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

final class AssetsModel<T: AnyEquatableObject> : Selectable {
    var delegate: AssetsDelegate?
    subscript (idx: Int) -> PHFetchResult {
        return _results[idx]
    }
    var count: Int {
        return _results.count
    }
    
    private var _selections = [T]()
    private var _results: [PHFetchResult]
    
    required init(fetchResult aFetchResult: [PHFetchResult]) {
        _results = aFetchResult
    }
    
    // MARK: PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(changeInstance: PHChange!) {
        for (index, fetchResult) in enumerate(_results) {
            // Check if there are changes to our fetch result
            if let collectionChanges = changeInstance.changeDetailsForFetchResult(fetchResult) {
                // Get the new fetch result
                let newResult = collectionChanges.fetchResultAfterChanges as PHFetchResult
                
                // Replace old result
                _results[index] = newResult
                
                // Sometimes the properties on PHFetchResultChangeDetail are nil
                // Work around it for now
                let incrementalChange = collectionChanges.hasIncrementalChanges && collectionChanges.removedIndexes != nil && collectionChanges.insertedIndexes != nil && collectionChanges.changedIndexes != nil
                
                let removedIndexPaths: [NSIndexPath]
                let insertedIndexPaths: [NSIndexPath]
                let changedIndexPaths: [NSIndexPath]
                
                if incrementalChange {
                    // Incremental change, tell delegate what has been deleted, inserted and changed
                    removedIndexPaths = indexPathsFromIndexSet(collectionChanges.removedIndexes, inSection: index)
                    insertedIndexPaths = indexPathsFromIndexSet(collectionChanges.insertedIndexes, inSection: index)
                    changedIndexPaths = indexPathsFromIndexSet(collectionChanges.changedIndexes, inSection: index)
                } else {
                    // No incremental change. Set empty arrays
                    removedIndexPaths = []
                    insertedIndexPaths = []
                    changedIndexPaths = []
                }
                
                // Notify delegate
                delegate?.didUpdateAssets(self, incrementalChange: incrementalChange, insert: insertedIndexPaths, delete: removedIndexPaths, change: changedIndexPaths)
            }
        }
    }
    
    private func indexPathsFromIndexSet(indexSet: NSIndexSet, inSection section: Int) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        
        indexSet.enumerateIndexesUsingBlock { (index, _) -> Void in
            indexPaths.append(NSIndexPath(forItem: index, inSection: section))
        }
        
        return indexPaths
    }
    
    // MARK: Selectable
    func selectObjectAtIndexPath(indexPath: NSIndexPath) {
        if let object = _results[indexPath.section][indexPath.row] as? T where contains(_selections, object) == false {
            _selections.append(object)
        }
    }
    
    func deselectObjectAtIndexPath(indexPath: NSIndexPath) {
        if let object = _results[indexPath.section][indexPath.row] as? T, let index = find(_selections, object) {
            _selections.removeAtIndex(index)
        }
    }
    
    func selectionCount() -> Int {
        return _selections.count
    }
    
    func selectedIndexPaths() -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        
        for object in _selections {
            for (resultIndex, fetchResult) in enumerate(_results) {
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
