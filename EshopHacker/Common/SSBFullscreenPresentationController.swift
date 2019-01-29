//
//  SSBFullscreenPresentationController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import SnapKit

class SSBFullscreenPresentationController: UIPresentationController {

    let dimmingView = UIView()
    private let targetFrame: CGRect
    
    init(targetFrame: CGRect = UIScreen.main.bounds, presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.targetFrame = targetFrame
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        dimmingView.alpha = 0
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        dimmingView.snp.makeConstraints { $0.edges.equalTo(0) }
        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1
            }, completion: nil)
        } else {
            dimmingView.alpha = 1
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0
            }, completion: nil)
        } else {
            dimmingView.alpha = 1
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return targetFrame.size;
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return targetFrame
    }
}
