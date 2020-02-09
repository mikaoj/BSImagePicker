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

import UIKit

extension ImagePickerController {
    @objc func albumsButtonPressed(_ sender: UIButton) {
        albumsViewController.albums = albums
        
        // Setup presentation controller
        albumsViewController.transitioningDelegate = dropdownTransitionDelegate
        albumsViewController.modalPresentationStyle = .custom
        rotateButtonArrow()
        
        present(albumsViewController, animated: true)
    }

    @objc func doneButtonPressed(_ sender: UIBarButtonItem) {
        imagePickerDelegate?.imagePicker(self, didFinishWithAssets: assetStore.assets)
        
        if settings.dismiss.enabled {
            dismiss(animated: true)
        }
    }

    @objc func cancelButtonPressed(_ sender: UIBarButtonItem) {
        imagePickerDelegate?.imagePicker(self, didCancelWithAssets: assetStore.assets)
        
        if settings.dismiss.enabled {
            dismiss(animated: true)
        }
    }
    
    func rotateButtonArrow() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let imageView = self?.albumButton.imageView else { return }
            imageView.transform = imageView.transform.rotated(by: .pi)
        }
    }
}
