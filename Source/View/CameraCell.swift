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

/**
 */
final class CameraCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var cameraBackground: UIView!
    var cameraImage: UIImage? {
        didSet {
            // Set image on image view and apply tint
            imageView.image = cameraImage?.withRenderingMode(.alwaysTemplate)
        }
    }

    var session: AVCaptureSession?
    var captureLayer: AVCaptureVideoPreviewLayer?
    let sessionQueue = DispatchQueue(label: "AVCaptureVideoPreviewLayer", attributes: [])

    override func awakeFromNib() {
        super.awakeFromNib()

        // Don't trigger camera access for the background if we don't have permission to!
        guard AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized else { return }

        // Prepare avcapture session
        session = AVCaptureSession()
        session?.sessionPreset = AVCaptureSessionPresetMedium

        // Hook upp device
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let input = try? AVCaptureDeviceInput(device: device)
        session?.addInput(input)

        // Setup capture layer
        guard let captureLayer = AVCaptureVideoPreviewLayer(session: session) else { return }
        captureLayer.frame = bounds
        captureLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraBackground.layer.addSublayer(captureLayer)

        self.captureLayer = captureLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        captureLayer?.frame = bounds
    }

    func startLiveBackground() {
        sessionQueue.async {
            self.session?.startRunning()
        }
    }

    func stopLiveBackground() {
        sessionQueue.async {
            self.session?.stopRunning()
        }
    }
}
