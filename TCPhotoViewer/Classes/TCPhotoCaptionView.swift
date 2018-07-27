//
//  TCPhotoCaptionView.swift
//  TCPhotoViewer
//
//  Created by Tiziano Coroneo on 24/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import UIKit

private let tcPhotoCaptionViewHorizontalMargin: CGFloat = 8.0
private let tcPhotoCaptionViewVerticalMargin: CGFloat = 7.0

class TCPhotoCaptionView: UIView, TCPhotoCaptionViewLayoutWidthHinting {

    let attributedTitle: NSAttributedString?
    let attributedSummary: NSAttributedString?
    let attributedCredit: NSAttributedString?

    let textView = UITextView(frame: .zero)
    let gradientLayer = CAGradientLayer()

    private var _preferredMaxLayoutWidth: CGFloat = 0
    var preferredMaxLayoutWidth: CGFloat {
        get { return _preferredMaxLayoutWidth }
        set {
            let value = ceil(newValue)

            if abs(value - _preferredMaxLayoutWidth) > 0.1 {
                _preferredMaxLayoutWidth = value
                invalidateIntrinsicContentSize()
            }
        }
    }

    override init(frame: CGRect) {
        self.attributedTitle = nil
        self.attributedSummary = nil
        self.attributedCredit = nil

        super.init(frame: .zero)
        commonInit()
    }

    public init(
        attributedTitle: NSAttributedString?,
        attributedSummary: NSAttributedString?,
        attributedCredit: NSAttributedString?) {

        self.attributedTitle = attributedTitle
        self.attributedSummary = attributedSummary
        self.attributedCredit = attributedCredit

        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        self.attributedTitle = nil
        self.attributedSummary = nil
        self.attributedCredit = nil

        super.init(coder: aDecoder)
        commonInit()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        let maxHeightConstraint = NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: .lessThanOrEqual,
            toItem: self.superview,
            attribute: .height,
            multiplier: 0.3,
            constant: 0)

        self.superview?.addConstraint(maxHeightConstraint)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradientLayer.frame = self.layer.bounds
    }

    override var intrinsicContentSize: CGSize {
        let contentSize = self.textView.sizeThatFits(CGSize(
            width: preferredMaxLayoutWidth,
            height: CGFloat.greatestFiniteMagnitude))

        let width = self.preferredMaxLayoutWidth
        let height = ceil(contentSize.height)

        return CGSize(width: width, height: height)
    }

    private func commonInit() {

        self.translatesAutoresizingMaskIntoConstraints = false

        self.setupTextView()
        self.updateTextViewAttributedText()
        self.setupGradient()
    }

    private func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.dataDetectorTypes = []
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(
            top: tcPhotoCaptionViewVerticalMargin,
            left: tcPhotoCaptionViewHorizontalMargin,
            bottom: tcPhotoCaptionViewVerticalMargin,
            right: tcPhotoCaptionViewHorizontalMargin)

        self.addSubview(textView)

        let topConstraint = NSLayoutConstraint(
            item: self.textView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1,
            constant: 0)

        let bottomConstraint = NSLayoutConstraint(
            item: self.textView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: 0)

        let widthConstraint = NSLayoutConstraint(
            item: self.textView,
            attribute: .width,
            relatedBy: .equal,
            toItem: self,
            attribute: .width,
            multiplier: 1,
            constant: 0)

        let horizontalConstraint = NSLayoutConstraint(
            item: self.textView,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1,
            constant: 0)

        self.addConstraints([
            topConstraint,
            bottomConstraint,
            widthConstraint,
            horizontalConstraint
            ])
    }

    private func setupGradient() {
        gradientLayer.frame = self.layer.bounds
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.85).cgColor
        ]
        layer.insertSublayer(gradientLayer, at: 0)
    }

    private func updateTextViewAttributedText() {
        textView.attributedText = [
            attributedTitle,
            attributedCredit,
            attributedSummary
            ]
            .compactMap { $0 }
            .reduce(NSMutableAttributedString()) {
                (acc: NSMutableAttributedString, x: NSAttributedString) -> NSMutableAttributedString in
                acc.append(x)
                return acc
        }
    }

}
