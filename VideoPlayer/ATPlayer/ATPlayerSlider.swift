//
//  ATPlayerSlider.swift
//  HighlightsNepal
//
//  Created by Creator-$ on 12/15/17.
//  Copyright © 2017 tiwariammit@gmail.com. All rights reserved.
//

import UIKit


public enum ATPlayerMediaFormat : String{
    case unknown
    case mpeg4
    case m3u8
    case mov
    case m4v
    case error
}


class ATPlayerUtils: NSObject {
    
    static func imageSize(image: UIImage, scaledToSize newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    static func decoderVideoFormat(_ URL: URL?) -> ATPlayerMediaFormat {
        if URL == nil {
            return .error
        }
        if let path = URL?.absoluteString{
            if path.contains(".mp4") {
                return .mpeg4
            } else if path.contains(".m3u8") {
                return .m3u8
            } else if path.contains(".mov") {
                return .mov
            } else if path.contains(".m4v"){
                return .m4v
            } else {
                return .unknown
            }
        } else {
            return .error
        }
    }
}


open class ATPlayerSlider: UISlider {
    
    open var progressView : UIProgressView = UIProgressView()
    
    public override init(frame: CGRect) {
//        self.progressView = UIProgressView()
        super.init(frame: frame)
        configureSlider()
        
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        configureSlider()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        self.progressView = UIProgressView()
        
        //fatalError("init(coder:) has not been implemented")
    }
    
    override open func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let rect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        let newRect = CGRect(x: rect.origin.x, y: rect.origin.y + 1, width: rect.width, height: rect.height)
        return newRect
    }
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.trackRect(forBounds: bounds)
        let newRect = CGRect(origin: rect.origin, size: CGSize(width: rect.size.width, height: 2.0))
        configureProgressView(newRect)
        return newRect
    }
    
    fileprivate func configureSlider() {
        minimumValue = 0.0
        value = 0.0
        
        minimumValue = 0
        maximumValue = 1.0 //Its depend upon

        minimumTrackTintColor = .red
        maximumTrackTintColor = .white
        isContinuous = true
        tintColor = .green
        
        let mask = CAGradientLayer(layer: self.layer)
        let lineTop = (self.bounds.height/2 - 0.5) / self.bounds.height
        mask.frame = self.bounds
        mask.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
//        mask.locations = [lineTop, lineTop] as [NSNumber]
      //  mask.backgroundColor = UIColor.appColor.cgColor
        self.layer.mask = mask
        
        let thumbImage = UIImage(named: "ic_slider_thumb.png")

        let normalThumbImage = ATPlayerUtils.imageSize(image: thumbImage!, scaledToSize: CGSize(width: 20, height: 20))
        setThumbImage(normalThumbImage, for: .normal)
        let highlightedThumbImage = ATPlayerUtils.imageSize(image: thumbImage!, scaledToSize: CGSize(width: 30, height: 30))
        setThumbImage(highlightedThumbImage, for: .highlighted)
//        thumbTintColor = .appColor

        //backgroundColor = UIColor.clear
        progressView.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7988548801)
        progressView.trackTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2964201627)
    }
    
    func configureProgressView(_ frame: CGRect) {
        progressView.frame = frame
        insertSubview(progressView, at: 0)
    }
    
    open func setProgress(_ progress: Float, animated: Bool) {
        progressView.setProgress(progress, animated: animated)
    }
}
