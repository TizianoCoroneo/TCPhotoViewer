//
//  TCPhotoViewController.swift
//  TCPhotoViewer
//
//  Created by Tiziano Coroneo on 25/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import UIKit

let tcPhotoViewControllerPhotoImageUpdatedNotification = "NYTPhotoViewControllerPhotoImageUpdatedNotification"

protocol TCPhotoViewControllerDelegate: class, NSObjectProtocol {
    func photoViewController(
        _ photoViewController: TCPhotoViewController,
        didLongPressWithGestureRecognizer: UILongPressGestureRecognizer)
}

class TCPhotoViewController: UIViewController, TCPhotoContainer, UIScrollViewDelegate {

    var photo: TCPhoto?

    weak var delegate: TCPhotoViewControllerDelegate?

    var scalingImageView: TCScalingImageView?
    var loadingView: UIView?
    var notificationCenter: NotificationCenter?

    lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(didDoubleTapWithGestureRecognizer(_:)))
        recognizer.numberOfTapsRequired = 2
        return recognizer
    }()

    lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(
        target: self,
        action: #selector(didLongPressWithGestureRecognizer(_:)))

    init(
        withPhoto photo: TCPhoto?,
        loadingView: UIView?,
        notificationCenter: NotificationCenter?) {
        super.init(nibName: nil, bundle: nil)
        self.commonInit(
            photo: photo,
            loadingView: loadingView,
            notificationCenter: notificationCenter)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit(photo: nil, loadingView: nil, notificationCenter: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit(photo: nil, loadingView: nil, notificationCenter: nil)
    }

    deinit {
        scalingImageView?.delegate = nil
        notificationCenter?.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.notificationCenter?.addObserver(
            self,
            selector: #selector(photoImageUpdated(withNotification:)),
            name: Notification.Name("tcPhotoViewControllerPhotoImageUpdatedNotification"),
            object: nil)

        scalingImageView?.frame = view.bounds
        scalingImageView.map(view.addSubview)

        loadingView.map(view.addSubview)
        loadingView?.sizeToFit()

        view.addGestureRecognizer(doubleTapGestureRecognizer)
        view.addGestureRecognizer(longPressGestureRecognizer)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        scalingImageView?.frame = view.bounds

        loadingView?.sizeToFit()
        loadingView?.center = CGPoint(
            x: view.bounds.midX,
            y: view.bounds.midY)
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

    func commonInit(
        photo: TCPhoto?,
        loadingView: UIView?,
        notificationCenter: NotificationCenter?) {

        self.photo = photo
        if let data = photo?.imageData {
            scalingImageView = TCScalingImageView(
                withImageData: data, frame: .zero)
        } else {
            let photoImage = photo?.image ?? photo?.placeholderImage

            scalingImageView = TCScalingImageView(
                withImage: photoImage,
                frame: .zero)

            if photoImage == nil {
                self.setupLoadingView(loadingView)
            }
        }

        scalingImageView?.delegate = self
        self.notificationCenter = notificationCenter
    }

    func setupLoadingView(_ loadingView: UIView?) {
        self.loadingView = loadingView
        guard loadingView == nil else { return }
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.startAnimating()
        self.loadingView = activityIndicator
    }

    @objc func photoImageUpdated(withNotification notification: Notification) {
        if let photo = notification.object as? TCPhoto,
            photo === self.photo! {
            self.updateImage(photo.image, imageData: photo.imageData)
        }
    }

    func updateImage(_ image: UIImage?, imageData: Data?) {
        if let imageData = imageData {
            self.scalingImageView?.updateImageData(imageData)
        } else {
            self.scalingImageView?.updateImage(image)
        }

        if imageData != nil || image != nil {
            self.loadingView?.removeFromSuperview()
        } else if let loadingView = loadingView {
            self.view.addSubview(loadingView)
        }
    }

    @objc func didDoubleTapWithGestureRecognizer(_ recognizer: UITapGestureRecognizer) {

        guard let scalingImageView = self.scalingImageView
            else { return }

        let pointInView = recognizer.location(in: scalingImageView.imageView)
        var newZoomScale = scalingImageView.minimumZoomScale

        if scalingImageView.zoomScale >= scalingImageView.maximumZoomScale
            || abs(scalingImageView.zoomScale - scalingImageView.maximumZoomScale) <= 0.01 {
            newZoomScale = scalingImageView.minimumZoomScale
        }

        let scrollViewSize = scalingImageView.bounds.size

        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let originX = pointInView.x - (width / 2.0)
        let originY = pointInView.y - (height / 2.0)

        let rectToZoomTo = CGRect(x: originX, y: originY, width: width, height: height)

        scalingImageView.zoom(to: rectToZoomTo, animated: true)
    }

    @objc func didLongPressWithGestureRecognizer(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            delegate?.photoViewController(self, didLongPressWithGestureRecognizer: recognizer)
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scalingImageView?.imageView
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.panGestureRecognizer.isEnabled = true
    }

    func scrollViewDidEndZooming(
        _ scrollView: UIScrollView,
        with view: UIView?,
        atScale scale: CGFloat) {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            scrollView.panGestureRecognizer.isEnabled = false
        }
    }
}
