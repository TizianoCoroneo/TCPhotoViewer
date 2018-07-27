//
//  TCPhotoCaptionViewLayoutWidthHinting.swift
//  TCPhotoViewer
//
//  Created by Tiziano Coroneo on 24/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import UIKit

protocol TCPhotoCaptionViewLayoutWidthHinting {

    var preferredMaxLayoutWidth: CGFloat { get set }
}

extension UILabel: TCPhotoCaptionViewLayoutWidthHinting {}
