//
//  SSBLaunchView.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit

class SSBLaunchView: UIView {

    private let animationLayer = CALayer()
    private let fixedHeight: CGFloat = 44
    private let duration: CFTimeInterval = 1
    private let label = UILabel()
    private var persistenceHelpers = [LayerPersistentHelper]()

    var fillColor = UIColor(r: 255, g: 156, b: 99) {
        didSet {
            animationLayer.sublayers?.forEach { $0.backgroundColor = fillColor.cgColor }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .eShopColor
        layer.addSublayer(animationLayer)

        addSubview(label)
        label.text = "eShop Helper"
        label.textColor = .white
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 26)
        label.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.bottom.equalTo(-20)
            make.right.equalTo(-20)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        animationLayer.frame = .init(origin: .zero, size: rect.size)

        let count = Int(rect.height / fixedHeight)

        // frame发生变化，或者屏幕转向发生变化，则需要重绘
        guard animationLayer.sublayers?.count ?? 0 != count ||
            animationLayer.frame.width != rect.width else {
            return
        }

        animationLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        animationLayer.sublayers?.removeAll()
        persistenceHelpers.removeAll()

        for (i, originY) in stride(from: 0, through: rect.height, by: fixedHeight).enumerated() {
            let bouncingLayer = CAShapeLayer()
            bouncingLayer.backgroundColor = fillColor.cgColor
            bouncingLayer.anchorPoint = .zero // 默认是在中间，这里需要设置为0.0
            bouncingLayer.frame = .init(x: 0, y: originY, width: rect.width, height: fixedHeight)

            let animation = CABasicAnimation(keyPath: "bounds.size.width")
            animation.duration = duration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.fromValue = 0
            animation.toValue = rect.width
            animation.beginTime = CACurrentMediaTime() + CFTimeInterval(i) * (duration / Double(count))
            animation.fillMode = CAMediaTimingFillMode.backwards
            animation.repeatCount = .greatestFiniteMagnitude
            animation.autoreverses = true

            bouncingLayer.add(animation, forKey: "bouncing_\(i)")

            animationLayer.addSublayer(bouncingLayer)
            // 添加前后台切换工具类
            let helper = LayerPersistentHelper(with: bouncingLayer)
            persistenceHelpers.append(helper)
        }
    }
}
