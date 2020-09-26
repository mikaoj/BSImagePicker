// The MIT License (MIT)
//
// Copyright (c) 2019 Joakim Gyllström
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

extension ImagePickerController: AssetsViewControllerDelegate {
    func assetsViewController(_ assetsViewController: AssetsViewController, didSelectAsset asset: PHAsset) {
        if settings.selection.unselectOnReachingMax && assetStore.count > settings.selection.max {
            if let first = assetStore.removeFirst() {
                assetsViewController.unselect(asset:first)
                imagePickerDelegate?.imagePicker(self, didDeselectAsset: first)
            }
        }
        updatedDoneButton()
        imagePickerDelegate?.imagePicker(self, didSelectAsset: asset)

        if assetStore.count >= settings.selection.max {
            imagePickerDelegate?.imagePicker(self, didReachSelectionLimit: assetStore.count)
        }
    }

    func assetsViewController(_ assetsViewController: AssetsViewController, didDeselectAsset asset: PHAsset) {
        updatedDoneButton()
        imagePickerDelegate?.imagePicker(self, didDeselectAsset: asset)
    }

    func assetsViewController(_ assetsViewController: AssetsViewController, didLongPressCell cell: AssetCollectionViewCell, displayingAsset asset: PHAsset) {
        let previewViewController = PreviewBuilder.createPreviewController(for: asset, with: settings)
        
        zoomTransitionDelegate.zoomedOutView = cell.imageView
        zoomTransitionDelegate.zoomedInView = previewViewController.imageView
        
        pushViewController(previewViewController, animated: true)
    }
}
