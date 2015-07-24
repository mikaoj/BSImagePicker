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

//TODO: Make functions static
/**
Collection view factory protocol
*/
protocol CollectionViewCellFactory {
    /**
    Registers the collection view for any nibs, classes, etc it needs to know about.
    - parameter collectionView: The collection view to register
    */
    func registerCellIdentifiersForCollectionView(collectionView: UICollectionView?)
    /**
    Get an collection view cell
    - parameter indexPath: The index path for cell
    - parameter withDataSource: The data source to fetch data from
    - parameter inCollectionView: Collection view to show cell in.
    */
    func cellForIndexPath(indexPath: NSIndexPath, withDataSource dataSource: SelectableDataSource, inCollectionView collectionView: UICollectionView) -> UICollectionViewCell
}