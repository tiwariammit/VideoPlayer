//
//  ViewController.swift
//  ATVideoPlayer
//
//  Created by Amrit Tiwari on 4/18/18.
//  Copyright © 2018 tiwariammit@gmail.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    
    let videoController = ATVideoPlayerView.loadFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        videoController.delegate = self
        self.videoView.addSubview(videoController)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoController.reInitiallizeObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let urlTestDemo = "http://www.streambox.fr/playlists/test_001/stream.m3u8";

//        let urlTestDemo = "http://jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v"
        let url = URL(string: urlTestDemo)
        
        videoController.playVideo(url!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        videoController.removeObserverAndPlayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIApplication.shared.statusBarOrientation.isPortrait{
            let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height * 0.5)
            self.videoView.bounds = frame
            self.videoController.videoProtraitModeScreenFrame = frame
        }else{
            
            let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.videoView.frame = frame
            self.videoController.videoLandScapeModeScreenFrame = frame
        }
    }
}

extension ViewController : ATVideoPlayerViewDelegate{
    
    func btnShowErrorMessageTouched(){
        
        let urlTestDemo = "http://jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v"
        let url = URL(string: urlTestDemo)
        
        videoController.playVideo(url!)
    }
}
