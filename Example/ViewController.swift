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
import BSImagePicker
import Photos

class ViewController: UIViewController {
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 2
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image, .video]
        present(imagePicker, animated: true)
        //        let vc = BSImagePickerViewController()
        //        vc.settings.selection.max = 6
        //
        //        bs_presentImagePickerController(vc, animated: true,
        //            select: { (asset: PHAsset) -> Void in
        //                print("Selected: \(asset)")
        //            }, deselect: { (asset: PHAsset) -> Void in
        //                print("Deselected: \(asset)")
        //            }, cancel: { (assets: [PHAsset]) -> Void in
        //                print("Cancel: \(assets)")
        //            }, finish: { (assets: [PHAsset]) -> Void in
        //                print("Finish: \(assets)")
        //            }, completion: nil)
    }
    
    @IBAction func showCustomImagePicker(_ sender: UIButton) {
        //        let vc = BSImagePickerViewController()
        //        vc.settings.selection.max = 6
        //        vc.settings.camera.icon = UIImage(named: "chat")
        //
        //        vc.albumButton.tintColor = UIColor.green
        //        vc.cancelButton.tintColor = UIColor.red
        //        vc.doneButton.tintColor = UIColor.purple
        //        vc.settings.selection.character = "✓"
        //        vc.settings.selection.fillColor = UIColor.gray
        //        vc.settings.selection.strokeColor = UIColor.yellow
        //        vc.settings.selection.shadowColor = UIColor.red
        //        vc.settings.selection.textAttributes[NSAttributedString.Key.foregroundColor] = UIColor.lightGray
        //        vc.settings.list.cellsPerRow = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
        //            switch (verticalSize, horizontalSize) {
        //            case (.compact, .regular): // iPhone5-6 portrait
        //                return 2
        //            case (.compact, .compact): // iPhone5-6 landscape
        //                return 2
        //            case (.regular, .regular): // iPad portrait/landscape
        //                return 3
        //            default:
        //                return 2
        //            }
        //        }
        //
        //        bs_presentImagePickerController(vc, animated: true,
        //            select: { (asset: PHAsset) -> Void in
        //                print("Selected: \(asset)")
        //            }, deselect: { (asset: PHAsset) -> Void in
        //                print("Deselected: \(asset)")
        //            }, cancel: { (assets: [PHAsset]) -> Void in
        //                print("Cancel: \(assets)")
        //            }, finish: { (assets: [PHAsset]) -> Void in
        //                print("Finish: \(assets)")
        //            }, completion: nil)
    }
    
    @IBAction func showImagePickerWithSelectedAssets(_ sender: UIButton) {
        //        let allAssets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        //        var evenAssetIds = [String]()
        //
        //        allAssets.enumerateObjects({ (asset, idx, stop) -> Void in
        //            if idx % 2 == 0 {
        //                evenAssetIds.append(asset.localIdentifier)
        //            }
        //        })
        //
        //        let evenAssets = PHAsset.fetchAssets(withLocalIdentifiers: evenAssetIds, options: nil)
        //
        //        let vc = BSImagePickerViewController()
        //        vc.defaultSelections = evenAssets
        //
        //        bs_presentImagePickerController(vc, animated: true,
        //          select: { (asset: PHAsset) -> Void in
        //            print("Selected: \(asset)")
        //          }, deselect: { (asset: PHAsset) -> Void in
        //            print("Deselected: \(asset)")
        //          }, cancel: { (assets: [PHAsset]) -> Void in
        //            print("Cancel: \(assets)")
        //          }, finish: { (assets: [PHAsset]) -> Void in
        //            print("Finish: \(assets)")
        //          }, completion: nil)
    }
}

