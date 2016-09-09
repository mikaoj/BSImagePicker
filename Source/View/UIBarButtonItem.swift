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

extension UIBarButtonItem {
    /**
     A UIBarButtonItem can shadow a UIButton. This method checks that.
     - parameter button: The button to check if being shadowed by this UIBarButtonItem
     - returns: A bool indicating if it is shadowing or not.
     */
    func shadows(button: UIButton) -> Bool {
        // Store previous values
        let wasEnabled = isEnabled
        let wasButtonEnabled = button.isEnabled

        // Set a known state for both buttons
        isEnabled = false
        button.isEnabled = false

        // Change one and see if other also changes
        isEnabled = true
        let isShadowingButton = button.isEnabled

        // Reset
        isEnabled = wasEnabled
        button.isEnabled = wasButtonEnabled

        return isShadowingButton
    }
}

extension UIBarButtonItem {
    /// Localized title for done button.
    @nonobjc static let localizedDoneTitle = UIBarButtonItem.doneLocalization()

    /// A little bit of voodoo for finding the system localization for 'Done'
    /// Quite resource heavy operation. So store the result.
    fileprivate static func doneLocalization() -> String {
        let navBar = UINavigationBar()
        let navItem = UINavigationItem()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        navItem.rightBarButtonItem = doneButton
        navBar.setItems([navItem], animated: false)

        for view in navBar.subviews {
            if let btn = view as? UIButton , doneButton.shadows(button: btn) {
                return btn.title(for: UIControlState()) ?? NSLocalizedString("Done", comment: "Done")
            }
        }

        return NSLocalizedString("Done", comment: "Done")
    }
}
