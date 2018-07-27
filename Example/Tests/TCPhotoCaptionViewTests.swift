//
//  TCPhotoCaptionViewTests.swift
//  TCPhotoViewerTests
//
//  Created by Tiziano Coroneo on 26/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import XCTest

@testable import TCPhotoViewer

class TCPhotoCaptionViewTests: XCTestCase {

    func testDesignatedInitializerAcceptsNilForTitle() {
        XCTAssertNoThrow(TCPhotoCaptionView(
            attributedTitle: nil,
            attributedSummary: NSAttributedString(),
            attributedCredit: NSAttributedString()))
    }
    
    func testDesignatedInitializerAcceptsNilForSummary() {
        XCTAssertNoThrow(TCPhotoCaptionView(
            attributedTitle: NSAttributedString(),
            attributedSummary: nil,
            attributedCredit: NSAttributedString()))
    }

    func testDesignatedInitializerAcceptsNilForCredit() {
        XCTAssertNoThrow(TCPhotoCaptionView(
            attributedTitle: NSAttributedString(),
            attributedSummary: NSAttributedString(),
            attributedCredit: nil))
    }
    
}
