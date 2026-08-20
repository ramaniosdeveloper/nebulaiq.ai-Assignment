//
//  GeoFenceEvaluatorTests.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import XCTest
@testable import GeoTrackAssignment

final class GeoFenceEvaluatorTests: XCTestCase {

    func test_isInside_returnsTrue_whenLocationIsAtCenter() {

        let result = GeoFenceEvaluator.isInside(
            geoFence: TestDataFactory.geoFence,
            lat: TestDataFactory.geoFence.centerLat,
            lon: TestDataFactory.geoFence.centerLon
        )

        XCTAssertTrue(result)
    }

    func test_isInside_returnsTrue_whenLocationIsWithinRadius() {

        let result = GeoFenceEvaluator.isInside(
            geoFence: TestDataFactory.geoFence,
            lat: 30.7047,
            lon: 76.7179
        )

        XCTAssertTrue(result)
    }

    func test_isInside_returnsFalse_whenLocationIsOutsideRadius() {

        let result = GeoFenceEvaluator.isInside(
            geoFence: TestDataFactory.geoFence,
            lat: 30.7100,
            lon: 76.7200
        )

        XCTAssertFalse(result)
    }

    func test_isInside_returnsTrue_forZeroDistanceAndZeroRadius() {

        let geoFence = GeoFence(
            centerLat: 30.7046,
            centerLon: 76.7179,
            radiusMeters: 0
        )

        let result = GeoFenceEvaluator.isInside(
            geoFence: geoFence,
            lat: 30.7046,
            lon: 76.7179
        )

        XCTAssertTrue(result)
    }
}
