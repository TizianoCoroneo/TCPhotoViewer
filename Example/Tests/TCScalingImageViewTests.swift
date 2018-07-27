//
//  TCScalingImageViewTests.swift
//  TCPhotoViewerTests
//
//  Created by Tiziano Coroneo on 27/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import XCTest

@testable import TCPhotoViewer

class TCScalingImageViewTests: XCTestCase {

    func testImageInitializationAcceptsEmptyData() {
        XCTAssertNoThrow(TCScalingImageView(withImage: UIImage(), frame: .zero))
    }

    func testDataInitializationAcceptsEmptyData() {
        XCTAssertNoThrow(TCScalingImageView(withImageData: Data(), frame: .zero))
    }

    func testImageViewExistsAfterImageInitialization() {
        let scaleView = TCScalingImageView(withImage: UIImage(), frame: .zero)
        XCTAssertNotNil(scaleView.imageView)
    }

    func testImageViewExistsAfterDataInitialization() {
        let scaleView = TCScalingImageView(withImageData: Data(), frame: .zero)
        XCTAssertNotNil(scaleView.imageView)
    }

    func testImageInitializationSetsImage() {
        let scaleView = TCScalingImageView(withImage: UIImage(), frame: .zero)
        XCTAssertNotNil(scaleView.imageView.image)
    }

    func testUpdateImageUpdatesImage() {
        let image = UIImage()
        let scaleView = TCScalingImageView(withImage: UIImage(), frame: .zero)
        scaleView.updateImage(image)
        XCTAssert(scaleView.imageView.image.flatMap(image.isEqual) ?? false)
    }
}
