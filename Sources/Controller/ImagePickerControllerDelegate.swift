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

/// Delegate of the image picker
public protocol ImagePickerControllerDelegate: class {
    /// An asset was selected
    /// - Parameter imagePicker: The image picker that asset was selected in
    /// - Parameter asset: selected asset
    func imagePicker(_ imagePicker: ImagePickerController, didSelectAsset asset: PHAsset)

    /// An asset was deselected
    /// - Parameter imagePicker: The image picker that asset was deselected in
    /// - Parameter asset: deselected asset
    func imagePicker(_ imagePicker: ImagePickerController, didDeselectAsset asset: PHAsset)

    /// User finished with selecting assets
    /// - Parameter imagePicker: The image picker that assets where selected in
    /// - Parameter assets: Selected assets
    func imagePicker(_ imagePicker: ImagePickerController, didFinishWithAssets assets: [PHAsset])

    /// User canceled selecting assets
    /// - Parameter imagePicker: The image picker that asset was selected in
    /// - Parameter assets: Assets selected when user canceled
    func imagePicker(_ imagePicker: ImagePickerController, didCancelWithAssets assets: [PHAsset])

    /// Selection limit reach
    /// - Parameter imagePicker: The image picker that selection limit was reached in.
    /// - Parameter count: Number of selected assets.
    func imagePicker(_ imagePicker: ImagePickerController, didReachSelectionLimit count: Int)
}
