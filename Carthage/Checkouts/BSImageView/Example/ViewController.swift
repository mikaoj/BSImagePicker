// The MIT License (MIT)
//
// Copyright (c) 2018 Joakim Gyllström
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
import BSImageView

class ViewController: UIViewController {
    @IBOutlet var bsImageView: BSImageView!
    @IBOutlet var uiImageView: UIImageView!
    @IBOutlet var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiImageView.contentMode = bsImageView.contentMode
        updateButton(contentMode: bsImageView.contentMode)
        
        bsImageView.layer.borderColor = UIColor.black.cgColor
        bsImageView.layer.borderWidth = 1
        bsImageView.layer.cornerRadius = 5
        uiImageView.layer.borderColor = UIColor.black.cgColor
        uiImageView.layer.borderWidth = 1
        uiImageView.layer.cornerRadius = 5
    }
    
    @IBAction func changeContentModeTapped(_ sender: UIButton) {
        let currentContentMode = bsImageView.contentMode
        var nextContentMode: UIView.ContentMode
        if currentContentMode.rawValue == 12 {
            nextContentMode = UIView.ContentMode(rawValue: 0)!
        } else {
            nextContentMode = UIView.ContentMode(rawValue: currentContentMode.rawValue + 1)!
        }
        
        if nextContentMode == .redraw {
            nextContentMode = UIView.ContentMode(rawValue: currentContentMode.rawValue + 2)!
        }
        
        self.updateButton(contentMode: nextContentMode)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.bsImageView.contentMode = nextContentMode
            self.uiImageView.contentMode = nextContentMode
        }) { (completed) in
            
        }
    }
    
    private func updateButton(contentMode: UIView.ContentMode) {
        button.setTitle("Content mode: \(contentMode)", for: .normal)
    }
}

extension UIView.ContentMode: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .scaleToFill:
            return "scaleToFill"
        case .scaleAspectFit:
            return "scaleAspectFit"
        case .scaleAspectFill:
            return "scaleAspectFill"
        case .redraw:
            return "redraw"
        case .center:
            return "center"
        case .top:
            return "top"
        case .bottom:
            return "bottom"
        case .left:
            return "left"
        case .right:
            return "right"
        case .topLeft:
            return "topLeft"
        case .topRight:
            return "topRight"
        case .bottomLeft:
            return "bottomLeft"
        case .bottomRight:
            return "bottomRight"
        }
    }
}
