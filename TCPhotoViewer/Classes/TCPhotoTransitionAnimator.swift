//
//  TCPhotoTransitionAnimator.swift
//  TCPhotoViewer
//
//  Created by Tiziano Coroneo on 25/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import UIKit

let tcPhotoTransitionAnimatorDurationWithZooming: TimeInterval = 0.5
let tcPhotoTransitionAnimatorDurationWithoutZooming: TimeInterval = 0.3
let tcPhotoTransitionAnimatorBackgroundFadeDurationRatio: TimeInterval = 4.0 / 9.0
let tcPhotoTransitionAnimatorEndingViewFadeInDurationRatio: TimeInterval = 0.1
let tcPhotoTransitionAnimatorStartingViewFadeOutDurationRatio: TimeInterval = 0.05
let tcPhotoTransitionAnimatorSpringDamping: CGFloat = 0.9

class TCPhotoTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    var shouldPerformZoomingAnimation: Bool {
        return startingView != nil && endingView != nil
    }

    var startingView: UIView?
    var endingView: UIView?

    var startingViewForAnimation: UIView?
    var endingViewForAnimation: UIView?

    var isDismissing: Bool = false

    var animationDurationWithZooming: TimeInterval
    var animationDurationWithoutZooming: TimeInterval
    var animationDurationFadeRatio: TimeInterval
    var animationDurationEndingViewFadeInRatio: TimeInterval
    var animationDurationEndingViewFadeOutRatio: TimeInterval

    var zoomingAnimationSpringDamping: CGFloat

    override init() {
        animationDurationWithZooming = tcPhotoTransitionAnimatorDurationWithZooming
        animationDurationWithoutZooming = tcPhotoTransitionAnimatorDurationWithoutZooming
        animationDurationFadeRatio = tcPhotoTransitionAnimatorBackgroundFadeDurationRatio
        animationDurationEndingViewFadeInRatio = tcPhotoTransitionAnimatorEndingViewFadeInDurationRatio
        animationDurationEndingViewFadeOutRatio = tcPhotoTransitionAnimatorStartingViewFadeOutDurationRatio
        zoomingAnimationSpringDamping = tcPhotoTransitionAnimatorSpringDamping

        super.init()
    }

    func setupTransitionContainerHierarchy(
        withTransitionContext transitionContext: UIViewControllerContextTransitioning) {

        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to),
            let toViewController = transitionContext.viewController(forKey: .to)
            else { return }

        toView.frame = transitionContext.finalFrame(for: toViewController)

        if !toView.isDescendant(of: transitionContext.containerView) {
            transitionContext.containerView.addSubview(toView)
        }

        if isDismissing {
            transitionContext.containerView.bringSubview(toFront: fromView)
        }
    }

    func setAnimationDurationFadeRatio(_ animationFadeRatio: TimeInterval) {
        self.animationDurationFadeRatio = min(animationFadeRatio, 1.0)
    }

    func setAnimationDurationEndingViewFadeInRatio(_ ratio: TimeInterval) {
        self.animationDurationEndingViewFadeInRatio = min(ratio, 1)
    }

    func setAnimationDurationEndingViewFadeOutRatio(_ ratio: TimeInterval) {
        self.animationDurationEndingViewFadeOutRatio = min(ratio, 1)
    }

    func performFadeAnimation(
        withTransitionContext transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
            else { return }

        var viewToFade = toView
        var beginningAlpha: CGFloat = 0
        var endingAlpha: CGFloat = 1

        if isDismissing {
            viewToFade = fromView
            beginningAlpha = 1
            endingAlpha = 0
        }

        viewToFade.alpha = beginningAlpha

        UIView.animate(withDuration: fadeDuration(forTransitionContext: transitionContext), animations: {
            viewToFade.alpha = endingAlpha
        }) { [weak self] _ in
            if !(self?.shouldPerformZoomingAnimation ?? true) {
                self?.completeTransition(withTransitionContext: transitionContext)
            }
        }
    }

    func fadeDuration(forTransitionContext transitionContext: UIViewControllerContextTransitioning) -> TimeInterval {
        if self.shouldPerformZoomingAnimation {
            return transitionDuration(using: transitionContext) * self.animationDurationFadeRatio
        }
        return transitionDuration(using: transitionContext)
    }

    func performZoomingAnimation(withTransitionContext transitionContext: UIViewControllerContextTransitioning) {

        guard let endingView = self.endingView,
            let startingView = self.startingView
            else { return }

        let containerView = transitionContext.containerView

        let startingViewForAnimation = self.startingViewForAnimation
            ?? TCPhotoTransitionAnimator.newAnimationViewFromView(startingView)!

        let endingViewForAnimation = self.endingViewForAnimation
            ?? TCPhotoTransitionAnimator.newAnimationViewFromView(endingView)!

        let finalEndingViewTransform = endingView.transform

        let endingViewInitialTransform = startingViewForAnimation.frame.height / endingViewForAnimation.frame.height

        let translatedStartingViewCenter = TCPhotoTransitionAnimator.centerPoint(
            forView: startingView,
            translatedToContainerView: containerView)

        startingViewForAnimation.center = translatedStartingViewCenter

        endingViewForAnimation.transform = endingViewForAnimation.transform
            .scaledBy(x: endingViewInitialTransform, y: endingViewInitialTransform)

        endingViewForAnimation.center = translatedStartingViewCenter
        endingViewForAnimation.alpha = 0

        transitionContext.containerView.addSubview(startingViewForAnimation)
        transitionContext.containerView.addSubview(endingViewForAnimation)

        endingView.alpha = 0
        startingView.alpha = 0

        let fadeInDuration = self.transitionDuration(using: transitionContext) * self.animationDurationEndingViewFadeInRatio
        let fadeOutDuration = self.transitionDuration(using: transitionContext) * self.animationDurationEndingViewFadeOutRatio

        UIView.animate(
            withDuration: fadeInDuration,
            delay: 0,
            options: [
                .allowAnimatedContent,
                .beginFromCurrentState
            ],
            animations: {
                endingViewForAnimation.alpha = 1
        }, completion: { _ in
            UIView.animate(
                withDuration: fadeOutDuration,
                delay: 0,
                options: [
                    .allowAnimatedContent,
                    .beginFromCurrentState
                ],
                animations: {
                    startingViewForAnimation.alpha = 0
            }, completion: { _ in
                startingViewForAnimation.removeFromSuperview()
            })
        })

        let startingViewFinalTransform = 1.0 / endingViewInitialTransform
        let translatedEndingViewFinalCenter = TCPhotoTransitionAnimator.centerPoint(
            forView: endingView,
            translatedToContainerView: containerView)

        UIView.animate(
            withDuration: self.transitionDuration(using: transitionContext),
            delay: 0,
            options: [
                .allowAnimatedContent,
                .beginFromCurrentState
            ],
            animations: {
                endingViewForAnimation.transform = finalEndingViewTransform
                endingViewForAnimation.center = translatedEndingViewFinalCenter
                startingViewForAnimation.transform = startingViewForAnimation.transform
                    .scaledBy(x: startingViewFinalTransform, y: startingViewFinalTransform)
                startingViewForAnimation.center = translatedEndingViewFinalCenter
        },
            completion: { _ in
                endingViewForAnimation.removeFromSuperview()
                self.endingView?.alpha = 1
                self.startingView?.alpha = 1

                self.completeTransition(withTransitionContext: transitionContext)
        })
    }

    func completeTransition(withTransitionContext transitionContext: UIViewControllerContextTransitioning) {
        if transitionContext.isInteractive {
            if transitionContext.transitionWasCancelled { transitionContext.cancelInteractiveTransition() }
            else { transitionContext.finishInteractiveTransition() }
        }

        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }

    static func centerPoint(
        forView view: UIView,
        translatedToContainerView containerView: UIView) -> CGPoint {

        var centerPoint = view.center

        // Special case for zoomed scroll views.
        if let scrollView = view.superview as? UIScrollView,
            scrollView.zoomScale != 1.0 {

            centerPoint.x += (scrollView.bounds.width - scrollView.contentSize.width) / 2.0 + scrollView.contentOffset.x;
            centerPoint.y += (scrollView.bounds.height - scrollView.contentSize.height) / 2.0 + scrollView.contentOffset.y;
        }

        return view.superview?.convert(centerPoint, to: containerView) ?? .zero
    }

    static func newAnimationViewFromView(_ view: UIView?) -> UIView? {
        guard let view = view else { return nil }

        var animationView: UIView?

        if view.layer.contents != nil {
            if let imageView = view as? UIImageView {
                animationView = UIImageView(image: imageView.image)
                animationView!.bounds = view.bounds
            } else {
                animationView = UIView.init(frame: view.frame)
                animationView!.layer.contents = view.layer.contents
                animationView!.layer.bounds = view.layer.bounds
            }

            animationView!.layer.cornerRadius = view.layer.cornerRadius
            animationView!.layer.masksToBounds = view.layer.masksToBounds
            animationView!.contentMode = view.contentMode
            animationView!.transform = view.transform
        } else {
            animationView = view.snapshotView(afterScreenUpdates: true)
        }

        return animationView
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if shouldPerformZoomingAnimation {
            return self.animationDurationWithZooming
        } else {
            return self.animationDurationWithoutZooming
        }
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.setupTransitionContainerHierarchy(withTransitionContext: transitionContext)

        self.performFadeAnimation(withTransitionContext: transitionContext)

        if self.shouldPerformZoomingAnimation {
            self.performZoomingAnimation(withTransitionContext: transitionContext)
        }
    }
}
