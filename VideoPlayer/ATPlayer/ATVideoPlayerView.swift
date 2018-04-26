//
//  ATVideoPlayerView.swift
//  ATVideoPlayer
//
//  Created by Amrit Tiwari on 4/18/18.
//  Copyright © 2018 tiwariammit@gmail.com. All rights reserved.
//

import UIKit
import AVKit

@objc protocol ATVideoPlayerViewDelegate : class{
    @objc optional func errorMessage(_ errorMessage : String)
    @objc optional func playerDidFinishPlaying()
    @objc optional func btnShowErrorMessageTouched()
}

@objc public class ATVideoPlayerView: UIView {
    
    //MARK:- Outlets
    @IBOutlet weak var videoPlayerView: UIView!
    
    //for player
    fileprivate  var playerLayer : AVPlayerLayer?
    fileprivate var observer:Any?
    
    fileprivate lazy var btnPlayPause: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: self.heightAndWidthOfPlayAndExitButton, height: self.heightAndWidthOfPlayAndExitButton))
        btn.addTarget(self, action: #selector(self.btnPlayPauseTouched(_:)), for: .touchUpInside)
        btn.setImage(self.imagePause, for: .normal)
        return btn
    }()
    
    lazy var btnShowErrorMessage: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.width * 0.7, height: self.heightAndWidthOfPlayAndExitButton))
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.numberOfLines = 0
        btn.addTarget(self, action: #selector(self.btnShowErrorMessageTouched(_:)), for: .touchUpInside)
        return btn
    }()
    
    //timer to check the player items status (to find error on player)
    fileprivate  var timerTofindPlayerError : Timer?
    //timer to hide and show control items
    fileprivate var timerToHideAndShowControls : Timer?
    
    fileprivate var videoPlayerTapGuesture = UITapGestureRecognizer()
    
    //Below are the publicly change variable according to the user needs
    
    @objc public var atPlayer : AVPlayer?

    //this is the hide and width of play pause button and exit and enter full screen
    @objc public var heightAndWidthOfPlayAndExitButton: CGFloat = 44
    
    //for image
    @objc public var imagePlay = UIImage(named: "ATPlayerPlay.png")
    @objc public var imagePause = UIImage(named: "ATPlayerPause.png")
    
    @objc var videoControlView = VideoControlView.loadFromNib()
    @objc public var videoControlViewHeight : CGFloat = 50
    @objc public var controlViewColor : UIColor = UIColor(red: 0.016, green: 0.063, blue: 0.329, alpha: 1.00)
    
    @objc weak var delegate : ATVideoPlayerViewDelegate?
    
    //time to hide and show control view and play pause button
    @objc public var timeToHideAndShowControl : TimeInterval = 5
    
    @objc public lazy var activityIndicator: UIActivityIndicatorView = {
        
        let act = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        act.tintColor = UIColor.lightGray
        return act
    }()
    
    //frame static frame for ATVideoPlayer on Protrait mode
    //you can change it according to your demand from you view controller
    @objc public lazy var videoProtraitModeScreenFrame : CGRect = {
        
        if #available(iOS 11.0, *) {
            
            let viewFrameWithSafeArea = UIApplication.shared.keyWindow!.safeAreaLayoutGuide.layoutFrame
            let frame = CGRect(x: 0, y: 0, width: viewFrameWithSafeArea.width, height: viewFrameWithSafeArea.height * 0.5)
            return frame
        }else{
            
            let size = UIApplication.shared.keyWindow!.layoutMarginsGuide.layoutFrame
            let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height * 0.5)
            return frame
        }
    }()
    
    //frame static frame for ATVideoPlayer on landscape mode
    //you can change it according to your demand from you view controller
    @objc public lazy var videoLandScapeModeScreenFrame : CGRect = {
        
        if #available(iOS 11.0, *) {
            
            let viewFrameWithSafeArea = UIApplication.shared.keyWindow!.safeAreaLayoutGuide.layoutFrame
            
            let frame = CGRect(x: 0, y: 0, width: viewFrameWithSafeArea.width, height: viewFrameWithSafeArea.height)
            return frame
        }else{
            
            let size = UIApplication.shared.keyWindow!.layoutMarginsGuide.layoutFrame//UIScreen.main.bounds
            let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            return frame
        }
    }()
    
    
    @objc public class func loadFromNib() -> ATVideoPlayerView{
        
        return (Bundle.main.loadNibNamed("ATVideoPlayerView", owner: self, options: nil)?[0] as? ATVideoPlayerView)!
    }
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.addSubview(self.activityIndicator)
        self.addSubview(self.btnPlayPause)
        self.addSubview(self.btnShowErrorMessage)
        self.btnShowErrorMessage.setTitle("", for: .normal)
        self.btnPlayPause.isSelected = false
        
        self.videoControlView.backgroundColor = controlViewColor
        
        self.addSubview(self.videoControlView)
        self.videoControlView.sliderValueChanged = { [weak self] slider in
            
            self?.sliderValueChanged(slider)
        }
        
        self.videoPlayerTapGuesture.numberOfTapsRequired = 1
        self.videoPlayerTapGuesture.addTarget(self, action: #selector(self.viewTouched))
        self.addGestureRecognizer(self.videoPlayerTapGuesture)
        self.videoPlayerTapGuesture.cancelsTouchesInView = false
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.reframeVideoPlayer()
    }
    
    //MARK:- Reframe Video Player
    fileprivate func reframeVideoPlayer(){
        
        if UIApplication.shared.statusBarOrientation.isPortrait{
            
            let frameChangeDueToNavBar = CGRect(x: 0, y: 0, width: videoProtraitModeScreenFrame.width, height: videoProtraitModeScreenFrame.height)
            
            self.frame = frameChangeDueToNavBar
            
            self.videoPlayerView.frame = self.bounds
            self.playerLayer?.frame = self.videoPlayerView.bounds
            
            self.videoControlView.btnToggleScreen.setImage(self.videoControlView.imageFullScreen, for: .normal)
            self.videoControlView.videoControlViewWidthConstraint.constant = self.frame.width - 20
            
            let yPostionForVieoControlView = self.videoPlayerView.bounds.height - self.videoControlViewHeight
            self.videoControlView.frame = CGRect(x: 0, y: yPostionForVieoControlView, width: self.frame.width, height: self.videoControlViewHeight)
        }else{
            
            let appDelagate = UIApplication.shared.delegate as! AppDelegate
            let window = appDelagate.window
            
            var yPosition: CGFloat = 0
            var leading: CGFloat = 0
            var trailing: CGFloat = 0
            
            if #available(iOS 11.0, *) {
                if let bottom = window?.safeAreaInsets.bottom, bottom > 0{
                    yPosition = bottom
                }
                if let left = window?.safeAreaInsets.left, left > 0{
                    leading = left
                }
                
                if let left = window?.safeAreaInsets.left, left > 0{
                    trailing = left
                }
            }
            
            self.frame = videoLandScapeModeScreenFrame
            self.videoPlayerView.frame = self.frame
            self.playerLayer?.frame = self.videoPlayerView.bounds
            self.playerLayer?.frame.size.height = self.videoPlayerView.bounds.height - yPosition
            
            self.videoControlView.btnToggleScreen.setImage(self.videoControlView.imageFullScreenExit, for: .normal)
            
            let safeAreaWidth = leading + trailing
            self.videoControlView.videoControlViewWidthConstraint.constant = self.frame.width - 20 - safeAreaWidth
            
            self.videoControlView.frame = CGRect(x: leading, y: self.bounds.height - self.videoControlViewHeight - yPosition, width: self.frame.width - safeAreaWidth, height: self.videoControlViewHeight)
        }
        
        self.btnPlayPause.frame = CGRect(x: (self.videoPlayerView.frame.width/2) - heightAndWidthOfPlayAndExitButton/2, y: (self.videoPlayerView.frame.height/2) - heightAndWidthOfPlayAndExitButton/2, width: heightAndWidthOfPlayAndExitButton, height: heightAndWidthOfPlayAndExitButton)
        
        self.activityIndicator.frame = self.btnPlayPause.frame
        
        btnShowErrorMessage.frame = self.btnPlayPause.frame
        btnShowErrorMessage.frame.size.width = self.frame.width * 0.6
        btnShowErrorMessage.frame.origin.x = self.frame.width/2 - btnShowErrorMessage.frame.width/2
        
        self.layoutIfNeeded()
    }
    
    //MARK:- Video Player
    @objc public func playVideo(_ url : URL){
        
        if let observer = self.observer{
            
            self.atPlayer?.removeTimeObserver(observer)
        }
        self.observer = nil
        
        self.atPlayer?.pause()
        self.removeObserverAndPlayer()
        self.atPlayer = AVPlayer(url: url)
        self.playerLayer = AVPlayerLayer(player: atPlayer!)
        self.reframeVideoPlayer()
        self.playerLayer?.backgroundColor = UIColor.black.cgColor
        self.videoPlayerView.layer.addSublayer(playerLayer!)
        
        self.btnPlayPause.layer.zPosition = 4
        self.activityIndicator.layer.zPosition = 4
        self.videoControlView.layer.zPosition = 4
        self.btnShowErrorMessage.layer.zPosition = 4
        self.btnShowErrorMessage.isHidden = true
        
        self.atPlayer?.play()
        self.reInitiallizeObserver()
    }
    
    
    //MARK:- ***** Observer *****
    @objc public func reInitiallizeObserver(){
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self,selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: atPlayer?.currentItem)
        self.startTimerTofindPlayerError()
        self.obseverPlay(nil)
        self.startTimerToControlCustomControl()
    }
    
    
    // Observer Play of video
    fileprivate func obseverPlay(_ slider : UISlider?){
        
        if let observer = self.observer{
            
            self.atPlayer?.removeTimeObserver(observer)
        }
        self.observer = nil
        self.activityIndicator.startAnimating()
        
        self.observer = self.atPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 600), queue: DispatchQueue.main) { [weak self] time in
            
            guard let this = self else{
                return
            }
            let sliderValue : Float64 = CMTimeGetSeconds(time)
            
            this.videoControlView.movieSlider.value =  Float(sliderValue)
            this.setUpSliderTime()
            
            let playbackLikelyToKeepUp = this.atPlayer?.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == true{
                
                this.activityIndicator.stopAnimating()
            }else{
                
                this.activityIndicator.startAnimating()
            }
        }
    }
    
    
    //MARK:- ***** De-initiallized *****
    deinit {
        print("ATPlayer deinitiallized")
        self.removeObserverAndPlayer()
    }
    
    
    @objc public func removeObserverAndPlayer(){
        
        if let observer = self.observer{
            
            self.atPlayer?.removeTimeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
        
        atPlayer?.pause()
        atPlayer = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        self.timerToHideAndShowControls?.invalidate()
        self.timerToHideAndShowControls = nil
        
        self.timerTofindPlayerError?.invalidate()
        self.timerTofindPlayerError = nil
    }
    
    
    //MARK:- ***** Timer *****
    
    //MARK:- for know error in player
    fileprivate func startTimerTofindPlayerError(){
        self.timerTofindPlayerError?.invalidate()
        self.timerTofindPlayerError = nil
        self.timerTofindPlayerError = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerTofindPlayerErrorTrigger), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func timerTofindPlayerErrorTrigger(){
        
        guard let currentItems = self.atPlayer?.currentItem else{
            return
        }
        
        guard let error = currentItems.error else{
            return
        }
        
        let errorMessage = error.localizedDescription
        let message = errorMessage
        
        self.removeObserverAndPlayer()
        
        self.btnShowErrorMessage.isHidden = false
        
        self.btnShowErrorMessage.setTitle(errorMessage, for: .normal)
        self.delegate?.errorMessage?(message)
        self.playerSliderViewStatus(true)
        print("ATPlayer Error:- \(error)")
    }
    
    //MARK:- for hide and show control
    fileprivate func startTimerToControlCustomControl(){
        
        self.timerToHideAndShowControls?.invalidate()
        self.timerToHideAndShowControls = nil
        self.timerToHideAndShowControls = Timer.scheduledTimer(timeInterval: self.timeToHideAndShowControl, target: self, selector: #selector(self.timerTrigger), userInfo: nil, repeats: false)
    }
    
    
    @objc fileprivate func timerTrigger(){
        
        self.playerSliderViewStatus(true)
    }
    
    
    fileprivate func playerSliderViewStatus(_ isHidden : Bool){
        self.videoControlView.isHidden = isHidden
        self.btnPlayPause.isHidden = isHidden
    }
    
    //MARK:-Time set up of slider
    fileprivate func setUpSliderTime(){
        if let currentItem = self.atPlayer?.currentItem {
            // Get the current time in seconds
            let playhead = currentItem.currentTime().seconds
            let duration = currentItem.duration.seconds
            
            let timeFormat = TimeFormat()
            // Format seconds for human readable string
            
            if playhead.isFinite{
                self.videoControlView.lblCurrentTime.text = timeFormat.formatTimeFor(playhead)
            }
            
            if duration.isFinite{
                
                self.videoControlView.lblTotalTime.text = timeFormat.formatTimeFor(duration)
                self.videoControlView.movieSlider.maximumValue = Float(duration)
            }
        }
    }
    
    
    //MARK:-Observed Methods
    @objc fileprivate func btnPlayPauseTouched(_ sender: UIButton) {
        
        self.btnPlayPause.isSelected = !self.btnPlayPause.isSelected
        if btnPlayPause.isSelected{
            
            self.btnPlayPause.setImage(imagePlay, for: .normal)
            atPlayer?.pause()
        }else{
            
            atPlayer?.play()
            self.btnPlayPause.setImage(imagePause, for: .normal)
        }
        
        self.playerSliderViewStatus(false)
        self.startTimerToControlCustomControl()
    }
    
    
    //when rotating the device.
    @objc fileprivate func rotated() {
        
        if UIApplication.shared.statusBarOrientation.isPortrait{
            print("isPortrait")
        }else{
            
            print("Landscape")
        }
        reframeVideoPlayer()
    }
    
    
    @objc fileprivate func viewTouched(){
        
        if self.videoControlView.isHidden{
            
            self.playerSliderViewStatus(false)
            
        }else{
            
            self.playerSliderViewStatus(true)
        }
        self.startTimerToControlCustomControl()
    }
    
    //when player did finished playing
    @objc fileprivate func playerDidFinishPlaying(note: NSNotification){
        print("Video Finished")
        self.delegate?.playerDidFinishPlaying?()
    }
    
    
    @objc fileprivate func btnShowErrorMessageTouched(_ sender: UIButton){
        
        self.removeObserverAndPlayer()
        self.btnShowErrorMessage.isHidden = true
        self.delegate?.btnShowErrorMessageTouched?()
    }
    
    
    fileprivate func sliderValueChanged(_ slider : UISlider){
        
        if let observer = self.observer{
            
            self.atPlayer?.removeTimeObserver(observer)
        }
        self.observer = nil
        
        self.obseverPlay(slider)
        let seconds : Int64 = Int64(slider.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        
        self.activityIndicator.startAnimating()
        atPlayer?.seek(to: targetTime)
        atPlayer?.pause()
        
        if atPlayer?.rate == 0{
            atPlayer?.play()
        }
        
        slider.setValue(Float(seconds), animated: true)
        
        let playhead = Double(seconds)
        let timeFormat = TimeFormat()
        
        self.videoControlView.lblCurrentTime.text = timeFormat.formatTimeFor(playhead)
        self.btnPlayPause.isSelected = false
        self.btnPlayPause.setImage(self.imagePause, for: .normal)
        self.playerSliderViewStatus(false)
        self.startTimerToControlCustomControl()
    }
}


