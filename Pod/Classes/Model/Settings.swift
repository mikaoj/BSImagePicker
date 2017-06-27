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
The settings object that gets passed around between classes for keeping...settings
*/
final class Settings : BSImagePickerSettings {
    var maxNumberOfSelections: Int = Int.max
    var selectionCharacter: Character? = nil
    var selectionFillColor: UIColor = UIView().tintColor
    var selectionStrokeColor: UIColor = UIColor.white
    var selectionShadowColor: UIColor = UIColor.black
    var selectionTextAttributes: [String: AnyObject] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        return [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 10.0),
            NSParagraphStyleAttributeName: paragraphStyle,
            NSForegroundColorAttributeName: UIColor.white
        ]
    }()
    var cellsPerRow: (_ verticalSize: UIUserInterfaceSizeClass, _ horizontalSize: UIUserInterfaceSizeClass) -> Int = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
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
    
    var takePhotos: Bool = false
    
    var takePhotoIcon: UIImage? = UIImage(named: "add_photo", in: BSImagePickerViewController.bundle, compatibleWith: nil)
}
