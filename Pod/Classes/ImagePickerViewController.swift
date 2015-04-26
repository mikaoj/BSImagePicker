import UIKit

public class ImagePickerViewController : UIViewController {
    let imagePickerViewName = "ImagePickerView"
    
    convenience init () {
        self.init(nibName: nil, bundle: nil)
    }

    required public convenience init(coder aDecoder: NSCoder) {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        // Get path for BSImagePicker bundle
        let bundlePath = NSBundle(forClass: ImagePickerViewController.self).pathForResource("BSImagePicker", ofType: "bundle")
        let bundle: NSBundle?
        
        // Load bundle
        if let bundlePath = bundlePath {
            bundle = NSBundle(path: bundlePath)
        } else {
            bundle = nil
        }
        
        // Call super with view name and bundle
        super.init(nibName: imagePickerViewName, bundle: bundle)
    }
}
