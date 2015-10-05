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

import Photos

/**
Class wrapping fetch results as an selectable data source.
It will register itself as an change observer. So be sure to set yourself as delegate to get notified about updates.
*/
final class FetchResultsDataSource : NSObject, SelectableDataSource, PHPhotoLibraryChangeObserver {
    private var fetchResults: [PHFetchResult]
    var selections: [PHObject] = []
    
    var delegate: SelectableDataDelegate?
    var allowsMultipleSelection: Bool = false
    var maxNumberOfSelections: Int = Int.max
    
    var selectedIndexPaths: [NSIndexPath] {
        get {
            var indexPaths: [NSIndexPath] = []
            
            for object in selections {
                for (resultIndex, fetchResult) in fetchResults.enumerate() {
                    let index = fetchResult.indexOfObject(object)
                    if index != NSNotFound {
                        let indexPath = NSIndexPath(forItem: index, inSection: resultIndex)
                        indexPaths.append(indexPath)
                    }
                }
            }
            
            return indexPaths
        }
    }
    
    convenience init(fetchResult: PHFetchResult) {
        self.init(fetchResults: [fetchResult])
    }
    
    required init(fetchResults: [PHFetchResult]) {
        self.fetchResults = fetchResults
        
        super.init()
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
    
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    // MARK: SelectableDataSource
    var sections: Int {
        get {
            return fetchResults.count
        }
    }
    
    func numberOfObjectsInSection(section: Int) -> Int {
        return fetchResults[section].count
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> PHObject {
        return fetchResults[indexPath.section][indexPath.row] as! PHObject
    }
    
    func selectObjectAtIndexPath(indexPath: NSIndexPath) {
        if isObjectAtIndexPathSelected(indexPath) == false && selections.count < maxNumberOfSelections {
            if allowsMultipleSelection == false {
                selections.removeAll(keepCapacity: true)
            }
            
            selections.append(objectAtIndexPath(indexPath))
        }
    }
    
    func deselectObjectAtIndexPath(indexPath: NSIndexPath) {
        let object = objectAtIndexPath(indexPath)
        if let index = selections.indexOf(object) {
            selections.removeAtIndex(index)
        }
    }
    
    func isObjectAtIndexPathSelected(indexPath: NSIndexPath) -> Bool {
        let object = objectAtIndexPath(indexPath)
        
        return selections.contains(object)
    }
    
    // MARK: PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(changeInstance: PHChange) {
        for (index, fetchResult) in fetchResults.enumerate() {
            // Check if there are changes to our fetch result
            if let collectionChanges = changeInstance.changeDetailsForFetchResult(fetchResult) {
                // Get the new fetch result
                let newResult = collectionChanges.fetchResultAfterChanges as PHFetchResult
                
                // Replace old result
                fetchResults[index] = newResult
                
                // Sometimes the properties on PHFetchResultChangeDetail are nil
                // Work around it for now
                let incrementalChange = collectionChanges.hasIncrementalChanges && collectionChanges.removedIndexes != nil && collectionChanges.insertedIndexes != nil && collectionChanges.changedIndexes != nil
                
                let removedIndexPaths: [NSIndexPath]
                let insertedIndexPaths: [NSIndexPath]
                let changedIndexPaths: [NSIndexPath]
                
                if incrementalChange {
                    // Incremental change, tell delegate what has been deleted, inserted and changed
                    removedIndexPaths = indexPathsFromIndexSet(collectionChanges.removedIndexes!, inSection: index)
                    insertedIndexPaths = indexPathsFromIndexSet(collectionChanges.insertedIndexes!, inSection: index)
                    changedIndexPaths = indexPathsFromIndexSet(collectionChanges.changedIndexes!, inSection: index)
                } else {
                    // No incremental change. Set empty arrays
                    removedIndexPaths = []
                    insertedIndexPaths = []
                    changedIndexPaths = []
                }
                
                // Notify delegate
                delegate?.didUpdateData(self, incrementalChange: incrementalChange, insertions: insertedIndexPaths, deletions: removedIndexPaths, changes: changedIndexPaths)
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
}
