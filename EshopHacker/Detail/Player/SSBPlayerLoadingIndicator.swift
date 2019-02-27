//
//  SSBPlayerLoadingIndicator.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/2.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

private let kRotationAnimationKey = "kRotationAnimationKey.rotation"

class SSBPlayerLoadingIndicator: UIView {

    fileprivate let indicatorLayer = CAShapeLayer()
    var timingFunction =  CAMediaTimingFunction(name: .easeInEaseOut)
    var isAnimating = false

    var lineWidth: CGFloat {
        get {
            return indicatorLayer.lineWidth
        }
        set {
            indicatorLayer.lineWidth = newValue
            updateIndicatorLayerPath()
        }
    }

    var strokeColor: UIColor {
        get {
            return UIColor(cgColor: indicatorLayer.strokeColor!)
        }
        set {
            indicatorLayer.strokeColor = newValue.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    convenience init() {
        self.init(frame: CGRect.zero)
        commonInit()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }

    func commonInit() {
        setupIndicatorLayer()
    }

    func setupIndicatorLayer() {
        indicatorLayer.strokeColor = UIColor.white.cgColor
        indicatorLayer.fillColor = nil
        indicatorLayer.lineWidth = 2.0
        indicatorLayer.lineJoin = CAShapeLayerLineJoin.round
        indicatorLayer.lineCap = CAShapeLayerLineCap.round
        layer.addSublayer(indicatorLayer)
        updateIndicatorLayerPath()
    }

    func updateIndicatorLayerPath() {
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let radius = min(self.bounds.width / 2, self.bounds.height / 2) - indicatorLayer.lineWidth / 2
        let startAngle: CGFloat = 0
        let endAngle: CGFloat = 2 * CGFloat(Double.pi)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        indicatorLayer.path = path.cgPath
        indicatorLayer.strokeStart = 0.1
        indicatorLayer.strokeEnd = 1.0
    }

    open func startAnimating() {
        if self.isAnimating {
            return
        }

        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 1
        animation.fromValue = 0
        animation.toValue = (2 * Double.pi)
        animation.repeatCount = Float.infinity
        animation.isRemovedOnCompletion = false
        indicatorLayer.add(animation, forKey: kRotationAnimationKey)
        isAnimating = true
    }

    open func stopAnimating() {
        if !isAnimating {
            return
        }
        indicatorLayer.removeAnimation(forKey: kRotationAnimationKey)
        isAnimating = false
    }
}
