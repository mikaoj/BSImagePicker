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
    private let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    private let lineView: UIView = UIView()

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

        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tableView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        tableView.sectionFooterHeight = CGFloat.leastNormalMagnitude
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(AlbumCell.self, forCellReuseIdentifier: AlbumCell.identifier)
        tableView.dataSource = dataSource
        tableView.delegate = self
        view.addSubview(tableView)

        let lineHeight: CGFloat = 0.5
        lineView.frame = view.bounds
        lineView.frame.size.height = lineHeight
        lineView.frame.origin.y = view.frame.size.height - lineHeight
        lineView.backgroundColor = .gray
        lineView.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        view.addSubview(lineView)

        modalPresentationStyle = .popover
        preferredContentSize = CGSize(width: 320, height: 300)
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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

extension AlbumsViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // TODO: Handle change
        print("Did recieve change in albums")
    }
}
