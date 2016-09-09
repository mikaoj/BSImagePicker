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
 A Folder is a collection of albums
 */
public struct Folder {
    fileprivate let fetchResult: PHFetchResult<PHAssetCollection>
    fileprivate let fetchOptions: PHFetchOptions = {
        let o = PHFetchOptions()
        o.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        // If anyone ever whants to support video, this is the place to start! :)
        o.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        return o
    }()
    
    init(fetchResult: PHFetchResult<PHAssetCollection>) {
        self.fetchResult = fetchResult
    }
}

// MARK: Collection
extension Folder: Collection {
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return fetchResult.count-1
    }
    
    public func index(after i: Int) -> Int {
        return i+1
    }
    
    public subscript(i: Int) -> Album {
        let a = fetchResult.object(at: i)
        
        let photosFetchResult = PHAsset.fetchAssets(in: a, options: fetchOptions)
        
        return Album(fetchResult: photosFetchResult)
    }
}

// MARK: Convenience
extension Folder {
    static func cameraRoll() -> Folder {
        return Folder(fetchResult: PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil))
    }
    
    static func allAlbums() -> Folder {
        return Folder(fetchResult: PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil))
    }
}

// MARK: Equatable
extension Folder: Equatable { }
public func ==(lhs: Folder, rhs: Folder) -> Bool {
    return lhs.fetchResult == rhs.fetchResult
}
