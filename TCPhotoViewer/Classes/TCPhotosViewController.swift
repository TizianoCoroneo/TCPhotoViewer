//
//  TCPhotosViewController.swift
//  TCPhotoViewer
//
//  Created by Tiziano Coroneo on 25/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import UIKit

let tcPhotosViewControllerDidNavigateToPhotoNotification = "NYTPhotosViewControllerDidNavigateToPhotoNotification"
let tcPhotosViewControllerWillDismissNotification = "NYTPhotosViewControllerWillDismissNotification"
let tcPhotosViewControllerDidDismissNotification = "NYTPhotosViewControllerDidDismissNotification"

let tcPhotosViewControllerOverlayAnimationDuration: TimeInterval = 0.2
let tcPhotosViewControllerInterPhotoSpacing: CGFloat = 16.0
let tcPhotosViewControllerCloseButtonImageInsets = UIEdgeInsets(
    top: 3, left: 0, bottom: -3, right: 0)

@objc protocol TCPhotosViewControllerDelegate: class, NSObjectProtocol {
    @objc optional func photoViewController(
        _ photoViewController: TCPhotosViewController,
        titleForPhoto photo: TCPhoto,
        atIndex indexPath: Int,
        totalPhotoCount count: Int) -> String

    @objc optional func photoViewController(
        _ photoViewController: TCPhotosViewController,
        captionViewForPhoto: TCPhoto) -> UIView

    @objc optional func photoViewController(
        _ photoViewController: TCPhotosViewController,
        loadingViewForPhoto: TCPhoto) -> UIView

    @objc optional func photosViewController(
        _ photoViewController: TCPhotosViewController,
        captionViewRespectsSafeAreaForPhoto: TCPhoto) -> Bool

    @objc optional func photosViewController(
        willDismiss photoViewController: TCPhotosViewController)

    @objc optional func photosViewController(
        didDismiss photoViewController: TCPhotosViewController)

    @objc optional func photosViewController(
        _ photoViewController: TCPhotosViewController,
        didNavigateToPhoto photo: TCPhoto?,
        atIndex index: Int)

    @objc optional func photoViewController(
        _ photoViewController: TCPhotosViewController,
        maximumZoomScaleForPhoto photo: TCPhoto?) -> CGFloat

    @objc optional func photoViewController(
        _ photoViewController: TCPhotosViewController,
        referenceViewForCurrentPhoto photo: TCPhoto?) -> UIView

    @objc optional func photosViewController(
        _ photoViewController: TCPhotosViewController,
        handleActionButtonTappedForPhoto: TCPhoto?) -> Bool

    @objc optional func photosViewController(
        _ photoViewController: TCPhotosViewController,
        handleLongPressForPhoto photo: TCPhoto?,
        withGestureRecognizer recognizer: UILongPressGestureRecognizer) -> Bool

    @objc optional func photosViewController(
        _ photoViewController: TCPhotosViewController,
        actionCompletedWithActivityType activityType: String) -> Bool

}

class TCPhotosViewController: UIViewController {

    lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [
                UIPageViewControllerOptionInterPageSpacingKey: tcPhotosViewControllerInterPhotoSpacing
            ])

        vc.delegate = self
        vc.dataSource = self
        return vc
    }()

    let transitionController = TCPhotoTransitionController()
