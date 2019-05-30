//
//  PVAnimationTransitionController.swift
//  PictureViewer
//
//  Created by Zephyr on 2018/6/12.
//  Copyright © 2018年 Zephyr. All rights reserved.
//

import UIKit

protocol ZYAnimationTransitionControllerDelegate: NSObjectProtocol {
    func willPresent(fromView: UIView, toView: UIView)
    func onPresent(fromView: UIView, toView: UIView)
    func didPresent(fromView: UIView, toView: UIView)
    func willDismiss(fromView: UIView, toView: UIView)
    func onDismiss(fromView: UIView, toView: UIView)
    func didDismiss(fromView: UIView, toView: UIView)
}

class ZYAnimationTransitionController: NSObject {
    
    fileprivate var isPresenting = false
    weak var delegate: ZYAnimationTransitionControllerDelegate?
    
    func prepareForPresent() -> ZYAnimationTransitionController {
        isPresenting = true
        return self
    }
    
    func prepareForDismiss() -> ZYAnimationTransitionController {
        isPresenting = false
        return self
    }
    
    fileprivate func present(transitionContext: UIViewControllerContextTransitioning, container: UIView, fromView: UIView, toView: UIView, completion: @escaping () -> Void) {
        container.addSubview(toView)
        guard let delegate = delegate else { return }
        delegate.willPresent(fromView: fromView, toView: toView)
        self.startAnimation(transitionContext: transitionContext, animations: {
            delegate.onPresent(fromView: fromView, toView: toView)
        }) {
            delegate.didPresent(fromView: fromView, toView: toView)
            completion()
        }
    }
    
    fileprivate func dismiss(transitionContext: UIViewControllerContextTransitioning, container: UIView, fromView: UIView, toView: UIView, completion: @escaping () -> Void) {
        container.addSubview(fromView)
        guard let delegate = delegate else { return }
        delegate.willDismiss(fromView: fromView, toView: toView)
        self .startAnimation(transitionContext: transitionContext, animations: {
            delegate.onDismiss(fromView: fromView, toView: toView)
        }) {
            delegate.didDismiss(fromView: fromView, toView: toView)
            completion()
        }
    }
    
    fileprivate func startAnimation(transitionContext: UIViewControllerContextTransitioning, animations: @escaping () -> Void, completion: @escaping () -> Void) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        UIView.animate(withDuration: self.transitionDuration(using: self as? UIViewControllerContextTransitioning), delay: 0, options: UIView.AnimationOptions(rawValue: 7 << 16), animations: animations, completion: { _ in
            UIApplication.shared.endIgnoringInteractionEvents()
            completion()
        })
    }

}

extension ZYAnimationTransitionController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        if isPresenting {
            present(transitionContext: transitionContext, container: containerView, fromView: fromVC.view, toView: toVC.view) {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else {
            dismiss(transitionContext: transitionContext, container: containerView, fromView: fromVC.view, toView: toVC.view) {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
}
