//
//  ComposedDataSourceTests.swift
//  BSImagePickerExample
//
//  Created by Joakim Gyllström on 2015-10-26.
//  Copyright © 2015 Joakim Gyllström. All rights reserved.
//

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
