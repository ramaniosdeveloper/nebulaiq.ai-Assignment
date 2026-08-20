//
//  InMemoryLocationRepositoryTests.swift
//  GeoTrackAssignment
//
//  Created by Raman kumar on 20/08/26.
//

import XCTest
@testable import GeoTrackAssignment

final class InMemoryLocationRepositoryTests: XCTestCase {

    func test_postLocation_storesSnapshotForGroup()
        async throws {

        let repository =
            InMemoryLocationRepository()

        let snapshot =
            TestDataFactory.locationSnapshot()

        try await repository.postLocation(
            snapshot,
            for: TestDataFactory.groupID
        )

        XCTAssertEqual(
            repository.snapshots[TestDataFactory.groupID]?.count,
            1
        )

        XCTAssertEqual(
            repository.snapshots[TestDataFactory.groupID]?.first,
            snapshot
        )
    }

    func test_postLocation_storesMultipleSnapshots()
        async throws {

        let repository =
            InMemoryLocationRepository()

        let first =
            TestDataFactory.locationSnapshot(
                latitude: 30.7046,
                longitude: 76.7179
            )

        let second =
            TestDataFactory.locationSnapshot(
                latitude: 30.7050,
                longitude: 76.7180
            )

        try await repository.postLocation(
            first,
            for: TestDataFactory.groupID
        )

        try await repository.postLocation(
            second,
            for: TestDataFactory.groupID
        )

        let snapshots =
            repository.snapshots[TestDataFactory.groupID]

        XCTAssertEqual(
            snapshots?.count,
            2
        )

        XCTAssertEqual(
            snapshots?[0],
            first
        )

        XCTAssertEqual(
            snapshots?[1],
            second
        )
    }

    func test_postLocation_keepsDifferentGroupsSeparate()
        async throws {

        let repository =
            InMemoryLocationRepository()

        let group1 =
            GroupID(rawValue: "group-1")

        let group2 =
            GroupID(rawValue: "group-2")

        let snapshot1 =
            TestDataFactory.locationSnapshot()

        let snapshot2 =
            TestDataFactory.locationSnapshot(
                latitude: 31.0,
                longitude: 77.0
            )

        try await repository.postLocation(
            snapshot1,
            for: group1
        )

        try await repository.postLocation(
            snapshot2,
            for: group2
        )

        XCTAssertEqual(
            repository.snapshots[group1]?.count,
            1
        )

        XCTAssertEqual(
            repository.snapshots[group2]?.count,
            1
        )
    }
}
