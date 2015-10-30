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

import XCTest
import Foundation
@testable import BSImagePicker

class NSIndexSetIndexPathTests: XCTestCase {
    func testEmptySet() {
        let set = NSIndexSet()
        
        XCTAssert(set.bs_indexPathsForSection(0).count == 0)
    }
    
    func testContinuousSet() {
        let range = NSMakeRange(2, 2)
        let set = NSIndexSet(indexesInRange: range)
        
        let expectedIndexPaths = [
            NSIndexPath(forItem: 2, inSection: 0),
            NSIndexPath(forItem: 3, inSection: 0)
        ]
        
        let actualIndexPaths = set.bs_indexPathsForSection(0)
        
        XCTAssert(expectedIndexPaths == actualIndexPaths)
    }
    
    func testDiscontinuousSet() {
        let set = NSMutableIndexSet()
        set.addIndex(3)
        set.addIndex(5)
        set.addIndex(12)
        
        let expectedIndexPaths = [
            NSIndexPath(forItem: 3, inSection: 3),
            NSIndexPath(forItem: 5, inSection: 3),
            NSIndexPath(forItem: 12, inSection: 3)
        ]
        
        let actualIndexPaths = set.bs_indexPathsForSection(3)
        
        XCTAssert(expectedIndexPaths == actualIndexPaths)
    }
}
