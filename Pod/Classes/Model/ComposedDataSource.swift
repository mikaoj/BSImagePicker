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

/**
Takes multiple UICollectionViewDataSources and joins them into one section
*/
class ComposedDataSource: NSObject, UICollectionViewDataSource {
    let dataSources: [UICollectionViewDataSource]
    
    init(dataSources: [UICollectionViewDataSource]) {
        self.dataSources = dataSources
        
        super.init()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1 // Always one section, no mather how many data sources we have
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources.reduce(0, combine: { (count, dataSource) -> Int in
            return dataSource.collectionView(collectionView, numberOfItemsInSection: 0) + count
        })
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Ask the correct data source for the cell
        // THIS IS REALLY UGLY...refactor pleeeeeaaaaase!
        // A custom collection view layout would probably allow multiple sections to appear on the same row...
        var cell: UICollectionViewCell!
        var previousCount = 0
        for dataSource in dataSources {
            let sourceIndex = indexPath.row - previousCount
            let sourceCount = dataSource.collectionView(collectionView, numberOfItemsInSection: 0)
            
            if sourceIndex < sourceCount {
                cell = dataSource.collectionView(collectionView, cellForItemAtIndexPath: NSIndexPath(forRow: sourceIndex, inSection: 0))
                break
            }
            
            previousCount += sourceCount
        }
        
        return cell
    }
}
