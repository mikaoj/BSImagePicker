//
//  AggregatedTableViewDataSource.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-07-28.
//
//

import UIKit

public final class AggregatedDataSource : NSObject, UITableViewDataSource {
    let dataSources: [UITableViewDataSource]
    
    init(dataSources: [UITableViewDataSource]) {
        self.dataSources = dataSources
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSources.count
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources[section].tableView(tableView, numberOfRowsInSection: 0)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return dataSources[indexPath.section].tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: indexPath.row, inSection: 0))
    }
}
