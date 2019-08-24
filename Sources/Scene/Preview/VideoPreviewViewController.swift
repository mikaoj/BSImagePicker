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

import AVFoundation
import Foundation
import os
import Photos
import UIKit

class VideoPreviewViewController: PreviewViewController {
    private let playButton = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    private let playerView = PlayerView()
    private var pauseBarButton: UIBarButtonItem!
    
    enum Button {
        case none
        case play
        case pause
    }
    
    override var asset: PHAsset? {
        didSet {
            guard let asset = asset, asset.mediaType == .video else {
                player = nil
                return
            }
            
            PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (avasset, audioMix, arguments) in
                guard let avasset = avasset as? AVURLAsset else { return }
                
                DispatchQueue.main.async {
                    self.player = AVPlayer(url: avasset.url)
                }
            }
        }
    }
    
    private var player: AVPlayer? {
        didSet {
            guard let player = player else { return }
            playerView.player = player
            
            NotificationCenter.default.addObserver(self, selector: #selector(reachedEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch {
            os_log("Failed to set the audio session category for playback sound")
        }

        pauseBarButton = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(pausePressed(sender:)))
        
        playerView.frame = view.bounds
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(playerView)
        
        playButton.center = view.center
        playButton.backgroundColor = .blue
        playButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
        playButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playTapped(sender:))))
        view.addSubview(playButton)

        scrollView.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playerView.isHidden = true
        showButton(.none, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerView.isHidden = false
        showButton(.play, animated: false)
        view.sendSubviewToBack(imageView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playerView.isHidden = true
        player?.pause()
        showButton(.none, animated: false)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func showButton(_ button: Button, animated: Bool = true) {
        let updateButtons: () -> Void = {
            switch button {
            case .none:
                self.playButton.alpha = 0
                self.navigationItem.rightBarButtonItem = nil
            case .play:
                self.playButton.alpha = 1
                self.navigationItem.rightBarButtonItem = nil
            case .pause:
                self.playButton.alpha = 0
                self.navigationItem.rightBarButtonItem = self.pauseBarButton
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: updateButtons)
        } else {
            updateButtons()
        }
    }
    
    // MARK: React to events
    @objc func playTapped(sender: UIGestureRecognizer) {
        if player?.currentTime() == player?.currentItem?.duration {
            player?.seek(to: .zero)
        }
        
        player?.play()
        showButton(.pause)
        fullscreen = true
    }
    
    @objc func pausePressed(sender: UIBarButtonItem) {
        player?.pause()
        showButton(.play)
        fullscreen = false
    }
    
    @objc func reachedEnd(notification: Notification) {
        fullscreen = false
        showButton(.play)
    }
}
