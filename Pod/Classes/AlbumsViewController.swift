//
//  AlbumsViewController.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-05-08.
//
//

import UIKit

internal class AlbumsViewController: UITableViewController {
    override func loadView() {
        super.loadView()
        
        // Add a little bit of blur to the background
        let visualEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Light)))
        visualEffectView.frame = tableView.bounds
        visualEffectView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        tableView.backgroundView = visualEffectView
        tableView.backgroundColor = UIColor.clearColor()
    }
}
