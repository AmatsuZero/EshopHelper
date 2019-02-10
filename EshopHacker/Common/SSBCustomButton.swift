//
//  SSBCustomButton.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/8.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

class SSBCustomButton: UIButton {
    
    class SSBBadgeLabel: UILabel {
        var contentEdgeInsets = UIEdgeInsets.zero {
            didSet {
                setNeedsDisplay()
            }
        }
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            var s = super.sizeThatFits(.init(width: size.width - contentEdgeInsets.horizontal,
                                             height: size.height - contentEdgeInsets.vertical))
            s.width += contentEdgeInsets.horizontal
            s.height += contentEdgeInsets.vertical
            return s
        }
    }

    enum ImagePosition {
        case left
        case right
        case top
        case bottom
    }
    
    ///  图片位置
    var buttonImagePosition = ImagePosition.left {
        didSet {
            setNeedsLayout()
        }
    }
    ///  文字颜色自动跟随tintColor调整,default NO
    var adjustsTitleTintColorAutomatically = false {
        didSet {
            updateTitleColorIfNeeded()
        }
    }
    /// 图片颜色自动跟随tintColor调整,default NO
   
    var adjustsImageTintColorAutomatically = false {
        didSet {
            let doesChanged = oldValue != adjustsImageTintColorAutomatically
            if doesChanged {
                updateImageRenderingModeIfNeeded()
            }
        }
    }
    /// default YES;相当于系统的adjustsImageWhenHighlighted
    var adjustsButtonWhenHighlighted = true
    /// default YES,相当于系统的adjustsImageWhenDisabled
    var adjustsButtonWhenDisabled = true
    /// 高亮状态button背景色，default nil，设置此属性后默认adjustsButtonWhenHighlighted=NO
    var highlightedBackgroundColor: UIColor? {
        didSet {
            if highlightedBackgroundColor != nil {
                // 只要开启了highlightedBackgroundColor, 就默认不需要alpha的高亮
                adjustsButtonWhenHighlighted = false
            }
        }
    }
    /// 高亮状态边框背景色，default nil，设置此属性后默认adjustsButtonWhenHighlighted=NO
    var highlightedBorderColor: UIColor? {
        didSet {
            if highlightedBorderColor != nil {
                // 只要开启了highlightedBorderColor, 就默认不需要alpha的高亮
                adjustsButtonWhenHighlighted = false
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted, originBorderColor == nil {
                // 手指在按钮上会不断触发highted的setter方法，所以这里设置了保护，设置过一次就不再设置了
                originBorderColor = UIColor(cgColor: layer.borderColor!)
            }
            
            // 渲染背景颜色
            if highlightedBackgroundColor != nil, highlightedBorderColor != nil {
                adjustButtonHighlighted()
            }
            
            // 如果此时是disbled，则disabled的样式优先
            guard isEnabled else {
                return
            }
            
            // 自定义highlighted样式
            if adjustsButtonWhenHighlighted {
                if isHighlighted {
                    alpha = 0.5
                } else {
                    UIView.animate(withDuration: 0.25) {
                        self.alpha = 1
                    }
                }
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if !isEnabled, adjustsButtonWhenDisabled {
                alpha = 0.5 // disabled的透明度
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.alpha = 0.5
                }
            }
        }
    }
    
    var badgeNumber: String = "" {
        didSet {
            badgeLabel.isHidden = badgeNumber.isEmpty
            badgeLabel.text = badgeNumber
            badgeLabel.sizeToFit()
            if badgeLabel.text?.count == 1 {
                let diameter = max(badgeLabel.bounds.width, badgeLabel.bounds.height)
                badgeLabel.frame = .init(x: badgeLabel.frame.minX, y: badgeLabel.frame.minY, width: diameter, height: diameter)
            }
            badgeLabel.layer.cornerRadius = (badgeLabel.bounds.height / 2).flat()
            badgeLabel.frame.origin = .init(x: imageView?.frame.maxX ?? 0 - 8, y: imageView?.frame.minY ?? 0 - 5)
        }
    }
    
    private var highlightedBackgroundLayer: CALayer?
    private var originBorderColor: UIColor?
    private lazy var badgeLabel: SSBBadgeLabel = {
        let label = SSBBadgeLabel()
        addSubview(label)
        label.backgroundColor = UIColor(r: 240, g: 71, b: 71)
        label.textColor = .white
        label.textAlignment = .center
        label.contentEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 11)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero)
        initialization()
    }
    
    func initialization() {
        tintColor = UIColor(r: 43, g: 133, b: 208)
        setTitleColor(tintColor, for: .normal)
        
        // 默认接管highlighted和disabled的表现，去掉系统默认的表现
        adjustsImageWhenDisabled = false
        adjustsImageWhenHighlighted = false
        adjustsButtonWhenDisabled = true
        adjustsButtonWhenHighlighted = true
        
        // iOS7以后的button，sizeToFit后默认会自带一个上下的contentInsets，为了保证按钮大小即为内容大小，这里直接去掉，改为一个最小的值。
        // 不能设为0，否则无效；也不能设置为小数点，否则无法像素对齐
        contentEdgeInsets = .init(top: 1, left: 0, bottom: 1, right: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds != .zero else {
            return
        }
        //默认布局不用处理
        guard buttonImagePosition != .left else {
            return
        }
        //content的实际size
        let contentSize = CGSize(width: bounds.width - contentEdgeInsets.horizontal, height: bounds.height - contentEdgeInsets.vertical)
        //垂直布局
        if buttonImagePosition == .top || buttonImagePosition == .bottom {
            let imageLimitWidth = contentSize.width - contentEdgeInsets.horizontal
            let imageSize = imageView?.sizeThatFits(.init(width: imageLimitWidth, height: .greatestFiniteMagnitude)) ?? .zero// 假设图片高度必定完整显示
            var imageFrame = CGRect(origin: .zero, size: imageSize)
            
            let titleLimitSize = CGSize(width: contentSize.width - titleEdgeInsets.horizontal,
                                        height: contentSize.height - imageEdgeInsets.vertical - imageSize.height - titleEdgeInsets.vertical)
            
            var titleSize = titleLabel?.sizeThatFits(titleLimitSize) ?? .zero
            titleSize.height = min(titleSize.height, titleLimitSize.height)
            var titleFrame = CGRect(origin: .zero, size: titleSize)
            
            //到这里image和title都是扣除了偏移量后的实际size，frame重置为x/y=0
            switch contentHorizontalAlignment {
            case .left:
                imageFrame.origin.x = contentEdgeInsets.left + imageEdgeInsets.left
                titleFrame.origin.x = contentEdgeInsets.left + titleEdgeInsets.left
            case .center:
                imageFrame.origin.x = contentEdgeInsets.left + imageEdgeInsets.left + imageLimitWidth.center(imageSize.width)
                titleFrame.origin.x = contentEdgeInsets.left + titleEdgeInsets.left + titleLimitSize.width.center(titleSize.width)
            case .right:
                imageFrame.origin.x = bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - imageSize.width
                titleFrame.origin.x = bounds.width - contentEdgeInsets.right - titleEdgeInsets.right - titleSize.width
            case .fill: // 此时要铺满button，所以要重置width
                imageFrame.origin.x = contentEdgeInsets.left + imageEdgeInsets.left
                imageFrame.size.width = imageLimitWidth
                titleFrame.origin.x = contentEdgeInsets.left + titleEdgeInsets.left
                titleFrame.size.width = titleLimitSize.width
            default:
                break
            }
            
            if buttonImagePosition == .top {// 重置Y坐标
                switch contentVerticalAlignment {
                case .top:
                    imageFrame.origin.y = contentEdgeInsets.top + imageEdgeInsets.top
                    titleFrame.origin.y = imageFrame.maxY + imageEdgeInsets.bottom + titleEdgeInsets.top
                case .center:
                    let contentHeight = imageFrame.height + imageEdgeInsets.vertical + titleFrame.height + titleEdgeInsets.vertical
                    let minY = contentSize.height.center(contentHeight) + contentEdgeInsets.top
                    imageFrame.origin.y = minY + imageEdgeInsets.top
                    titleFrame.origin.y = imageFrame.maxY + imageEdgeInsets.bottom + titleEdgeInsets.top
                case .bottom:
                    titleFrame.origin.y = bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.height
                    imageFrame.origin.y = titleFrame.minY - titleEdgeInsets.top - imageEdgeInsets.bottom - imageFrame.height
                case .fill: // 图片按自身大小显示，剩余空间标题填满
                    imageFrame.origin.y = contentEdgeInsets.top + imageEdgeInsets.top
                    titleFrame.origin.y = imageFrame.maxX + imageEdgeInsets.bottom + titleEdgeInsets.top
                    titleFrame.size.height = bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.minY
                default:
                    break
                }
            } else {
                switch contentVerticalAlignment {
                case .top:
                    titleFrame.origin.y = contentEdgeInsets.top + titleEdgeInsets.top
                    imageFrame.origin.y = titleFrame.maxY + titleEdgeInsets.bottom + imageEdgeInsets.top
                case .center:
                    let contentHeight = titleFrame.height + titleEdgeInsets.vertical + imageFrame.height + imageEdgeInsets.vertical
                    let minY = contentSize.height.center(contentHeight) + contentEdgeInsets.top
                    titleFrame.origin.y = minY + titleEdgeInsets.top
                    imageFrame.origin.y = titleFrame.maxY + titleEdgeInsets.bottom + imageEdgeInsets.top
                case .bottom:
                    imageFrame.origin.y = bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.height
                    titleFrame.origin.y = imageFrame.minY - imageEdgeInsets.top - titleEdgeInsets.bottom - titleFrame.height
                case .fill:
                    imageFrame.origin.y = bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.height
                    titleFrame.origin.y = contentEdgeInsets.top + titleEdgeInsets.top
                    titleFrame.size.height = imageFrame.minY - imageEdgeInsets.top - titleEdgeInsets.bottom - titleFrame.minY
                }
            }
            imageView?.frame = imageFrame.flatted()
            titleLabel?.frame = titleFrame.flatted()
        } else if buttonImagePosition == .right {// 水平布局
            let imageLimitHeight = contentSize.height - imageEdgeInsets.vertical
            let imageSize = imageView?.sizeThatFits(.init(width: .greatestFiniteMagnitude, height: imageLimitHeight)) ?? .zero // 假设图片宽度必须完整显示，高度不超过按钮内容
            var imageFrame = CGRect(origin: .zero, size: imageSize)
            
            let titleLimitSize = CGSize(width: contentSize.width - titleEdgeInsets.horizontal - imageFrame.width - imageEdgeInsets.horizontal, height: contentSize.height - titleEdgeInsets.vertical)
            var titleSize = titleLabel?.sizeThatFits(titleLimitSize) ?? .zero
            titleSize.height = min(titleSize.height, titleLimitSize.height)
            var titleFrame = CGRect(origin: .zero, size: titleSize)
            
            switch contentHorizontalAlignment {
            case .left:
                titleFrame.origin.x = contentEdgeInsets.left + titleEdgeInsets.left
                imageFrame.origin.x = titleFrame.maxX + titleEdgeInsets.right + imageEdgeInsets.left
            case .center:
                let contentWidth = titleFrame.width + titleEdgeInsets.horizontal + imageFrame.width + imageEdgeInsets.horizontal
                let minX = contentEdgeInsets.left + contentSize.width.center(contentWidth)
                titleFrame.origin.x = minX + titleEdgeInsets.left
                imageFrame.origin.x = imageFrame.maxX + titleEdgeInsets.right + imageEdgeInsets.left
            case .right:
                imageFrame.origin.x = bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - imageFrame.width
                titleFrame.origin.x = imageFrame.minX - imageEdgeInsets.left - titleEdgeInsets.right - titleFrame.width
            case .fill: // 图片按自身大小显示，剩余空间由标题占满
                switch contentVerticalAlignment {
                case .top:
                    titleFrame.origin.y = contentEdgeInsets.top + titleEdgeInsets.top
                    imageFrame.origin.y = contentEdgeInsets.top + imageEdgeInsets.top
                case .center:
                    titleFrame.origin.y = contentEdgeInsets.top + titleEdgeInsets.top + contentSize.height.center(titleFrame.height + titleEdgeInsets.vertical)
                    imageFrame.origin.y = contentEdgeInsets.top + imageEdgeInsets.top + contentSize.height.center(imageFrame.height + imageEdgeInsets.vertical)
                case .bottom:
                    titleFrame.origin.y = bounds.height  - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.height
                    imageFrame.origin.y = bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.height
                case .fill:
                    titleFrame.origin.y = contentEdgeInsets.top + titleEdgeInsets.top
                    titleFrame.size.height = bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.minY
                    imageFrame.origin.y = contentEdgeInsets.top + imageEdgeInsets.top
                    imageFrame.size.height = bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.minY
                }
            default:
                break
            }
            imageView?.frame = imageFrame.flatted()
            titleLabel?.frame = titleFrame.flatted()
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = size
        // 如果调用sizeToFit, 那么传进来的size就是当前size，此时的计算不要去限制宽高
        if bounds.size == size {
            size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        }
        
        var resultSize = CGSize.zero
        let contentLimitSize = CGSize(width: size.width - contentEdgeInsets.horizontal, height: size.height - contentEdgeInsets.vertical)
        switch buttonImagePosition {
        case .top, .bottom: // 图片和文字上下排版时，宽度已文字或图片的最大宽度为最大宽度
            let imageLimitWidth = contentLimitSize.width - imageEdgeInsets.horizontal
            let imageSize = imageView?.sizeThatFits(.init(width: imageLimitWidth, height: CGFloat.greatestFiniteMagnitude)) ?? .zero
            let titleLimitSize = CGSize(width: contentLimitSize.width - titleEdgeInsets.horizontal,
                                        height: contentLimitSize.height - imageEdgeInsets.vertical - imageSize.height - titleEdgeInsets.vertical)
            var titleSize = titleLabel?.sizeThatFits(titleLimitSize) ?? .zero
            titleSize.height = min(titleSize.height, titleLimitSize.height)
            
            resultSize.width = contentEdgeInsets.horizontal
            resultSize.width += max(imageEdgeInsets.horizontal + imageSize.width, titleEdgeInsets.horizontal + titleSize.width)
            resultSize.height = contentEdgeInsets.vertical + imageEdgeInsets.vertical + imageSize.height + titleEdgeInsets.vertical + titleSize.height
        case .left, .right:
            guard buttonImagePosition != .left || titleLabel?.numberOfLines != 1 else {
                return super.sizeThatFits(size)
            }
            // 图片和文字水平排版时，高度以文字或图片的最大高度为最终高度
            let imageLimitHeight = contentLimitSize.height - imageEdgeInsets.vertical
            let imageSize = imageView?.sizeThatFits(.init(width: .greatestFiniteMagnitude, height: imageLimitHeight))
            let titleLimitSize = CGSize(width: contentLimitSize.width - titleEdgeInsets.horizontal - (imageSize?.width ?? 0) - imageEdgeInsets.horizontal,
                                        height: contentLimitSize.height - titleEdgeInsets.vertical)
            var titleSize = titleLabel?.sizeThatFits(titleLimitSize) ?? .zero
            titleSize.height = min(titleSize.height, titleLimitSize.height)
            
            resultSize.width  = contentEdgeInsets.horizontal + imageEdgeInsets.horizontal + titleSize.width
            resultSize.height = contentEdgeInsets.vertical
            resultSize.height += max(imageEdgeInsets.vertical + (imageSize?.height ?? 0), titleEdgeInsets.vertical + titleSize.height)
        }
        return resultSize
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        var img = image
        if adjustsImageTintColorAutomatically {
            img = image?.withRenderingMode(.alwaysTemplate)
        }
        super.setImage(img, for: state)
    }
    
    private func adjustButtonHighlighted() {
        if let bgColor = highlightedBackgroundColor {
            if highlightedBackgroundLayer == nil {
                highlightedBackgroundLayer = CALayer() // 创建一个不带默认动画的Layere
                highlightedBackgroundLayer?.removeDefaultAnimations() // 移除系统默认的隐性动画
                layer.insertSublayer(highlightedBackgroundLayer!, at: 0) // 替换为自定义的Layer
            }
            // 为新的Layer添加属性
            highlightedBackgroundLayer?.frame = bounds
            highlightedBackgroundLayer?.cornerRadius = layer.cornerRadius
            highlightedBackgroundLayer?.backgroundColor = isHighlighted ? bgColor.cgColor : UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor
        }
        
        if let borderColor = highlightedBorderColor {
            layer.borderColor = isHighlighted ? borderColor.cgColor : originBorderColor!.cgColor
        }
    }
    
    // title的Color变化时调用
    private func updateTitleColorIfNeeded() {
        if adjustsTitleTintColorAutomatically {
            setTitleColor(tintColor, for: .normal)
        }
        if adjustsTitleTintColorAutomatically, let attrStr = currentAttributedTitle {
            let attributedString = NSMutableAttributedString(attributedString: attrStr)
            attributedString.addAttribute(.foregroundColor, value: tintColor, range: .init(location: 0, length: attributedString.length))
            setAttributedTitle(attributedString, for: .normal)
        }
    }
    
    func updateImageRenderingModeIfNeeded() {
        guard currentImage != nil else {
            return
        }
        
        let states: [UIControl.State] = [.normal, .highlighted, .disabled]
        for state in states {
            guard let image = image(for: state) else { continue }
            if adjustsTitleTintColorAutomatically {
                // 这里的Imgae不用做rendering的处理，而是放到重新的setImage:forState:方法里面
                setImage(image, for: state)
            } else {
                // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回original
                setImage(image.withRenderingMode(.alwaysOriginal), for: state)
            }
        }
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateTitleColorIfNeeded()
        if adjustsImageTintColorAutomatically {
            updateImageRenderingModeIfNeeded()
        }
    }
}

fileprivate extension CALayer {
    
    /// 把某个sublayer移动到当前所有sublayers的最后面
    ///
    /// - Parameter layer: 要被移动的layer
    /// - 要被移动的sublayer必须已经添加到当前layer上
    func sendSubLayerToBack(_ layer: CALayer)  {
        guard layer.superlayer == self else {
            return
        }
        layer.removeFromSuperlayer()
        insertSublayer(layer, at: 0)
    }
    
    ///  把某个sublayer移动到当前所有sublayers的最前面
    ///
    /// - Parameter layer: 要被移动的layer
    /// 要被移动的sublayer必须已经添加到当前layer上
    func bringToFront(_ layer: CALayer) {
        guard layer.superlayer == self else {
            return
        }
        layer.removeFromSuperlayer()
        layer.addSublayer(layer)
    }
    
    /// 移除 CALayer（包括 CAShapeLayer 和 CAGradientLayer）所有支持动画的属性的默认动画，方便需要一个不带动画的 layer 时使用。
    func removeDefaultAnimations() {
        var acts = [String: CAAction]()
        func addaction(_ selector: Selector, act: CAAction = NSNull()) {
            acts[NSStringFromSelector(selector)] = act
        }
        addaction(#selector(getter: bounds))
        addaction(#selector(setter: position))
        addaction(#selector(getter: zPosition))
        addaction(#selector(getter: anchorPoint))
        addaction(#selector(getter: anchorPointZ))
        addaction(#selector(getter: transform))
        addaction(#selector(getter: isHidden))
        addaction(#selector(getter: isDoubleSided))
        addaction(#selector(getter: sublayerTransform))
        addaction(#selector(getter: masksToBounds))
        addaction(#selector(getter: contents))
        addaction(#selector(getter: contentsRect))
        addaction(#selector(getter: contentsScale))
        addaction(#selector(getter: contentsCenter))
        addaction(#selector(getter: minificationFilterBias))
        addaction(#selector(getter: backgroundColor))
        addaction(#selector(getter: cornerRadius))
        addaction(#selector(getter: borderWidth))
        addaction(#selector(getter: borderColor))
        addaction(#selector(getter: opacity))
        addaction(#selector(getter: compositingFilter))
        addaction(#selector(getter: filters))
        addaction(#selector(getter: backgroundFilters))
        addaction(#selector(getter: shouldRasterize))
        addaction(#selector(getter: rasterizationScale))
        addaction(#selector(getter: shadowColor))
        addaction(#selector(getter: shadowOpacity))
        addaction(#selector(getter: shadowOffset))
        addaction(#selector(getter: shadowRadius))
        addaction(#selector(getter: shadowPath))
        
        if self is CAShapeLayer {
            addaction(#selector(getter: CAShapeLayer.path))
            addaction(#selector(getter: CAShapeLayer.fillColor))
            addaction(#selector(getter: CAShapeLayer.strokeColor))
            addaction(#selector(getter: CAShapeLayer.strokeStart))
            addaction(#selector(getter: CAShapeLayer.strokeEnd))
            addaction(#selector(getter: CAShapeLayer.lineWidth))
            addaction(#selector(getter: CAShapeLayer.miterLimit))
            addaction(#selector(getter: CAShapeLayer.lineDashPhase))
        }
        
        if self is CAGradientLayer {
            addaction(#selector(getter: CAGradientLayer.colors))
            addaction(#selector(getter: CAGradientLayer.locations))
            addaction(#selector(getter: CAGradientLayer.startPoint))
            addaction(#selector(getter: CAGradientLayer.endPoint))
        }
        self.actions = acts
    }
}

extension UIEdgeInsets {
    /// SwifterSwift: Return the vertical insets. The vertical insets is composed by top + bottom.
    ///
    public var vertical: CGFloat {
        // Source: https://github.com/MessageKit/MessageKit/blob/master/Sources/Extensions/UIEdgeInsets%2BExtensions.swift
        return top + bottom
    }
    
    /// SwifterSwift: Return the horizontal insets. The horizontal insets is composed by  left + right.
    ///
    public var horizontal: CGFloat {
        // Source: https://github.com/MessageKit/MessageKit/blob/master/Sources/Extensions/UIEdgeInsets%2BExtensions.swift
        return left + right
    }
}

extension CGFloat {
    
    func flat(scale: CGFloat = UIScreen.main.scale) -> CGFloat {
        return ceil(self * scale) / scale
    }
    
    func center(_ child: CGFloat) -> CGFloat {
        return ((self - child) / 2).flat()
    }
}

extension CGRect {
    func flatted() -> CGRect {
        return CGRect(x: minX.flat(), y: minY.flat(),
                      width: width.flat(), height: height.flat())
    }
}
