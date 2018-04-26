//
//  ViewController1.swift
//  ATVideoPlayer
//
//  Created by Amrit Tiwari on 4/20/18.
//  Copyright © 2018 tiwariammit@gmail.com. All rights reserved.
//

import UIKit

class ViewController1: UIViewController {

    @IBOutlet weak var videoView: UIView!
    
    let videoController = ATVideoPlayerView.loadFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.videoView.addSubview(videoController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoController.reInitiallizeObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let urlTestDemo = "http://www.streambox.fr/playlists/test_001/stream.m3u8";
        let url = URL(string: urlTestDemo)
        
        videoController.playVideo(url!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoController.removeObserverAndPlayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let navBarAndStatusBarHeight : CGFloat = 44 + 20
        if UIApplication.shared.statusBarOrientation.isPortrait{
            
            let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height * 0.35)
            self.videoView.bounds = frame
            self.videoController.videoProtraitModeScreenFrame = frame
        }else{
            
            let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.videoView.frame = frame
            self.videoController.videoLandScapeModeScreenFrame = frame
        }
    }
    
    deinit {
        
        print("ViewController1 deinit")
    }

}
