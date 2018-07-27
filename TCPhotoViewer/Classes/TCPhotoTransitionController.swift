//
//  TCPhotoTransitionController.swift
//  TCPhotoViewer
//
//  Created by Tiziano Coroneo on 25/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import UIKit

class TCPhotoTransitionController: NSObject, UIViewControllerTransitioningDelegate {

    var forcesNonInteractiveDismissal: Bool = true

    private let animator = TCPhotoTransitionAnimator()
    private let interactionController = TCPhotoDismissalInteractionController()

    var startingView: UIView? {
        get { return animator.startingView }
        set { animator.startingView = newValue }
    }

    var endingView: UIView? {
        get { return animator.endingView }
        set { animator.endingView = newValue }
    }

    override init() {
        super.init()
    }

    func didPanWithPanGestureRecognizer(
        _ panGestureRecognizer: UIPanGestureRecognizer,
        viewToPan: UIView,
        anchorPoint: CGPoint) {

        self.interactionController.didPanWithPanGestureRecognizer(
            panGestureRecognizer, viewToPan: viewToPan, anchorPoint: anchorPoint)
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        animator.isDismissing = false
        return animator
    }

    func animationController(
        forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isDismissing = true
        return animator
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        if forcesNonInteractiveDismissal { return nil }

        self.animator.endingViewForAnimation = TCPhotoTransitionAnimator
            .newAnimationViewFromView(self.endingView)

        self.interactionController.animator = animator
        self.interactionController.shouldAnimateUsingAnimator = endingView != nil
        self.interactionController.viewToHideWhenBeginningTransition = startingView != nil ? endingView : nil

        return self.interactionController
    }


}
