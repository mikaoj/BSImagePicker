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
        let set = IndexSet()
        
        XCTAssert(set.bs_indexPathsForSection(0).count == 0)
    }
    
    func testContinuousSet() {
        let range = 2..<4
        let set = IndexSet(integersIn: range)
        
        let expectedIndexPaths = [
            IndexPath(item: 2, section: 0),
            IndexPath(item: 3, section: 0)
        ]
        
        let actualIndexPaths = set.bs_indexPathsForSection(0)
        
        XCTAssert(expectedIndexPaths == actualIndexPaths)
    }
    
    func testDiscontinuousSet() {
        var set = IndexSet()
        set.insert(3)
        set.insert(5)
        set.insert(12)
        
        let expectedIndexPaths = [
            IndexPath(item: 3, section: 3),
            IndexPath(item: 5, section: 3),
            IndexPath(item: 12, section: 3)
        ]
        
        let actualIndexPaths = set.bs_indexPathsForSection(3)
        
        XCTAssert(expectedIndexPaths == actualIndexPaths)
    }
}
