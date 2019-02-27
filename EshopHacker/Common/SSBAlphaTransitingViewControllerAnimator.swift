//
//  SSBRootViewControllerAnimator.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

class SSBAlphaTransitingViewControllerAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let isPresentation: Bool
    private let duration: TimeInterval

    init(isPresentation: Bool, duration: TimeInterval = 0.3) {
        self.isPresentation = isPresentation
        self.duration = duration
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let controller = isPresentation
            ? transitionContext.viewController(forKey: .to)
            : transitionContext.viewController(forKey: .from) else {
            return
        }
        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }
        let duration = transitionDuration(using: transitionContext)
        let initialAlpha: CGFloat = isPresentation ? 0.0 : 1.0
        let finalAlpha: CGFloat = isPresentation ? 1.0 : 0.0

        controller.view.alpha = initialAlpha
        UIView.animate(withDuration: duration, animations: {
             controller.view.alpha = finalAlpha
        }, completion: { isComplete in
            transitionContext.completeTransition(isComplete)
        })
    }
}
