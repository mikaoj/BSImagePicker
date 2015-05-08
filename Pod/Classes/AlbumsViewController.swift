//
//  AlbumsViewController.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-05-08.
//
//

import UIKit

internal class AlbumsViewController: UITableViewController {
    private let albumsDataSource = AlbumsDataSource()
    
    override func loadView() {
        super.loadView()
        
        tableView.dataSource = albumsDataSource
    }
}
