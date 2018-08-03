//
//  TCPhoto.swift
//  TCPhotoViewer
//
//  Created by Tiziano Coroneo on 24/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import UIKit

@objc public protocol TCPhoto: NSObjectProtocol {

    var image: UIImage? { get }

    var imageData: Data? { get }

    var placeholderImage: UIImage? { get }

    var attributedCaptionTitle: NSAttributedString? { get }
    var attributedCaptionSummary: NSAttributedString? { get }
    var attributedCaptionCredit: NSAttributedString? { get }
}

