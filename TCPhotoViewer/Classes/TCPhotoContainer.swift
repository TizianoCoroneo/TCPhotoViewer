//
//  TCPhotoContainer.swift
//  TCPhotoViewer
//
//  Created by Tiziano Coroneo on 24/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import UIKit

public protocol TCPhotoContainer {

    var photo: TCPhoto? { get }
}

public protocol TCPhotoViewerDataSource: class {
    var numberOfPhotos: Int { get }

    func indexOfPhoto(_ photo: TCPhoto) -> Int?
    func photoAtIndex(_ index: Int) -> TCPhoto?
}
