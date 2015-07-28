//
//  AggregatedTableViewDataSource.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-07-28.
//
//

import UIKit

final class AggregatedTableViewDataSource<T: UITableViewDataSource> : NSObject, UITableViewDataSource {
    let dataSources: [T]
    
    init(dataSources: [T]) {
        self.dataSources = dataSources
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSources.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources[section].tableView(tableView, numberOfRowsInSection: 0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return dataSources[indexPath.section].tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: indexPath.row, inSection: 0))
    }
}
