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
    }
}
