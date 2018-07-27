//
//  TCPhotosViewControllerTests.swift
//  TCPhotoViewerTests
//
//  Created by Tiziano Coroneo on 26/07/2018.
//  Copyright © 2018 DTT Multimedia. All rights reserved.
//

import XCTest

@testable import TCPhotoViewer

class TCPhotosViewControllerTests: XCTestCase {

    func testPanGestureRecognizerHasAssociatedViewAfterViewDidLoad() {

        let photosViewController = TCPhotosViewController(
            withPhotos: TestPhoto.newTestPhotos())

        _ = photosViewController.view

        XCTAssertNotNil(photosViewController.panGestureRecognizer.view)
    }

    func testSingleTapGestureRecognizerHasAssociatedViewAfterViewDidLoad() {

        let photosViewController = TCPhotosViewController(
            withPhotos: TestPhoto.newTestPhotos())

        _ = photosViewController.view

        XCTAssertNotNil(photosViewController.singleTapGestureRecognizer.view)
    }

    func testPageViewControllerDoesNotHaveAssociatedSuperviewBeforeViewLoads() {

        let photosViewController = TCPhotosViewController(
            withPhotos: TestPhoto.newTestPhotos())

        XCTAssertNil(photosViewController.pageViewController.view.superview)
    }

    func testPageViewControllerDoesHaveAssociatedSuperviewAfterViewLoads() {

        let photosViewController = TCPhotosViewController(
            withPhotos: TestPhoto.newTestPhotos())

        _ = photosViewController.view

        XCTAssertNotNil(photosViewController.pageViewController.view.superview)
    }

    func testCurrentlyDisplayedPhotoIsFirstAfterConvenienceInitialization() {
        let photos = TestPhoto.newTestPhotos()

        let photosViewController = TCPhotosViewController(
            withPhotos: photos)

        _ = photosViewController.view

        XCTAssertNotNil(photosViewController.currentlyDisplayedPhoto)
        XCTAssert(photosViewController.currentlyDisplayedPhoto?
            .isEqual(photos.first!) ?? false)
    }

    func testCurrentlyDisplayedPhotoIsAccurateAfterSettingInitialPhoto() {
        let photos = TestPhoto.newTestPhotos()

        let photosViewController = TCPhotosViewController(
            dataSource: TCPhotoViewerArrayDataSource(withPhotos: photos),
            initialPhoto: photos.last!,
            delegate: nil)

        _ = photosViewController.view

        XCTAssertNotNil(photosViewController.currentlyDisplayedPhoto)
        XCTAssert(photosViewController.currentlyDisplayedPhoto?
            .isEqual(photos.last!) ?? false)
    }

    func testCurrentlyDisplayedPhotoIsAccurateAfterDisplayPhotoCall() {
        let photos = TestPhoto.newTestPhotos()

        let photosViewController = TCPhotosViewController(
            dataSource: TCPhotoViewerArrayDataSource(withPhotos: photos),
            initialPhoto: photos.last!,
            delegate: nil)

        _ = photosViewController.view
        photosViewController.displayPhoto(photos.first!, animated: false)

        XCTAssertNotNil(photosViewController.currentlyDisplayedPhoto)
        XCTAssert(photosViewController.currentlyDisplayedPhoto?
            .isEqual(photos.first!) ?? false)
    }

    func testLeftBarButtonItemIsPopulatedAfterInitialization() {
        let photos = TestPhoto.newTestPhotos()
        let photosViewController = TCPhotosViewController(withPhotos: photos)
        XCTAssertNotNil(photosViewController.leftBarButtonItem)
    }

    func testLeftBarButtonItemIsNilAfterSettingNil() {
        let photos = TestPhoto.newTestPhotos()
        let photosViewController = TCPhotosViewController(withPhotos: photos)
        photosViewController.leftBarButtonItem = nil
        XCTAssertNil(photosViewController.leftBarButtonItem)
    }

    func testLeftBarButtonItemsIsPopulatedAfterInitialization() {
        let photos = TestPhoto.newTestPhotos()
        let photosViewController = TCPhotosViewController(withPhotos: photos)
        XCTAssertNotNil(photosViewController.leftBarButtonItems)
    }

    func testLeftBarButtonItemsIsNilAfterSettingNil() {
        let photos = TestPhoto.newTestPhotos()
        let photosViewController = TCPhotosViewController(withPhotos: photos)
        photosViewController.leftBarButtonItems = nil
        XCTAssertNil(photosViewController.leftBarButtonItems)
    }

    func testRightBarButtonItemIsPopulatedAfterInitialization() {
        let photos = TestPhoto.newTestPhotos()
        let photosViewController = TCPhotosViewController(withPhotos: photos)
        XCTAssertNotNil(photosViewController.rightBarButtonItem)
    }

    func testRightBarButtonItemIsNilAfterSettingNil() {
        let photos = TestPhoto.newTestPhotos()
        let photosViewController = TCPhotosViewController(withPhotos: photos)
        photosViewController.rightBarButtonItem = nil
        XCTAssertNil(photosViewController.rightBarButtonItem)
    }

    func testRightBarButtonItemsIsPopulatedAfterInitialization() {
        let photos = TestPhoto.newTestPhotos()
        let photosViewController = TCPhotosViewController(withPhotos: photos)
        XCTAssertNotNil(photosViewController.rightBarButtonItems)
    }

    func testRightBarButtonItemsIsNilAfterSettingNil() {
        let photos = TestPhoto.newTestPhotos()
        let photosViewController = TCPhotosViewController(withPhotos: photos)
        photosViewController.rightBarButtonItems = nil
        XCTAssertNil(photosViewController.rightBarButtonItems)
    }