//    let activityPopoverController: UIPopoverController

    lazy var panGestureRecognizer = UIPanGestureRecognizer(
        target: self, action: #selector(didPanWithGestureRecognizer(_:)))
    lazy var singleTapGestureRecognizer = UITapGestureRecognizer(
        target: self, action: #selector(didSingleTapWithGestureRecognizer(_:)))

    @IBInspectable var leftCloseButtonImage: UIImage?
    @IBInspectable var leftLandscapeCloseButtonImage: UIImage?

    lazy var overlayView: TCPhotoOverlayView = {
        let v = TCPhotoOverlayView(frame: .zero)
        v.leftBarButtonItem = UIBarButtonItem.init(
            image: leftCloseButtonImage,
            landscapeImagePhone: leftLandscapeCloseButtonImage,
            style: .plain,
            target: self,
            action: #selector(doneButtonTapped))
        v.leftBarButtonItem?.imageInsets = tcPhotosViewControllerCloseButtonImageInsets
        v.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(actionButtontapped))
        return v
    }()

    var notificationCenter: NotificationCenter = .default

    var shouldHandleLongPress: Bool = false
    var overlayWasHiddenBeforeTransition: Bool = false

    var initialPhoto: TCPhoto?

    var dataSource: TCPhotoViewerDataSource?
    var delegate: TCPhotosViewControllerDelegate?

    var currentPhotoViewController: TCPhotoViewController? {
        return pageViewController.viewControllers?.first as? TCPhotoViewController
    }

    var currentlyDisplayedPhoto: TCPhoto? {
        return currentPhotoViewController?.photo
    }

    var referenceViewForCurrentPhoto: UIView? {
        guard let delegate = delegate,
            let photo = currentlyDisplayedPhoto
            else { return nil }

        return delegate.photoViewController?(
            self,
            referenceViewForCurrentPhoto: photo)
    }

    var boundsCenterPoint: CGPoint {
        return CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }

    deinit {
        pageViewController.dataSource = nil
        pageViewController.delegate = nil
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.image = currentlyDisplayedPhoto?.image
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func canPerformAction(
        _ action: Selector,
        withSender sender: Any?) -> Bool {
        return shouldHandleLongPress
            && action == #selector(copy(_:))
            && currentlyDisplayedPhoto?.image != nil
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        commonInit(
            dataSource: TCPhotoViewerArrayDataSource(withPhotos: []),
            initialPhoto: nil,
            delegate: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit(
            dataSource: TCPhotoViewerArrayDataSource(withPhotos: []),
            initialPhoto: nil,
            delegate: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configurePageViewControllerWithInitialPhoto()
        view.tintColor = .white
        view.backgroundColor = .black
        pageViewController.view.backgroundColor = .clear

        pageViewController.view.addGestureRecognizer(panGestureRecognizer)
        pageViewController.view.addGestureRecognizer(singleTapGestureRecognizer)

        addChildViewController(pageViewController)

        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)

        addOverlayView()

        transitionController.startingView = referenceViewForCurrentPhoto

        var endingView: UIView? = nil
        if currentlyDisplayedPhoto?.image != nil || currentlyDisplayedPhoto?.placeholderImage != nil {
            endingView = currentPhotoViewController?.scalingImageView?.imageView
        }

        transitionController.endingView = endingView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !overlayWasHiddenBeforeTransition {
            setOverlay(hidden: false, animated: true)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        pageViewController.view.frame = view.bounds
        overlayView.frame = view.bounds
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }


    func configurePageViewControllerWithInitialPhoto(_ initialPhotoViewController: TCPhotoViewController) {

        var initialPhotoViewController: TCPhotoViewController? = nil

        if let photo = initialPhoto,
            dataSource?.indexOfPhoto(photo) != nil {
            initialPhotoViewController = self.newPhotoViewControllerForPhoto(photo)
        } else if let first = dataSource?.photoAtIndex(0) {
            initialPhotoViewController = self.newPhotoViewControllerForPhoto(first)
        }

        if let vc = initialPhotoViewController {
            setCurrentlyDisplayed(vc, animated: false)
        }
    }

    init(dataSource: TCPhotoViewerDataSource?) {
        super.init(nibName: nil, bundle: nil)
        commonInit(
            dataSource: dataSource,
            initialPhoto: nil,
            delegate: nil)
    }

    init(
        dataSource: TCPhotoViewerDataSource?,
        initialPhotoIndex: Int,
        delegate: TCPhotosViewControllerDelegate?) {
        super.init(nibName: nil, bundle: nil)
        commonInit(
            dataSource: dataSource,
            initialPhoto: dataSource?.photoAtIndex(initialPhotoIndex),
            delegate: delegate)
    }

    init(
        dataSource: TCPhotoViewerDataSource?,
        initialPhoto: TCPhoto?,
        delegate: TCPhotosViewControllerDelegate?) {
        super.init(nibName: nil, bundle: nil)
        commonInit(dataSource: dataSource, initialPhoto: initialPhoto, delegate: delegate)
    }

    convenience init(withPhotos photos: [TCPhoto]?) {
        let dataSource = TCPhotoViewerArrayDataSource(withPhotos: photos)
        self.init(dataSource: dataSource)
    }

    convenience init(withPhotos photos: [TCPhoto]?, initialPhoto: TCPhoto?) {
        let dataSource = TCPhotoViewerArrayDataSource(withPhotos: photos)
        self.init(
            dataSource: dataSource,
            initialPhoto: initialPhoto,
            delegate: nil)
    }

    func commonInit(
        dataSource: TCPhotoViewerDataSource?,
        initialPhoto: TCPhoto?,
        delegate: TCPhotosViewControllerDelegate?,
        notificationCenter: NotificationCenter = .default) {

        self.dataSource = dataSource
        self.delegate = delegate
        self.initialPhoto = initialPhoto
        self.notificationCenter = notificationCenter

        self.modalPresentationStyle = .custom
        self.transitioningDelegate = transitionController
        self.modalPresentationCapturesStatusBarAppearance = true

        _ = pageViewController
    }

    func configurePageViewControllerWithInitialPhoto() {
        var initialPhotoViewController: TCPhotoViewController? = nil

        if let photo = initialPhoto,
            dataSource?.indexOfPhoto(photo) != nil,
            let newVC = self.newPhotoViewControllerForPhoto(photo) {
            initialPhotoViewController = newVC
        } else if let photo = self.dataSource?.photoAtIndex(0) {
            initialPhotoViewController = self.newPhotoViewControllerForPhoto(photo)
        }

        if let vc = initialPhotoViewController {
            setCurrentlyDisplayed(vc, animated: false)
        }
    }

    func addOverlayView() {

        let textColor: UIColor = self.view.tintColor ?? .white
        self.overlayView.titleTextAttribute = [
            NSAttributedStringKey.foregroundColor: textColor]

        updateOverlayInformation()
        self.view.addSubview(self.overlayView)

        self.setOverlay(hidden: true, animated: false)
    }

    func updateOverlayInformation() {
        guard
            let dataSource = dataSource,
            let photo = self.currentlyDisplayedPhoto,
            let photoIndex = currentlyDisplayedPhoto.flatMap(dataSource.indexOfPhoto)
            else { return }

        var overlayTitle: String? = nil
        let displayIndex = photoIndex + 1

        overlayTitle = delegate?.photoViewController?(
            self,
            titleForPhoto: photo,
            atIndex: photoIndex,
            totalPhotoCount: dataSource.numberOfPhotos)

        if overlayTitle == nil && dataSource.numberOfPhotos == 0 {

        } else if overlayTitle == nil && dataSource.numberOfPhotos > 1 {
            overlayTitle = "\(displayIndex) / \(dataSource.numberOfPhotos)"
        }

        self.overlayView.title = overlayTitle

        var captionView: UIView? = nil

        if let view = delegate?.photoViewController?(
            self,
            captionViewForPhoto: photo) {
            captionView = view
        }

        if captionView == nil {
            captionView = TCPhotoCaptionView(
                attributedTitle: photo.attributedCaptionTitle,
                attributedSummary: photo.attributedCaptionSummary,
                attributedCredit: photo.attributedCaptionCredit)
        }

        var captionViewRespectsSafeArea = true
        if let shouldRespectSafeArea = delegate?.photosViewController?(
            self,
            captionViewRespectsSafeAreaForPhoto: photo) {
            captionViewRespectsSafeArea = shouldRespectSafeArea
        }

        self.overlayView.captionViewRespectsSafeArea = captionViewRespectsSafeArea
        self.overlayView.captionView = captionView
    }

    func setOverlay(hidden: Bool, animated: Bool) {

        if hidden == self.overlayView.isHidden { return }
        guard animated else { overlayView.isHidden = hidden; return }

        overlayView.isHidden = false

        overlayView.alpha = hidden ? 1 : 0
        UIView.animate(
            withDuration: tcPhotosViewControllerOverlayAnimationDuration,
            delay: 0,
            options: [.curveEaseInOut, .allowAnimatedContent, .allowUserInteraction],
            animations: {
                self.overlayView.alpha = hidden ? 0 : 1.0
        }) { _ in
            self.overlayView.alpha = 1
            self.overlayView.isHidden = hidden
        }
    }


    @objc func didSingleTapWithGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
        setOverlay(hidden: !overlayView.isHidden, animated: true)
    }

    @objc func didPanWithGestureRecognizer(_ recognizer: UIPanGestureRecognizer) {
        if panGestureRecognizer.state == .began {
            transitionController.forcesNonInteractiveDismissal = false
            dismiss(animated: true, isUserInitiated: true, completion: nil)
        } else {
            transitionController.forcesNonInteractiveDismissal = true
            if let view = panGestureRecognizer.view {
                transitionController.didPanWithPanGestureRecognizer(
                    recognizer,
                    viewToPan: view,
                    anchorPoint: boundsCenterPoint)
            }
        }
    }

    func setCurrentlyDisplayed(_ viewController: TCPhotoContainer?, animated: Bool) {
        guard let viewController = viewController,
            let dataSource = dataSource
            else { return }

        var isAnimated = animated
        if viewController.photo?.isEqual(currentlyDisplayedPhoto) ?? false {
            isAnimated = false
        }

        var direction: UIPageViewControllerNavigationDirection = .forward

        if let currentIndex = currentlyDisplayedPhoto.flatMap(dataSource.indexOfPhoto),
            let newIndex = viewController.photo.flatMap(dataSource.indexOfPhoto) {
            direction = newIndex < currentIndex
                ? .reverse : .forward
        }

        pageViewController.setViewControllers(
            [viewController].compactMap { $0 as? UIViewController },
            direction: direction,
            animated: isAnimated,
            completion: nil)
    }

    func newPhotoViewControllerForPhoto(_ photo: TCPhoto?) -> TCPhotoViewController? {
        guard let photo = photo else { return nil }

        var loadingView: UIView?
        if let loading = delegate?.photoViewController?(
            self, loadingViewForPhoto: photo) {
            loadingView = loading
        }

        let photoViewController = TCPhotoViewController(
            withPhoto: photo,
            loadingView: loadingView,
            notificationCenter: notificationCenter)
        photoViewController.delegate = self
        singleTapGestureRecognizer.require(toFail: photoViewController.doubleTapGestureRecognizer)

        if let maximumZoomScale = delegate?.photoViewController?(
            self,
            maximumZoomScaleForPhoto: photo) {
            photoViewController.scalingImageView?.maximumZoomScale = maximumZoomScale
        }

        return photoViewController
    }

    func didNavigate(toPhoto photo: TCPhoto) {
        if let index = dataSource?.indexOfPhoto(photo) {
            delegate?.photosViewController?(
                self,
                didNavigateToPhoto: photo,
                atIndex: index)
        }

        notificationCenter.post(name: NSNotification.Name(tcPhotosViewControllerDidNavigateToPhotoNotification), object: self)
    }


    @objc func doneButtonTapped() {
        dismiss(animated: true, isUserInitiated: true, completion: nil)
    }

    @objc func actionButtontapped(_ sender: UIBarButtonItem) {
        guard let photo = self.currentlyDisplayedPhoto else { return }

        var clientDidHandle = false

        if let result = delegate?.photosViewController?(
            self,
            handleActionButtonTappedForPhoto: photo) {
            clientDidHandle = result
        }

        if !clientDidHandle,
            photo.image != nil || photo.imageData != nil {
            let image = currentlyDisplayedPhoto?.image ?? currentlyDisplayedPhoto?.imageData.flatMap(UIImage.init)

            let activityViewController = UIActivityViewController.init(
                activityItems: [image].compactMap { $0 },
                applicationActivities: nil)
            activityViewController.popoverPresentationController?.barButtonItem = sender
            activityViewController.completionWithItemsHandler = { (
                activityType: UIActivityType?,
                completed: Bool,
                returnedItems: [Any]?,
                activityError: Error?) in

                if completed, let type = activityType {
                    _ = self.delegate?.photosViewController?(self, actionCompletedWithActivityType: type.rawValue)
                }
            }

            self.displayActivityViewController(activityViewController, animated: true)
        }
    }

    func displayActivityViewController(
        _ controller: UIActivityViewController,
        animated: Bool) {

        if UIDevice.current.userInterfaceIdiom == .phone {
            self.present(controller, animated: animated, completion: nil)
        } else {
            controller.popoverPresentationController?.barButtonItem = self.rightBarButtonItem
            self.present(controller, animated: animated, completion: nil)
        }
    }

    var leftBarButtonItem: UIBarButtonItem? {
        get { return overlayView.leftBarButtonItem }
        set { overlayView.leftBarButtonItem = newValue }
    }

    var leftBarButtonItems: [UIBarButtonItem]? {
        get { return overlayView.leftBarButtonItems }
        set { overlayView.leftBarButtonItems = newValue }
    }

    var rightBarButtonItem: UIBarButtonItem? {
        get { return overlayView.rightBarButtonItem }
        set { overlayView.rightBarButtonItem = newValue }
    }

    var rightBarButtonItems: [UIBarButtonItem]? {
        get { return overlayView.rightBarButtonItems }
        set { overlayView.rightBarButtonItems = newValue }
    }

    func displayPhoto(_ photo: TCPhoto?, animated: Bool) {
        guard
            let photo = photo,
            let _ = dataSource?.indexOfPhoto(photo),
            let photoVC = newPhotoViewControllerForPhoto(photo)
            else { return }

        setCurrentlyDisplayed(photoVC, animated: animated)
        updateOverlayInformation()
    }

    func updatePhoto(atIndex photoIndex: Int) {
        guard let photo = self.dataSource?.photoAtIndex(photoIndex)
            else { return }
        self.updatePhoto(photo: photo)
    }

    func updatePhoto(photo: TCPhoto?) {
        guard let photo = photo,
            let _ = dataSource?.indexOfPhoto(photo)
            else { return }
        self.notificationCenter.post(
            name: NSNotification.Name(tcPhotoViewControllerPhotoImageUpdatedNotification), object: photo)

        if self.currentlyDisplayedPhoto?.isEqual(photo) ?? true {
            self.updateOverlayInformation()
        }
    }

    func reloadPhotos(animated: Bool) {
        let newCurrentPhoto: TCPhoto?

        if let dataSource = dataSource,
            currentlyDisplayedPhoto.flatMap(dataSource.indexOfPhoto) != nil {
            newCurrentPhoto = currentlyDisplayedPhoto
        } else {
            newCurrentPhoto = dataSource?.photoAtIndex(0)
        }

        if let newPhoto = newCurrentPhoto {
            displayPhoto(newPhoto, animated: animated)
        }

        if overlayView.isHidden {
            self.setOverlay(hidden: false, animated: animated)
        }
    }

    func dismiss(
        animated: Bool,
        isUserInitiated: Bool,
        completion: (() -> Void)? = nil) {

        if presentedViewController != nil {
            super.dismiss(animated: animated, completion: completion)
            return
        }

        var startingView: UIView?
        if currentlyDisplayedPhoto?.image != nil
            || currentlyDisplayedPhoto?.imageData != nil
            || currentlyDisplayedPhoto?.placeholderImage != nil {
            startingView = currentPhotoViewController?.scalingImageView?.imageView
        }

        transitionController.startingView = startingView
        transitionController.endingView = referenceViewForCurrentPhoto

        overlayWasHiddenBeforeTransition = overlayView.isHidden

        setOverlay(hidden: true, animated: animated)

        let shouldSendDelegateMessages = isUserInitiated
        if shouldSendDelegateMessages {
            delegate?.photosViewController?(willDismiss: self)
        }

        notificationCenter.post(
            name: NSNotification.Name(tcPhotosViewControllerWillDismissNotification
            ),
            object: self)

        dismiss(animated: animated) { [weak self] in
            let isStillOnscreen = self?.view.window != nil

            if isStillOnscreen && !(self?.overlayWasHiddenBeforeTransition ?? true) {
                self?.setOverlay(hidden: false, animated: true)
            }

            if !isStillOnscreen {
                if shouldSendDelegateMessages,
                    let `self` = self {
                    self.delegate?.photosViewController?(didDismiss: self)
                }

                self?.notificationCenter.post(name: NSNotification.Name(tcPhotosViewControllerDidDismissNotification), object: self)
            }

            completion?()
        }
    }
}

extension TCPhotosViewController: TCPhotoViewControllerDelegate {
    func photoViewController(_ photoViewController: TCPhotoViewController, didLongPressWithGestureRecognizer recognizer: UILongPressGestureRecognizer) {
        self.shouldHandleLongPress = false

        let clientDidHandle = delegate?.photosViewController?(
            self,
            handleLongPressForPhoto: photoViewController.photo,
            withGestureRecognizer: recognizer)
            ?? false

        self.shouldHandleLongPress = !clientDidHandle

        if shouldHandleLongPress,
            let view = recognizer.view {
            let menuController = UIMenuController.shared
            var targetRect: CGRect = .zero
            targetRect.origin = recognizer.location(in: view)
            menuController.setTargetRect(targetRect, in: view)
            menuController.setMenuVisible(true, animated: true)
        }
    }
}

extension TCPhotosViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let viewC = viewController as? TCPhotoContainer,
            let dataSource = dataSource
            else { return nil }

        let photoIndex = viewC.photo.flatMap(dataSource.indexOfPhoto)

        guard let index = photoIndex,
            index != 0
            else { return nil }

        return newPhotoViewControllerForPhoto(dataSource.photoAtIndex(index - 1))
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let viewC = viewController as? TCPhotoContainer,
            let dataSource = dataSource
            else { return nil }

        let photoIndex = viewC.photo.flatMap(dataSource.indexOfPhoto)

        guard let index = photoIndex else { return nil }

        return newPhotoViewControllerForPhoto(dataSource.photoAtIndex(index + 1))
    }


    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
        guard completed else { return }
        self.updateOverlayInformation()

        if let photoViewController = pageViewController.viewControllers?.first as? TCPhotoContainer,
            let photo = photoViewController.photo {
            self.didNavigate(toPhoto: photo)
        }
    }
}




















