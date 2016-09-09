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

import Foundation
import Photos

/**
 An Album is a collection of Photos
 */
public struct Album {
    fileprivate let fetchResult: PHFetchResult<PHAsset>
    init(fetchResult: PHFetchResult<PHAsset>) {
        self.fetchResult = fetchResult
    }
}

// MARK: Collection
extension Album: Collection {
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return fetchResult.count-1
    }
    
    public func index(after i: Int) -> Int {
        return i+1
    }
    
    public subscript(i: Int) -> Photo {
        let a = fetchResult.object(at: i)
        return Photo.asset(a)
    }
}

extension Album: Equatable { }
public func ==(lhs: Album, rhs: Album) -> Bool {
    return lhs.fetchResult == rhs.fetchResult
}
