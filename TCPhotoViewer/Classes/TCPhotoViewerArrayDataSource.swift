//
//  TCPhotoViewerArrayDataSource.swift
//  TCPhotoViewer
//
//  Created by Tiziano Coroneo on 25/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import UIKit

class TCPhotoViewerArrayDataSource: NSObject, TCPhotoViewerDataSource {

    var photos: [TCPhoto]?

    init(withPhotos photos: [TCPhoto]?) {
        self.photos = photos
        super.init()
    }

    var numberOfPhotos: Int {
        return photos?.count ?? 0
    }

    func photoAtIndex(_ index: Int) -> TCPhoto? {
        guard index < photos?.count ?? -1 else { return nil }
        return photos?[index]
    }

    func indexOfPhoto(_ photo: TCPhoto) -> Int? {
        return photos?.index { $0.isEqual(photo) }
    }

    subscript(_ index: Int) -> TCPhoto? {
        return photoAtIndex(index)
    }
}

class TCPhotoViewerSinglePhotoDataSource: NSObject, TCPhotoViewerDataSource {

    let photo: TCPhoto

    init(withPhoto photo: TCPhoto) {
        self.photo = photo
        super.init()
    }

    var numberOfPhotos: Int {
        return 1
    }

    func photoAtIndex(_ index: Int) -> TCPhoto? {
        return photo
    }

    func indexOfPhoto(_ photo: TCPhoto) -> Int? {
        return 0
    }
}

