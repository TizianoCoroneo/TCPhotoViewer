//
//  TCPhotosDataSourceTests.swift
//  TCPhotoViewerTests
//
//  Created by Tiziano Coroneo on 26/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import XCTest

@testable import TCPhotoViewer

class TCPhotosOverlayViewTests: XCTestCase {

    func testLeftBarButtonItemSetterAffectsNavigationBar() {

        let overlayView = TCPhotoOverlayView(frame: .zero)
        let leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: nil, action: nil)

        overlayView.leftBarButtonItem = leftBarButtonItem

        XCTAssert(leftBarButtonItem
            .isEqual(overlayView.navigationBar.items?.first?.leftBarButtonItem))
    }

    func testRightBarButtonItemSetterAffectsNavigationBar() {

        let overlayView = TCPhotoOverlayView(frame: .zero)
        let rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: nil, action: nil)

        overlayView.rightBarButtonItem = rightBarButtonItem

        XCTAssert(rightBarButtonItem
            .isEqual(overlayView.navigationBar.items?.first?.rightBarButtonItem))
    }

    func testTitleSetterAffectsNavigationBar() {
        let overlayView = TCPhotoOverlayView(frame: .zero)

        let title = "Title"

        overlayView.title = title

        XCTAssertEqual(title, overlayView.navigationBar.items?.first?.title)
    }

    func testTitleTextAttributeSetterAffectsNavigationBar() {
        let overlayView = TCPhotoOverlayView(frame: .zero)

        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.foregroundColor: UIColor.orange
        ]
        overlayView.titleTextAttribute = attributes

        if let overlayAttributes = overlayView.navigationBar.titleTextAttributes,
            let color1 = attributes[.foregroundColor] as? UIColor,
            let color2 = overlayAttributes[.foregroundColor] as? UIColor {
            XCTAssertEqual(color1, color2)
        } else {
            XCTFail()
        }
    }


}
