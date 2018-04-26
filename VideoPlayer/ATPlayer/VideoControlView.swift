//
//  VideoControlView.swift
//  ATVideoPlayer
//
//  Created by Amrit Tiwari on 4/20/18.
//  Copyright © 2018 tiwariammit@gmail.com. All rights reserved.
//

import UIKit

@objc class VideoControlView: UIView {
    
    //    @IBOutlet weak var videoControlView: UIView!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var movieSlider: ATPlayerSlider!
    @IBOutlet weak var lblTotalTime: UILabel!
    @IBOutlet weak var btnToggleScreen: UIButton!
    
    @IBOutlet weak var videoControlViewWidthConstraint: NSLayoutConstraint!
    
    fileprivate var sliderTapGuesture = UITapGestureRecognizer()
    
    @objc public var imageFullScreen = UIImage(named: "ATPlayerFullScreen.png")
    @objc public var imageFullScreenExit = UIImage(named: "ATPlayerFullScreenExit.png")
    
    @objc public var sliderValueChanged : ((ATPlayerSlider)->())?
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        movieSlider?.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        
        self.sliderTapGuesture.numberOfTapsRequired = 1
        self.sliderTapGuesture.addTarget(self, action: #selector(self.playbackSliderTouched(sender:)))
        self.movieSlider?.addGestureRecognizer(self.sliderTapGuesture)
        self.sliderTapGuesture.cancelsTouchesInView = false
        self.btnToggleScreen.isSelected = false
        self.btnToggleScreen.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    
    @objc public class func loadFromNib() -> VideoControlView{
        
        return (Bundle.main.loadNibNamed("VideoControlView", owner: self, options: nil)?[0] as? VideoControlView)!
    }
    
    
    @objc fileprivate func playbackSliderValueChanged(_ slider:ATPlayerSlider){
        
        self.sliderValueChanged?(slider)
    }
    
    
    @objc fileprivate func playbackSliderTouched(sender: UITapGestureRecognizer){
        
        guard let slider = sender.view as? ATPlayerSlider else{
            
            return
        }
        
        if slider.isHighlighted { return }
        
        let point = sender.location(in: slider)
        let percentage = Float(point.x / slider.bounds.width)
        let delta = percentage * (slider.maximumValue - slider.minimumValue)
        let value = slider.minimumValue + delta
        slider.setValue(value, animated: true)
        self.sliderValueChanged?(slider)
    }
    
    
    //MARK:- Actions
    @IBAction fileprivate func btnToggleScreenTouched(_ sender: UIButton) {
        
        self.btnToggleScreen.isSelected  = !self.btnToggleScreen.isSelected
        if btnToggleScreen.isSelected{
            
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            self.btnToggleScreen.setImage(imageFullScreenExit, for: .normal)
        }else{
            
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            self.btnToggleScreen.setImage(imageFullScreen, for: .normal)
        }
    }
}

