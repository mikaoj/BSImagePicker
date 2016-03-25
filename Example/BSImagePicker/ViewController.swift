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
    
    @IBAction func showImagePicker(sender: UIButton) {
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 6
        
        bs_presentImagePickerController(vc, animated: true,
            select: { (asset: PHAsset) -> Void in
                print("Selected: \(asset)")
            }, deselect: { (asset: PHAsset) -> Void in
                print("Deselected: \(asset)")
            }, cancel: { (assets: [PHAsset]) -> Void in
                print("Cancel: \(assets)")
            }, finish: { (assets: [PHAsset]) -> Void in
                print("Finish: \(assets)")
            }, completion: nil)
    }
    
    @IBAction func showCustomImagePicker(sender: UIButton) {
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 6
        vc.takePhotoIcon = UIImage(named: "chat")
        
        vc.albumButton.tintColor = UIColor.greenColor()
        vc.cancelButton.tintColor = UIColor.redColor()
        vc.doneButton.tintColor = UIColor.purpleColor()
        vc.selectionCharacter = "✓"
        vc.selectionFillColor = UIColor.grayColor()
        vc.selectionStrokeColor = UIColor.yellowColor()
        vc.selectionShadowColor = UIColor.redColor()
        vc.selectionTextAttributes[NSForegroundColorAttributeName] = UIColor.lightGrayColor()
        vc.cellsPerRow = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
            switch (verticalSize, horizontalSize) {
            case (.Compact, .Regular): // iPhone5-6 portrait
                return 2
            case (.Compact, .Compact): // iPhone5-6 landscape
                return 2
            case (.Regular, .Regular): // iPad portrait/landscape
                return 3
            default:
                return 2
            }
        }
        
        bs_presentImagePickerController(vc, animated: true,
            select: { (asset: PHAsset) -> Void in
                print("Selected: \(asset)")
            }, deselect: { (asset: PHAsset) -> Void in
                print("Deselected: \(asset)")
            }, cancel: { (assets: [PHAsset]) -> Void in
                print("Cancel: \(assets)")
            }, finish: { (assets: [PHAsset]) -> Void in
                print("Finish: \(assets)")
            }, completion: nil)
    }
  
    @IBAction func showImagePickerWithSelectedAssets(sender: UIButton) {
        let allAssets = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
        var evenAssetIds = [String]()
      
        allAssets.enumerateObjectsUsingBlock { (asset, idx, stop) -> Void in
          if let asset = asset as? PHAsset where idx % 2 == 0 {
            evenAssetIds.append(asset.localIdentifier)
          }
        }
      
        let evenAssets = PHAsset.fetchAssetsWithLocalIdentifiers(evenAssetIds, options: nil)
      
        let vc = BSImagePickerViewController()
        vc.defaultSelections = evenAssets
      
        bs_presentImagePickerController(vc, animated: true,
          select: { (asset: PHAsset) -> Void in
            print("Selected: \(asset)")
          }, deselect: { (asset: PHAsset) -> Void in
            print("Deselected: \(asset)")
          }, cancel: { (assets: [PHAsset]) -> Void in
            print("Cancel: \(assets)")
          }, finish: { (assets: [PHAsset]) -> Void in
            print("Finish: \(assets)")
          }, completion: nil)
      
    }
}

