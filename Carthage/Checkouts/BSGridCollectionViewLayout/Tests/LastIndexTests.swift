// The MIT License (MIT)
//
// Copyright (c) 2016 Joakim Gyllström
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

import XCTest
@testable import BSGridCollectionViewLayout

class LastIndexTests: XCTestCase {
    func testLastIndexFirstRowLowNumberOfItems() {
        let index = GridCollectionViewLayout.lastIndexInRow(0, withItemsPerRow: 3, numberOfItems: 2)
        XCTAssertEqual(index, 1)
    }
    
    func testLastIndexFirstRowMediumNumberOfItems() {
        let index = GridCollectionViewLayout.lastIndexInRow(0, withItemsPerRow: 3, numberOfItems: 6)
        XCTAssertEqual(index, 2)
    }
    
    func testLastIndexFirstRowLargeNumberOfItems() {
        let index = GridCollectionViewLayout.lastIndexInRow(0, withItemsPerRow: 3, numberOfItems: 500)
        XCTAssertEqual(index, 2)
    }
    
    func testLastIndexThirdRowLowNumberOfItems() {
        let index = GridCollectionViewLayout.lastIndexInRow(2, withItemsPerRow: 3, numberOfItems: 7)
        XCTAssertEqual(index, 6)
    }
    
    func testLastIndexThirdRowMediumNumberOfItems() {
        let index = GridCollectionViewLayout.lastIndexInRow(2, withItemsPerRow: 3, numberOfItems: 8)
        XCTAssertEqual(index, 7)
    }
    
    func testLastIndexThirdRowLargeNumberOfItems() {
        let index = GridCollectionViewLayout.lastIndexInRow(2, withItemsPerRow: 3, numberOfItems: 500)
        XCTAssertEqual(index, 8)
    }
}
