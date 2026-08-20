//
//  NotificationDelegateTests.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import XCTest
import UserNotifications
@testable import GeoTrackAssignment

final class NotificationDelegateTests: XCTestCase {

    func test_sharedInstance_returnsSameInstance() {

        let first =
            NotificationDelegate.shared

        let second =
            NotificationDelegate.shared

        XCTAssertTrue(
            first === second
        )
    }

}
