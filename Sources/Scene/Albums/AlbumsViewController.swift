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

import UIKit
import Photos

protocol AlbumsViewControllerDelegate: class {
    func albumsViewController(_ albumsViewController: AlbumsViewController, didSelectAlbum album: PHAssetCollection)
    func didDismissAlbumsViewController(_ albumsViewController: AlbumsViewController)
}

class AlbumsViewController: UIViewController {
    weak var delegate: AlbumsViewControllerDelegate?
    var settings: Settings!

    private var fetchResults: [PHFetchResult<PHAssetCollection>] = []
    private lazy var libraryFetchResult: PHFetchResult<PHAssetCollection> = {
        return PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: PHFetchOptions())
    }()
    private var dataSource: AlbumsTableViewDataSource = AlbumsTableViewDataSource(fetchResults: [])
    private var tableView: UITableView = UITableView(frame: .zero, style: .grouped)

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        PHPhotoLibrary.shared().register(self)
        fetchResults = [
            libraryFetchResult,
            PHAssetCollection.fetchAssetCollections(with: settings.fetch.album.type, subtype: settings.fetch.album.subtype, options: settings.fetch.album.options)
        ]
        dataSource = AlbumsTableViewDataSource(fetchResults: fetchResults)

        view = tableView
        
        tableView.backgroundColor = settings.theme.backgroundColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        modalPresentationStyle = .popover
        preferredContentSize = CGSize(width: 320, height: 300)

        tableView.register(AlbumCell.self, forCellReuseIdentifier: AlbumCell.identifier)
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Since AlbumsViewController is presented with a presentation controller
        // And we change the state of the album button depending on if it's presented or not
        // We need to get some sort of callback to update that state.
        // Perhaps do something else
        if isBeingDismissed {
            delegate?.didDismissAlbumsViewController(self)
        }
    }
}

extension AlbumsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = fetchResults[indexPath.section].object(at: indexPath.row)
        delegate?.albumsViewController(self, didSelectAlbum: album)
    }
}

extension AlbumsViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // TODO: Handle change
        print("Did recieve change in albums")
    }
}