    func testOneArgConvenienceInitializerAcceptsNil() {
        XCTAssertNoThrow(TCPhotosViewController(withPhotos: nil))
    }

    func testTwoArgConvenienceInitializerAcceptsNilForPhotosParameter() {
        XCTAssertNoThrow(TCPhotosViewController(withPhotos: nil, initialPhoto: TestPhoto()))
    }

    func testTwoArgConvenienceInitializerAcceptsNilForInitialPhoto() {
        XCTAssertNoThrow(TCPhotosViewController(withPhotos: TestPhoto.newTestPhotos(), initialPhoto: nil))
    }

    func testTwoArgConvenienceInitializerAcceptsNilForBothParameters() {
        XCTAssertNoThrow(TCPhotosViewController(withPhotos: nil, initialPhoto: nil))
    }

    func testDesignatedInitializerAcceptsNilForPhotosParameter() {
        XCTAssertNoThrow(TCPhotosViewController(
            dataSource: nil,
            initialPhoto: TestPhoto(),
            delegate: TestDelegate()))
    }

    func testDesignatedInitializerAcceptsNilForInitialPhoto() {
        let dataSource = TCPhotoViewerArrayDataSource(withPhotos: TestPhoto.newTestPhotos())

        XCTAssertNoThrow(TCPhotosViewController(
            dataSource: dataSource,
            initialPhoto: nil,
            delegate: TestDelegate()))
    }

    func testDesignatedInitializerAcceptsNilForDelegate() {
        let photos = TestPhoto.newTestPhotos()
        let dataSource = TCPhotoViewerArrayDataSource(withPhotos: photos)

        XCTAssertNoThrow(TCPhotosViewController(
            dataSource: dataSource,
            initialPhoto: photos.first,
            delegate: nil))
    }

    func testDesignatedInitializerAcceptsNilForAllParameters() {
        XCTAssertNoThrow(TCPhotosViewController(
            dataSource: nil,
            initialPhoto: nil,
            delegate: nil))
    }

    func testDesignatedInitializerSetsDelegate() {
        let delegate = TestDelegate()
        let sut = TCPhotosViewController(
            dataSource: nil,
            initialPhoto: nil,
            delegate: delegate)

        XCTAssert(sut.delegate?.isEqual(delegate) ?? false)
    }

    func testDisplayPhotoAcceptsNil() {
        let vc = TCPhotosViewController(withPhotos: TestPhoto.newTestPhotos())
        XCTAssertNoThrow(vc.displayPhoto(nil, animated: false))
    }

    func testDisplayPhotoDoesNothingWhenPassedPhotoOutsideDataSource() {
        let photos = TestPhoto.newTestPhotos()
        let photosVC = TCPhotosViewController(
            withPhotos: photos,
            initialPhoto: photos.first)
        _ = photosVC.view

        let invalidPhoto = TestPhoto()
        photosVC.displayPhoto(invalidPhoto, animated: false)
        XCTAssert(photos.first?.isEqual(photosVC.currentlyDisplayedPhoto!) ?? false)
    }

    func testDisplayPhotoMovesToCorrectPhoto() {
        let photos = TestPhoto.newTestPhotos()
        let photosVC = TCPhotosViewController(
            withPhotos: photos,
            initialPhoto: photos.first)

        _ = photosVC.view

        let photoToDisplay = photos[2]
        photosVC.displayPhoto(photoToDisplay, animated: false)
        XCTAssert(photosVC.currentlyDisplayedPhoto.map(photoToDisplay.isEqual) ?? false)
    }

    func testUpdateImageForPhotoAcceptsNil() {
        let photos = TestPhoto.newTestPhotos()
        let photosVC = TCPhotosViewController(
            withPhotos: photos,
            initialPhoto: photos.first)

        XCTAssertNoThrow(photosVC.updatePhoto(photo: nil))
    }

    func testUpdateImageForPhotoDoesNothingWhenPassedPhotoOutsideDataSource() {
        let photos = TestPhoto.newTestPhotos()
        let photosVC = TCPhotosViewController(
            withPhotos: photos,
            initialPhoto: photos.first)

        _ = photosVC.view

        let invalidPhoto = TestPhoto()
        photosVC.updatePhoto(photo: invalidPhoto)
        XCTAssert(photosVC.currentlyDisplayedPhoto.map(photos.first!.isEqual) ?? false)
    }

    func testUpdateImageForPhotoUpdatesImage() {
        let photos = TestPhoto.newTestPhotos()
        let photosVC = TCPhotosViewController(
            withPhotos: photos,
            initialPhoto: photos.first)

        _ = photosVC.view

        let photoToUpdate = photos.last!
        photosVC.updatePhoto(photo: photoToUpdate)
        XCTAssert(photosVC.currentlyDisplayedPhoto.map(photoToUpdate.isEqual) ?? false)
    }

    func testViewIsntLoadedAfterInit() {
        let photos = TestPhoto.newTestPhotos()
        let photosVC = TCPhotosViewController(withPhotos: photos)
        XCTAssertFalse(photosVC.isViewLoaded)
    }

    func testPageViewIsntLoadedAfterInit() {
        let photos = TestPhoto.newTestPhotos()
        let photosVC = TCPhotosViewController(withPhotos: photos)
        XCTAssertFalse(photosVC.pageViewController.isViewLoaded)
    }
}

private class TestDelegate: NSObject, TCPhotosViewControllerDelegate {
}

