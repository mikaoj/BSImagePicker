//
//  DataSource.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-07-24.
//
//

import Foundation
import Photos

public protocol DataSource : NSObjectProtocol {
    /**
    Data source delegate (notify if any updates have been done, etc).
    */
    var delegate: DataDelegate? { get set }
    
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
}
