//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by human on 2019. 1. 16..
//  Copyright © 2019년 com.humantrion. All rights reserved.
//

import UIKit

class DimmingPresentationController:UIPresentationController {
    
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = (containerView?.bounds)!
        containerView?.insertSubview(dimmingView, at: 0)
        
        dimmingView.alpha = 0
        
        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: {_ in
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: {_ in
                self.dimmingView.alpha = 0
            }, completion: nil)
        }
    }
}
