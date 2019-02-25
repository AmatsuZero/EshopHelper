//
//  SSBGamePriceListModalViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/24.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

class SSBGameDetailModalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let isPresentation: Bool
    
    init(isPresentation: Bool) {
        self.isPresentation = isPresentation
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let controller = transitionContext.viewController(forKey: isPresentation ? .to : .from) else {
            return
        }
        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }
        let duration = transitionDuration(using: transitionContext)
        controller.view.alpha = isPresentation ? 0 : 1
        controller.view.frame = transitionContext.finalFrame(for: controller)
        UIView.animate(withDuration: duration, animations: {
            controller.view.alpha = self.isPresentation ? 1 : 0
        }) { flag in
            transitionContext.completeTransition(flag)
        }
    }
}

private let buttonSize: CGFloat = 52

class SSBGameDetailModalView: UIView {

    private let shapeLayer = CAShapeLayer()
    
    let closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.fontAwesomeIcon(name: .times, style: .solid, textColor: UIColor(r: 218, g: 219, b: 220),
                                             size: .init(width: buttonSize, height: buttonSize)), for: .normal)
        btn.backgroundColor = UIColor(r: 244, g: 245, b: 246)
        btn.layer.cornerRadius = buttonSize / 2
        btn.layer.masksToBounds = true
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        layer.mask = shapeLayer
        layer.masksToBounds = true
        backgroundColor = .white
        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(buttonSize)
            make.bottom.equalToSuperview().offset(-buttonSize/2)
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        UIColor.white.setFill()
        let radius: CGFloat = 76 / 2
        let frame = CGRect(origin: .zero, size: .init(width: rect.width, height: rect.height - radius))
        let path = UIBezierPath(roundedRect: frame, cornerRadius: 16)
        path.move(to: .init(x: frame.midX - radius, y: frame.maxY))
        path.addQuadCurve(to: .init(x: frame.midX + radius, y: frame.maxY), controlPoint: .init(x: frame.midX, y: radius + frame.maxY))
        path.fill()
        shapeLayer.path = path.cgPath
        shapeLayer.frame = frame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SSBGameDetailModalViewController: UIViewController {
    
    let contentView = SSBGameDetailModalView()
    
    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
        contentView.closeButton.addTarget(self, action: #selector(closePage(_:)), for: .touchUpInside)
    }
    
    override func loadView() {
        view = contentView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    @objc func closePage(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension SSBGameDetailModalViewController: UIViewControllerTransitioningDelegate, UIAdaptivePresentationControllerDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let padding: CGFloat = 14
        let bottom: CGFloat = {
            if #available(iOS 11.0, *) {
                return presented.view.safeAreaInsets.bottom + 125 + padding
            } else {
                return 125 + padding
            }
        }()
        let top: CGFloat = {
            if #available(iOS 11.0, *) {
                return presented.view.safeAreaInsets.top + 121 + padding
            } else {
                return CGFloat.statusBarHeight + 121 + padding
            }
        }()
        let presentationController = SSBFullscreenPresentationController(targetFrame: .init(origin: .init(x: padding, y: top),
                                                                                            size: .init(width: CGFloat.screenWidth - padding * 2,
                                                                                                        height: CGFloat.screenHeight - bottom - top)),
                                                                         presentedViewController: presented,
                                                                         presenting: presenting)
        presentationController.delegate = self
        return presentationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SSBGameDetailModalAnimator(isPresentation: false)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SSBGameDetailModalAnimator(isPresentation: true)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return traitCollection.verticalSizeClass == .compact ? .fullScreen : .none
    }
}

class SSBGamePriceListModalView: UIView {
    
}

class SSBGamePriceListModalViewController: SSBGameDetailModalViewController {
    
    init(dataSource: [GameInfoService.GameInfoData.Info.GamePrice]) {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
