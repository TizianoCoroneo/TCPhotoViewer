//
//  TCScalingImageView.swift
//  TCPhotoViewer
//
//  Created by Tiziano Coroneo on 25/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import UIKit

class TCScalingImageView: UIScrollView {

    var imageView: UIImageView!

    override var frame: CGRect {
        get { return super.frame }
        set {
            super.frame = newValue
            updateZoomScale()
            centerScrollViewContents()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(photo: UIImage(), data: nil)
    }

    init(withImage image: UIImage?, frame: CGRect) {
        super.init(frame: frame)
        commonInit(photo: image, data: nil)
    }

    init(withImageData imageData: Data?, frame: CGRect) {
        super.init(frame: frame)
        commonInit(photo: nil, data: imageData)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(photo: nil, data: nil)
    }

    private func commonInit(photo: UIImage?, data: Data?) {
        setupInternalImageView(withImage: photo, imageData: data)
        setupImageScrollView()
        updateZoomScale()
    }

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        centerScrollViewContents()
    }

    private func setupInternalImageView(
        withImage image: UIImage?,
        imageData data: Data?) {
        let imageToUse = image ?? data.map(UIImage.init) ?? nil

        self.imageView = UIImageView(image: imageToUse)
        self.updateImage(imageToUse, data)
        self.addSubview(imageView)
    }

    func updateImage(_ image: UIImage?) {
        updateImage(image, nil)
    }

    func updateImageData(_ data: Data?) {
        updateImage(nil, data)
    }

    func updateImage(_ image: UIImage?, _ data: Data?) {
        guard let imageToUse = image ?? data.map(UIImage.init) ?? nil
            else { return }

        self.imageView.transform = .identity
        self.imageView.image = imageToUse

        self.imageView.frame = CGRect(
            x: 0, y: 0,
            width: imageToUse.size.width,
            height: imageToUse.size.width)

        self.contentSize = imageToUse.size

        self.updateZoomScale()
        self.centerScrollViewContents()
    }

    private func setupImageScrollView() {
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bouncesZoom = true
        self.decelerationRate = UIScrollViewDecelerationRateFast
    }

    func updateZoomScale() {
        guard let image = imageView?.image,
            image.size.width != 0,
            image.size.height != 0
            else { return }

        let scrollViewFrame = self.bounds

        let scaleWidth = scrollViewFrame.size.width / image.size.width
        let scaleHeight = scrollViewFrame.size.height / image.size.height
        let minScale = min(scaleWidth, scaleHeight, 0.001)

        self.minimumZoomScale = minScale
        self.maximumZoomScale = max(minScale, self.maximumZoomScale)

        self.zoomScale = self.minimumZoomScale

        // scrollView.panGestureRecognizer.enabled is on by default and enabled by
        // viewWillLayoutSubviews in the container controller so disable it here
        // to prevent an interference with the container controller's pan gesture.
        //
        // This is enabled in scrollViewWillBeginZooming so panning while zoomed-in
        // is unaffected.
        self.panGestureRecognizer.isEnabled = false
    }

    func centerScrollViewContents() {
        var horizontalInset: CGFloat = 0
        var verticalInset: CGFloat = 0

        if self.contentSize.width < self.bounds.width {
            horizontalInset = (bounds.width - contentSize.width) * 0.5
        }

        if self.contentSize.height < self.bounds.height {
            verticalInset = (bounds.height - contentSize.height) * 0.5
        }

        if (window?.screen.scale ?? 0) < 2.0 {
            horizontalInset = floor(horizontalInset)
            verticalInset = floor(verticalInset)
        }

        // Use `contentInset` to center the contents in the scroll view. Reasoning explained here: http://petersteinberger.com/blog/2013/how-to-center-uiscrollview/
        self.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset)
    }
}










