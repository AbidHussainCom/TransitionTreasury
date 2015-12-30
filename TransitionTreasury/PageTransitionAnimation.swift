//
//  PageTransitionAnimation.swift
//  TransitionTreasury
//
//  Created by DianQK on 12/30/15.
//  Copyright © 2015 TransitionTreasury. All rights reserved.
//

import UIKit

public class PageTransitionAnimation: NSObject, TRViewControllerAnimatedTransitioning {
    
    public var transitionStatus: TransitionStatus?
    
    public var transitionContext: UIViewControllerContextTransitioning?
    
    public var percentTransition: UIPercentDrivenInteractiveTransition?
    /// 判断是否取消了 Pop
    public var cancelPop: Bool = false
    /// 判断是否在交互中
    public var interacting: Bool = false
    
    private lazy var maskView: UIView = {
        let maskView = UIView(frame: UIScreen.mainScreen().bounds)
        maskView.backgroundColor = UIColor.blackColor()
        return maskView
    }()
    
    public init(status: TransitionStatus = .Push) {
        transitionStatus = status
        super.init()
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.7
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        var fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        var toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let containView = transitionContext.containerView()
        
        var startPositionX: CGFloat = UIScreen.mainScreen().bounds.width
        var endPositionX: CGFloat = 0
        
        var startOpacity: Float = 0
        var endOpacity: Float = 0.3
        
        var transform3D: CATransform3D = CATransform3DIdentity
        transform3D.m34 = -1.0/500.0
        
        if transitionStatus == .Pop {
            swap(&fromVC, &toVC)
            swap(&startPositionX, &endPositionX)
            swap(&startOpacity, &endOpacity)
        } else {
            transform3D = CATransform3DTranslate(transform3D, 0, 0, -35)
        }
        
        containView?.addSubview(fromVC!.view)
        containView?.addSubview(toVC!.view)
        fromVC?.view.addSubview(maskView)
        
        maskView.layer.opacity = startOpacity
        toVC?.view.layer.position.x = startPositionX + toVC!.view.layer.bounds.width / 2
        toVC?.view.layer.shadowOpacity = 0.5
        toVC?.view.layer.shadowOffset = CGSize(width: -3, height: 0)
        toVC?.view.layer.shadowRadius = 5
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveEaseInOut, animations: {
            self.maskView.layer.opacity = endOpacity
            fromVC?.view.layer.transform = transform3D
            toVC?.view.layer.position.x = endPositionX + toVC!.view.layer.bounds.width / 2
            }) { (finished) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                toVC?.view.layer.shadowOpacity = 0
                if self.transitionStatus == .Pop && finished {
                    self.maskView.removeFromSuperview()
                }
        }
    }
    
}
