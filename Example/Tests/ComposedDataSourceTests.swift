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
@testable import BSImagePicker
import XCTest

let firstDataSourceTag = 1
let secondDataSourceTag = 2

class ComposedDataSourceTest: XCTestCase {
    var composedDataSource: ComposedCollectionViewDataSource!
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func setUp() {
        super.setUp()
        
        composedDataSource = ComposedCollectionViewDataSource(dataSources: [FirstDataSource(), SecondDataSource()])
    }
    
    func testNoDataSourcesSectionCount() {
        XCTAssert(ComposedCollectionViewDataSource(dataSources: []).numberOfSectionsInCollectionView(collectionView) == 0)
    }
    
    func testOneDataSourceSectionCount() {
        XCTAssert(ComposedCollectionViewDataSource(dataSources: [FirstDataSource()]).numberOfSectionsInCollectionView(collectionView) == 1)
    }
    
    func testTwoDataSourcesSectionCount() {
        XCTAssert(composedDataSource.numberOfSectionsInCollectionView(collectionView) == 2)
    }
    
    func testFirstSectionItemCount() {
        XCTAssert(composedDataSource.collectionView(collectionView, numberOfItemsInSection: 0) == 2)
    }
    
    func testSecondSectionItemCount() {
        XCTAssert(composedDataSource.collectionView(collectionView, numberOfItemsInSection: 1) == 3)
    }
    
    func testFirstSectionCell() {
        XCTAssert(composedDataSource.collectionView(collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0)).tag == firstDataSourceTag)
        XCTAssert(composedDataSource.collectionView(collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 1, inSection: 0)).tag == firstDataSourceTag)
    }
    
    func testSecondSectionCell() {
        XCTAssert(composedDataSource.collectionView(collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 1)).tag == secondDataSourceTag)
        XCTAssert(composedDataSource.collectionView(collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 1, inSection: 1)).tag == secondDataSourceTag)
        XCTAssert(composedDataSource.collectionView(collectionView, cellForItemAtIndexPath: NSIndexPath(forItem: 2, inSection: 1)).tag == secondDataSourceTag)
    }
}

class FirstDataSource: NSObject, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        cell.tag = firstDataSourceTag
        
        return cell
    }
}

class SecondDataSource: NSObject, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        cell.tag = secondDataSourceTag
        
        return cell
    }
}
