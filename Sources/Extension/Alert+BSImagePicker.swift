// The MIT License (MIT)
//
// Copyright (c) 2021 Mithilesh Parmar
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
import Photos

extension AssetsViewController {
    internal func showAlertForRestricedOrNotDeterminedAccess(){

        let localizedTitle = NSLocalizedString("bsimagepicker.restrictedAccess.alert.title", comment: "Allow access to your photos")
        let localizedMessage = NSLocalizedString("bsimagepicker.restrictedAccess.alert.message", comment: "This lets you share from your camera roll and enables other features for photos. Go to your settings and tap \"Photos\".")
        let notNowLocalizedText = NSLocalizedString("bsimagepicker.restrictedAccess.alert.secondaryButton.title", comment: "Not now")
        let openSettinsgLocalizedText = NSLocalizedString("bsimagepicker.restrictedAccess.alert.openSettings.title", comment: "Open Settings")
        
        let alert = UIAlertController(title: localizedTitle, message: localizedMessage, preferredStyle: .alert)
        
        let notNowAction = UIAlertAction(title: notNowLocalizedText, style: .cancel, handler: nil)
        alert.addAction(notNowAction)
        
        let openSettingsAction = UIAlertAction(title: openSettinsgLocalizedText, style: .default) { [unowned self] (_) in
            // Open app privacy settings
            gotoAppPrivacySettings()
        }
        alert.addAction(openSettingsAction)
        present(alert, animated: true, completion: nil)
    }
    
    internal func showAlerForLimitedAccess(){
        
        let localizedTitle = NSLocalizedString("bsimagepicker.limitedAccess.alert.title", comment: "")
        let localizedMessage = NSLocalizedString("bsimagepicker.limitedAccess.alert.message", comment: "Select more photos or go to Settings to allow access to all photos.")
        let selectMorePhotosLocalizedText = NSLocalizedString("bsimagepicker.limitedAccess.alert.selectMorePhotos", comment: "Select more photos")
        let allowAccessToAllPhotosLocalizedText = NSLocalizedString("bsimagepicker.limitedAccess.alert.allowAccessToAllPhotos", comment: "Allow access to all photos")
        
        let cancelLocalizedText = NSLocalizedString("bsimagepicker.cancel", comment: "Cancel")
        
        let actionSheet = UIAlertController(title: localizedTitle, message: localizedMessage, preferredStyle: .actionSheet)
        
        let selectPhotosAction = UIAlertAction(title: selectMorePhotosLocalizedText, style: .default) { [unowned self] (_) in
            // Show limited library picker
            if #available(iOS 14, *) {
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            }
        }
        actionSheet.addAction(selectPhotosAction)
        
        let allowFullAccessAction = UIAlertAction(title: allowAccessToAllPhotosLocalizedText, style: .default) { [unowned self] (_) in
            // Open app privacy settings
            self.gotoAppPrivacySettings()
        }
        actionSheet.addAction(allowFullAccessAction)
        
        let cancelAction = UIAlertAction(title: cancelLocalizedText, style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    internal func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            assertionFailure("Not able to open App privacy settings")
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
