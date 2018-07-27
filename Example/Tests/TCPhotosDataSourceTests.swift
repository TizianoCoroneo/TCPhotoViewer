//
//  TCPhotosDataSourceTests.swift
//  TCPhotoViewerTests
//
//  Created by Tiziano Coroneo on 26/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import XCTest

@testable import TCPhotoViewer

class TCPhotosDataSourceTests: XCTestCase {

    func testInitializeAcceptsNil() {
        XCTAssertNoThrow(TCPhotoViewerArrayDataSource(withPhotos: nil))
    }

    func testOutOfBoundsDoNotCrash() {
        let dataSource = TCPhotoViewerArrayDataSource(withPhotos: nil)
        XCTAssertNoThrow(dataSource[1])
    }

    func testOutOfBoundsReturnsNil() {
        let dataSource = TCPhotoViewerArrayDataSource(withPhotos: nil)
        XCTAssertNil(dataSource[1])
    }

    func testValidIndexReturnsPhoto() {
        let dataSource = TCPhotoViewerArrayDataSource(withPhotos: TestPhoto.newTestPhotos())
        XCTAssertNotNil(dataSource[1])
    }

    func testValidIndexReturnsCorrectPhoto() {
        let photos = TestPhoto.newTestPhotos()
        let dataSource = TCPhotoViewerArrayDataSource(withPhotos: photos)
        XCTAssert(dataSource[1]! === photos[1])
    }
}

class TestPhoto: NSObject, TCPhoto {
    var image: UIImage?

    var imageData: Data?

    var placeholderImage: UIImage?

    var attributedCaptionTitle: NSAttributedString?

    var attributedCaptionSummary: NSAttributedString?

    var attributedCaptionCredit: NSAttributedString?

    override init() {
        super.init()
        self.image = UIImage()
        self.attributedCaptionTitle = NSAttributedString(string: "Title")
        self.attributedCaptionSummary = NSAttributedString(string: "Summary")
        self.attributedCaptionCredit = NSAttributedString(string: "Credit")
    }

    static func newTestPhotos() -> [TestPhoto] {
        return Array(repeating: TestPhoto(), count: 5)
    }
}
