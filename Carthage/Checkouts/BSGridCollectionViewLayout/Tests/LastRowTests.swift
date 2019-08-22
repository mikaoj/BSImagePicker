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

class LastRowTests: XCTestCase {
    
    func testLastRowInZeroRect() {
        let lastRow = GridCollectionViewLayout.lastRowInRect(CGRect.zero, withRowHeight: 100, max: 3)
        XCTAssertEqual(lastRow, 0)
    }
    
    func testLastRowWithoutOffsetSmallMax() {
        let max = 2
        let lastRow = GridCollectionViewLayout.lastRowInRect(CGRect(x: 0, y: 0, width: 100, height: 300), withRowHeight: 100, max: max)
        XCTAssertEqual(lastRow, 1)
    }
    
    func testLastRowWithoutOffsetMediumMax() {
        let max = 3
        let lastRow = GridCollectionViewLayout.lastRowInRect(CGRect(x: 0, y: 0, width: 100, height: 300), withRowHeight: 100, max: max)
        XCTAssertEqual(lastRow, 2)
    }
    
    func testLastRowWithoutOffsetLargeMax() {
        let max = 8
        let lastRow = GridCollectionViewLayout.lastRowInRect(CGRect(x: 0, y: 0, width: 100, height: 300), withRowHeight: 100, max: max)
        XCTAssertEqual(lastRow, 2)
    }
    
    func testLastRowWith1RowOffsetSmallMax() {
        let max = 2
        let lastRow = GridCollectionViewLayout.lastRowInRect(CGRect(x: 0, y: 100, width: 100, height: 300), withRowHeight: 100, max: max)
        XCTAssertEqual(lastRow, 1)
    }
    
    func testLastRowWith1RowOffsetMediumMax() {
        let max = 3
        let lastRow = GridCollectionViewLayout.lastRowInRect(CGRect(x: 0, y: 100, width: 100, height: 300), withRowHeight: 100, max: max)
        XCTAssertEqual(lastRow, 2)
    }
    
    func testLastRowWith1RowOffsetLargeMax() {
        let max = 8
        let lastRow = GridCollectionViewLayout.lastRowInRect(CGRect(x: 0, y: 100, width: 100, height: 300), withRowHeight: 100, max: max)
        XCTAssertEqual(lastRow, 3)
    }
    
    func testLastRowWithHalfRowOffsetSmallMax() {
        let max = 2
        let lastRow = GridCollectionViewLayout.lastRowInRect(CGRect(x: 0, y: 50, width: 100, height: 300), withRowHeight: 100, max: max)
        XCTAssertEqual(lastRow, 1)
    }
    
    func testLastRowWithHalfRowOffsetMediumMax() {
        let max = 3
        let lastRow = GridCollectionViewLayout.lastRowInRect(CGRect(x: 0, y: 50, width: 100, height: 300), withRowHeight: 100, max: max)
        XCTAssertEqual(lastRow, 2)
    }
    
    func testLastRowWithHalfRowOffsetLargeMax() {
        let max = 8
        let lastRow = GridCollectionViewLayout.lastRowInRect(CGRect(x: 0, y: 50, width: 100, height: 300), withRowHeight: 100, max: max)
        XCTAssertEqual(lastRow, 3)
    }
}
