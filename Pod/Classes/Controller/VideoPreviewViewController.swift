//
//  VideoPreviewViewController.swift
//  Pods
//
//  Created by Henrique Ormonde on 25/09/15.
//
//


import UIKit
import AVKit
import AVFoundation

final class VideoPreviewViewController : AVPlayerViewController {
    
    override var player: AVPlayer? {
        didSet {
            if let avpVC = self.childViewControllers.first as? AVPlayerViewController {
                DispatchQueue.main.async {
                    avpVC.player = self.player
                }
            }
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        view.backgroundColor = UIColor.white
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(VideoPreviewViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton;
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.player?.play();
    }
    
    func back(_ sender: UIBarButtonItem) {
        self.player?.pause()
        // Go back to the previous ViewController
        self.navigationController?.popViewController(animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
    }
}

