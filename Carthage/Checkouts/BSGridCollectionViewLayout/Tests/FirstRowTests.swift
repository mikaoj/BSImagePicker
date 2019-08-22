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

import UIKit
import XCTest
@testable import BSGridCollectionViewLayout

class FirstRowTests: XCTestCase {
    
    func testFirstRowInZeroRect() {
        let firstRow = GridCollectionViewLayout.firstRowInRect(CGRect.zero, withRowHeight: 100.0)
        XCTAssertEqual(firstRow, 0)
    }
    
    func testFirstRowWithoutOffset() {
        let firstRow = GridCollectionViewLayout.firstRowInRect(CGRect(x: 0, y: 0, width: 100, height: 300), withRowHeight: 100.0)
        XCTAssertEqual(firstRow, 0)
    }
    
    func testFirstRowWith1RowOffset() {
        let firstRow = GridCollectionViewLayout.firstRowInRect(CGRect(x: 0, y: 100, width: 100, height: 300), withRowHeight: 100.0)
        XCTAssertEqual(firstRow, 1)
    }
    
    func testFirstRowWithHalfRowOffset() {
        let firstRow = GridCollectionViewLayout.firstRowInRect(CGRect(x: 0, y: 50, width: 100, height: 300), withRowHeight: 100.0)
        XCTAssertEqual(firstRow, 0)
    }
    
    func testFirstRowWith2RowOffset() {
        let firstRow = GridCollectionViewLayout.firstRowInRect(CGRect(x: 0, y: 200, width: 100, height: 300), withRowHeight: 100.0)
        XCTAssertEqual(firstRow, 2)
    }
    
    func testFirstRowWithNegativeRectOffset() {
        let firstRow = GridCollectionViewLayout.firstRowInRect(CGRect(x: 0, y: -200, width: 100, height: 300), withRowHeight: 100.0)
        XCTAssertEqual(firstRow, 0)
    }
}
