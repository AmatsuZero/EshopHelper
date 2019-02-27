//
//  SSBCustomRefreshHeader.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/31.
//  Copyright © 2019 Daubert. All rights reserved.
//

import MJRefresh
import FontAwesome_swift

class SSBCustomRefreshHeader: MJRefreshHeader, CAAnimationDelegate {

    private let label = UILabel()
    private let imageView = UIImageView()
    var imageViewSize: CGFloat = 46
    var padding: CGFloat = 4

    private var sholudStop = false
    private var isRotating = false

    override func prepare() {
        super.prepare()

        mj_h = 80
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .darkGray
        addSubview(label)

        imageView.image = UIImage.fontAwesomeIcon(name: .redo,
                                                  style: .solid,
                                                  textColor: .eShopColor,
                                                  size: .init(width: imageViewSize, height: imageViewSize))
        addSubview(imageView)
    }

    override func placeSubviews() {
        super.placeSubviews()
        let top = bounds.midY - (imageViewSize + 16 + padding) / 2
        imageView.frame = CGRect(x: bounds.midX - imageViewSize / 2, y: top, width: imageViewSize, height: imageViewSize)
        label.frame = CGRect(x: 0, y: imageView.frame.maxY + padding, width: mj_w, height: 16)
    }

    override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                reset()
                label.text = "下拉刷新"
            case .pulling:
                reset()
                label.text = "松手开始"
            case .refreshing:
                imageView.layer.removeAllAnimations()
                label.text = "刷新中"
                startAnimation()
            case .willRefresh:
                reset()
                label.text = "即将刷新"
            case .noMoreData:
                reset()
                label.text = "没有更多数据了"
            }
        }
    }

    private func startAnimation() {
        guard !isRotating else {
            return
        }
        imageView.rotate360Degrees(completionDelegate: self)
        isRotating = true
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if sholudStop {
            reset()
        } else {
            imageView.rotate360Degrees(completionDelegate: self)
        }
    }

    override var pullingPercent: CGFloat {
        willSet {
            let animationGroup = CAAnimationGroup()

            let alpha = CABasicAnimation(keyPath: "alpha")
            alpha.fromValue = imageView.alpha
            alpha.toValue = pullingPercent
            alpha.fillMode = .forwards

            let rotate = CABasicAnimation(keyPath: "transform.rotation")
            rotate.fromValue = pullingPercent * .pi * 2
            rotate.toValue = newValue * .pi * 2
            rotate.fillMode = .forwards

            animationGroup.animations = [rotate, alpha]
            imageView.layer.add(animationGroup, forKey: nil)
        }
    }

    private func reset() {
        isRotating = false
        sholudStop = false
    }
}

class SSBCustomAutoFooter: MJRefreshAutoFooter, CAAnimationDelegate {

    private let label = UILabel()
    private let imageView = UIImageView()
    var imageViewSize: CGFloat = 40

    private var sholudStop = false
    private var isRotating = false

    var top: CGFloat = 0

    override func prepare() {
        super.prepare()

        mj_h = 50
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .darkGray
        addSubview(label)
        imageView.image = UIImage.fontAwesomeIcon(name: .redo,
                                                  style: .solid,
                                                  textColor: .eShopColor,
                                                  size: .init(width: imageViewSize, height: imageViewSize))
        addSubview(imageView)
    }

    override var pullingPercent: CGFloat {
        willSet {
            let animationGroup = CAAnimationGroup()

            let alpha = CABasicAnimation(keyPath: "alpha")
            alpha.fromValue = imageView.alpha
            alpha.toValue = pullingPercent
            alpha.fillMode = .forwards

            let rotate = CABasicAnimation(keyPath: "transform.rotation")
            rotate.fromValue = pullingPercent * .pi * 2
            rotate.toValue = newValue * .pi * 2
            rotate.fillMode = .forwards

            animationGroup.animations = [rotate, alpha]
            imageView.layer.add(animationGroup, forKey: nil)
        }
    }

    override var state: MJRefreshState {
        didSet {
            imageView.isHidden = false
            switch state {
            case .idle:
                reset()
                label.text = "上拉加载更多"
            case .pulling:
                reset()
                label.text = "松手开始"
            case .refreshing:
                imageView.layer.removeAllAnimations()
                label.text = "刷新中"
                startAnimation()
            case .willRefresh:
                reset()
                label.text = "即将刷新"
            case .noMoreData:
                reset()
                imageView.isHidden = true
                label.text = "没有更多数据了"
            }
        }
    }

    private func startAnimation() {
        guard !isRotating else {
            return
        }
        imageView.rotate360Degrees(completionDelegate: self)
        isRotating = true
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if sholudStop {
            reset()
        } else {
            imageView.rotate360Degrees(completionDelegate: self)
        }
    }

    override func placeSubviews() {
        super.placeSubviews()
        label.frame = CGRect(x: 0, y: top, width: mj_w, height: 14)
        imageView.frame = CGRect(x: bounds.midX - imageViewSize / 2, y: label.frame.maxY + 4, width: imageViewSize, height: imageViewSize)
    }

    private func reset() {
        isRotating = false
        sholudStop = false
    }
}

extension UIView {
    func rotate360Degrees(_ duration: CFTimeInterval = 1.0, completionDelegate: CAAnimationDelegate? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = .pi * 2.0
        rotateAnimation.duration = duration

        if let delegate: CAAnimationDelegate = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
