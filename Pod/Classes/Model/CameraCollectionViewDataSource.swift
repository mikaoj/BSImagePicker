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

/**
Data source for the camera cell. Will not show up if your device doesn't support camera or you have turned it off in settings
*/
final class CameraCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    let cameraCellIdentifier = "cameraCellIdentifier"
    let cameraAvailable: Bool
    let settings: BSImagePickerSettings
    
    init(settings: BSImagePickerSettings, cameraAvailable: Bool) {
        self.settings = settings
        self.cameraAvailable = cameraAvailable
        
        super.init()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (cameraAvailable && settings.takePhotos) ? 1:0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (cameraAvailable && settings.takePhotos) ? 1:0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cameraCell = collectionView.dequeueReusableCell(withReuseIdentifier: cameraCellIdentifier, for: indexPath) as! CameraCell
        cameraCell.accessibilityIdentifier = "camera_cell_\(indexPath.item)"
        cameraCell.takePhotoIcon = settings.takePhotoIcon
        
        return cameraCell
    }
    
    func registerCellIdentifiersForCollectionView(_ collectionView: UICollectionView?) {
        collectionView?.register(UINib(nibName: "CameraCell", bundle: BSImagePickerViewController.bundle), forCellWithReuseIdentifier: cameraCellIdentifier)
    }
}
