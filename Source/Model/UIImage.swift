// The MIT License (MIT)
//
// Copyright (c) 2016 Joakim Gyllström
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
import AVFoundation
import ImageIO

extension UIImage: Previewable {
    fileprivate static let scalingQueue = DispatchQueue(label: "BSImagePicker Scaling", attributes: [])

    func thumbnail(size: CGSize, contentMode: ContentMode, result: @escaping ((UIImage?) -> Void)) -> Int {
        // TODO: Scale
        // TODO: Cache result?
        UIImage.scalingQueue.async {
            // Calculate rect with maintained aspect ratio
            let targetAspectRatioSize = AVMakeRect(aspectRatio: self.size, insideRect: CGRect(x: 0, y: 0, width: size.width, height: size.height)).size
            
            guard let imageData = UIImageJPEGRepresentation(self, 1) else { return }
            guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil) else { return }
            let options: [NSString: Any] = [
                kCGImageSourceThumbnailMaxPixelSize: max(targetAspectRatioSize.width, targetAspectRatioSize.height) / 2.0,
                kCGImageSourceCreateThumbnailFromImageAlways: true
            ]
            
            guard let scaledCGImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary?) else { return }
            let scaledImage = UIImage(cgImage: scaledCGImage)
            DispatchQueue.main.async(execute: {
                result(scaledImage)
            })
        }

        return hash
    }
}
