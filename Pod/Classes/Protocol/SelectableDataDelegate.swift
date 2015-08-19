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

/**
Keep track of whats happening in your selectable data source by implementing this protocol and settings yourself as delegate.
*/
public protocol SelectableDataDelegate {
    /**
    Called when there has been changes in the data source.
    - parameter dataSource: The data source with updates
    - parameter incrementalChange: If true there has been incremental change and you should updated given index paths. If false reload your entire view.
    - parameter insertions: Index paths with insertions
    - parameter deletions: Index paths with deletions
    - parameter changes: Index paths with changes
    */
    func didUpdateData(dataSource: SelectableDataSource, incrementalChange: Bool, insertions: [NSIndexPath], deletions: [NSIndexPath], changes: [NSIndexPath])
}
