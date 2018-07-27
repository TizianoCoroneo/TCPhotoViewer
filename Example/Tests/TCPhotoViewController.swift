//
//  TCPhotoViewController.swift
//  TCPhotoViewerTests
//
//  Created by Tiziano Coroneo on 27/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import XCTest

@testable import TCPhotoViewer

class TCPhotoViewControllerTests: XCTestCase {

    func testScalingImageViewExistsAfterInitialization() {
        let photoVC = TCPhotoViewController(
            withPhoto: TestPhoto(),
            loadingView: nil,
            notificationCenter: .default)
        XCTAssertNotNil(photoVC.scalingImageView)
    }

    func testLoadingViewExistsAfterNilInitialization() {
        let photoVC = TCPhotoViewController(
            withPhoto: nil,
            loadingView: nil,
            notificationCenter: .default)
        XCTAssertNotNil(photoVC.loadingView)
    }

    func testDesignatedInitializerAcceptNilForPhotoArgument() {
        XCTAssertNoThrow(TCPhotoViewController(
            withPhoto: nil,
            loadingView: UIView(),
            notificationCenter: .default))
    }

    func testDesignatedInitializerAcceptNilForLoadingView() {
        XCTAssertNoThrow(TCPhotoViewController(
            withPhoto: TestPhoto(),
            loadingView: nil,
            notificationCenter: .default))
    }

    func testDesignatedInitializerAcceptNilForNotificationCenter() {
        XCTAssertNoThrow(TCPhotoViewController(
            withPhoto: TestPhoto(),
            loadingView: UIView(),
            notificationCenter: nil))
    }

    func testDesignatedInitializerAcceptNilForAllArguments() {
        XCTAssertNoThrow(TCPhotoViewController(
            withPhoto: nil,
            loadingView: nil,
            notificationCenter: nil))
    }
}
