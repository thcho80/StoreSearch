//
//  SlideOutAnimationController.swift
//  StoreSearch
//
//  Created by human on 2019. 1. 18..
//  Copyright © 2019년 com.humantrion. All rights reserved.
//

import UIKit

class SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
            let duration = transitionDuration(using: transitionContext)
            let containerView = transitionContext.containerView
            
            UIView.animate(withDuration: duration, animations: {
                fromView.center.y -= containerView.bounds.height
                fromView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }, completion: {finished in
                transitionContext.completeTransition(finished)
            })
        }
    }    
}
