//
//  ImageTransition.swift
//  ImageViewer
//
//  Created by Aman gupta on 03/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit

protocol ZoomImageDelegate: class {
    func zoomingImageView(for transition: ImageTransition) -> UIImageView?
}

enum TransitionState {
    case initial
    case final
}

class ImageTransition: NSObject {
    var transitionDuration = 0.5
    var navigationOperation: UINavigationController.Operation = .none
    let backgroundScale = CGFloat(0.7)
    
    func configureViews(for state: TransitionState, containerView: UIView, backgroundViewController: UIViewController, backgroundImageView: UIImageView, foregroundImageView: UIImageView, transitionImageView: UIImageView) {
        switch state {
            
        case .initial:
            backgroundViewController.view.transform = CGAffineTransform.identity
            backgroundViewController.view.alpha = 1
            
            transitionImageView.frame = containerView.convert(backgroundImageView.frame, from: backgroundImageView.superview)
            
        case .final:
            backgroundViewController.view.transform = CGAffineTransform(scaleX: backgroundScale, y: backgroundScale)
            backgroundViewController.view.alpha = 0
            
            if navigationOperation == .push {
                let topBarHeight = UIApplication.shared.statusBarFrame.size.height + 44
                transitionImageView.frame = CGRect(x: 0, y: topBarHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - topBarHeight)
            } else {
                //While transitioning back to small image
                let width = foregroundImageView.image?.size.width ?? 1
                
                let scale = foregroundImageView.frame.width / width
                
                let height = (foregroundImageView.frame.height) / scale
                
                
                transitionImageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
                transitionImageView.center = foregroundImageView.center
                
            }
        }
    }
    
}

//MARK: - UIViewControllerAnimatedTransitioning Methods
extension ImageTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let duration = transitionDuration(using: transitionContext)
        
        
        guard let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from) else {
                transitionContext.completeTransition(true)
                return
        }
        
        
        let containerView = transitionContext.containerView
        
        var backgroundVC = fromVC
        var foregroundVC = toVC
        
        //For simplicity we are considering the view controller to be backgroundVC and detailVC to be foregroundVC
        if navigationOperation == .pop {
            backgroundVC = toVC
            foregroundVC = fromVC
        }
        
        guard let backgroundImageView = (backgroundVC as? ZoomImageDelegate)?.zoomingImageView(for: self),
            let foregroundImageView = (foregroundVC as? ZoomImageDelegate)?.zoomingImageView(for: self) else {
                transitionContext.completeTransition(true)
                return
        }
        
        //Setting image so it does not feels jerky when high resolution image comes
        foregroundImageView.image = backgroundImageView.image
        
        //Creating transition image view
        let transitionImageView = UIImageView(image: backgroundImageView.image)
        transitionImageView.contentMode = navigationOperation == .pop ? .scaleAspectFit : .scaleAspectFill
        transitionImageView.clipsToBounds = true
        
        //Setting colours
        backgroundImageView.isHidden = true
        foregroundImageView.isHidden = true
        let foregroundViewBackgroundColor = foregroundVC.view.backgroundColor
        foregroundVC.view.backgroundColor = UIColor.clear
        containerView.backgroundColor = UIColor.white
        
        containerView.addSubview((backgroundVC.view))
        containerView.addSubview((foregroundVC.view))
        containerView.addSubview(transitionImageView)
        
        
        var preTransitionState = TransitionState.initial
        var postTransitionState = TransitionState.final
        
        if navigationOperation == .pop {
            preTransitionState = .final
            postTransitionState = .initial
        }
        
        
        configureViews(for: preTransitionState, containerView: containerView, backgroundViewController: backgroundVC, backgroundImageView: backgroundImageView, foregroundImageView: foregroundImageView, transitionImageView: transitionImageView)
        
        foregroundVC.view.layoutIfNeeded()
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            
            transitionImageView.contentMode = self.navigationOperation == .pop ? .scaleAspectFill : .scaleAspectFit
            
            self.configureViews(for: postTransitionState, containerView: containerView, backgroundViewController: backgroundVC, backgroundImageView: backgroundImageView, foregroundImageView: foregroundImageView, transitionImageView: transitionImageView)
            
        }) { (finished) in
            
            backgroundVC.view.transform = CGAffineTransform.identity
            transitionImageView.removeFromSuperview()
            backgroundImageView.isHidden = false
            foregroundImageView.isHidden = false
            foregroundVC.view.backgroundColor = foregroundViewBackgroundColor
            backgroundImageView.contentMode = .scaleAspectFill
            foregroundImageView.contentMode = .scaleAspectFit
            
            transitionContext.completeTransition(true)
        }
    }
}

// MARK: - UINavigationControllerDelegate Methods
extension ImageTransition: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is ZoomImageDelegate && toVC is ZoomImageDelegate {
            self.navigationOperation = operation
            return self
        } else {
            return nil
        }
    }
    
}


