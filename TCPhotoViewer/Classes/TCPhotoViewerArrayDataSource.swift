//
//  TCPhotoViewerArrayDataSource.swift
//  TCPhotoViewer
//
//  Created by Tiziano Coroneo on 25/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import UIKit

open class TCPhotoViewerArrayDataSource: NSObject, TCPhotoViewerDataSource {

    open var photos: [TCPhoto]?

    public init(withPhotos photos: [TCPhoto]?) {
        self.photos = photos
        super.init()
    }

    open var numberOfPhotos: Int {
        return photos?.count ?? 0
    }

    open func photoAtIndex(_ index: Int) -> TCPhoto? {
        guard index < photos?.count ?? -1 else { return nil }
        return photos?[index]
    }

    open func indexOfPhoto(_ photo: TCPhoto) -> Int? {
        return photos?.index { $0.isEqual(photo) }
    }

    open subscript(_ index: Int) -> TCPhoto? {
        return photoAtIndex(index)
    }
}

open class TCPhotoViewerSinglePhotoDataSource: NSObject, TCPhotoViewerDataSource {

    open let photo: TCPhoto

    public init(withPhoto photo: TCPhoto) {
        self.photo = photo
        super.init()
    }

    open var numberOfPhotos: Int {
        return 1
    }

    open func photoAtIndex(_ index: Int) -> TCPhoto? {
        return photo
    }

    open func indexOfPhoto(_ photo: TCPhoto) -> Int? {
        return 0
    }
}

