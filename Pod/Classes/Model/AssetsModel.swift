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

internal protocol AssetsDelegate {
    func didUpdateAssets(sender: NSObject, incrementalChange: Bool, insert: [NSIndexPath], delete: [NSIndexPath], change: [NSIndexPath])
}

internal class AssetsModel : NSObject, PHPhotoLibraryChangeObserver {
    internal var delegate: AssetsDelegate?
    internal var results: [PHFetchResult] {
        get {
            return _results
        }
    }
    
    private var _results: [PHFetchResult]
    
    required init(fetchResult aFetchResult: [PHFetchResult]) {
        _results = aFetchResult
        
        super.init()
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
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
                
                let removedIndexes: [NSIndexPath]
                let insertedIndexes: [NSIndexPath]
                let changedIndexes: [NSIndexPath]
                
                if collectionChanges.hasIncrementalChanges {
                    // Incremental change, tell delegate what has been deleted, inserted and changed
                    removedIndexes = indexPathsFromIndexSet(collectionChanges.removedIndexes, inSection: index)
                    insertedIndexes = indexPathsFromIndexSet(collectionChanges.insertedIndexes, inSection: index)
                    changedIndexes = indexPathsFromIndexSet(collectionChanges.changedIndexes, inSection: index)
                } else {
                    // No incremental change. Set empty arrays
                    removedIndexes = []
                    insertedIndexes = []
                    changedIndexes = []
                }
                
                // Notify delegate
                delegate?.didUpdateAssets(self, incrementalChange: collectionChanges.hasIncrementalChanges, insert: insertedIndexes, delete: removedIndexes, change: changedIndexes)
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
}
