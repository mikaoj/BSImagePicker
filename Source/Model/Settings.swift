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

import Foundation
import UIKit

public struct Settings {
    /// Maximum number of selections
    var maxSelections: Int
    
    /// Minimum number of selections
    var minSelections: Int
    
    /// Enabled camera
    var cameraEnabled: Bool
    
    /// Spacing between photos
    var spacing: Float
    
    /// Image to use for selections
    var selectionImage: UIImage
    
    /// Return how many cells per row you want to show for the given size classes
    var cellsPerRow: (_ verticalSize: UIUserInterfaceSizeClass, _ horizontalSize: UIUserInterfaceSizeClass) -> Int
}

extension Settings {
    static func classic() -> Settings {
        let image = UIImage(named: "Checkmark", in: Bundle.imagePicker, compatibleWith: nil)!
        return Settings(maxSelections: Int.max, minSelections: 1, cameraEnabled: false, spacing: 2, selectionImage: image) { (verticalSize, horizontalSize) -> Int in
            switch (verticalSize, horizontalSize) {
            case (.compact, .regular): // iPhone5-6 portrait
                return 3
            case (.compact, .compact): // iPhone5-6 landscape
                return 5
            case (.regular, .regular): // iPad portrait/landscape
                return 7
            default:
                return 3
            }
        }
    }
}
