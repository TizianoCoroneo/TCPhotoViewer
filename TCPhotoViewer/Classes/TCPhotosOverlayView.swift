//
//  TCPhotosOverlayView.swift
//  TCPhotoViewer
//
//  Created by Tiziano Coroneo on 25/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import UIKit

class TCPhotoOverlayView: UIView {

    var navigationBar = UINavigationBar()
    var navigationItem = UINavigationItem(title: "")

    var captionView: UIView?

    var captionViewRespectsSafeArea: Bool = false


    override init(frame: CGRect) {
        super.init(frame: frame)

        setupNavigationBar()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupNavigationBar()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView === self { return nil }
        return hitView
    }

    override func layoutSubviews() {
        UIView.performWithoutAnimation { [weak self] in
            self?.navigationBar.invalidateIntrinsicContentSize()
            self?.navigationBar.layoutIfNeeded()
        }

        super.layoutSubviews()

        if var caption = captionView as? TCPhotoCaptionViewLayoutWidthHinting {
            caption.preferredMaxLayoutWidth = self.bounds.size.width
        }
    }

    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.backgroundColor = .clear
        navigationBar.barTintColor = nil
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()

        navigationBar.setBackgroundImage(UIImage(), for: .default)

        navigationBar.items = [navigationItem]

        self.addSubview(navigationBar)

        if self.responds(to: #selector(getter: safeAreaLayoutGuide)) {
            let top = navigationBar.topAnchor
                .constraint(equalTo: safeAreaLayoutGuide.topAnchor)
            let left = navigationBar.leftAnchor
                .constraint(equalTo: safeAreaLayoutGuide.leftAnchor)
            let right = navigationBar.rightAnchor
                .constraint(equalTo: safeAreaLayoutGuide.rightAnchor)
            self.addConstraints([top, left, right])
        } else {
            let top = navigationBar.topAnchor
                .constraint(equalTo: topAnchor)
            let width = navigationBar.widthAnchor
                .constraint(equalTo: widthAnchor)
            let horizontal = navigationBar.centerXAnchor
                .constraint(equalTo: centerXAnchor)
            self.addConstraints([top, width, horizontal])
        }
    }

    func setCaptionView(_ captionView: UIView) {
        if self.captionView === captionView { return }

        self.captionView?.removeFromSuperview()
        self.captionView = captionView
        self.captionView?.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.captionView!)

        if self.responds(to: #selector(getter: safeAreaLayoutGuide)) && self.captionViewRespectsSafeArea {
            let bottom = self.captionView!.bottomAnchor
                .constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
            let left = self.captionView!.leftAnchor
                .constraint(equalTo: safeAreaLayoutGuide.leftAnchor)
            let right = self.captionView!.rightAnchor
                .constraint(equalTo: safeAreaLayoutGuide.rightAnchor)
            self.addConstraints([bottom, left, right])
        } else {
            let bottom = self.captionView!.bottomAnchor
                .constraint(equalTo: bottomAnchor)
            let width = self.captionView!.widthAnchor
                .constraint(equalTo: widthAnchor)
            let horizontal = self.captionView!.centerXAnchor
                .constraint(equalTo: centerXAnchor)
            self.addConstraints([bottom, width, horizontal])
        }
    }

    var leftBarButtonItem: UIBarButtonItem? {
        get { return navigationItem.leftBarButtonItem }
        set { navigationItem.setLeftBarButton(newValue, animated: false) }
    }

    var leftBarButtonItems: [UIBarButtonItem]? {
        get { return navigationItem.leftBarButtonItems }
        set { navigationItem.setLeftBarButtonItems(newValue, animated: false) }
    }

    var rightBarButtonItem: UIBarButtonItem? {
        get { return navigationItem.rightBarButtonItem }
        set { navigationItem.setRightBarButton(newValue, animated: false) }
    }

    var rightBarButtonItems: [UIBarButtonItem]? {
        get { return navigationItem.rightBarButtonItems }
        set { navigationItem.setRightBarButtonItems(newValue, animated: false) }
    }

    var title: String? {
        get { return navigationItem.title }
        set { navigationItem.title = newValue }
    }

    var titleTextAttribute: [NSAttributedStringKey: Any]? {
        get { return navigationBar.titleTextAttributes }
        set { navigationBar.titleTextAttributes = newValue }
    }
}












