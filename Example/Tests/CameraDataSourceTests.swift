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
import XCTest
import UIKit
@testable import BSImagePicker

class CameraDataSourceTests: XCTestCase {
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    
    func testCameraNotAvailableSettingOn() {
        let settings = Settings()
        settings.takePhotos = true
        
        let dataSource = CameraCollectionViewDataSource(settings: settings, cameraAvailable: false)
        XCTAssert(dataSource.numberOfSectionsInCollectionView(collectionView) == 0)
    }
    
    func testCameraNotAvailableSettingsOff() {
        let settings = Settings()
        settings.takePhotos = false
        
        let dataSource = CameraCollectionViewDataSource(settings: settings, cameraAvailable: false)
        XCTAssert(dataSource.numberOfSectionsInCollectionView(collectionView) == 0)
    }
    
    func testCameraAvailableSettingsOn() {
        let settings = Settings()
        settings.takePhotos = true
        
        let dataSource = CameraCollectionViewDataSource(settings: settings, cameraAvailable: true)
        XCTAssert(dataSource.numberOfSectionsInCollectionView(collectionView) == 1)
        XCTAssert(dataSource.collectionView(collectionView, numberOfItemsInSection: 0) == 1)
    }
    
    func testCameraAvailableSettingsOff() {
        let settings = Settings()
        settings.takePhotos = false
        
        let dataSource = CameraCollectionViewDataSource(settings: settings, cameraAvailable: true)
        XCTAssert(dataSource.numberOfSectionsInCollectionView(collectionView) == 0)
    }
}
