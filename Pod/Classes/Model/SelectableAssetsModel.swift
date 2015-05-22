//
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

// TODO: Generic
internal class SelectableAssetsModel<T: Equatable> : AssetsModel {
    internal var selectedAssets = [T]()
    
    required init(fetchResult aFetchResult: [PHFetchResult]) {
        super.init(fetchResult: aFetchResult)
    }
    
    // MARK: Selection & deselection
    func selectResult(atIndexPath indexPath: NSIndexPath) {
        if let result = results[indexPath.section][indexPath.row] as? T where contains(selectedAssets, result) == false {
            selectedAssets.append(result)
        }
    }
    
    func deselectResult(atIndexPath indexPath: NSIndexPath) {
        if let result = results[indexPath.section][indexPath.row] as? T, let index = find(selectedAssets, result) {
            selectedAssets.removeAtIndex(index)
        }
    }
    
    func numberOfselectedAssets() -> Int {
        return selectedAssets.count
    }

    func indexPathsForselectedAssets() -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        
        for result in selectedAssets {
            if let result: AnyObject = result as? AnyObject {
                for (resultIndex, fetchResult) in enumerate(results) {
                    let index = fetchResult.indexOfObject(result)
                    if index != NSNotFound {
                        let indexPath = NSIndexPath(forItem: index, inSection: resultIndex)
                        indexPaths.append(indexPath)
                    }
                }
            }
        }
        
        return indexPaths
    }
    
    func selections() -> [T] {
        return selectedAssets
    }
}
