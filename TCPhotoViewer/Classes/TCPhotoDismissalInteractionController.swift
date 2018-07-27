//
//  TCPhotoDismissalInteractionController.swift
//  TCPhotoViewer
//
//  Created by Tiziano Coroneo on 24/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import UIKit

let tcPhotoDismissalInteractionControllerPanDismissDistanceRatio: CGFloat = 50.0 / 667.0
let tcPhotoDismissalInteractionControllerPanDismissMaximumDuration: CGFloat = 0.45
let tcPhotoDismissalInteractionControllerReturnToCenterVelocityAnimationRatio: CGFloat = 0.00007 // Arbitrary value that looked decent.

class TCPhotoDismissalInteractionController: NSObject, UIViewControllerInteractiveTransitioning {

    var transitionContext: UIViewControllerContextTransitioning?

    var animator: UIViewControllerAnimatedTransitioning? = nil

    var viewToHideWhenBeginningTransition: UIView?

    var shouldAnimateUsingAnimator: Bool = false

    func didPanWithPanGestureRecognizer(
        _ panGestureRecognizer: UIPanGestureRecognizer,
        viewToPan: UIView,
        anchorPoint: CGPoint) {

        guard let fromView = self.transitionContext?.view(forKey: .from)
            else { return }

        let translatePanGesturePoint = panGestureRecognizer.translation(in: fromView)
        let newCenterPoint = CGPoint(x: anchorPoint.x, y: anchorPoint.y + translatePanGesturePoint.y)

        viewToPan.center = newCenterPoint

        let verticalDelta = newCenterPoint.y - anchorPoint.y

        let backgroundAlpha = backgroundAlphaForPanningWithVerticalDelta(verticalDelta: verticalDelta)
        fromView.backgroundColor = fromView.backgroundColor?.withAlphaComponent(backgroundAlpha)

        if panGestureRecognizer.state == .ended {
            finishPanWithPanGestureRecognizer(
                panGestureRecognizer,
                verticalDelta: verticalDelta,
                viewToPan: viewToPan,
                anchorPoint: anchorPoint)
        }
    }

    func finishPanWithPanGestureRecognizer(
        _ panGestureRecognizer: UIPanGestureRecognizer,
        verticalDelta: CGFloat,
        viewToPan: UIView,
        anchorPoint: CGPoint) {

        guard let fromView = transitionContext?.view(forKey: .from),
            let transitionContext = transitionContext
            else { return }

        let velocityY = panGestureRecognizer.velocity(in: fromView).y

        var animationDuration = abs(velocityY) * tcPhotoDismissalInteractionControllerReturnToCenterVelocityAnimationRatio + 0.2
        var animationCurve: UIViewAnimationOptions = .curveEaseOut
        var finalPageViewCenterPoint = anchorPoint
        var finalBackgroundAlpha = 1.0

        let dismissDistance = tcPhotoDismissalInteractionControllerPanDismissDistanceRatio * fromView.bounds.height

        let isDismissing = abs(verticalDelta) > dismissDistance

        var didAnimateUsingAnimator = false

        if isDismissing {
            if shouldAnimateUsingAnimator {
                animator!.animateTransition(using: transitionContext)
                didAnimateUsingAnimator = true
            } else {
                let isPositiveDelta = verticalDelta >= 0

                let modifier = isPositiveDelta ? 1 : -1
                let finalCenterY = fromView.bounds.midY + CGFloat(modifier) * fromView.bounds.height

                finalPageViewCenterPoint = CGPoint(x: fromView.center.x, y: finalCenterY)
                animationDuration = abs(finalPageViewCenterPoint.y - viewToPan.center.y) / abs(velocityY)
                animationDuration = min(animationDuration, tcPhotoDismissalInteractionControllerPanDismissMaximumDuration)

                animationCurve = .curveEaseOut
                finalBackgroundAlpha = 0
            }
        }

        guard !didAnimateUsingAnimator
            else {
                self.transitionContext = nil
                return
        }

        UIView.animate(
            withDuration: Double(animationDuration),
            delay: 0,
            options: animationCurve,
            animations: {
                viewToPan.center = finalPageViewCenterPoint
                fromView.backgroundColor = fromView.backgroundColor?
                    .withAlphaComponent(CGFloat(finalBackgroundAlpha))
        }, completion: { [weak self] _ in
            guard
                let `self` = self,
                let transitionContext = self.transitionContext
                else { return }

            if isDismissing {
                transitionContext.finishInteractiveTransition()
            } else {
                transitionContext.cancelInteractiveTransition()
            }

            self.viewToHideWhenBeginningTransition?.alpha = 1
            transitionContext.completeTransition(isDismissing && !transitionContext.transitionWasCancelled)

            self.transitionContext = nil
        })
    }

    func backgroundAlphaForPanningWithVerticalDelta(verticalDelta: CGFloat) -> CGFloat {
        let startingAlpha: CGFloat = 1.0
        let finalAlpha: CGFloat = 0.1
        let totalAvailableAlpha = startingAlpha - finalAlpha

        let maximumDelta = transitionContext!.view(forKey: .from)!.bounds.height / 2.0
        let deltaAsPercentageOfMaximum = min(abs(verticalDelta) / maximumDelta, 1)

        return startingAlpha - (deltaAsPercentageOfMaximum * totalAvailableAlpha)
    }

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.viewToHideWhenBeginningTransition?.alpha = 0

        self.transitionContext = transitionContext
    }
}
