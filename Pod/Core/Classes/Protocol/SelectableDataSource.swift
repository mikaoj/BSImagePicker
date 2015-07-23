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
import Photos

/**
Selectable data source protocol. Based on index paths and coupled to Photos for now...
*/
public protocol SelectableDataSource : NSObjectProtocol {
    /**
    Data source delegate (notify if any updates have been done, etc).
    */
    var delegate: SelectableDataDelegate? { get set }
    
    /**
    Number of sections in the data source
    */
    var sections: Int { get }
    
    /**
    Number of objects for a given section.
    */
    func numberOfObjectsInSection(section: Int) -> Int
    /**
    Get object at given index path.
    */
    func objectAtIndexPath(indexPath: NSIndexPath) -> PHObject
    
    /**
    Does this data source allow multiple selection?. 
    true: Selection is allowed up to maxNumberOfSelections.
    false: On selection previous selection will be deselected.
    */
    var allowsMultipleSelection: Bool { get set }
    /**
    How many selections are allowed?
    */
    var maxNumberOfSelections: Int { get set }
    /**
    All selected objects
    */
    var selections: [PHObject] { get set }
    /**
    Index paths for all selections
    */
    var selectedIndexPaths: [NSIndexPath] { get }
    
    /**
    Select an object
    */
    func selectObjectAtIndexPath(indexPath: NSIndexPath)
    /**
    Deselect an object
    */
    func deselectObjectAtIndexPath(indexPath: NSIndexPath)
    /**
    Check if selected
    */
    func isObjectAtIndexPathSelected(indexPath: NSIndexPath) -> Bool
}
