//
//  CameraCell.swift
//  Pods
//
//  Created by Joakim Gyllström on 2015-09-26.
//
//

import UIKit
import AVFoundation

/**
*/
final class CameraCell: UICollectionViewCell {
    static let cellIdentifier = "cameraCellIdentifier"

    let imageView: UIImageView = UIImageView(frame: .zero)
    let cameraBackground: UIView = UIView(frame: .zero)
    
    var takePhotoIcon: UIImage? {
        didSet {
            imageView.image = takePhotoIcon
            
            // Apply tint to image
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    var session: AVCaptureSession?
    var captureLayer: AVCaptureVideoPreviewLayer?
    let sessionQueue = DispatchQueue(label: "AVCaptureVideoPreviewLayer", attributes: [])

    override init(frame: CGRect) {
        super.init(frame: frame)

        cameraBackground.frame = contentView.bounds
        cameraBackground.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(cameraBackground)
        imageView.frame = contentView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .center
        contentView.addSubview(imageView)

        setupCaptureLayer()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        captureLayer?.frame = bounds
    }
    
    func startLiveBackground() {
        sessionQueue.async { () -> Void in
            self.session?.startRunning()
        }
    }
    
    func stopLiveBackground() {
        sessionQueue.async { () -> Void in
            self.session?.stopRunning()
        }
    }

    private func setupCaptureLayer() {
        // Don't trigger camera access for the background
        guard AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized else {
            return
        }

        do {
            // Prepare avcapture session
            session = AVCaptureSession()
            session?.sessionPreset = AVCaptureSession.Preset.medium

            // Hook upp device
            let device = AVCaptureDevice.default(for: AVMediaType.video)
            let input = try AVCaptureDeviceInput(device: device!)
            session?.addInput(input)

            // Setup capture layer

            guard session != nil else {
                return
            }

            let captureLayer = AVCaptureVideoPreviewLayer(session: session!)
            captureLayer.frame = bounds
            captureLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            cameraBackground.layer.addSublayer(captureLayer)

            self.captureLayer = captureLayer
        } catch {
            session = nil
        }
    }
}
