//
//  SAHistoryNavigationTransitionController.swift
//  SAHistoryNavigationViewController
//
//  Created by 鈴木大貴 on 2015/05/26.
//  Copyright (c) 2015年 鈴木大貴. All rights reserved.
//

import UIKit

class SAHistoryNavigationTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
    //MARK: - Static constants
    private struct Const {
        static let defaultDuration: NSTimeInterval = 0.3
    }
        
    //MARK: - Properties
    private(set) var navigationControllerOperation: UINavigationControllerOperation
    private var currentTransitionContext: UIViewControllerContextTransitioning?
    private var backgroundView: UIView?
    private var alphaView: UIView?
    
    //MARK: - Initializers
    required init(operation: UINavigationControllerOperation) {
        navigationControllerOperation = operation
        super.init()
    }
    
    //MARK: Life cycle
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return Const.defaultDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)?.view,
            let toView = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view
        else { return }
        
        let containerView = transitionContext.containerView()
        currentTransitionContext = transitionContext
        switch navigationControllerOperation {
            case .Push:
                pushAnimation(transitionContext, toView: toView, fromView: fromView, containerView: containerView)
            case .Pop:
                popAnimation(transitionContext, toView: toView, fromView: fromView, containerView: containerView)
            case .None:
                let cancelled = transitionContext.transitionWasCancelled()
                transitionContext.completeTransition(!cancelled)
        }
    }

    func forceFinish() {
        let navigationControllerOperation = self.navigationControllerOperation
        guard let backgroundView = backgroundView, let alphaView = alphaView else { return }
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64((Const.defaultDuration + 0.1) * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue()) { [weak self] in
            guard let currentTransitionContext = self?.currentTransitionContext else { return }
            let toViewContoller = currentTransitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
            let fromViewContoller = currentTransitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
                
            guard let fromView = fromViewContoller?.view, let toView = toViewContoller?.view else { return }
            switch navigationControllerOperation {
                case .Push:
                    self?.pushAniamtionCompletion(currentTransitionContext, toView: toView, fromView: fromView, backgroundView: backgroundView, alphaView: alphaView)
                case .Pop:
                    self?.popAniamtionCompletion(currentTransitionContext, toView: toView, fromView: fromView, backgroundView: backgroundView, alphaView: alphaView)
                case .None:
                    let cancelled = currentTransitionContext.transitionWasCancelled()
                    currentTransitionContext.completeTransition(!cancelled)
            }
            self?.currentTransitionContext = nil
            self?.backgroundView = nil
            self?.alphaView = nil
        }
    }

    //MARK: - Pop animations
    private func popAnimation(transitionContext: UIViewControllerContextTransitioning, toView: UIView, fromView: UIView, containerView: UIView) {
        let backgroundView = UIView(frame: containerView.bounds)
        backgroundView.backgroundColor = .blackColor()
        containerView.addSubview(backgroundView)
        self.backgroundView = backgroundView
        
        toView.frame = containerView.bounds
        containerView.addSubview(toView)
        
        let alphaView = UIView(frame: containerView.bounds)
        alphaView.backgroundColor = .blackColor()
        containerView.addSubview(alphaView)
        self.alphaView = alphaView
        
        fromView.frame = containerView.bounds
        containerView.addSubview(fromView)
        
        let completion: (Bool) -> Void = { [weak self] finished in
            if finished {
                self?.popAniamtionCompletion(transitionContext, toView: toView, fromView: fromView, backgroundView: backgroundView, alphaView: alphaView)
            }
        }
        
        toView.frame.origin.x = -(toView.frame.size.width / 4.0)
        alphaView.alpha = 0.4
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, options: .CurveEaseOut, animations: {
            toView.frame.origin.x = 0
            fromView.frame.origin.x = containerView.frame.size.width
            alphaView.alpha = 0.0
        }, completion: completion)
    }
    
    private func popAniamtionCompletion(transitionContext: UIViewControllerContextTransitioning, toView: UIView, fromView: UIView, backgroundView: UIView, alphaView: UIView) {
        let cancelled = transitionContext.transitionWasCancelled()
        if cancelled {
            toView.transform = CGAffineTransformIdentity
            toView.removeFromSuperview()
        } else {
            fromView.removeFromSuperview()
        }
        
        backgroundView.removeFromSuperview()
        alphaView.removeFromSuperview()
        
        transitionContext.completeTransition(!cancelled)
        
        currentTransitionContext = nil
        self.backgroundView = nil
        self.alphaView = nil
    }

    //MARK: - pushAnimations
    private func pushAnimation(transitionContext: UIViewControllerContextTransitioning, toView: UIView, fromView: UIView, containerView: UIView) {
        let backgroundView = UIView(frame: containerView.bounds)
        backgroundView.backgroundColor = .blackColor()
        containerView.addSubview(backgroundView)
        self.backgroundView = backgroundView
        
        fromView.frame = containerView.bounds
        containerView.addSubview(fromView)
        
        let alphaView = UIView(frame: containerView.bounds)
        alphaView.backgroundColor = .blackColor()
        alphaView.alpha = 0.0
        containerView.addSubview(alphaView)
        self.alphaView = alphaView
        
        toView.frame = containerView.bounds
        toView.frame.origin.x = containerView.frame.size.width
        containerView.addSubview(toView)
        
        let completion: (Bool) -> Void = { [weak self] finished in
            if finished {
                self?.pushAniamtionCompletion(transitionContext, toView: toView, fromView: fromView, backgroundView: backgroundView, alphaView: alphaView)
            }
        }
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, options: .CurveEaseOut, animations: {
            fromView.frame.origin.x = -(fromView.frame.size.width / 4.0)
            toView.frame.origin.x = 0.0
            alphaView.alpha = 0.4
        }, completion: completion)
    }
    
    private func pushAniamtionCompletion(transitionContext: UIViewControllerContextTransitioning, toView: UIView, fromView: UIView, backgroundView: UIView, alphaView: UIView) {
        let cancelled = transitionContext.transitionWasCancelled()
        if cancelled {
            toView.removeFromSuperview()
        }
        
        fromView.transform = CGAffineTransformIdentity
        backgroundView.removeFromSuperview()
        fromView.removeFromSuperview()
        alphaView.removeFromSuperview()
        
        transitionContext.completeTransition(!cancelled)
        
        currentTransitionContext = nil
        self.backgroundView = nil
        self.alphaView = nil
    }
}
