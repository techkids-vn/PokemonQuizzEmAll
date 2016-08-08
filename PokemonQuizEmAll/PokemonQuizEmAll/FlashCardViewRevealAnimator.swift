//
//  FlashCardViewRevealAnimator.swift
//  PokemonQuizEmAll
//
//  Created by AVAVT on 8/6/16.
//  Copyright © 2016 vu. All rights reserved.
//

import UIKit

class FlashCardViewRevealAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let animationDuration = 0.4
    var operation: UINavigationControllerOperation = .Push
    
    weak var storedContext: UIViewControllerContextTransitioning?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        storedContext = transitionContext
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = animationDuration
        animation.delegate = self
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        
        if operation == .Push {
            let toVC = transitionContext.viewControllerForKey( UITransitionContextToViewControllerKey) as! FlashCardViewController
            
            let scale = toVC.view.bounds.size.height*2/10
            
            transitionContext.containerView()?.addSubview(toVC.view)
            
            animation.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(0.1, 0.1, 1.0))
            animation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(scale, scale, 1.0))
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            
            toVC.maskLayer.addAnimation(animation, forKey: nil)
        }
        else if operation == .Pop {
            let fromVC = transitionContext.viewControllerForKey( UITransitionContextFromViewControllerKey) as! FlashCardViewController
            let toVC = transitionContext.viewControllerForKey( UITransitionContextToViewControllerKey) as! PlayViewController
            
            let scale = toVC.view.bounds.size.height*2/10
            
            transitionContext.containerView()?.addSubview(toVC.view)
            transitionContext.containerView()?.addSubview(fromVC.view)
            
            animation.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(scale, scale, 1.0))
            animation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(0.1, 0.1, 1.0))
            animation.timingFunction = CAMediaTimingFunction(name:
                kCAMediaTimingFunctionEaseOut)
            
            fromVC.maskLayer.addAnimation(animation, forKey: nil)
        }
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let context = storedContext {
            context.completeTransition(!context.transitionWasCancelled())
        }
        storedContext = nil
    }
}
