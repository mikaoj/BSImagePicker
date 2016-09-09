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

/**
 Extension on UIButton for settings the title without an animation
 */
extension UIButton {
    /**
     Gives the options of settings button title with or without animation
     - parameter title: The String to use as title
     - parameter for: Which state it applies to
     - parameter animated: Should it be animated or not?
     */
    func setTitle(_ title: String?, for state: UIControlState, animated: Bool) {

        // Disable/enable animations
        let wasAnimated = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(animated)

        // Set title without the default animation
        setTitle(title, for: state)
        layoutIfNeeded()

        // Enable animations if animation where enabled before
        UIView.setAnimationsEnabled(wasAnimated)
    }
}
