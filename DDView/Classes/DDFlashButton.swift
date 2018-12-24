//
//  DDFlashButton.swift
//  DDJiaMi
//
//  Created by 风荷举 on 2018/12/23.
//  Copyright © 2018年 ddWorker. All rights reserved.
//

import UIKit

public class DDFlashButton: UIButton {
    
    public var flashPercent: Float = 2.14 {
        didSet { setupflashView() }
    }
    
    public var flashColor: UIColor = UIColor.orange.alpha(0.45) {
        didSet { flashView.backgroundColor = flashColor  }
    }
    
    public var flashBackgroundColor: UIColor = UIColor.blue {
        didSet { flashBackgroundView.backgroundColor = flashBackgroundColor }
    }
    
    public var buttonCornerRadius: Float = 0 {
        didSet{ layer.cornerRadius = CGFloat(buttonCornerRadius) }
    }
    
    public var flashOverBounds: Bool = false
    public var shadowflashRadius: Float = 0.1
    public var shadowflashEnable: Bool = true
    public var trackTouchLocation: Bool = true
    public var touchUpAnimationTime: Double = 0.6
    
    let flashView = UIView()
    let flashBackgroundView = UIView()
    
    fileprivate var tempShadowRadius: CGFloat = 0
    fileprivate var tempShadowOpacity: Float = 0
    fileprivate var touchCenterLocation: CGPoint?
    
    fileprivate var flashMask: CAShapeLayer? {
        get {
            if !flashOverBounds {
                let maskLayer = CAShapeLayer()
                maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
                return maskLayer
            } else {
                return nil
            }
        }
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    fileprivate func setup() {
        setupflashView()
        flashBackgroundView.backgroundColor = flashBackgroundColor
        flashBackgroundView.frame = bounds
        flashBackgroundView.addSubview(flashView)
        flashBackgroundView.alpha = 0
        addSubview(flashBackgroundView)
        layer.shadowRadius = 0
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).cgColor
    }
    
    fileprivate func setupflashView() {
        let size: CGFloat = bounds.width * CGFloat(flashPercent)
        let x: CGFloat = (bounds.width/2) - (size/2)
        let y: CGFloat = (bounds.height/2) - (size/2)
        let corner: CGFloat = size/2
        
        flashView.backgroundColor = flashColor
        flashView.frame = CGRect(x: x, y: y, width: size, height: size)
        flashView.layer.cornerRadius = corner
    }
    
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if trackTouchLocation {
            touchCenterLocation = touch.location(in: self)
        } else {
            touchCenterLocation = nil
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {
            self.flashBackgroundView.alpha = 1
        }, completion: nil)
        
        flashView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        
        
        UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseOut, .allowUserInteraction],
                       animations: {
                        self.flashView.transform = CGAffineTransform.identity
        }, completion: nil)
        
        if shadowflashEnable {
            tempShadowRadius = layer.shadowRadius
            tempShadowOpacity = layer.shadowOpacity
            
            let shadowAnim = CABasicAnimation(keyPath:"shadowRadius")
            shadowAnim.toValue = shadowflashRadius
            
            let opacityAnim = CABasicAnimation(keyPath:"shadowOpacity")
            opacityAnim.toValue = 1
            
            let groupAnim = CAAnimationGroup()
            groupAnim.duration = 0.7
            groupAnim.fillMode = .forwards
            groupAnim.isRemovedOnCompletion = false
            groupAnim.animations = [shadowAnim, opacityAnim]
            layer.add(groupAnim, forKey:"shadow")
        }
        return super.beginTracking(touch, with: event)
    }
    
    override public func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        animateToNormal()
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        animateToNormal()
    }
    
    fileprivate func animateToNormal() {
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {
            self.flashBackgroundView.alpha = 1
        }, completion: {(success: Bool) -> () in
            UIView.animate(withDuration: self.touchUpAnimationTime, delay: 0, options: .allowUserInteraction, animations: {
                self.flashBackgroundView.alpha = 0
            }, completion: nil)
        })
        
        UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction], animations: {
            self.flashView.transform = CGAffineTransform.identity
            let shadowAnim = CABasicAnimation(keyPath:"shadowRadius")
            shadowAnim.toValue = self.tempShadowRadius
            let opacityAnim = CABasicAnimation(keyPath:"shadowOpacity")
            opacityAnim.toValue = self.tempShadowOpacity
            let groupAnim = CAAnimationGroup()
            groupAnim.duration = 0.7
            groupAnim.fillMode = .forwards
            groupAnim.isRemovedOnCompletion = false
            groupAnim.animations = [shadowAnim, opacityAnim]
            self.layer.add(groupAnim, forKey:"shadowBack")
        }, completion: nil)
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        setupflashView()
        if let knownTouchCenterLocation = touchCenterLocation {
            flashView.center = knownTouchCenterLocation
        }
        flashBackgroundView.layer.frame = bounds
        flashBackgroundView.layer.mask = flashMask
    }
}
